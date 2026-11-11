from typing import Any, Dict, List, Optional
from pydantic import BaseModel, Field


# ============================================================
# Auth & User Schemas
# ============================================================
class SendOtpRequest(BaseModel):
    phone: str


class SendOtpResponse(BaseModel):
    verification_id: str
    phone: str
    sms_sent: bool
    provider: str
    expires_in_seconds: int
    message: str
    sandbox_otp_preview: Optional[str] = None


class VerifyOtpAuthRequest(BaseModel):
    verification_id: str
    sms_code: str
    role: str = "farmer"
    name: Optional[str] = None
    location: Optional[str] = None


class PinLoginRequest(BaseModel):
    phone: str
    pin: str
    role: str = "farmer"


class RegisterUserRequest(BaseModel):
    name: str
    phone: str
    location: str
    role: str = "farmer"
    pin: str = "123456"


class AuthUserResponse(BaseModel):
    uid: str
    name: str
    phone: str
    role: str
    location: str
    is_verified: bool
    created_at: str


class AuthSessionResponse(BaseModel):
    user: AuthUserResponse
    access_token: str
    token_type: str = "bearer"


# ============================================================
# Marketplace & Orders Schemas
# ============================================================
class ProductCreate(BaseModel):
    name: str
    description: str = "Freshly harvested produce directly from farm."
    category: str
    price_per_kg: float
    mandi_benchmark: float
    available_kg: float
    farmer_id: str = "user-farmer-ramesh"
    farmer_name: str
    farmer_location: str
    farmer_phone: str
    harvest_date: str = "Harvested Today"
    is_organic: bool = True


class ProductUpdate(BaseModel):
    status: Optional[str] = None
    available_kg: Optional[float] = None
    is_organic: Optional[bool] = None
    moderation_note: Optional[str] = None


class ProductResponse(BaseModel):
    id: str
    farmer_id: str = "user-farmer-ramesh"
    name: str
    description: str = ""
    category: str
    price_per_kg: float
    mandi_benchmark: float
    available_kg: float
    farmer_name: str
    farmer_location: str
    farmer_phone: str
    harvest_date: str = "Harvested Today"
    is_organic: bool
    rating: float
    review_count: int
    status: str
    moderation_note: Optional[str] = None
    created_at: str


class OrderCreate(BaseModel):
    product_id: str
    quantity_kg: float
    buyer_name: str
    buyer_phone: str
    delivery_address: str
    customer_id: str = "cust-current"
    payment_method: str = "RAZORPAY_UPI"
    payment_id: Optional[str] = None
    total_amount_override: Optional[float] = None


class OrderStatusUpdate(BaseModel):
    status: str


class OrderResponse(BaseModel):
    id: str
    product_id: str
    product_name: str
    quantity_kg: float
    total_amount: float
    customer_id: str = "cust-current"
    buyer_name: str
    buyer_phone: str
    delivery_address: str
    farmer_id: str = "user-farmer-ramesh"
    farmer_name: str = "Ramesh Farm"
    driver_name: str
    driver_phone: str
    driver_vehicle: str
    delivery_otp: str
    status: str
    payment_status: str
    payment_method: str = "Razorpay UPI"
    payment_id: str = ""
    created_at: str


class VerifyOtpRequest(BaseModel):
    order_id: str
    entered_otp: str
    driver_id: Optional[str] = None


class DeliveryOtpVerifyRequest(BaseModel):
    otp: str
    driver_id: Optional[str] = None


class PayoutRequest(BaseModel):
    amount: float
    upi_or_bank: str


# ============================================================
# Reviews & Persona Usability Schemas
# ============================================================
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
    order_id: Optional[str] = None
    farmer_name: str
    buyer_name: str
    rating: float
    comment: str
    usability_feedback: Optional[str] = None
    persona_type: str
    created_at: str


# ============================================================
# Crop Pathology & Voice Assistant Schemas
# ============================================================
class CropDiagnosisCreate(BaseModel):
    crop_name: str
    disease_name: str
    scientific_name: str = ""
    health_score: int = 75
    severity: str
    confidence: float
    symptoms: List[str] = []
    organic_treatments: List[str] = []
    chemical_treatments: List[str] = []
    preventive_measures: List[str] = []
    farmer_id: str
    image_base64: Optional[str] = None
    image_mime_type: str = "image/jpeg"


class VoiceQueryRequest(BaseModel):
    query: str
    language: str = "en"  # en, te, hi


# ============================================================
# Mandi, Admin KYC, Dispatches, Settings & Broadcasts
# ============================================================
class MandiRateResponse(BaseModel):
    id: str
    crop_name: str
    variety: str = ""
    category: str = "Vegetables"
    market_yard: str
    distance_km: float = 5.0
    modal_price: float
    min_price: float
    max_price: float
    price_change: float = 0.0
    trend: str
    last_updated: str


class MandiRateUpdateRequest(BaseModel):
    modal_price: float
    min_price: Optional[float] = None
    max_price: Optional[float] = None
    trend: Optional[str] = None


class KycDecisionRequest(BaseModel):
    reason: Optional[str] = None
    reviewed_by: str = "Admin Officer (HQ)"


class DispatchReassignRequest(BaseModel):
    driver_name: str
    driver_phone: str
    driver_vehicle: str


class SystemSettingsUpdate(BaseModel):
    gemini_model: Optional[str] = None
    razorpay_mode: Optional[str] = None
    platform_commission_percent: Optional[float] = None
    default_voice_speech_rate: Optional[float] = None
    is_auto_dispatch_enabled: Optional[bool] = None


class BroadcastCreate(BaseModel):
    district: str
    crop: str
    advisory: str


# ============================================================
# Community, Satellite Radar, VRA Calculator & Simulation
# ============================================================
class SimulationRunRequest(BaseModel):
    scenarios: List[str] = Field(
        default_factory=lambda: ["DISEASE_SCAN", "MARKETPLACE_ORDER", "LOGISTICS_DISPATCH", "USER_REVIEW"]
    )
    cycles: int = 1


class SimulationRunResponse(BaseModel):
    run_id: str
    timestamp: str
    personas_involved: int
    transactions_count: int
    avg_rating: float
    feedback_summary: str
    logs: List[str]


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


class DilutionCalculationRequest(BaseModel):
    crop_name: str
    disease_name: str
    acreage: float
    tank_capacity_liters: float = 16.0
    treatment_type: str = "organic"
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
