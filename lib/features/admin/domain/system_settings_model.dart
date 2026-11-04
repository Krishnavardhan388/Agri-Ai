class SystemSettings {
  final String geminiModel;
  final bool isGeminiKeyConfigured;
  final String firestoreEnvironment;
  final String razorpayMode;
  final bool isRazorpayKeyConfigured;
  final double platformCommissionPercent;
  final String voiceEngine;
  final double defaultVoiceSpeechRate;
  final bool isAutoDispatchEnabled;
  final DateTime lastConfiguredAt;

  const SystemSettings({
    this.geminiModel = 'Gemini 1.5 Flash (Multimodal)',
    this.isGeminiKeyConfigured = true,
    this.firestoreEnvironment = 'Cloud Firestore (asia-south1 / Mumbai)',
    this.razorpayMode = 'Sandbox / Test Mode',
    this.isRazorpayKeyConfigured = true,
    this.platformCommissionPercent = 5.0,
    this.voiceEngine = 'Bhashini & Google Native Indian Regional Speech',
    this.defaultVoiceSpeechRate = 0.48,
    this.isAutoDispatchEnabled = true,
    required this.lastConfiguredAt,
  });

  SystemSettings copyWith({
    String? geminiModel,
    bool? isGeminiKeyConfigured,
    String? firestoreEnvironment,
    String? razorpayMode,
    bool? isRazorpayKeyConfigured,
    double? platformCommissionPercent,
    String? voiceEngine,
    double? defaultVoiceSpeechRate,
    bool? isAutoDispatchEnabled,
    DateTime? lastConfiguredAt,
  }) {
    return SystemSettings(
      geminiModel: geminiModel ?? this.geminiModel,
      isGeminiKeyConfigured: isGeminiKeyConfigured ?? this.isGeminiKeyConfigured,
      firestoreEnvironment: firestoreEnvironment ?? this.firestoreEnvironment,
      razorpayMode: razorpayMode ?? this.razorpayMode,
      isRazorpayKeyConfigured: isRazorpayKeyConfigured ?? this.isRazorpayKeyConfigured,
      platformCommissionPercent: platformCommissionPercent ?? this.platformCommissionPercent,
      voiceEngine: voiceEngine ?? this.voiceEngine,
      defaultVoiceSpeechRate: defaultVoiceSpeechRate ?? this.defaultVoiceSpeechRate,
      isAutoDispatchEnabled: isAutoDispatchEnabled ?? this.isAutoDispatchEnabled,
      lastConfiguredAt: lastConfiguredAt ?? this.lastConfiguredAt,
    );
  }
}
