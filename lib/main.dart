import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/services/firebase_service.dart';
import 'core/services/local_storage_service.dart';
import 'features/auth/state/auth_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize offline local storage service
  final localStorage = await LocalStorageService.init();

  // Safely initialize Firebase (graceful fallback if google-services.json not yet placed)
  await FirebaseService.initialize();

  runApp(
    ProviderScope(
      overrides: [
        localStorageProvider.overrideWithValue(localStorage),
      ],
      child: const AgriApp(),
    ),
  );
}
