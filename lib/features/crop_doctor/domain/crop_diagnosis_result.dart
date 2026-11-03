class CropDiagnosisResult {
  final String id;
  final String cropName;
  final String diseaseName;
  final String scientificName;
  final int healthScore;
  final String severity;
  final double confidence;
  final List<String> symptoms;
  final List<String> organicTreatments;
  final List<String> chemicalTreatments;
  final List<String> preventiveMeasures;
  final DateTime diagnosedAt;
  final String? imagePath;

  const CropDiagnosisResult({
    required this.id,
    required this.cropName,
    required this.diseaseName,
    required this.scientificName,
    required this.healthScore,
    required this.severity,
    required this.confidence,
    required this.symptoms,
    required this.organicTreatments,
    required this.chemicalTreatments,
    required this.preventiveMeasures,
    required this.diagnosedAt,
    this.imagePath,
  });

  bool get isHealthy => healthScore >= 85 || diseaseName.toLowerCase().contains('healthy');

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cropName': cropName,
      'diseaseName': diseaseName,
      'scientificName': scientificName,
      'healthScore': healthScore,
      'severity': severity,
      'confidence': confidence,
      'symptoms': symptoms,
      'organicTreatments': organicTreatments,
      'chemicalTreatments': chemicalTreatments,
      'preventiveMeasures': preventiveMeasures,
      'diagnosedAt': diagnosedAt.toIso8601String(),
      'imagePath': imagePath,
    };
  }

  factory CropDiagnosisResult.fromMap(Map<String, dynamic> map, [String? docId]) {
    return CropDiagnosisResult(
      id: docId ?? map['id'] ?? 'diag-${DateTime.now().millisecondsSinceEpoch}',
      cropName: map['cropName'] ?? 'Unknown Crop',
      diseaseName: map['diseaseName'] ?? 'Undetermined Condition',
      scientificName: map['scientificName'] ?? 'N/A',
      healthScore: (map['healthScore'] as num?)?.toInt() ?? 70,
      severity: map['severity'] ?? 'Moderate',
      confidence: (map['confidence'] as num?)?.toDouble() ?? 0.85,
      symptoms: List<String>.from(map['symptoms'] ?? []),
      organicTreatments: List<String>.from(map['organicTreatments'] ?? []),
      chemicalTreatments: List<String>.from(map['chemicalTreatments'] ?? []),
      preventiveMeasures: List<String>.from(map['preventiveMeasures'] ?? []),
      diagnosedAt: map['diagnosedAt'] != null
          ? DateTime.tryParse(map['diagnosedAt']) ?? DateTime.now()
          : DateTime.now(),
      imagePath: map['imagePath'],
    );
  }
}

