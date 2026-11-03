import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  static bool isInitialized = false;

  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      isInitialized = true;
      if (kDebugMode) {
        print('✅ Firebase initialized successfully.');
      }
    } catch (e) {
      isInitialized = false;
      if (kDebugMode) {
        print('ℹ️ Firebase not initialized with native config: $e');
        print('👉 Running in offline / local development mode.');
      }
    }
  }
}
