# AGRI AI — Smart Agriculture & Farmer Marketplace

An intelligent Android application built with **Flutter** designed to empower Indian farmers, connect rural agricultural producers directly with consumers, provide AI-powered crop diagnostics, and streamline farm-to-doorstep delivery.

---

## 🌾 Project Overview

**AGRI AI** unites three key user ecosystems into a single, intuitive mobile platform:
1. **Farmers**: Diagnose crop diseases using camera AI, access smart weather and mandi price intelligence, list produce for sale directly at fair prices, and track orders.
2. **Customers**: Browse fresh farm-to-table produce, filter by category and location, add to cart, pay securely via Razorpay, and track delivery.
3. **Delivery Partners**: Accept delivery assignments, navigate to farms and customer locations, and confirm deliveries via secure OTP.

---

## 🛠️ Technology Stack

| Component | Technology | Purpose |
| :--- | :--- | :--- |
| **Framework** | Flutter (Dart 3.x) | Cross-platform mobile development (Target: Android) |
| **State Management** | Riverpod 2.x | Scalable, compile-safe reactive state management |
| **Backend / Database** | Firebase (Auth, Firestore, Cloud Storage) | Authentication, NoSQL real-time data, media storage |
| **Push Notifications** | Firebase Cloud Messaging (FCM) | Order status and farming alerts |
| **AI Crop Doctor** | Google Gemini 1.5 Flash / Pro Vision | High-accuracy plant pathology and disease detection |
| **Microservices** | Python FastAPI (Optional / Cloud-hosted) | Custom ML models & compute-heavy services |
| **Maps & Location** | Google Maps Platform | GPS geocoding, route mapping, and mandi discovery |
| **Payment Gateway** | Razorpay SDK | UPI, debit/credit cards, and net banking (India) |
| **Voice Assistant** | AGRI MITRA (BHASHINI / Speech-to-Text) | Multilingual voice assistance (English, Hindi, Telugu) |

---

## 📁 Recommended Feature-First Architecture

```text
lib/
├── main.dart                   # Application entry point
├── app.dart                    # MaterialApp, Riverpod ProviderScope, Global Themes & Routing
├── core/                       # Shared across all features
│   ├── constants/              # App strings, asset paths, API endpoints
│   ├── theme/                  # Agricultural green color palette, typography, button styles
│   ├── network/                # HTTP/Dio client & Firebase base handlers
│   ├── utils/                  # Formatters (currency, dates), validators, logger
│   └── widgets/                # Common reusable UI components (custom buttons, cards, text fields)
├── features/                   # Self-contained modules
│   ├── splash_onboarding/      # Animated splash screen & 3-step farmer-friendly intro
│   ├── auth/                   # Phone OTP / Email auth, role selection (Farmer, Customer, Delivery)
│   ├── crop_doctor/            # Camera scan, AI Gemini diagnosis, disease reports & treatments
│   ├── smart_farming/          # Weather forecasting, advisory, crop calendar
│   ├── mandi_prices/           # GPS location, daily agricultural market prices & trends
│   ├── marketplace/            # Product listings, farmer catalog, customer cart & checkout
│   ├── orders_delivery/        # Order tracking, delivery partner dashboard, OTP verification
│   └── voice_assistant/        # AGRI MITRA voice assistant (multilingual audio interface)
└── services/                   # Third-party integrations (Firebase, Gemini API, Razorpay, Location)
```

---

## 🚀 Getting Started & Prerequisites

### 1. Development Prerequisites
Before running AGRI AI, your development machine requires:
- **Git** (Already installed on your system)
- **Flutter SDK** (v3.24.0 or newer recommended)
- **Android Studio** with:
  - Android SDK Platform (API 34 / Android 14)
  - Android SDK Command-line Tools
  - Android SDK Build-Tools
  - Android Virtual Device (AVD Emulator) or a physical Android phone with USB Debugging enabled

### 2. Environment Verification
Open PowerShell and verify your environment:
```powershell
flutter doctor -v
```
All critical checks for **Flutter**, **Android toolchain**, and **VS Code / Android Studio** should show green checkmarks.

### 3. Running the Project (Once Initialized)
```powershell
# Get all project dependencies
flutter pub get

# Run on an attached Android device or emulator
flutter run
```

---

## 📋 Development Roadmap Summary

- **Phase 1**: Environment setup, brand design system, onboarding, role selection & base navigation. *(Current Phase)*
- **Phase 2**: Firebase Authentication & Role-Based Profiles (Farmer, Customer, Delivery Partner).
- **Phase 3**: AI Crop Doctor (Camera scan, Gemini Vision integration, diagnosis card & history).
- **Phase 4**: Smart Farming & GPS Mandi Prices (Weather API, Mandi Price API, Geo-location).
- **Phase 5**: Farmer-to-Consumer Marketplace (Product listings, catalog, cart, Razorpay payments).
- **Phase 6**: Delivery Partner Module & Real-Time Tracking (Order dispatch, route map, OTP confirmation).
- **Phase 7**: AGRI MITRA Voice Assistant & Production Polishing (Voice input/TTS, multilingual support, release APK build).

