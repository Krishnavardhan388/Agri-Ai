import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agri_ai/features/crop_doctor/data/diagnosis_history_repository.dart';
import 'package:agri_ai/features/crop_doctor/data/gemini_crop_doctor_service.dart';
import 'package:agri_ai/features/crop_doctor/domain/crop_diagnosis_result.dart';

void main() {
  late SharedPreferences prefs;
  late GeminiCropDoctorService geminiService;
  late DiagnosisHistoryRepository historyRepo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    geminiService = GeminiCropDoctorService(prefs: prefs);
    historyRepo = DiagnosisHistoryRepository(prefs);
  });

  test('GeminiCropDoctorService saves and retrieves API key', () async {
    expect(geminiService.getApiKey(), isEmpty);
    await geminiService.saveApiKey('test-key-12345');
    expect(geminiService.getApiKey(), 'test-key-12345');
  });

  test('GeminiCropDoctorService generates smart agricultural diagnosis', () async {
    final dummyBytes = Uint8List.fromList([0, 1, 2, 3]);
    final result = await geminiService.diagnoseCropImage(
      imageBytes: dummyBytes,
      localImagePath: '/test/leaf.jpg',
    );

    expect(result.cropName, isNotEmpty);
    expect(result.diseaseName, isNotEmpty);
    expect(result.healthScore, inInclusiveRange(0, 100));
    expect(result.confidence, inInclusiveRange(0.0, 1.0));
    expect(result.organicTreatments, isNotEmpty);
    expect(result.chemicalTreatments, isNotEmpty);
    expect(result.preventiveMeasures, isNotEmpty);
  });

  test('DiagnosisHistoryRepository persists and retrieves scan history', () async {
    final sampleResult = CropDiagnosisResult(
      id: 'test-scan-1',
      cropName: 'Tomato',
      diseaseName: 'Early Blight',
      scientificName: 'Alternaria solani',
      healthScore: 65,
      severity: 'Moderate',
      confidence: 0.91,
      symptoms: ['Brown target-like concentric rings'],
      organicTreatments: ['Neem oil spray (5ml/L)'],
      chemicalTreatments: ['Mancozeb 75% WP @ 2.5g/L'],
      preventiveMeasures: ['Drip irrigation'],
      diagnosedAt: DateTime.now(),
      imagePath: '/path/to/image.jpg',
    );

    await historyRepo.saveDiagnosis('farmer-user-1', sampleResult);
    final history = await historyRepo.getDiagnosisHistory('farmer-user-1');

    expect(history.length, 1);
    expect(history.first.cropName, 'Tomato');
    expect(history.first.diseaseName, 'Early Blight');
    expect(history.first.healthScore, 65);
  });
}
