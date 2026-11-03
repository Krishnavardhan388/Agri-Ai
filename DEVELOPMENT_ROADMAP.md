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

## 🛒 Phase 5: Farmer Marketplace & Razorpay Payments ✅ COMPLETED
- [x] Integrated `razorpay_flutter` for Indian online payments (UPI, Cards, NetBanking).
- [x] Implemented `ProductModel`, `CartItem`, and `OrderModel` domain entities.
- [x] Built `ProductRepository` with Cloud Firestore persistence and initial catalog fallback.
- [x] Built `OrderRepository` for tracking order lifecycle states (`pending` ➔ `accepted` ➔ `packed` ➔ `inTransit` ➔ `delivered`).
- [x] Built `RazorpayPaymentService` with payment callbacks and seamless testing simulation.
- [x] Implemented `AddProductScreen` for farmers to register new harvest produce (price per kg, stock in kg, organic toggle).
- [x] Wired `FarmerMarketplaceTab` with live product counts, total stock in kg, and add-crop action.
- [x] Wired `CustomerHomeTab` with live catalog, search, category filters, and real-time cart badge.
- [x] Wired `CustomerCartTab` with dynamic bill calculations (15% direct farm discount, delivery fee) and Razorpay checkout.
- [x] Wired `CustomerOrdersTab` with dynamic progress stepper and 4-digit handover delivery OTP.
- [x] Wired `FarmerOrdersTab` with one-tap "Pack Harvest" action.
- [x] Verified with unit & widget tests (`flutter test` -> 14/14 passed).
- [x] Verified zero issues (`flutter analyze` -> No issues found).

---

## 🚚 Phase 6: Delivery Partner Module & Real-Time Tracking ✅ COMPLETED
- [x] Integrated `url_launcher` for external Google Maps route intents and direct phone dialer.
- [x] Added `queries` in `AndroidManifest.xml` for `https`, `geo`, and `tel` intent schemes.
- [x] Implemented `DeliveryTask` domain model (`id`, `farmAddress`, `customerAddress`, `tripPayout`, `requiredOtp`, `status`).
- [x] Implemented `DeliveryWalletRecord` for tracking transaction credits and withdrawal debits.
- [x] Built `MapNavigationService` supporting turnkey Google Maps turn-by-turn navigation and direct phone calling.
- [x] Built `DeliveryRepository` managing active trips, nearby available farm pickups, and persistent wallet transactions.
- [x] Built `DeliveryNotifier` with Riverpod `StateNotifierProvider` managing online status, trip lifecycle, and wallet payouts.
- [x] Upgraded `DeliveryTasksTab` featuring:
  - Online/Offline toggle with interactive availability status.
  - Active Trip Card with stage indicators ("PICKUP PENDING" ➔ "IN TRANSIT").
  - One-tap "Mark Harvest Picked Up from Farm".
  - Turn-by-turn Google Maps navigation to Farm & Customer.
  - Direct calling buttons for Farmer and Customer.
  - Doorstep 4-digit OTP handover verification dialog with instant wallet credit.
  - Available Farm Orders list with "Accept Trip" action.
- [x] Upgraded `DeliveryEarningsTab` featuring:
  - Dynamic wallet balance banner and today's earnings sum.
  - Trips completed counter and weekly rating.
  - Interactive "Withdraw to Bank / UPI" bottom sheet.
  - Live ledger history showing credits and debits.
- [x] Upgraded `DeliveryProfileTab` with driver vehicle registration, RC/insurance specs, linked bank account, and 24x7 helpline.
- [x] Verified with automated unit tests (`test/delivery_test.dart` -> 19/19 tests passed).
- [x] Verified zero issues (`flutter analyze` -> No issues found).

---

## 🎙️ Phase 7: AGRI MITRA Voice Assistant & Production Release (NEXT UP)
- [ ] Multilingual voice assistant (English, Telugu, Hindi).
- [ ] Speech-to-text and Text-to-speech for farmers with limited literacy.
- [ ] Read AI diagnosis results aloud and answer agricultural queries.
- [ ] Production Android release build (`flutter build apk` & `flutter build appbundle`).
