# 🔥 AGRI AI — Firebase Integration & Setup Guide

This guide explains how to connect your live Firebase project to AGRI AI for real Cloud Firestore database storage and live SMS Phone Authentication.

---

## 🛠️ Step 1: Create a Free Firebase Project

1. Go to the [Firebase Console](https://console.firebase.google.com/).
2. Click **Add project** (or **Create a project**).
3. Project Name: `agri-ai` (or any name you prefer).
4. Google Analytics: Optional (can be enabled or disabled).
5. Click **Create project**.

---

## 📱 Step 2: Register Android Application

1. On your Firebase Project Overview page, click the **Android** icon.
2. Enter the exact Android package name:
   ```text
   com.agriai.app.agri_ai
   ```
3. App nickname: `AGRI AI`
4. Debug signing certificate SHA-1 (Required for Phone SMS Auth):
   - In terminal, run:
     ```powershell
     cd android
     ./gradlew signingReport
     ```
   - Copy the `SHA1` fingerprint and paste it into Firebase.
5. Click **Register app**.

---

## 📥 Step 3: Download `google-services.json`

1. Download the generated `google-services.json` file from Firebase Console.
2. Move this file directly into your app's android directory:
   ```text
   d:\antigravity\ai crop disease detection system\android\app\google-services.json
   ```

---

## 🔑 Step 4: Enable Phone Authentication & Firestore

1. In Firebase Console, go to **Build** → **Authentication** → **Sign-in method**.
2. Click **Phone** and toggle **Enable**.
3. (Recommended for free testing): Under **Phone numbers for testing**, add:
   - Phone: `+91 9876543210`
   - Test OTP: `123456`
   *(This lets you test authentication without consuming real SMS quotas!)*
4. Go to **Build** → **Firestore Database**.
5. Click **Create database**, select **Start in test mode** for development, and choose a region close to India (e.g. `asia-south1` Mumbai).
6. Click **Enable**.

---

## 💡 Developer Note

AGRI AI includes an automatic **Hybrid Auth Layer**:
- **With `google-services.json`**: Connects to live Firebase Phone Auth and Cloud Firestore.
- **Without `google-services.json` (Local Mode)**: Automatically runs in offline developer mode so all screens, OTP modals, role switching, and dashboards function smoothly during development.

