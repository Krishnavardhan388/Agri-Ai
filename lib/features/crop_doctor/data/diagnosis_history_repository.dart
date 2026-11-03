import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/firebase_service.dart';
import '../domain/crop_diagnosis_result.dart';

class DiagnosisHistoryRepository {
  static const String _keyHistory = 'crop_diagnosis_history_cache';

  final SharedPreferences _prefs;
  FirebaseFirestore? _firestore;

  DiagnosisHistoryRepository(this._prefs, {FirebaseFirestore? firestore}) {
    if (firestore != null) {
      _firestore = firestore;
    }
  }

  FirebaseFirestore? get firestore {
    if (_firestore != null) return _firestore;
    if (FirebaseService.isInitialized) {
      _firestore = FirebaseFirestore.instance;
      return _firestore;
    }
    return null;
  }

  Future<List<CropDiagnosisResult>> getDiagnosisHistory(String userId) async {
    // 1. Try local cache first for instant response
    final rawList = _prefs.getStringList(_keyHistory) ?? [];
    List<CropDiagnosisResult> cachedList = [];
    try {
      cachedList = rawList
          .map((item) => CropDiagnosisResult.fromMap(jsonDecode(item)))
          .toList();
    } catch (_) {}

    // 2. If online and Firebase initialized, fetch latest from Firestore
    final fs = firestore;
    if (FirebaseService.isInitialized && fs != null && userId.isNotEmpty) {
      try {
        final snapshot = await fs
            .collection('users')
            .doc(userId)
            .collection('diagnoses')
            .orderBy('diagnosedAt', descending: true)
            .limit(20)
            .get();

        if (snapshot.docs.isNotEmpty) {
          final cloudList = snapshot.docs
              .map((doc) => CropDiagnosisResult.fromMap(doc.data(), doc.id))
              .toList();

          // Update local cache
          await _saveListToCache(cloudList);
          return cloudList;
        }
      } catch (_) {}
    }

    return cachedList;
  }

  Future<void> saveDiagnosis(String userId, CropDiagnosisResult result) async {
    // Save to local cache
    final currentList = await getDiagnosisHistory(userId);
    final updatedList = [result, ...currentList.where((d) => d.id != result.id)];
    await _saveListToCache(updatedList);

    // Save to Firestore if available
    final fs = firestore;
    if (FirebaseService.isInitialized && fs != null && userId.isNotEmpty) {
      try {
        await fs
            .collection('users')
            .doc(userId)
            .collection('diagnoses')
            .doc(result.id)
            .set(result.toMap(), SetOptions(merge: true));
      } catch (_) {}
    }
  }

  Future<void> _saveListToCache(List<CropDiagnosisResult> list) async {
    final encoded = list.take(20).map((item) => jsonEncode(item.toMap())).toList();
    await _prefs.setStringList(_keyHistory, encoded);
  }
}

