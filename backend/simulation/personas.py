from dataclasses import dataclass, field
from typing import List, Dict, Any
import random

@dataclass
class Persona:
    persona_id: str
    name: str
    role: str
    location: str
    language: str
    traits: List[str]
    sample_queries: List[str]

FARMER_RAMESH = Persona(
    persona_id="FARMER-01",
    name="Ramesh Kumar",
    role="Farmer",
    location="Geesugonda Village, Warangal",
    language="Telugu / English",
    traits=["Elderly smallholder", "Prefers vernacular voice speech", "Focuses on prompt organic remedies"],
    sample_queries=[
        "మొక్కల ఆకులపై తెల్లని మచ్చలు ఉన్నాయి (White powdery spots on cotton leaves)",
        "Is Warangal APMC mandi price better for medium staple cotton today?",
        "List 25 kg naturally grown red tomatoes at ₹38/kg"
    ]
)

BUYER_PRIYA = Persona(
    persona_id="BUYER-01",
    name="Dr. Priya Sharma",
    role="Consumer",
    location="Hanamkonda, Telangana",
    language="English / Hindi",
    traits=["Health conscious physician", "Prefers direct farm-to-table organic", "Values doorstep traceability"],
    sample_queries=[
        "Looking for residue-free tomatoes harvested today",
        "Compare farmer asking price with Bowenpally wholesale rate",
        "Pay ₹190 via Razorpay UPI and verify farmer KYC badge"
    ]
)

DRIVER_SURESH = Persona(
    persona_id="DRIVER-01",
    name="Suresh Patel",
    role="DeliveryPartner",
    location="Kazipet Subedari Hub",
    language="Telugu / Hindi",
    traits=["Two-wheeler rural cargo fleet", "Experienced with rural mud-track GPS", "Focuses on prompt OTP handovers"],
    sample_queries=[
        "Accept dispatch TRIP-4019 from Ramesh Farm (8.5 km)",
        "Navigate rural bypass road to Green Meadows, Hanamkonda",
        "Request 4-digit OTP handover code from customer"
    ]
)

ADMIN_OPERATIONS = Persona(
    persona_id="ADMIN-01",
    name="Operations Administrator",
    role="Administrator",
    location="Central Command Hub, Hyderabad",
    language="English",
    traits=["Risk moderation specialist", "Inspects Dharani land records", "Monitors anti-price-gouging safeguards"],
    sample_queries=[
        "Verify Ramesh Kumar Dharani Passbook #TS-WGL-98214",
        "Audit daily platform GMV and active transit delivery trips",
        "Dispatch district-wide pest outbreak advisory for Pink Bollworm"
    ]
)

PERSONAS = [FARMER_RAMESH, BUYER_PRIYA, DRIVER_SURESH, ADMIN_OPERATIONS]
