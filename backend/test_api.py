import unittest
from fastapi.testclient import TestClient

from backend.main import app


class TestAgriAiBackend(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.client = TestClient(app)

    def test_01_health_check(self):
        response = self.client.get("/api/v1/health")
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertEqual(data["status"], "ONLINE")
        self.assertIn("mongodb_connected", data)
        self.assertIn("sms_gateway_active", data)
        self.assertIn("active_products", data["statistics"])

    def test_02_real_time_otp_and_pin_auth(self):
        # 1. Request OTP for a new phone
        phone = "9876500112"
        otp_resp = self.client.post("/api/v1/auth/send-otp", json={"phone": phone})
        self.assertEqual(otp_resp.status_code, 200)
        otp_data = otp_resp.json()
        self.assertIn("verification_id", otp_data)
        self.assertIn("sms_sent", otp_data)
        ver_id = otp_data["verification_id"]
        preview_otp = otp_data.get("sandbox_otp_preview")

        # 2. Wrong OTP should be rejected cleanly
        bad_verify = self.client.post(
            "/api/v1/auth/verify-otp",
            json={"verification_id": ver_id, "sms_code": "000000", "role": "farmer"},
        )
        if preview_otp != "000000":
            self.assertEqual(bad_verify.status_code, 400)

        # 3. Valid OTP logs in and persists user in DB
        if preview_otp:
            good_verify = self.client.post(
                "/api/v1/auth/verify-otp",
                json={
                    "verification_id": ver_id,
                    "sms_code": preview_otp,
                    "role": "farmer",
                    "name": "Test Farmer",
                    "location": "Warangal",
                },
            )
            self.assertEqual(good_verify.status_code, 200)
            session = good_verify.json()
            self.assertIn("access_token", session)
            self.assertEqual(session["user"]["name"], "Test Farmer")

            # Verify token endpoint `/api/v1/auth/me`
            me_resp = self.client.get(
                "/api/v1/auth/me",
                headers={"Authorization": f"Bearer {session['access_token']}"},
            )
            self.assertEqual(me_resp.status_code, 200)
            self.assertEqual(me_resp.json()["phone"], "+919876500112")

        # 4. Register new user with custom PIN and test PIN login
        reg_resp = self.client.post(
            "/api/v1/auth/register",
            json={
                "name": "Startup Buyer",
                "phone": "9876500999",
                "location": "Hyderabad",
                "role": "customer",
                "pin": "654321",
            },
        )
        self.assertEqual(reg_resp.status_code, 201)

        wrong_pin = self.client.post(
            "/api/v1/auth/login-pin",
            json={"phone": "9876500999", "pin": "111111", "role": "customer"},
        )
        self.assertEqual(wrong_pin.status_code, 401)

        good_pin = self.client.post(
            "/api/v1/auth/login-pin",
            json={"phone": "9876500999", "pin": "654321", "role": "customer"},
        )
        self.assertEqual(good_pin.status_code, 200)
        self.assertEqual(good_pin.json()["user"]["name"], "Startup Buyer")

    def test_03_marketplace_order_and_delivery_flow(self):
        # 1. Create product
        prod_resp = self.client.post(
            "/api/v1/marketplace/products",
            json={
                "name": "Organic Red Capsicum",
                "category": "Vegetables",
                "price_per_kg": 60.0,
                "mandi_benchmark": 55.0,
                "available_kg": 100.0,
                "farmer_name": "Ramesh Kumar",
                "farmer_location": "Warangal",
                "farmer_phone": "+91 98765 11001",
                "is_organic": True,
            },
        )
        self.assertEqual(prod_resp.status_code, 201)
        prod_id = prod_resp.json()["id"]

        # 2. Place order -> creates order AND dispatch task
        order_resp = self.client.post(
            "/api/v1/orders/create",
            json={
                "product_id": prod_id,
                "quantity_kg": 10.0,
                "buyer_name": "Dr. Priya Sharma",
                "buyer_phone": "+91 98765 99001",
                "delivery_address": "Hanamkonda",
                "payment_method": "RAZORPAY_UPI",
            },
        )
        self.assertEqual(order_resp.status_code, 201)
        order = order_resp.json()
        self.assertEqual(order["total_amount"], 600.0)
        order_id = order["id"]
        delivery_otp = order["delivery_otp"]

        # 3. Verify linked dispatch task exists & run Accept -> Pickup -> Verify OTP
        tasks = self.client.get("/api/v1/delivery/tasks").json()
        linked_task = next((t for t in tasks if t["order_id"] == order_id), None)
        self.assertIsNotNone(linked_task)
        task_id = linked_task["id"]

        self.assertEqual(self.client.post(f"/api/v1/delivery/tasks/{task_id}/accept").status_code, 200)
        self.assertEqual(self.client.post(f"/api/v1/delivery/tasks/{task_id}/pickup").status_code, 200)
        verify_task = self.client.post(
            f"/api/v1/delivery/tasks/{task_id}/verify-otp",
            json={"otp": delivery_otp},
        )
        self.assertEqual(verify_task.status_code, 200)
        self.assertTrue(verify_task.json()["verified"])

    def test_04_reviews_and_crop_doctor_and_voice(self):
        rev_resp = self.client.post(
            "/api/v1/reviews",
            json={
                "farmer_name": "Ramesh Kumar",
                "buyer_name": "Dr. Priya Sharma",
                "rating": 5.0,
                "comment": "Crisp and fresh organic produce.",
                "usability_feedback": "Seamless UPI checkout.",
                "persona_type": "CONSUMER_TEST",
            },
        )
        self.assertEqual(rev_resp.status_code, 201)

        diag_resp = self.client.post(
            "/api/v1/crop-doctor/diagnose",
            json={
                "crop_name": "Tomato",
                "disease_name": "Early Blight",
                "health_score": 68,
                "severity": "Moderate",
                "confidence": 0.93,
                "organic_treatments": ["Neem Oil 5ml/L"],
                "chemical_treatments": ["Mancozeb 2.5g/L"],
                "farmer_id": "user-farmer-ramesh",
            },
        )
        self.assertEqual(diag_resp.status_code, 201)
        history = self.client.get("/api/v1/crop-doctor/history?user_id=user-farmer-ramesh").json()
        self.assertGreater(len(history), 0)

        voice_resp = self.client.post("/api/v1/voice/ask", json={"query": "today mandi cotton price", "language": "en"})
        self.assertEqual(voice_resp.status_code, 200)
        self.assertIn("Cotton", voice_resp.json()["reply"])

    def test_05_mandi_admin_kyc_settings_and_broadcasts(self):
        rates = self.client.get("/api/v1/mandi/rates").json()
        self.assertGreater(len(rates), 0)

        analytics = self.client.get("/api/v1/admin/analytics").json()
        self.assertIn("total_gmv", analytics)

        kyc_list = self.client.get("/api/v1/admin/kyc").json()
        self.assertGreater(len(kyc_list), 0)

        broadcast = self.client.post(
            "/api/v1/admin/broadcasts",
            json={"district": "Warangal District", "crop": "Cotton", "advisory": "Monitor pink bollworm traps."},
        )
        self.assertEqual(broadcast.status_code, 201)

        settings = self.client.put("/api/v1/admin/settings", json={"platform_commission_percent": 4.0}).json()
        self.assertEqual(settings["platform_commission_percent"], 4.0)

    def test_06_simulation_and_community_and_radar_and_calculator(self):
        sim = self.client.post("/api/v1/simulation/run", json={"cycles": 1}).json()
        self.assertEqual(sim["personas_involved"], 4)
        self.assertGreater(sim["transactions_count"], 0)

        analysis = self.client.get("/api/v1/simulation/analysis").json()
        self.assertGreater(len(analysis["feature_recommendations"]), 0)

        posts = self.client.get("/api/v1/community/posts").json()
        self.assertGreater(len(posts), 0)
        post_id = posts[0]["id"]
        orig_upvotes = posts[0]["upvotes"]
        upvoted = self.client.post(f"/api/v1/community/posts/{post_id}/upvote").json()
        self.assertEqual(upvoted["upvotes"], orig_upvotes + 1)

        radar = self.client.get("/api/v1/satellite/farm-radar?lat=17.9689&lng=79.5941").json()
        self.assertGreater(radar["ndvi_index"], 0.7)

        calc = self.client.post(
            "/api/v1/calculator/dilution",
            json={
                "crop_name": "Tomato",
                "disease_name": "Early Blight",
                "acreage": 2.0,
                "tank_capacity_liters": 16.0,
                "treatment_type": "organic",
            },
        ).json()
        self.assertEqual(calc["water_volume_liters"], 400.0)
        self.assertEqual(calc["tanks_count"], 25.0)


if __name__ == "__main__":
    unittest.main()
