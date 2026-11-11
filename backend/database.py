import json
import os
import sqlite3
import tempfile
import threading
from contextlib import contextmanager
from datetime import datetime, timezone
from typing import Any, Dict, List, Optional

from dotenv import load_dotenv

load_dotenv()

try:
    from pymongo import ASCENDING, DESCENDING, MongoClient
    PYMONGO_AVAILABLE = True
except ImportError:
    PYMONGO_AVAILABLE = False
    MongoClient = None
    ASCENDING = 1
    DESCENDING = -1


def _resolve_sqlite_path() -> str:
    if os.environ.get("VERCEL") or not os.access(os.path.dirname(__file__) or ".", os.W_OK):
        return os.path.join(tempfile.gettempdir(), "agri_ai.db")
    return os.path.join(os.path.dirname(__file__), "agri_ai.db")


DB_PATH = _resolve_sqlite_path()


class UnifiedDatabaseStore:
    """
    Production Database Abstraction Layer:
    - Primary: MongoDB Atlas Cloud (`MONGODB_URI`) via PyMongo.
    - Fallback: Local/Serverless SQLite Document Store when `MONGODB_URI` is not yet configured.
    """

    def __init__(self):
        self._lock = threading.RLock()
        self._mongo_client = None
        self._mongo_db = None
        self.mongo_connected = False
        self.mongo_error: Optional[str] = None
        self._initialized = False

    def connect(self, force_reconnect: bool = False):
        with self._lock:
            if self._initialized and not force_reconnect:
                return

            mongo_uri = os.environ.get("MONGODB_URI", "").strip()
            db_name = os.environ.get("MONGODB_DB_NAME", "agri_ai").strip() or "agri_ai"

            if mongo_uri and PYMONGO_AVAILABLE and "<username>" not in mongo_uri:
                try:
                    self._mongo_client = MongoClient(mongo_uri, serverSelectionTimeoutMS=4500)
                    self._mongo_client.admin.command("ping")
                    self._mongo_db = self._mongo_client[db_name]
                    self.mongo_connected = True
                    self.mongo_error = None
                    self._ensure_mongo_indexes()
                except Exception as exc:
                    self.mongo_connected = False
                    self.mongo_error = str(exc)
                    self._mongo_client = None
                    self._mongo_db = None
            elif mongo_uri and "<username>" in mongo_uri:
                self.mongo_error = "MONGODB_URI still contains placeholder credentials."
            elif not mongo_uri:
                self.mongo_error = "MONGODB_URI is not set in environment."

            if not self.mongo_connected:
                self._init_sqlite_table()

            self._initialized = True
            self._seed_initial_data()

    def _ensure_mongo_indexes(self):
        if self._mongo_db is None:
            return
        try:
            self._mongo_db["users"].create_index([("phone", ASCENDING)], unique=True)
            self._mongo_db["otp_sessions"].create_index([("expire_at", ASCENDING)], expireAfterSeconds=0)
            self._mongo_db["products"].create_index([("created_at", DESCENDING)])
            self._mongo_db["orders"].create_index([("created_at", DESCENDING)])
            self._mongo_db["community_posts"].create_index([("upvotes", DESCENDING)])
        except Exception:
            pass

    @contextmanager
    def _sqlite_conn(self):
        conn = sqlite3.connect(DB_PATH, check_same_thread=False)
        conn.row_factory = sqlite3.Row
        conn.execute("PRAGMA journal_mode=WAL;")
        try:
            yield conn
            conn.commit()
        except Exception:
            conn.rollback()
            raise
        finally:
            conn.close()

    def _init_sqlite_table(self):
        with self._sqlite_conn() as conn:
            conn.execute(
                """
                CREATE TABLE IF NOT EXISTS doc_store (
                    collection TEXT NOT NULL,
                    doc_id TEXT NOT NULL,
                    data TEXT NOT NULL,
                    updated_at TEXT NOT NULL,
                    PRIMARY KEY (collection, doc_id)
                );
                """
            )

    def _clean_doc(self, doc: Optional[Dict[str, Any]]) -> Optional[Dict[str, Any]]:
        if doc is None:
            return None
        cleaned = dict(doc)
        cleaned.pop("_id", None)
        return cleaned

    def find_all(
        self,
        collection: str,
        filter_dict: Optional[Dict[str, Any]] = None,
        sort_by: Optional[str] = None,
        desc: bool = True,
    ) -> List[Dict[str, Any]]:
        self.connect()
        query = filter_dict or {}

        if self.mongo_connected and self._mongo_db is not None:
            cursor = self._mongo_db[collection].find(query)
            if sort_by:
                cursor = cursor.sort(sort_by, DESCENDING if desc else ASCENDING)
            return [self._clean_doc(d) for d in cursor]  # type: ignore

        with self._lock, self._sqlite_conn() as conn:
            rows = conn.execute(
                "SELECT data FROM doc_store WHERE collection = ?;",
                (collection,),
            ).fetchall()

        results = []
        for r in rows:
            doc = json.loads(r["data"])
            if all(doc.get(k) == v for k, v in query.items()):
                results.append(doc)

        if sort_by:
            results.sort(key=lambda x: str(x.get(sort_by, "")), reverse=desc)
        return results

    def find_one(self, collection: str, filter_dict: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        self.connect()
        if self.mongo_connected and self._mongo_db is not None:
            doc = self._mongo_db[collection].find_one(filter_dict)
            return self._clean_doc(doc)

        matches = self.find_all(collection, filter_dict=filter_dict)
        return matches[0] if matches else None

    def insert_one(self, collection: str, doc: Dict[str, Any]) -> Dict[str, Any]:
        self.connect()
        payload = dict(doc)
        doc_id = str(payload.get("id") or payload.get("uid") or payload.get("trip_id") or "")
        if not doc_id:
            doc_id = datetime.now(timezone.utc).isoformat()
            payload["id"] = doc_id

        if self.mongo_connected and self._mongo_db is not None:
            to_insert = dict(payload)
            self._mongo_db[collection].replace_one({"id": doc_id}, to_insert, upsert=True)
            return self._clean_doc(payload)  # type: ignore

        with self._lock, self._sqlite_conn() as conn:
            conn.execute(
                """
                INSERT OR REPLACE INTO doc_store (collection, doc_id, data, updated_at)
                VALUES (?, ?, ?, ?);
                """,
                (
                    collection,
                    doc_id,
                    json.dumps(payload, default=str),
                    datetime.now(timezone.utc).isoformat(),
                ),
            )
        return payload

    def update_one(
        self,
        collection: str,
        filter_dict: Dict[str, Any],
        set_fields: Optional[Dict[str, Any]] = None,
        inc_fields: Optional[Dict[str, Any]] = None,
    ) -> Optional[Dict[str, Any]]:
        self.connect()

        if self.mongo_connected and self._mongo_db is not None:
            update_op: Dict[str, Any] = {}
            if set_fields:
                update_op["$set"] = set_fields
            if inc_fields:
                update_op["$inc"] = inc_fields
            if not update_op:
                return self.find_one(collection, filter_dict)
            self._mongo_db[collection].update_one(filter_dict, update_op)
            return self.find_one(collection, filter_dict)

        with self._lock:
            existing = self.find_one(collection, filter_dict)
            if not existing:
                return None
            if set_fields:
                existing.update(set_fields)
            if inc_fields:
                for k, delta in inc_fields.items():
                    current = existing.get(k, 0)
                    existing[k] = (current or 0) + delta
            doc_id = str(existing.get("id") or existing.get("uid") or existing.get("trip_id"))
            with self._sqlite_conn() as conn:
                conn.execute(
                    """
                    UPDATE doc_store SET data = ?, updated_at = ?
                    WHERE collection = ? AND doc_id = ?;
                    """,
                    (
                        json.dumps(existing, default=str),
                        datetime.now(timezone.utc).isoformat(),
                        collection,
                        doc_id,
                    ),
                )
            return existing

    def count(self, collection: str, filter_dict: Optional[Dict[str, Any]] = None) -> int:
        self.connect()
        if self.mongo_connected and self._mongo_db is not None:
            return self._mongo_db[collection].count_documents(filter_dict or {})
        return len(self.find_all(collection, filter_dict=filter_dict))

    def _seed_initial_data(self):
        now_iso = datetime.now(timezone.utc).isoformat()

        if self.count("users") == 0:
            import hashlib

            def _hash_pin(pin: str, salt: str) -> str:
                return hashlib.pbkdf2_hmac("sha256", pin.encode(), salt.encode(), 100_000).hex()

            seed_users = [
                {
                    "id": "user-farmer-ramesh",
                    "uid": "user-farmer-ramesh",
                    "name": "Ramesh Kumar (Farmer)",
                    "phone": "+919876543210",
                    "role": "farmer",
                    "location": "Geesugonda, Warangal, Telangana",
                    "pin_salt": "seed_salt_1",
                    "pin_hash": _hash_pin("123456", "seed_salt_1"),
                    "is_verified": True,
                    "created_at": now_iso,
                },
                {
                    "id": "user-customer-priya",
                    "uid": "user-customer-priya",
                    "name": "Priya Sharma (Buyer)",
                    "phone": "+919876512345",
                    "role": "customer",
                    "location": "Flat 402, Green Meadows, Hanamkonda",
                    "pin_salt": "seed_salt_2",
                    "pin_hash": _hash_pin("123456", "seed_salt_2"),
                    "is_verified": True,
                    "created_at": now_iso,
                },
                {
                    "id": "user-driver-suresh",
                    "uid": "user-driver-suresh",
                    "name": "Suresh Patel (Delivery Partner)",
                    "phone": "+919876522114",
                    "role": "deliveryPartner",
                    "location": "Subedari, Hanamkonda",
                    "pin_salt": "seed_salt_3",
                    "pin_hash": _hash_pin("123456", "seed_salt_3"),
                    "is_verified": True,
                    "created_at": now_iso,
                },
                {
                    "id": "user-admin-hq",
                    "uid": "user-admin-hq",
                    "name": "HQ Operations Officer (Admin)",
                    "phone": "+919999900000",
                    "role": "admin",
                    "location": "Hyderabad Command Center",
                    "pin_salt": "seed_salt_4",
                    "pin_hash": _hash_pin("123456", "seed_salt_4"),
                    "is_verified": True,
                    "created_at": now_iso,
                },
            ]
            for u in seed_users:
                self.insert_one("users", u)

        if self.count("mandi_rates") == 0:
            mandi_items = [
                {"id": "MANDI-101", "crop_name": "Cotton (Kapas)", "variety": "Medium Staple (Kapas)", "category": "Cash Crops", "market_yard": "Warangal APMC Yard", "distance_km": 3.8, "modal_price": 7250.0, "min_price": 6850.0, "max_price": 7420.0, "price_change": 150.0, "trend": "up", "last_updated": now_iso},
                {"id": "MANDI-102", "crop_name": "Paddy / Rice (Dhan)", "variety": "BPT 5204 (Sona Masoori)", "category": "Cereals", "market_yard": "Warangal APMC Yard", "distance_km": 3.8, "modal_price": 2380.0, "min_price": 2240.0, "max_price": 2420.0, "price_change": 40.0, "trend": "up", "last_updated": now_iso},
                {"id": "MANDI-103", "crop_name": "Red Chilli (Mirchi)", "variety": "Teja Superior", "category": "Spices", "market_yard": "Enumamula Grain Market", "distance_km": 5.2, "modal_price": 18500.0, "min_price": 17200.0, "max_price": 19800.0, "price_change": 200.0, "trend": "down", "last_updated": now_iso},
                {"id": "MANDI-104", "crop_name": "Fresh Tomato", "variety": "Desi Hybrid", "category": "Vegetables", "market_yard": "Subedari Rythu Bazar", "distance_km": 2.1, "modal_price": 3500.0, "min_price": 2800.0, "max_price": 3800.0, "price_change": 250.0, "trend": "up", "last_updated": now_iso},
                {"id": "MANDI-105", "crop_name": "Turmeric (Haldi)", "variety": "Selam / Finger", "category": "Spices", "market_yard": "Kesamudram Mandi", "distance_km": 18.4, "modal_price": 13600.0, "min_price": 12500.0, "max_price": 14200.0, "price_change": 350.0, "trend": "up", "last_updated": now_iso},
            ]
            for m in mandi_items:
                self.insert_one("mandi_rates", m)

        if self.count("products") == 0:
            products = [
                {"id": "PROD-101", "farmer_id": "user-farmer-ramesh", "name": "Fresh Organic Red Tomatoes", "description": "Plump, naturally vine-ripened red tomatoes. Zero chemical sprays, pure organic manure.", "category": "Vegetables", "price_per_kg": 35.0, "mandi_benchmark": 48.0, "available_kg": 450.0, "farmer_name": "Ramesh Farm, Warangal", "farmer_location": "Village Nallabelli (3.2 km)", "farmer_phone": "+919876543210", "harvest_date": "Harvested 1 day ago", "is_organic": True, "rating": 4.9, "review_count": 28, "status": "active", "created_at": now_iso},
                {"id": "PROD-102", "farmer_id": "user-farmer-ramesh", "name": "Pure Sona Masoori Raw Rice", "description": "Single-origin premium BPT 5204 aged rice. High aroma, slender grain, pesticide-free harvest.", "category": "Grains & Pulses", "price_per_kg": 55.0, "mandi_benchmark": 68.0, "available_kg": 1200.0, "farmer_name": "Krishna Valley Farms", "farmer_location": "Parkal, Warangal (14 km)", "farmer_phone": "+919876511001", "harvest_date": "Current Season Harvest", "is_organic": True, "rating": 4.8, "review_count": 42, "status": "active", "created_at": now_iso},
                {"id": "PROD-103", "farmer_id": "farmer-lakshmi", "name": "Guntur Teja Sun-Dried Red Chilli", "description": "Authentic pungent Teja variety chilies naturally sun-dried on clean tarpaulins.", "category": "Spices", "price_per_kg": 195.0, "mandi_benchmark": 225.0, "available_kg": 150.0, "farmer_name": "Lakshmi Devi Farms", "farmer_location": "Madhira, Khammam", "farmer_phone": "+919876511002", "harvest_date": "Harvested 4 days ago", "is_organic": True, "rating": 5.0, "review_count": 19, "status": "active", "created_at": now_iso},
                {"id": "PROD-104", "farmer_id": "farmer-govind", "name": "Organic Red Onions (Pyaz)", "description": "Crisp medium Garwa variety onions with natural pungent flavour and long shelf-life.", "category": "Vegetables", "price_per_kg": 28.0, "mandi_benchmark": 38.0, "available_kg": 600.0, "farmer_name": "Govind Rao Farms", "farmer_location": "Hanamkonda Rural (5 km)", "farmer_phone": "+919876511003", "harvest_date": "Harvested 3 days ago", "is_organic": True, "rating": 4.7, "review_count": 55, "status": "active", "created_at": now_iso},
                {"id": "PROD-105", "farmer_id": "user-farmer-ramesh", "name": "Premium Raw Cotton (Kapas)", "description": "Medium staple high-strength cotton bolls ready for ginning and textile use.", "category": "Cash Crops", "price_per_kg": 75.0, "mandi_benchmark": 85.0, "available_kg": 800.0, "farmer_name": "Ramesh Farm, Warangal", "farmer_location": "Village Nallabelli (3.2 km)", "farmer_phone": "+919876543210", "harvest_date": "Harvested 1 week ago", "is_organic": False, "rating": 4.9, "review_count": 32, "status": "active", "created_at": now_iso},
            ]
            for p in products:
                self.insert_one("products", p)

        if self.count("orders") == 0:
            seed_orders = [
                {
                    "id": "AGRI-1092",
                    "product_id": "PROD-101",
                    "product_name": "Fresh Organic Red Tomatoes",
                    "quantity_kg": 5.0,
                    "total_amount": 190.0,
                    "customer_id": "user-customer-priya",
                    "buyer_name": "Priya Sharma",
                    "buyer_phone": "+919876512345",
                    "delivery_address": "Flat 402, Green Meadows, Hanamkonda",
                    "farmer_id": "user-farmer-ramesh",
                    "farmer_name": "Ramesh Farm, Warangal",
                    "driver_name": "Suresh Patel",
                    "driver_phone": "+919876522114",
                    "driver_vehicle": "Hero Splendor (TS-03-EB-4421)",
                    "delivery_otp": "4821",
                    "status": "inTransit",
                    "payment_status": "PAID_RAZORPAY",
                    "payment_method": "Razorpay UPI (Google Pay)",
                    "payment_id": "pay_live_49921",
                    "created_at": now_iso,
                },
                {
                    "id": "AGRI-1088",
                    "product_id": "PROD-102",
                    "product_name": "Pure Sona Masoori Raw Rice",
                    "quantity_kg": 50.0,
                    "total_amount": 2510.0,
                    "customer_id": "cust-anand",
                    "buyer_name": "Anand Rao",
                    "buyer_phone": "+919876599999",
                    "delivery_address": "Subedari, Kazipet (6 km)",
                    "farmer_id": "user-farmer-ramesh",
                    "farmer_name": "Ramesh Farm, Warangal",
                    "driver_name": "Rajesh Goud",
                    "driver_phone": "+919876544332",
                    "driver_vehicle": "Piaggio Ape Cargo (TS-03-TR-9102)",
                    "delivery_otp": "7192",
                    "status": "accepted",
                    "payment_status": "PAID_RAZORPAY",
                    "payment_method": "Razorpay UPI (PhonePe)",
                    "payment_id": "pay_live_48122",
                    "created_at": now_iso,
                },
            ]
            for o in seed_orders:
                self.insert_one("orders", o)

        if self.count("dispatches") == 0:
            seed_dispatches = [
                {
                    "id": "TASK-101",
                    "order_id": "AGRI-1092",
                    "farm_name": "Ramesh Farm (Gate 2)",
                    "farm_address": "Village Nallabelli, Warangal Rural",
                    "farm_lat": 17.9689,
                    "farm_lng": 79.5941,
                    "farm_phone": "+91 98765 43210",
                    "customer_name": "Priya Sharma",
                    "customer_address": "Flat 402, Green Meadows, Hanamkonda",
                    "customer_lat": 18.0072,
                    "customer_lng": 79.5583,
                    "customer_phone": "+91 98765 12345",
                    "crop_summary": "5 kg Fresh Organic Tomatoes",
                    "total_weight_kg": 5.0,
                    "distance_km": 6.5,
                    "trip_payout": 95.0,
                    "required_otp": "4821",
                    "driver_id": "user-driver-suresh",
                    "driver_name": "Suresh Patel",
                    "driver_phone": "+91 98765 22114",
                    "driver_vehicle": "Hero Splendor (TS-03-EB-4421)",
                    "status": "accepted",
                    "created_at": now_iso,
                },
                {
                    "id": "TASK-102",
                    "order_id": "AGRI-1088",
                    "farm_name": "Krishna Valley Farms",
                    "farm_address": "Wardhannapet Agro Cluster, Warangal",
                    "farm_lat": 17.8812,
                    "farm_lng": 79.6105,
                    "farm_phone": "+91 98480 22334",
                    "customer_name": "Anand Rao",
                    "customer_address": "Subedari, Kazipet",
                    "customer_lat": 17.9814,
                    "customer_lng": 79.5298,
                    "customer_phone": "+91 98765 99999",
                    "crop_summary": "50 kg Sona Masoori Raw Rice Bag",
                    "total_weight_kg": 50.0,
                    "distance_km": 4.8,
                    "trip_payout": 115.0,
                    "required_otp": "7192",
                    "driver_id": "",
                    "driver_name": "Awaiting Driver Allocation",
                    "driver_phone": "",
                    "driver_vehicle": "",
                    "status": "available",
                    "created_at": now_iso,
                },
            ]
            for d in seed_dispatches:
                self.insert_one("dispatches", d)

        if self.count("wallet_transactions") == 0:
            self.insert_one("wallet_transactions", {
                "id": "TXN-401",
                "title": "Trip Payout #TASK-098",
                "order_id": "AGRI-1075",
                "amount": 1180.0,
                "is_credit": True,
                "status": "Completed",
                "created_at": now_iso,
            })

        if self.count("kyc_applications") == 0:
            kyc_list = [
                {"id": "KYC-FARM-101", "user_id": "farmer-ramesh", "applicant_name": "Ramesh Kumar", "phone": "+91 98765 12345", "role": "farmer", "location": "Geesugonda, Warangal", "document_type": "NPOP Organic Certificate", "document_number": "TS-ORG-2026-8812", "document_details": "Certified 4.5 Acres organic paddy & red chilli farm.", "status": "pending", "applied_at": now_iso},
                {"id": "KYC-DRV-201", "user_id": "driver-suresh", "applicant_name": "Suresh Patel", "phone": "+91 98765 22114", "role": "deliveryPartner", "location": "Subedari, Hanamkonda", "document_type": "Commercial DL & RC", "document_number": "TS-03-EB-4421", "document_details": "Hero Splendor Plus carrier box + commercial DL.", "status": "approved", "applied_at": now_iso, "reviewed_by": "Admin HQ"},
                {"id": "KYC-FARM-102", "user_id": "farmer-venkat", "applicant_name": "Venkat Rao", "phone": "+91 98765 33221", "role": "farmer", "location": "Manakondur, Karimnagar", "document_type": "Pattadar Passbook", "document_number": "TS-LND-KM-4901", "document_details": "Dharani Survey No. 412/A, 6.2 Acres irrigated land.", "status": "pending", "applied_at": now_iso},
            ]
            for k in kyc_list:
                self.insert_one("kyc_applications", k)

        if self.count("reviews") == 0:
            reviews = [
                {"id": "REV-1", "order_id": "AGRI-1001", "farmer_name": "Ramesh Kumar", "buyer_name": "Dr. Priya Sharma", "rating": 5.0, "comment": "Exceptional farm-fresh organic tomatoes! Sweet, firm, and chemical-free.", "usability_feedback": "Seamless checkout flow with Razorpay UPI.", "persona_type": "CONSUMER_PERSONA", "created_at": now_iso},
                {"id": "REV-2", "order_id": "AGRI-1002", "farmer_name": "Ramesh Kumar", "buyer_name": "Anand Rao", "rating": 4.5, "comment": "Sona Masoori rice cooks fluffy with great natural aroma.", "usability_feedback": "GPS map accurately pointed to farm pick-up yard.", "persona_type": "CONSUMER_PERSONA", "created_at": now_iso},
                {"id": "REV-3", "order_id": "AGRI-1003", "farmer_name": "Lakshmi Devi", "buyer_name": "Sneha Reddy", "rating": 5.0, "comment": "High pungency genuine Teja chillies. Great packaging.", "usability_feedback": "Loved the Telugu voice assistant advisory.", "persona_type": "CONSUMER_PERSONA", "created_at": now_iso},
            ]
            for r in reviews:
                self.insert_one("reviews", r)

        if self.count("community_posts") == 0:
            posts = [
                {
                    "id": "POST-101",
                    "author_name": "Ramesh Patel",
                    "author_role": "Cotton Grower (3.5 Acres)",
                    "location": "Warangal, Telangana",
                    "crop_name": "Cotton",
                    "title": "Pink Bollworm infestation observed in 45-day Bt cotton crop - need urgent spray schedule",
                    "content": "Noticed rosette flowers and small entrance boreholes on cotton bolls. Temp 31°C, 70% humidity. What is safe knapsack dilution for Emamectin Benzoate 5% SG?",
                    "upvotes": 35,
                    "ai_verified": True,
                    "expert_verified": True,
                    "created_at": now_iso,
                    "comments": [
                        {"id": "COMM-1", "post_id": "POST-101", "author_name": "Dr. V. K. Rao (ICAR Agronomist)", "author_role": "Certified Entomologist", "content": "Spray Emamectin Benzoate 5% SG @ 6.5g per 16L knapsack tank in late afternoon. Install 8 pheromone traps/acre.", "is_agronomist_reply": True, "created_at": now_iso}
                    ],
                },
                {
                    "id": "POST-102",
                    "author_name": "Srinivasulu Naidu",
                    "author_role": "Horticulture Farmer",
                    "location": "Guntur, AP",
                    "crop_name": "Chilli",
                    "title": "Black Thrips (Thrips parvispinus) leaf curling & flower drop remedy",
                    "content": "Severe upward leaf curling in 3rd picking stage chilli. Blue sticky traps caught hundreds. Seeking IPM rotation.",
                    "upvotes": 49,
                    "ai_verified": True,
                    "expert_verified": True,
                    "created_at": now_iso,
                    "comments": [
                        {"id": "COMM-2", "post_id": "POST-102", "author_name": "AGRI AI Diagnosis Engine", "author_role": "Automated IPM Specialist", "content": "Spray Neem Oil 10,000 ppm @ 50ml per 16L tank. Rotate with Spinetoram 11.7% SC @ 15ml per tank.", "is_agronomist_reply": True, "created_at": now_iso}
                    ],
                },
                {
                    "id": "POST-103",
                    "author_name": "Gurpreet Singh",
                    "author_role": "Paddy Grower",
                    "location": "Karnal, Haryana",
                    "crop_name": "Paddy",
                    "title": "Pre-emptive spray for Sheath Blight before upcoming monsoon spell",
                    "content": "Sentinel-2 radar shows high canopy moisture (NDWI 0.58). Should I apply Pseudomonas fluorescens now?",
                    "upvotes": 24,
                    "ai_verified": True,
                    "expert_verified": False,
                    "created_at": now_iso,
                    "comments": [],
                },
            ]
            for post in posts:
                self.insert_one("community_posts", post)

        if self.count("system_settings") == 0:
            self.insert_one("system_settings", {
                "id": "global_settings",
                "gemini_model": "gemini-1.5-flash",
                "razorpay_mode": "Test Sandbox",
                "platform_commission_percent": 3.5,
                "default_voice_speech_rate": 0.45,
                "is_auto_dispatch_enabled": True,
                "last_configured_at": now_iso,
            })


db_store = UnifiedDatabaseStore()


def init_db():
    db_store.connect()
