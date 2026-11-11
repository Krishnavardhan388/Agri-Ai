import os
import re
import secrets
from typing import Any, Dict, Optional

import httpx


def normalize_phone_e164(phone: str) -> str:
    digits = re.sub(r"\D", "", phone.strip())
    if len(digits) == 10:
        return f"+91{digits}"
    if len(digits) == 12 and digits.startswith("91"):
        return f"+{digits}"
    if phone.strip().startswith("+"):
        return f"+{digits}"
    return f"+{digits}" if digits else phone.strip()


def extract_indian_10_digits(phone: str) -> str:
    digits = re.sub(r"\D", "", phone.strip())
    if len(digits) >= 10:
        return digits[-10:]
    return digits


class Fast2SmsService:
    """
    Production SMS OTP Gateway powered by Fast2SMS REST API v2.
    Reads FAST2SMS_API_KEY and optional FAST2SMS_ROUTE ("q", "otp", or "dlt") from environment.
    """

    BULK_V2_URL = "https://www.fast2sms.com/dev/bulkV2"

    @property
    def is_configured(self) -> bool:
        key = os.environ.get("FAST2SMS_API_KEY", "").strip()
        return bool(key and key != "your_fast2sms_api_key_here")

    def generate_otp(self) -> str:
        return f"{secrets.randbelow(900000) + 100000}"

    def send_otp_sms(self, phone: str, otp: str) -> Dict[str, Any]:
        api_key = os.environ.get("FAST2SMS_API_KEY", "").strip()
        route = os.environ.get("FAST2SMS_ROUTE", "q").strip().lower() or "q"
        sender_id = os.environ.get("FAST2SMS_SENDER_ID", "AGRIAI").strip() or "AGRIAI"
        template_id = os.environ.get("FAST2SMS_DLT_TEMPLATE_ID", "").strip()

        ten_digit = extract_indian_10_digits(phone)
        if len(ten_digit) != 10:
            return {
                "sms_sent": False,
                "provider": "INVALID_PHONE",
                "message": "Please enter a valid 10-digit Indian mobile number.",
                "error": "Invalid 10-digit mobile length",
            }

        if not self.is_configured:
            return {
                "sms_sent": False,
                "provider": "FAST2SMS_UNCONFIGURED",
                "message": (
                    "FAST2SMS_API_KEY is not configured in server environment variables. "
                    "Add FAST2SMS_API_KEY in Vercel / .env to dispatch live SMS."
                ),
                "error": "Missing FAST2SMS_API_KEY",
            }

        headers = {
            "authorization": api_key,
            "Content-Type": "application/json",
            "Accept": "application/json",
        }

        if route == "dlt" and template_id:
            payload: Dict[str, Any] = {
                "route": "dlt",
                "sender_id": sender_id,
                "message": template_id,
                "variables_values": otp,
                "flash": 0,
                "numbers": ten_digit,
            }
        elif route == "otp":
            payload = {
                "route": "otp",
                "variables_values": otp,
                "flash": 0,
                "numbers": ten_digit,
            }
        else:
            payload = {
                "route": "q",
                "message": f"Your AGRI AI verification code is {otp}. Valid for 5 minutes. Do not share this code.",
                "flash": 0,
                "numbers": ten_digit,
            }

        try:
            with httpx.Client(timeout=10.0) as client:
                resp = client.post(self.BULK_V2_URL, headers=headers, json=payload)
                data = resp.json() if resp.headers.get("content-type", "").startswith("application/json") else {}

                if resp.status_code == 200 and data.get("return") is True:
                    return {
                        "sms_sent": True,
                        "provider": f"Fast2SMS ({route})",
                        "request_id": data.get("request_id"),
                        "message": f"Verification SMS dispatched to +91{ten_digit}",
                    }

                error_msg = data.get("message") if isinstance(data.get("message"), str) else str(data.get("message") or resp.text)
                return {
                    "sms_sent": False,
                    "provider": f"Fast2SMS ({route})",
                    "message": f"Fast2SMS gateway rejected request: {error_msg}",
                    "error": error_msg,
                }
        except Exception as exc:
            return {
                "sms_sent": False,
                "provider": "Fast2SMS",
                "message": f"SMS network error: {exc}",
                "error": str(exc),
            }


sms_service = Fast2SmsService()
