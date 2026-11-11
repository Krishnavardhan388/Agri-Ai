import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/api_client.dart';
import '../domain/crop_diagnosis_result.dart';

class DiagnosisHistoryRepository {
  static const String _keyHistory = 'crop_diagnosis_history_cache';

  final SharedPreferences _prefs;
  final ApiClient _apiClient;

  DiagnosisHistoryRepository(this._prefs, {ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<List<CropDiagnosisResult>> getDiagnosisHistory(String userId) async {
    final rawList = _prefs.getStringList(_keyHistory) ?? [];
    List<CropDiagnosisResult> cachedList = [];
    try {
      cachedList = rawList
          .map((item) => CropDiagnosisResult.fromMap(jsonDecode(item)))
          .toList();
    } catch (_) {}

    if (userId.isNotEmpty) {
      try {
        final resp = await _apiClient.get(
          '/api/v1/crop-doctor/history',
          queryParameters: {'user_id': userId},
        );
        if (resp is List && resp.isNotEmpty) {
          final cloudList = resp.whereType<Map>().map((doc) {
            return CropDiagnosisResult(
              id: doc['id']?.toString() ?? '',
              cropName: doc['crop_name']?.toString() ?? 'Crop',
              diseaseName: doc['disease_name']?.toString() ?? 'Unknown',
              scientificName: doc['scientific_name']?.toString() ?? '',
              healthScore: (doc['health_score'] as num?)?.toInt() ?? 75,
              severity: doc['severity']?.toString() ?? 'Moderate',
              confidence: (doc['confidence'] as num?)?.toDouble() ?? 0.9,
              symptoms: List<String>.from(doc['symptoms'] ?? const []),
              organicTreatments: List<String>.from(doc['organic_treatments'] ?? const []),
              chemicalTreatments: List<String>.from(doc['chemical_treatments'] ?? const []),
              preventiveMeasures: List<String>.from(doc['preventive_measures'] ?? const []),
              diagnosedAt: DateTime.tryParse(doc['diagnosed_at']?.toString() ?? '') ?? DateTime.now(),
            );
          }).toList();
          await _saveListToCache(cloudList);
          return cloudList;
        }
      } catch (_) {}
    }

    return cachedList;
  }

  Future<void> saveDiagnosis(String userId, CropDiagnosisResult result) async {
    final currentList = await getDiagnosisHistory(userId);
    final updatedList = [result, ...currentList.where((d) => d.id != result.id)];
    await _saveListToCache(updatedList);

    if (userId.isNotEmpty) {
      try {
        await _apiClient.post(
          '/api/v1/crop-doctor/diagnose',
          body: {
            'crop_name': result.cropName,
            'disease_name': result.diseaseName,
            'scientific_name': result.scientificName,
            'health_score': result.healthScore,
            'severity': result.severity,
            'confidence': result.confidence,
            'symptoms': result.symptoms,
            'organic_treatments': result.organicTreatments,
            'chemical_treatments': result.chemicalTreatments,
            'preventive_measures': result.preventiveMeasures,
            'farmer_id': userId,
          },
        );
      } catch (_) {}
    }
  }

  Future<void> _saveListToCache(List<CropDiagnosisResult> list) async {
    final encoded = list.take(20).map((item) => jsonEncode(item.toMap())).toList();
    await _prefs.setStringList(_keyHistory, encoded);
  }
}
