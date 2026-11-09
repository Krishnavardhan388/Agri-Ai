import sqlite3
import os
from contextlib import contextmanager
from datetime import datetime

DB_PATH = os.path.join(os.path.dirname(__file__), "agri_ai.db")

@contextmanager
def get_db():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    # Enable WAL mode for high concurrency
    conn.execute("PRAGMA journal_mode=WAL;")
    conn.execute("PRAGMA foreign_keys=ON;")
    try:
        yield conn
        conn.commit()
    except Exception:
        conn.rollback()
        raise
    finally:
        conn.close()

def init_db():
    with get_db() as conn:
        cursor = conn.cursor()

        # 1. Products / Marketplace
        cursor.execute("""
        CREATE TABLE IF NOT EXISTS products (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            category TEXT NOT NULL,
            price_per_kg REAL NOT NULL,
            mandi_benchmark REAL NOT NULL,
            available_kg REAL NOT NULL,
            farmer_name TEXT NOT NULL,
            farmer_location TEXT NOT NULL,
            farmer_phone TEXT NOT NULL,
            is_organic INTEGER DEFAULT 1,
            rating REAL DEFAULT 4.8,
            review_count INTEGER DEFAULT 12,
            status TEXT DEFAULT 'active',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        """)

        # 2. Orders & Deliveries
        cursor.execute("""
        CREATE TABLE IF NOT EXISTS orders (
            id TEXT PRIMARY KEY,
            product_id TEXT NOT NULL,
            product_name TEXT NOT NULL,
            quantity_kg REAL NOT NULL,
            total_amount REAL NOT NULL,
            buyer_name TEXT NOT NULL,
            buyer_phone TEXT NOT NULL,
            delivery_address TEXT NOT NULL,
            driver_name TEXT DEFAULT 'Awaiting Driver Allocation',
            driver_phone TEXT DEFAULT '',
            driver_vehicle TEXT DEFAULT '',
            delivery_otp TEXT NOT NULL,
            status TEXT DEFAULT 'pendingAssignment',
            payment_status TEXT DEFAULT 'PAID_RAZORPAY',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            delivered_at TIMESTAMP
        );
        """)

        # 3. Reviews & Persona Usability Feedback
        cursor.execute("""
        CREATE TABLE IF NOT EXISTS reviews (
            id TEXT PRIMARY KEY,
            order_id TEXT,
            farmer_name TEXT NOT NULL,
            buyer_name TEXT NOT NULL,
            rating REAL NOT NULL,
            comment TEXT NOT NULL,
            usability_feedback TEXT,
            persona_type TEXT DEFAULT 'REAL_USER',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        """)

        # 4. Crop Pathology Diagnostics
        cursor.execute("""
        CREATE TABLE IF NOT EXISTS crop_diagnoses (
            id TEXT PRIMARY KEY,
            crop_name TEXT NOT NULL,
            disease_name TEXT NOT NULL,
            severity TEXT NOT NULL,
            confidence REAL NOT NULL,
            organic_remedy TEXT NOT NULL,
            chemical_treatment TEXT NOT NULL,
            farmer_id TEXT NOT NULL,
            image_url TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        """)

        # 5. Mandi APMC Floor Rates
        cursor.execute("""
        CREATE TABLE IF NOT EXISTS mandi_rates (
            id TEXT PRIMARY KEY,
            crop_name TEXT NOT NULL,
            market_yard TEXT NOT NULL,
            modal_price REAL NOT NULL,
            min_price REAL NOT NULL,
            max_price REAL NOT NULL,
            trend TEXT DEFAULT 'up',
            last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        """)

        # 6. KYC Applications
        cursor.execute("""
        CREATE TABLE IF NOT EXISTS kyc_applications (
            id TEXT PRIMARY KEY,
            applicant_name TEXT NOT NULL,
            phone TEXT NOT NULL,
            role TEXT NOT NULL,
            document_type TEXT NOT NULL,
            document_number TEXT NOT NULL,
            district TEXT NOT NULL,
            status TEXT DEFAULT 'pending',
            submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        """)

        # 7. Simulation Audit History
        cursor.execute("""
        CREATE TABLE IF NOT EXISTS simulation_runs (
            id TEXT PRIMARY KEY,
            timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            personas_involved INTEGER NOT NULL,
            transactions_count INTEGER NOT NULL,
            avg_rating REAL NOT NULL,
            feedback_summary TEXT NOT NULL
        );
        """)

        # 8. Kisan Charcha (Community Posts)
        cursor.execute("""
        CREATE TABLE IF NOT EXISTS community_posts (
            id TEXT PRIMARY KEY,
            author_name TEXT NOT NULL,
            author_role TEXT NOT NULL,
            location TEXT NOT NULL,
            crop_name TEXT NOT NULL,
            title TEXT NOT NULL,
            content TEXT NOT NULL,
            upvotes INTEGER DEFAULT 0,
            ai_verified INTEGER DEFAULT 1,
            expert_verified INTEGER DEFAULT 0,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        """)

        # 9. Kisan Charcha (Community Comments / Expert Advice)
        cursor.execute("""
        CREATE TABLE IF NOT EXISTS community_comments (
            id TEXT PRIMARY KEY,
            post_id TEXT NOT NULL,
            author_name TEXT NOT NULL,
            author_role TEXT NOT NULL,
            content TEXT NOT NULL,
            is_agronomist_reply INTEGER DEFAULT 0,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (post_id) REFERENCES community_posts(id) ON DELETE CASCADE
        );
        """)

        # Seed initial Mandi Rates & Products if empty
        cursor.execute("SELECT COUNT(*) FROM mandi_rates;")
        if cursor.fetchone()[0] == 0:
            cursor.executemany("""
            INSERT INTO mandi_rates (id, crop_name, market_yard, modal_price, min_price, max_price, trend)
            VALUES (?, ?, ?, ?, ?, ?, ?);
            """, [
                ('MANDI-101', 'Cotton (Medium Staple)', 'Warangal APMC Yard', 7200.0, 6800.0, 7500.0, 'up'),
                ('MANDI-102', 'Tomato (Desi Organic)', 'Bowenpally Wholesale Yard', 34.0, 28.0, 40.0, 'up'),
                ('MANDI-103', 'Red Chilli (Teja Guntur)', 'Khammam Agriculture Market', 185.0, 160.0, 210.0, 'stable'),
                ('MANDI-104', 'Sona Masoori Paddy', 'Karimnagar Grain Yard', 2350.0, 2180.0, 2450.0, 'up'),
                ('MANDI-105', 'Green Capsicum (Shimla)', 'Malakpet APMC Market', 48.0, 42.0, 56.0, 'down')
            ])

        cursor.execute("SELECT COUNT(*) FROM products;")
        if cursor.fetchone()[0] == 0:
            cursor.executemany("""
            INSERT INTO products (id, name, category, price_per_kg, mandi_benchmark, available_kg, farmer_name, farmer_location, farmer_phone, is_organic, rating, review_count)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
            """, [
                ('PROD-101', 'Fresh Organic Red Tomatoes', 'Vegetables', 38.0, 34.0, 450.0, 'Ramesh Kumar', 'Geesugonda, Warangal', '+91 98765 11001', 1, 4.9, 28),
                ('PROD-102', 'Pure Sona Masoori Raw Rice', 'Grains', 52.0, 48.0, 1200.0, 'Ramesh Kumar', 'Geesugonda, Warangal', '+91 98765 11001', 1, 4.8, 42),
                ('PROD-103', 'Guntur Teja Sun-Dried Red Chilli', 'Spices', 195.0, 185.0, 150.0, 'Lakshmi Devi', 'Madhira, Khammam', '+91 98765 11002', 1, 5.0, 19),
                ('PROD-104', 'Organic Green Capsicum', 'Vegetables', 50.0, 48.0, 280.0, 'Sri Krishna Farm', 'Bypass Road, Karimnagar', '+91 98765 11003', 1, 4.7, 15)
            ])

        cursor.execute("SELECT COUNT(*) FROM reviews;")
        if cursor.fetchone()[0] == 0:
            cursor.executemany("""
            INSERT INTO reviews (id, order_id, farmer_name, buyer_name, rating, comment, usability_feedback, persona_type)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?);
            """, [
                ('REV-1', 'AGRI-1001', 'Ramesh Kumar', 'Dr. Priya Sharma', 5.0, 'Exceptional farm-fresh organic tomatoes! Sweet, firm, and chemical-free.', 'Seamless checkout flow with Razorpay UPI.', 'CONSUMER_PERSONA'),
                ('REV-2', 'AGRI-1002', 'Ramesh Kumar', 'Anand Rao', 4.5, 'Sona Masoori rice cooks fluffy with great natural aroma. Fast delivery.', 'GPS map accurately pointed to the farm pick-up yard.', 'CONSUMER_PERSONA'),
                ('REV-3', 'AGRI-1003', 'Lakshmi Devi', 'Sneha Reddy', 5.0, 'High pungency genuine Teja chillies. Great packaging in jute bags.', 'Loved the Telugu voice assistant advisory before ordering.', 'CONSUMER_PERSONA')
            ])

        cursor.execute("SELECT COUNT(*) FROM community_posts;")
        if cursor.fetchone()[0] == 0:
            cursor.executemany("""
            INSERT INTO community_posts (id, author_name, author_role, location, crop_name, title, content, upvotes, ai_verified, expert_verified)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
            """, [
                (
                    'POST-101',
                    'Ramesh Patel',
                    'Cotton Farmer',
                    'Warangal, Telangana',
                    'Cotton',
                    'Pink Bollworm infestation observed in 45-day Bt cotton crop - need urgent spray schedule',
                    'I noticed rosette flowers and small entrance boreholes on cotton bolls. Current temperature is 31°C with 70% humidity. Has anyone tried Profenofos 50% EC vs Emamectin Benzoate 5% SG? What is the safe tank dilution?',
                    34,
                    1,
                    1
                ),
                (
                    'POST-102',
                    'Srinivasulu Naidu',
                    'Horticulture Farmer',
                    'Guntur, AP',
                    'Chilli',
                    'Black Thrips (Thrips parvispinus) leaf curling & flower drop remedy',
                    'Severe upward leaf curling in 3rd picking stage chilli. Blue sticky traps caught hundreds. Seeking organic biological control or IPM rotation to prevent chemical resistance.',
                    48,
                    1,
                    1
                ),
                (
                    'POST-103',
                    'Gurpreet Singh',
                    'Paddy Grower',
                    'Karnal, Haryana',
                    'Paddy (Basmati)',
                    'Pre-emptive spray for Sheath Blight before upcoming monsoon spell',
                    'Satellite radar is showing high canopy moisture (NDWI 0.58). Should I apply Hexaconazole 5% SC now or wait for clear sunshine?',
                    22,
                    1,
                    0
                )
            ])

            cursor.executemany("""
            INSERT INTO community_comments (id, post_id, author_name, author_role, content, is_agronomist_reply)
            VALUES (?, ?, ?, ?, ?, ?);
            """, [
                (
                    'COMM-1',
                    'POST-101',
                    'Dr. V. K. Rao (ICAR Agronomist)',
                    'Certified Entomologist',
                    'Immediate action: Spray Emamectin Benzoate 5% SG @ 0.4g per Liter water (6.5g per 16L knapsack tank) in late afternoon. Avoid synthetic pyrethroids which cause flare-up of secondary sucking pests.',
                    1
                ),
                (
                    'COMM-2',
                    'POST-102',
                    'AGRI AI Diagnosis Engine',
                    'Automated IPM Specialist',
                    'IPM Protocol: Install 20 blue sticky traps/acre. Spray Neem Oil 10,000 ppm @ 3ml/L water mixed with Pongamia soap. Rotate with Spinetoram 11.7% SC @ 0.9ml/L if thrips threshold exceeds 5 per terminal leaf.',
                    1
                )
            ])

if __name__ == "__main__":
    init_db()
    print("AGRI AI Database initialized with tables and initial seed data.")
