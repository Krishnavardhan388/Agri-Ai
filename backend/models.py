from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime

class ProductCreate(BaseModel):
    name: str
    category: str
    price_per_kg: float
    mandi_benchmark: float
    available_kg: float
    farmer_name: str
    farmer_location: str
    farmer_phone: str
    is_organic: bool = True

class ProductResponse(BaseModel):
    id: str
    name: str
    category: str
    price_per_kg: float
    mandi_benchmark: float
    available_kg: float
    farmer_name: str
    farmer_location: str
    farmer_phone: str
    is_organic: bool
    rating: float
    review_count: int
    status: str
    created_at: str

class OrderCreate(BaseModel):
    product_id: str
    quantity_kg: float
    buyer_name: str
    buyer_phone: str
    delivery_address: str
    payment_method: str = "RAZORPAY_UPI"

class OrderResponse(BaseModel):
    id: str
    product_id: str
    product_name: str
    quantity_kg: float
    total_amount: float
    buyer_name: str
    buyer_phone: str
    delivery_address: str
    driver_name: str
    driver_phone: str
    driver_vehicle: str
    delivery_otp: str
    status: str
    payment_status: str
    created_at: str

class VerifyOtpRequest(BaseModel):
    order_id: str
    entered_otp: str
    driver_id: Optional[str] = None

class ReviewCreate(BaseModel):
    order_id: Optional[str] = None
    farmer_name: str
    buyer_name: str
    rating: float
    comment: str
    usability_feedback: Optional[str] = None
    persona_type: str = "REAL_USER"

class ReviewResponse(BaseModel):
    id: str
    order_id: Optional[str]
    farmer_name: str
    buyer_name: str
    rating: float
    comment: str
    usability_feedback: Optional[str]
    persona_type: str
    created_at: str

class CropDiagnosisCreate(BaseModel):
    crop_name: str
    disease_name: str
    severity: str
    confidence: float
    organic_remedy: str
    chemical_treatment: str
    farmer_id: str
    image_url: Optional[str] = None

class MandiRateResponse(BaseModel):
    id: str
    crop_name: str
    market_yard: str
    modal_price: float
    min_price: float
    max_price: float
    trend: str
    last_updated: str

class SimulationRunRequest(BaseModel):
    scenarios: List[str] = Field(default_factory=lambda: ["DISEASE_SCAN", "MARKETPLACE_ORDER", "LOGISTICS_DISPATCH", "USER_REVIEW"])
    cycles: int = 1

class SimulationRunResponse(BaseModel):
    run_id: str
    timestamp: str
    personas_involved: int
    transactions_count: int
    avg_rating: float
    feedback_summary: str
    logs: List[str]

# Community Kisan Charcha Models
class CommentCreate(BaseModel):
    author_name: str
    author_role: str = "Farmer"
    content: str
    is_agronomist_reply: bool = False

class CommentResponse(BaseModel):
    id: str
    post_id: str
    author_name: str
    author_role: str
    content: str
    is_agronomist_reply: bool
    created_at: str

class CommunityPostCreate(BaseModel):
    author_name: str
    author_role: str = "Farmer"
    location: str
    crop_name: str
    title: str
    content: str

class CommunityPostResponse(BaseModel):
    id: str
    author_name: str
    author_role: str
    location: str
    crop_name: str
    title: str
    content: str
    upvotes: int
    ai_verified: bool
    expert_verified: bool
    created_at: str
    comments: List[CommentResponse] = []

# Satellite & Bio-Climatic Radar Models
class SatelliteRadarResponse(BaseModel):
    satellite_name: str
    orbit_time: str
    ndvi_index: float
    ndvi_status: str
    ndre_index: float
    ndwi_index: float
    soil_moisture_percentage: float
    soil_temperature_celsius: float
    spore_infection_risk: str
    microclimate_alert: str
    recommended_spray_window: str

# Variable-Rate Application Dosage Calculator
class DilutionCalculationRequest(BaseModel):
    crop_name: str
    disease_name: str
    acreage: float
    tank_capacity_liters: float = 16.0
    treatment_type: str = "organic" # or "chemical"
    spray_speed_kmh: float = 3.5

class DilutionCalculationResponse(BaseModel):
    crop_name: str
    disease_name: str
    acreage: float
    tank_capacity_liters: float
    water_volume_liters: float
    tanks_count: float
    active_ingredient: str
    dose_per_liter: str
    dose_per_tank: str
    total_material_needed: str
    ppe_guideline: str
    wind_restriction: str
    estimated_cost_savings_inr: float

