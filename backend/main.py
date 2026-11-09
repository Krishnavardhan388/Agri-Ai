import uuid
from typing import List, Dict, Any, Optional
from fastapi import FastAPI, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from backend.database import get_db, init_db
from backend.models import (
    ProductCreate, ProductResponse,
    OrderCreate, OrderResponse, VerifyOtpRequest,
    ReviewCreate, ReviewResponse,
    MandiRateResponse, SimulationRunRequest, SimulationRunResponse
)
from backend.simulation.simulation_engine import SimulationEngine
from backend.simulation.feedback_analyzer import FeedbackAnalyzer

# Initialize tables
init_db()

app = FastAPI(
    title="AGRI AI — Real-Time Operations & Multi-Agent Backend",
    description="Production-grade API providing live marketplace synchronization, crop diagnostics telemetry, Razorpay order lifecycle, and autonomous AI stakeholder simulations.",
    version="2.0.0"
)

# CORS Configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

simulation_engine = SimulationEngine()
feedback_analyzer = FeedbackAnalyzer()

# ============================================================
# 1. Health & Telemetry
# ============================================================
@app.get("/api/v1/health")
def health_check():
    with get_db() as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT COUNT(*) FROM products;")
        prod_count = cursor.fetchone()[0]
        cursor.execute("SELECT COUNT(*) FROM orders;")
        order_count = cursor.fetchone()[0]
        cursor.execute("SELECT COUNT(*) FROM reviews;")
        review_count = cursor.fetchone()[0]

    return {
        "status": "ONLINE",
        "service": "AGRI AI Real-Time API Engine",
        "version": "2.0.0",
        "database": "SQLite WAL High-Concurrency",
        "statistics": {
            "active_products": prod_count,
            "total_orders": order_count,
            "recorded_reviews": review_count
        }
    }

# ============================================================
# 2. Marketplace & Products
# ============================================================
@app.get("/api/v1/marketplace/products", response_model=List[ProductResponse])
def get_products():
    with get_db() as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM products ORDER BY created_at DESC;")
        rows = cursor.fetchall()
        return [
            ProductResponse(
                id=r["id"],
                name=r["name"],
                category=r["category"],
                price_per_kg=r["price_per_kg"],
                mandi_benchmark=r["mandi_benchmark"],
                available_kg=r["available_kg"],
                farmer_name=r["farmer_name"],
                farmer_location=r["farmer_location"],
                farmer_phone=r["farmer_phone"],
                is_organic=bool(r["is_organic"]),
                rating=r["rating"],
                review_count=r["review_count"],
                status=r["status"],
                created_at=str(r["created_at"])
            )
            for r in rows
        ]

@app.post("/api/v1/marketplace/products", response_model=ProductResponse, status_code=status.HTTP_201_CREATED)
def create_product(product: ProductCreate):
    prod_id = f"PROD-{uuid.uuid4().hex[:6].upper()}"
    with get_db() as conn:
        cursor = conn.cursor()
        cursor.execute("""
        INSERT INTO products (id, name, category, price_per_kg, mandi_benchmark, available_kg, farmer_name, farmer_location, farmer_phone, is_organic)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        """, (
            prod_id,
            product.name,
            product.category,
            product.price_per_kg,
            product.mandi_benchmark,
            product.available_kg,
            product.farmer_name,
            product.farmer_location,
            product.farmer_phone,
            1 if product.is_organic else 0
        ))
        cursor.execute("SELECT * FROM products WHERE id = ?;", (prod_id,))
        r = cursor.fetchone()
        return ProductResponse(
            id=r["id"],
            name=r["name"],
            category=r["category"],
            price_per_kg=r["price_per_kg"],
            mandi_benchmark=r["mandi_benchmark"],
            available_kg=r["available_kg"],
            farmer_name=r["farmer_name"],
            farmer_location=r["farmer_location"],
            farmer_phone=r["farmer_phone"],
            is_organic=bool(r["is_organic"]),
            rating=r["rating"],
            review_count=r["review_count"],
            status=r["status"],
            created_at=str(r["created_at"])
        )

# ============================================================
# 3. Orders & Real-Time Logistics State Machine
# ============================================================
@app.get("/api/v1/orders", response_model=List[OrderResponse])
def get_orders():
    with get_db() as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM orders ORDER BY created_at DESC;")
        rows = cursor.fetchall()
        return [
            OrderResponse(
                id=r["id"],
                product_id=r["product_id"],
                product_name=r["product_name"],
                quantity_kg=r["quantity_kg"],
                total_amount=r["total_amount"],
                buyer_name=r["buyer_name"],
                buyer_phone=r["buyer_phone"],
                delivery_address=r["delivery_address"],
                driver_name=r["driver_name"],
                driver_phone=r["driver_phone"],
                driver_vehicle=r["driver_vehicle"],
                delivery_otp=r["delivery_otp"],
                status=r["status"],
                payment_status=r["payment_status"],
                created_at=str(r["created_at"])
            )
            for r in rows
        ]

@app.post("/api/v1/orders/create", response_model=OrderResponse, status_code=status.HTTP_201_CREATED)
def create_order(order: OrderCreate):
    with get_db() as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM products WHERE id = ?;", (order.product_id,))
        product = cursor.fetchone()
        if not product:
            raise HTTPException(status_code=404, detail="Product not found.")

        if product["available_kg"] < order.quantity_kg:
            raise HTTPException(status_code=400, detail="Requested quantity exceeds available stock.")

        import random
        order_id = f"AGRI-{random.randint(1000, 9999)}"
        total_amount = order.quantity_kg * product["price_per_kg"]
        delivery_otp = str(random.randint(1000, 9999))

        cursor.execute("""
        INSERT INTO orders (id, product_id, product_name, quantity_kg, total_amount, buyer_name, buyer_phone, delivery_address, driver_name, driver_phone, driver_vehicle, delivery_otp, status, payment_status)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        """, (
            order_id,
            order.product_id,
            product["name"],
            order.quantity_kg,
            total_amount,
            order.buyer_name,
            order.buyer_phone,
            order.delivery_address,
            "Suresh Patel (Assigned)",
            "+91 98765 22114",
            "Hero Splendor Cargo (TS-03-EB-4421)",
            delivery_otp,
            "inTransit",
            f"PAID_{order.payment_method}"
        ))

        # Decrement product inventory
        cursor.execute("UPDATE products SET available_kg = available_kg - ? WHERE id = ?;", (order.quantity_kg, order.product_id))

        cursor.execute("SELECT * FROM orders WHERE id = ?;", (order_id,))
        r = cursor.fetchone()
        return OrderResponse(
            id=r["id"],
            product_id=r["product_id"],
            product_name=r["product_name"],
            quantity_kg=r["quantity_kg"],
            total_amount=r["total_amount"],
            buyer_name=r["buyer_name"],
            buyer_phone=r["buyer_phone"],
            delivery_address=r["delivery_address"],
            driver_name=r["driver_name"],
            driver_phone=r["driver_phone"],
            driver_vehicle=r["driver_vehicle"],
            delivery_otp=r["delivery_otp"],
            status=r["status"],
            payment_status=r["payment_status"],
            created_at=str(r["created_at"])
        )

@app.post("/api/v1/orders/verify-otp")
def verify_delivery_otp(req: VerifyOtpRequest):
    with get_db() as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM orders WHERE id = ?;", (req.order_id,))
        order = cursor.fetchone()
        if not order:
            raise HTTPException(status_code=404, detail="Order not found.")

        if order["delivery_otp"] != req.entered_otp:
            raise HTTPException(status_code=400, detail="Invalid 4-digit OTP code.")

        cursor.execute("""
        UPDATE orders 
        SET status = 'delivered', delivered_at = CURRENT_TIMESTAMP 
        WHERE id = ?;
        """, (req.order_id,))

        return {
            "success": True,
            "order_id": req.order_id,
            "status": "delivered",
            "message": "OTP verified successfully. Produce delivered to buyer doorstep."
        }

# ============================================================
# 4. Reviews & Continuous Feedback Loop
# ============================================================
@app.get("/api/v1/reviews", response_model=List[ReviewResponse])
def get_reviews():
    with get_db() as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM reviews ORDER BY created_at DESC;")
        rows = cursor.fetchall()
        return [
            ReviewResponse(
                id=r["id"],
                order_id=r["order_id"],
                farmer_name=r["farmer_name"],
                buyer_name=r["buyer_name"],
                rating=r["rating"],
                comment=r["comment"],
                usability_feedback=r["usability_feedback"],
                persona_type=r["persona_type"],
                created_at=str(r["created_at"])
            )
            for r in rows
        ]

@app.post("/api/v1/reviews", response_model=ReviewResponse, status_code=status.HTTP_201_CREATED)
def submit_review(review: ReviewCreate):
    rev_id = f"REV-{uuid.uuid4().hex[:6].upper()}"
    with get_db() as conn:
        cursor = conn.cursor()
        cursor.execute("""
        INSERT INTO reviews (id, order_id, farmer_name, buyer_name, rating, comment, usability_feedback, persona_type)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?);
        """, (
            rev_id,
            review.order_id,
            review.farmer_name,
            review.buyer_name,
            review.rating,
            review.comment,
            review.usability_feedback,
            review.persona_type
        ))
        cursor.execute("SELECT * FROM reviews WHERE id = ?;", (rev_id,))
        r = cursor.fetchone()
        return ReviewResponse(
            id=r["id"],
            order_id=r["order_id"],
            farmer_name=r["farmer_name"],
            buyer_name=r["buyer_name"],
            rating=r["rating"],
            comment=r["comment"],
            usability_feedback=r["usability_feedback"],
            persona_type=r["persona_type"],
            created_at=str(r["created_at"])
        )

# ============================================================
# 5. Mandi Rates APMC Integration
# ============================================================
@app.get("/api/v1/mandi/rates", response_model=List[MandiRateResponse])
def get_mandi_rates():
    with get_db() as conn:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM mandi_rates ORDER BY modal_price DESC;")
        rows = cursor.fetchall()
        return [
            MandiRateResponse(
                id=r["id"],
                crop_name=r["crop_name"],
                market_yard=r["market_yard"],
                modal_price=r["modal_price"],
                min_price=r["min_price"],
                max_price=r["max_price"],
                trend=r["trend"],
                last_updated=str(r["last_updated"])
            )
            for r in rows
        ]

# ============================================================
# 6. Autonomous Stakeholder Simulation & Feedback Evolution
# ============================================================
@app.post("/api/v1/simulation/run", response_model=SimulationRunResponse)
def trigger_simulation(req: SimulationRunRequest):
    """
    Triggers an autonomous AI simulation cycle:
    Farmer -> Plant Diagnosis -> Produce Listing -> Buyer Discovery -> Razorpay Checkout -> Logistics OTP Handover -> Usability Feedback.
    """
    result = simulation_engine.run_full_stakeholder_cycle()
    return SimulationRunResponse(**result)

@app.get("/api/v1/simulation/analysis")
def get_simulation_analysis():
    """
    Aggregates review feedback across all real users and AI synthetic personas,
    identifies UX friction points, and outputs feature recommendations.
    """
    return feedback_analyzer.analyze_feedback()

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("backend.main:app", host="127.0.0.1", port=8000, reload=True)
