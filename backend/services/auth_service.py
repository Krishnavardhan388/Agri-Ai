import base64
import hashlib
import hmac
import json
import os
import secrets
import uuid
from datetime import datetime, timedelta, timezone
from typing import Any, Dict, Optional

from backend.database import db_store
from backend.services.sms_service import normalize_phone_e164, sms_service


def _secret_key() -> bytes:
    raw = os.environ.get("AUTH_SECRET_KEY", "agri-ai-startup-production-secret-2026")
    return raw.encode("utf-8")


def hash_pin(pin: str, salt: Optional[str] = None) -> tuple[str, str]:
    used_salt = salt or secrets.token_hex(16)
    digest = hashlib.pbkdf2_hmac("sha256", pin.encode("utf-8"), used_salt.encode("utf-8"), 100_000).hex()
    return used_salt, digest


def verify_pin(pin: str, salt: str, expected_hash: str) -> bool:
    _, candidate = hash_pin(pin, salt)
    return hmac.compare_digest(candidate, expected_hash)


def create_session_token(user_id: str, phone: str, role: str) -> str:
    payload = {
        "uid": user_id,
        "phone": phone,
        "role": role,
        "exp": int((datetime.now(timezone.utc) + timedelta(days=30)).timestamp()),
    }
    payload_bytes = base64.urlsafe_b64encode(json.dumps(payload).encode("utf-8"))
    sig = hmac.new(_secret_key(), payload_bytes, hashlib.sha256).hexdigest()
    return f"{payload_bytes.decode('utf-8')}.{sig}"


def decode_session_token(token: str) -> Optional[Dict[str, Any]]:
    try:
        payload_b64, sig = token.split(".", 1)
        expected_sig = hmac.new(_secret_key(), payload_b64.encode("utf-8"), hashlib.sha256).hexdigest()
        if not hmac.compare_digest(sig, expected_sig):
            return None
        payload = json.loads(base64.urlsafe_b64decode(payload_b64.encode("utf-8")).decode("utf-8"))
        if int(payload.get("exp", 0)) < int(datetime.now(timezone.utc).timestamp()):
            return None
        return payload
    except Exception:
        return None


def sanitize_user_for_response(user_doc: Dict[str, Any]) -> Dict[str, Any]:
    return {
        "uid": user_doc.get("uid") or user_doc.get("id"),
        "name": user_doc.get("name", ""),
        "phone": user_doc.get("phone", ""),
        "role": user_doc.get("role", "farmer"),
        "location": user_doc.get("location", "Warangal, Telangana"),
        "is_verified": bool(user_doc.get("is_verified", True)),
        "created_at": str(user_doc.get("created_at", datetime.now(timezone.utc).isoformat())),
    }


class AuthService:
    OTP_EXPIRY_MINUTES = 5
    MAX_OTP_ATTEMPTS = 5

    def request_otp(self, phone: str) -> Dict[str, Any]:
        e164_phone = normalize_phone_e164(phone)
        otp_code = sms_service.generate_otp()
        verification_id = f"OTP-{uuid.uuid4().hex[:10].upper()}"
        now = datetime.now(timezone.utc)
        expires_at = now + timedelta(minutes=self.OTP_EXPIRY_MINUTES)

        salt, otp_hash = hash_pin(otp_code)

        db_store.insert_one("otp_sessions", {
            "id": verification_id,
            "phone": e164_phone,
            "otp_salt": salt,
            "otp_hash": otp_hash,
            "attempts": 0,
            "verified": False,
            "created_at": now.isoformat(),
            "expire_at": expires_at,
            "expires_at_iso": expires_at.isoformat(),
        })

        sms_result = sms_service.send_otp_sms(e164_phone, otp_code)
        sms_sent = bool(sms_result.get("sms_sent"))

        response: Dict[str, Any] = {
            "verification_id": verification_id,
            "phone": e164_phone,
            "sms_sent": sms_sent,
            "provider": sms_result.get("provider", "Fast2SMS"),
            "expires_in_seconds": self.OTP_EXPIRY_MINUTES * 60,
            "message": sms_result.get("message", "OTP generated"),
        }

        # IMPORTANT: Only return diagnostic preview OTP when live SMS gateway is NOT yet configured,
        # never when real telecom SMS was sent.
        if not sms_sent and not sms_service.is_configured:
            response["sandbox_otp_preview"] = otp_code

        return response

    def verify_otp_and_login(
        self,
        verification_id: str,
        sms_code: str,
        role: str = "farmer",
        name: Optional[str] = None,
        location: Optional[str] = None,
    ) -> Dict[str, Any]:
        session = db_store.find_one("otp_sessions", {"id": verification_id})
        if not session:
            raise ValueError("Invalid or expired verification session. Please request a new OTP.")

        if session.get("verified"):
            raise ValueError("OTP already used. Please request a fresh verification code.")

        attempts = int(session.get("attempts", 0))
        if attempts >= self.MAX_OTP_ATTEMPTS:
            raise ValueError("Maximum OTP attempts exceeded. Please request a new OTP.")

        expires_iso = session.get("expires_at_iso")
        if expires_iso:
            exp_dt = datetime.fromisoformat(str(expires_iso))
            if datetime.now(timezone.utc) > exp_dt:
                raise ValueError("OTP expired (5 min limit). Please resend verification SMS.")

        if not verify_pin(sms_code.strip(), session["otp_salt"], session["otp_hash"]):
            db_store.update_one("otp_sessions", {"id": verification_id}, inc_fields={"attempts": 1})
            remaining = max(0, self.MAX_OTP_ATTEMPTS - (attempts + 1))
            raise ValueError(f"Incorrect 6-digit OTP code. {remaining} attempt(s) remaining.")

        db_store.update_one("otp_sessions", {"id": verification_id}, set_fields={"verified": True})

        phone = session["phone"]
        existing_user = db_store.find_one("users", {"phone": phone})
        now_iso = datetime.now(timezone.utc).isoformat()

        if existing_user:
            update_fields: Dict[str, Any] = {"role": role, "last_login_at": now_iso}
            if name and name.strip():
                update_fields["name"] = name.strip()
            if location and location.strip():
                update_fields["location"] = location.strip()
            updated = db_store.update_one("users", {"phone": phone}, set_fields=update_fields)
            user_doc = updated or existing_user
        else:
            default_names = {
                "farmer": "Kisan Farmer",
                "customer": "Verified Buyer",
                "deliveryPartner": "Fleet Partner",
                "admin": "Operations Officer",
            }
            uid = f"user-{uuid.uuid4().hex[:8]}"
            salt, pin_hash = hash_pin("123456")
            user_doc = {
                "id": uid,
                "uid": uid,
                "name": (name or "").strip() or default_names.get(role, "AGRI AI User"),
                "phone": phone,
                "role": role,
                "location": (location or "").strip() or "Warangal, Telangana",
                "pin_salt": salt,
                "pin_hash": pin_hash,
                "is_verified": True,
                "created_at": now_iso,
                "last_login_at": now_iso,
            }
            db_store.insert_one("users", user_doc)

        clean_user = sanitize_user_for_response(user_doc)
        token = create_session_token(clean_user["uid"], clean_user["phone"], clean_user["role"])
        return {"user": clean_user, "access_token": token, "token_type": "bearer"}

    def login_with_pin(self, phone: str, pin: str, role: str) -> Dict[str, Any]:
        e164_phone = normalize_phone_e164(phone)
        user_doc = db_store.find_one("users", {"phone": e164_phone})
        if not user_doc:
            raise ValueError("Account not found for this mobile number. Please sign in with OTP or Register first.")

        salt = user_doc.get("pin_salt", "")
        expected_hash = user_doc.get("pin_hash", "")
        if not salt or not expected_hash or not verify_pin(pin.strip(), salt, expected_hash):
            raise ValueError("Invalid security PIN / password. Try Mobile OTP or check your PIN.")

        now_iso = datetime.now(timezone.utc).isoformat()
        updated = db_store.update_one("users", {"phone": e164_phone}, set_fields={"role": role, "last_login_at": now_iso})
        clean_user = sanitize_user_for_response(updated or user_doc)
        token = create_session_token(clean_user["uid"], clean_user["phone"], clean_user["role"])
        return {"user": clean_user, "access_token": token, "token_type": "bearer"}

    def register_user(
        self,
        name: str,
        phone: str,
        location: str,
        role: str,
        pin: str = "123456",
    ) -> Dict[str, Any]:
        e164_phone = normalize_phone_e164(phone)
        existing = db_store.find_one("users", {"phone": e164_phone})
        now_iso = datetime.now(timezone.utc).isoformat()
        salt, pin_hash = hash_pin(pin.strip() if pin.strip() else "123456")

        if existing:
            updated = db_store.update_one(
                "users",
                {"phone": e164_phone},
                set_fields={
                    "name": name.strip(),
                    "location": location.strip(),
                    "role": role,
                    "pin_salt": salt,
                    "pin_hash": pin_hash,
                    "last_login_at": now_iso,
                },
            )
            user_doc = updated or existing
        else:
            uid = f"user-{uuid.uuid4().hex[:8]}"
            user_doc = {
                "id": uid,
                "uid": uid,
                "name": name.strip(),
                "phone": e164_phone,
                "role": role,
                "location": location.strip(),
                "pin_salt": salt,
                "pin_hash": pin_hash,
                "is_verified": True,
                "created_at": now_iso,
                "last_login_at": now_iso,
            }
            db_store.insert_one("users", user_doc)

        clean_user = sanitize_user_for_response(user_doc)
        token = create_session_token(clean_user["uid"], clean_user["phone"], clean_user["role"])
        return {"user": clean_user, "access_token": token, "token_type": "bearer"}


auth_service = AuthService()
