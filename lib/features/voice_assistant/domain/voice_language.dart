enum VoiceLanguage {
  telugu(
    code: 'te-IN',
    displayName: 'Telugu',
    nativeName: 'తెలుగు',
    greeting: 'నమస్కారం రైతు సోదరులారా! నేను అగ్రి మిత్ర. మీకు ఏ విధంగా సహాయపడగలను?',
  ),
  hindi(
    code: 'hi-IN',
    displayName: 'Hindi',
    nativeName: 'हिन्दी',
    greeting: 'नमस्ते किसान भाई! मैं एग्री मित्रा हूँ। मैं आपकी क्या सहायता कर सकता हूँ?',
  ),
  english(
    code: 'en-IN',
    displayName: 'English',
    nativeName: 'English',
    greeting: 'Hello Kisan Brother! I am AGRI MITRA. How can I assist with your crops today?',
  );

  final String code;
  final String displayName;
  final String nativeName;
  final String greeting;

  const VoiceLanguage({
    required this.code,
    required this.displayName,
    required this.nativeName,
    required this.greeting,
  });
}

class VoiceMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final VoiceLanguage language;

  const VoiceMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    required this.language,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'language': language.name,
    };
  }

  factory VoiceMessage.fromMap(Map<String, dynamic> map) {
    return VoiceMessage(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      isUser: map['isUser'] ?? false,
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp']) ?? DateTime.now()
          : DateTime.now(),
      language: VoiceLanguage.values.firstWhere(
        (e) => e.name == map['language'],
        orElse: () => VoiceLanguage.telugu,
      ),
    );
  }
}

