import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_client.dart';
import '../services/local_storage_service.dart';

final localStorageProvider = Provider<LocalStorageService>((ref) {
  throw UnimplementedError('localStorageProvider must be initialized in main.dart');
});

final apiClientProvider = Provider<ApiClient>((ref) {
  LocalStorageService? storage;
  try {
    storage = ref.watch(localStorageProvider);
  } catch (_) {}
  return ApiClient(localStorage: storage);
});
