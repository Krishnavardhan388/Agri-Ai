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
        self.assertIn("active_products", data["statistics"])

    def test_02_get_products(self):
        response = self.client.get("/api/v1/marketplace/products")
        self.assertEqual(response.status_code, 200)
        products = response.json()
        self.assertIsInstance(products, list)
        self.assertGreater(len(products), 0)
        self.assertIn("name", products[0])
        self.assertIn("price_per_kg", products[0])

    def test_03_create_product_and_order(self):
        # 1. Create a product
        prod_payload = {
            "name": "Organic Red Capsicum",
            "category": "Vegetables",
            "price_per_kg": 60.0,
            "mandi_benchmark": 55.0,
            "available_kg": 100.0,
            "farmer_name": "Ramesh Kumar",
            "farmer_location": "Warangal",
            "farmer_phone": "+91 98765 11001",
            "is_organic": True
        }
        prod_resp = self.client.post("/api/v1/marketplace/products", json=prod_payload)
        self.assertEqual(prod_resp.status_code, 201)
        prod = prod_resp.json()
        prod_id = prod["id"]

        # 2. Place an order for 10kg
        order_payload = {
            "product_id": prod_id,
            "quantity_kg": 10.0,
            "buyer_name": "Dr. Priya Sharma",
            "buyer_phone": "+91 98765 99001",
            "delivery_address": "Hanamkonda",
            "payment_method": "RAZORPAY_UPI"
        }
        order_resp = self.client.post("/api/v1/orders/create", json=order_payload)
        self.assertEqual(order_resp.status_code, 201)
        order = order_resp.json()
        self.assertEqual(order["total_amount"], 600.0)
        self.assertEqual(order["status"], "inTransit")
        order_id = order["id"]
        delivery_otp = order["delivery_otp"]

        # 3. Verify OTP Handover
        verify_resp = self.client.post("/api/v1/orders/verify-otp", json={
            "order_id": order_id,
            "entered_otp": delivery_otp
        })
        self.assertEqual(verify_resp.status_code, 200)
        self.assertEqual(verify_resp.json()["status"], "delivered")

    def test_04_get_and_post_reviews(self):
        review_payload = {
            "farmer_name": "Ramesh Kumar",
            "buyer_name": "Dr. Priya Sharma",
            "rating": 5.0,
            "comment": "Crisp and fresh organic produce directly from farm.",
            "usability_feedback": "Seamless UPI payment experience.",
            "persona_type": "CONSUMER_TEST"
        }
        resp = self.client.post("/api/v1/reviews", json=review_payload)
        self.assertEqual(resp.status_code, 201)
        created = resp.json()
        self.assertEqual(created["rating"], 5.0)

        list_resp = self.client.get("/api/v1/reviews")
        self.assertEqual(list_resp.status_code, 200)
        self.assertGreater(len(list_resp.json()), 0)

    def test_05_mandi_rates(self):
        resp = self.client.get("/api/v1/mandi/rates")
        self.assertEqual(resp.status_code, 200)
        rates = resp.json()
        self.assertGreater(len(rates), 0)
        self.assertIn("modal_price", rates[0])

    def test_06_simulation_cycle_and_analysis(self):
        # Trigger autonomous simulation
        sim_resp = self.client.post("/api/v1/simulation/run", json={"cycles": 1})
        self.assertEqual(sim_resp.status_code, 200)
        sim = sim_resp.json()
        self.assertEqual(sim["personas_involved"], 4)
        self.assertGreater(sim["transactions_count"], 0)
        self.assertIn("logs", sim)
        self.assertGreater(len(sim["logs"]), 0)

        # Retrieve feedback analytics & recommendations
        analysis_resp = self.client.get("/api/v1/simulation/analysis")
        self.assertEqual(analysis_resp.status_code, 200)
        analysis = analysis_resp.json()
        self.assertIn("feature_recommendations", analysis)
        self.assertGreater(len(analysis["feature_recommendations"]), 0)

    def test_07_community_kisan_charcha(self):
        # 1. Fetch community posts
        posts_resp = self.client.get("/api/v1/community/posts")
        self.assertEqual(posts_resp.status_code, 200)
        posts = posts_resp.json()
        self.assertGreater(len(posts), 0)
        post_id = posts[0]["id"]
        original_upvotes = posts[0]["upvotes"]

        # 2. Upvote post
        upvote_resp = self.client.post(f"/api/v1/community/posts/{post_id}/upvote")
        self.assertEqual(upvote_resp.status_code, 200)
        self.assertEqual(upvote_resp.json()["upvotes"], original_upvotes + 1)

        # 3. Add an agronomist comment
        comment_payload = {
            "author_name": "Dr. Subba Rao",
            "author_role": "Soil Scientist",
            "content": "Apply Trichoderma viride enriched FYM 2 weeks prior to sowing.",
            "is_agronomist_reply": True
        }
        comment_resp = self.client.post(f"/api/v1/community/posts/{post_id}/comments", json=comment_payload)
        self.assertEqual(comment_resp.status_code, 201)
        self.assertTrue(comment_resp.json()["is_agronomist_reply"])

    def test_08_satellite_radar(self):
        resp = self.client.get("/api/v1/satellite/farm-radar?lat=17.9689&lng=79.5941")
        self.assertEqual(resp.status_code, 200)
        radar = resp.json()
        self.assertGreater(radar["ndvi_index"], 0.7)
        self.assertEqual(radar["spore_infection_risk"], "LOW (Safe)")
        self.assertIn("recommended_spray_window", radar)

    def test_09_variable_rate_dilution_calculator(self):
        # 1. Test Organic calculation
        payload_organic = {
            "crop_name": "Tomato",
            "disease_name": "Early Blight",
            "acreage": 2.0,
            "tank_capacity_liters": 16.0,
            "treatment_type": "organic"
        }
        resp = self.client.post("/api/v1/calculator/dilution", json=payload_organic)
        self.assertEqual(resp.status_code, 200)
        data = resp.json()
        self.assertEqual(data["water_volume_liters"], 400.0)
        self.assertEqual(data["tanks_count"], 25.0)
        self.assertIn("Neem Oil", data["active_ingredient"])
        self.assertGreater(data["estimated_cost_savings_inr"], 0)

        # 2. Test Chemical calculation
        payload_chemical = {
            "crop_name": "Tomato",
            "disease_name": "Early Blight",
            "acreage": 1.5,
            "tank_capacity_liters": 15.0,
            "treatment_type": "chemical"
        }
        resp_chem = self.client.post("/api/v1/calculator/dilution", json=payload_chemical)
        self.assertEqual(resp_chem.status_code, 200)
        chem_data = resp_chem.json()
        self.assertEqual(chem_data["water_volume_liters"], 300.0)
        self.assertEqual(chem_data["tanks_count"], 20.0)
        self.assertIn("Mancozeb", chem_data["active_ingredient"])

if __name__ == "__main__":
    unittest.main()
