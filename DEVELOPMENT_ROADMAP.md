# AGRI AI — Development Roadmap & Master Checklist

This checklist tracks our end-to-end development journey from setup to production release. We work strictly one phase at a time and ensure each milestone is tested and verified before proceeding.

---

## 🚦 Phase 1: Environment Setup, Design System & Navigation Shell ✅ COMPLETED
- [x] **Step 1.1: Environment Verification**
  - [x] Workspace inspected and verified.
  - [x] Git confirmed installed (`v2.56.0`).
  - [x] Flutter SDK 3.47.9 & Dart 3.13.7 verified.
  - [x] Android SDK 36.0.0 and Java OpenJDK (build 25) verified.
  - [x] `flutter doctor -v` passes with 100% green checkmarks.
- [x] **Step 1.2: Project Scaffolding**
  - [x] Flutter Android project created (`com.agriai.app.agri_ai`).
  - [x] Configured `pubspec.yaml` with Riverpod, Google Fonts, and Intl.
  - [x] Established feature-first clean architecture directory structure.
- [x] **Step 1.3: Brand Design System & Theme**
  - [x] Defined agricultural green palette (`#2E7D32`, `#1B5E20`, `#E8F5E9`).
  - [x] Configured Google Fonts Poppins typography with outdoor contrast.
  - [x] Built reusable UI widgets: `CustomButton`, `CustomTextField`, `AgriCard`.
- [x] **Step 1.4: Onboarding & Authentication Flow (UI & State)**
  - [x] Animated Splash Screen with AGRI AI branding.
  - [x] 3-Step Flipkart-style Interactive Onboarding Slider (AI Doctor, Smart Farming, Direct Marketplace).
  - [x] Role Selection Screen (Farmer, Customer, Delivery Partner) with interactive cards.
  - [x] Login & Registration screens with validation and role badge.
  - [x] Riverpod `authProvider` state management.
- [x] **Step 1.5: Role-Based Navigation Shell**
  - [x] Farmer Bottom Navigation (5 tabs: Home, Crop Doctor, Marketplace, Orders, Profile).
  - [x] Customer Bottom Navigation (4 tabs: Shop, Cart, My Orders, Account).
  - [x] Delivery Partner Navigation (3 tabs: Trips, Earnings, Profile).
  - [x] Verified zero warnings (`flutter analyze` -> No issues found).
  - [x] Automated widget test verified (`flutter test` -> All tests passed).

---

## 🔒 Phase 2: Firebase Integration & Role-Based Authentication ✅ COMPLETED
- [x] Integrated `firebase_core`, `firebase_auth`, and `cloud_firestore` with Flutter 3.47.
- [x] Configured safe `FirebaseService.initialize()` with graceful local fallback.
- [x] Implemented typed `UserModel` with role assignment (`farmer`, `customer`, `deliveryPartner`).
- [x] Implemented `FirestoreUserService` for Cloud Firestore profile synchronization.
- [x] Implemented `FirebaseAuthRepository` supporting real SMS Phone Auth & fast local dev simulation.
- [x] Built interactive 6-digit `OtpVerificationSheet` with digit jumping and resend SMS.
- [x] Implemented persistent session login using `LocalStorageService` (`SharedPreferences`).
- [x] Implemented auto-redirect on app reboot (restores user session directly to their dashboard).
- [x] Created [FIREBASE_SETUP_GUIDE.md](file:///d:/antigravity/ai%20crop%20disease%20detection%20system/FIREBASE_SETUP_GUIDE.md) explaining how to obtain `google-services.json`.
- [x] Verified with unit & widget tests (`flutter test` -> 4/4 passed).
- [x] Verified zero issues (`flutter analyze` -> No issues found).

---

## 🌿 Phase 3: AI Crop Doctor Module ✅ COMPLETED
- [x] Integrated `image_picker` and `google_generative_ai` packages.
- [x] Added Camera, Gallery, and Internet permissions in `AndroidManifest.xml`.
- [x] Implemented `CropDiagnosisResult` model (health score, pathogen, symptoms, remedies).
- [x] Built `GeminiCropDoctorService` with prompt engineered for Indian crops and graceful offline simulation fallback.
- [x] Built `DiagnosisHistoryRepository` with local caching and Cloud Firestore synchronization.
- [x] Built interactive `CameraScanScreen` with viewfinder guide, leaf alignment targets, and Gemini API key configurator.
- [x] Built rich `DiagnosisResultScreen` featuring:
  - Circular Plant Health Score meter (0-100%).
  - Severity level & AI confidence percentage.
  - Observed symptoms breakdown.
  - Tabbed action plan: 🌿 Organic Remedies, 🧪 Chemical Sprays & Dosage, 🛡️ Farm Prevention.
- [x] Wired `FarmerCropDoctorTab` with live scan triggers and tap-to-inspect history cards.
- [x] Verified with unit & widget tests (`flutter test` -> 7/7 passed).
- [x] Verified zero issues (`flutter analyze` -> No issues found).

---

## ⛅ Phase 4: Smart Farming & GPS Mandi Market Intelligence ✅ COMPLETED
- [x] Integrated `geolocator` and `geocoding` packages.
- [x] Added `ACCESS_FINE_LOCATION` and `ACCESS_COARSE_LOCATION` in `AndroidManifest.xml`.
- [x] Built `LocationService` with reverse-geocoding into district and graceful offline fallback.
- [x] Built `WeatherService` with temperature, rain chance, humidity, and "Ideal Spraying Window" intelligence.
- [x] Built `MandiService` with Agmarknet Indian commodity pricing (Cotton, Paddy, Chilli, Maize, Turmeric, Tomato, Onion).
- [x] Built `MandiMarketScreen` featuring:
  - Real-time search and category filtering chips (Cash Crops, Cereals, Spices, Vegetables).
  - Nearest Mandi APMC yard indicator with GPS distance calculation.
  - Toggle between "Price per Quintal (100 kg)" and "Price per kg".
  - Price fluctuation badges (+₹150 $\uparrow$ / -₹200 $\downarrow$).
  - Multi-mandi comparison bottom sheet highlighting the highest profit market.
- [x] Wired live weather, location, and Mandi cards to `FarmerHomeTab`.
- [x] Verified with automated unit tests (`flutter test` -> 11/11 passed).
- [x] Verified zero issues (`flutter analyze` -> No issues found).

---

## 🛒 Phase 5: Farmer Marketplace & Razorpay Payments (NEXT UP)
- [ ] Farmer crop listing screen: upload crop photo, select category, set price per kg, enter available stock (kg).
- [ ] Customer catalog: search, category chips, stock check, real-time cart counter.
- [ ] Customer cart with dynamic subtotal, delivery charges, direct-farm discount, and net payable.
- [ ] Razorpay payment gateway integration (UPI, Debit/Credit cards, NetBanking).
- [ ] Cloud Firestore order creation lifecycle: `Pending` ➔ `Accepted` ➔ `In Transit` ➔ `Delivered`.
- [ ] Verification tests & static analysis.

---

## 🚚 Phase 6: Delivery Partner Module & Real-Time Tracking
- [ ] Delivery partner dashboard: available farm pickup & drop jobs.
- [ ] Order acceptance and Google Maps turn-by-turn navigation.
- [ ] OTP generation for customer and verification on delivery handover.
- [ ] Delivery earnings ledger & wallet payout tracking.

---

## 🎙️ Phase 7: AGRI MITRA Voice Assistant & Production Release
- [ ] Multilingual voice assistant (English, Telugu, Hindi).
- [ ] Speech-to-text and Text-to-speech for farmers with limited literacy.
- [ ] Read AI diagnosis results aloud and answer agricultural queries.
- [ ] Production Android release build (`flutter build apk` & `flutter build appbundle`).
