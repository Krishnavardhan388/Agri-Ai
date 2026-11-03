import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'core/services/firebase_service.dart';
import 'core/services/local_storage_service.dart';
import 'features/auth/state/auth_provider.dart';
import 'features/crop_doctor/state/crop_doctor_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize shared preferences for persistent storage
  final prefs = await SharedPreferences.getInstance();
  final localStorage = LocalStorageService(prefs);

  // Safely initialize Firebase (graceful fallback if google-services.json not yet placed)
  await FirebaseService.initialize();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        localStorageProvider.overrideWithValue(localStorage),
      ],
      child: const AgriApp(),
    ),
  );
}
