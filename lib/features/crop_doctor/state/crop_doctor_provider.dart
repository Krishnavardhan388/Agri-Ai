import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/state/auth_provider.dart';
import '../data/diagnosis_history_repository.dart';
import '../data/gemini_crop_doctor_service.dart';
import '../domain/crop_diagnosis_result.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});

final geminiServiceProvider = Provider<GeminiCropDoctorService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return GeminiCropDoctorService(prefs: prefs);
});

final diagnosisHistoryRepositoryProvider = Provider<DiagnosisHistoryRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return DiagnosisHistoryRepository(prefs);
});

class CropDoctorState {
  final bool isAnalyzing;
  final CropDiagnosisResult? currentResult;
  final String? selectedImagePath;
  final List<CropDiagnosisResult> history;
  final String? errorMessage;

  const CropDoctorState({
    this.isAnalyzing = false,
    this.currentResult,
    this.selectedImagePath,
    this.history = const [],
    this.errorMessage,
  });

  CropDoctorState copyWith({
    bool? isAnalyzing,
    CropDiagnosisResult? currentResult,
    String? selectedImagePath,
    List<CropDiagnosisResult>? history,
    String? errorMessage,
  }) {
    return CropDoctorState(
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      currentResult: currentResult ?? this.currentResult,
      selectedImagePath: selectedImagePath ?? this.selectedImagePath,
      history: history ?? this.history,
      errorMessage: errorMessage,
    );
  }
}

class CropDoctorNotifier extends StateNotifier<CropDoctorState> {
  final GeminiCropDoctorService geminiService;
  final DiagnosisHistoryRepository historyRepo;
  final ImagePicker _picker;

  CropDoctorNotifier({
    required this.geminiService,
    required this.historyRepo,
    ImagePicker? picker,
  })  : _picker = picker ?? ImagePicker(),
        super(const CropDoctorState());

  Future<void> loadHistory(String userId) async {
    final list = await historyRepo.getDiagnosisHistory(userId);
    state = state.copyWith(history: list);
  }

  Future<CropDiagnosisResult?> pickAndAnalyze({
    required ImageSource source,
    required String userId,
  }) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 85,
      );

      if (file == null) return null;

      state = state.copyWith(
        isAnalyzing: true,
        selectedImagePath: file.path,
        errorMessage: null,
      );

      final bytes = await file.readAsBytes();
      final result = await geminiService.diagnoseCropImage(
        imageBytes: bytes,
        localImagePath: file.path,
      );

      // Save to history repository
      await historyRepo.saveDiagnosis(userId, result);
      final updatedHistory = [result, ...state.history.where((d) => d.id != result.id)];

      state = state.copyWith(
        isAnalyzing: false,
        currentResult: result,
        history: updatedHistory,
      );

      return result;
    } catch (e) {
      state = state.copyWith(
        isAnalyzing: false,
        errorMessage: 'Image analysis error: ${e.toString()}',
      );
      return null;
    }
  }

  void clearCurrentResult() {
    state = state.copyWith(currentResult: null, selectedImagePath: null);
  }
}

final cropDoctorProvider =
    StateNotifierProvider<CropDoctorNotifier, CropDoctorState>((ref) {
  final geminiService = ref.watch(geminiServiceProvider);
  final historyRepo = ref.watch(diagnosisHistoryRepositoryProvider);
  final auth = ref.watch(authProvider);

  final notifier = CropDoctorNotifier(
    geminiService: geminiService,
    historyRepo: historyRepo,
  );

  // Auto-load history for logged-in user
  final uid = auth.user?.uid ?? 'guest-farmer';
  notifier.loadHistory(uid);

  return notifier;
});
