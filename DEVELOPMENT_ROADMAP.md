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

## 🔒 Phase 2: Firebase Integration & Role-Based Authentication (NEXT UP)
- [ ] Create Firebase Project & register Android package (`com.agriai.app.agri_ai`).
- [ ] Add `google-services.json` to `android/app/`.
- [ ] Implement Firebase Phone Authentication (with real SMS OTP).
- [ ] Cloud Firestore user profile synchronization (`users` collection with role tagging).
- [ ] Role-based route guard: auto-redirect on app restart based on active role.
- [ ] Verification tests.

---

## 🌿 Phase 3: AI Crop Doctor Module
- [ ] Camera & Gallery image picker integration with Android permissions.
- [ ] Crop disease image pre-processing (compression & aspect ratio).
- [ ] Google Gemini 1.5 Vision API integration for crop pathology.
- [ ] Diagnosis Result screen:
  - Disease name & scientific pathogen.
  - Confidence rating & plant health score (0-100).
  - Organic and chemical treatment recommendations.
  - Preventive farming advisories.
- [ ] Cloud Firestore diagnosis history logs with thumbnails.

---

## ⛅ Phase 4: Smart Farming & GPS Mandi Market Intelligence
- [ ] Real-time GPS location with `geolocator` and runtime permissions.
- [ ] Live weather forecast (temperature, humidity, rain probability, spraying advisory).
- [ ] Mandi Price Tracker (Agmarknet data for local agricultural markets).
- [ ] Nearby Mandi price comparison & historical trend graphs.

---

## 🛒 Phase 5: Farmer Marketplace & Razorpay Payments
- [ ] Farmer product listing screen: photo, category, price per kg, available stock.
- [ ] Customer catalog: search, category chips, stock check.
- [ ] Shopping cart with real-time bill calculation.
- [ ] Razorpay payment gateway integration (UPI, Debit/Credit cards, NetBanking).
- [ ] Firestore order collection lifecycle (`Pending` -> `Accepted` -> `In Transit` -> `Delivered`).

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
