import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../crop_doctor/domain/crop_diagnosis_result.dart';
import '../data/agri_ai_advisory_service.dart';
import '../data/voice_service.dart';
import '../domain/voice_language.dart';

class VoiceAssistantState {
  final VoiceLanguage currentLanguage;
  final bool isListening;
  final bool isSpeaking;
  final bool isProcessing;
  final String recognizedWords;
  final List<VoiceMessage> messages;
  final String? activePlayingMessageId;
  final String? errorMessage;

  const VoiceAssistantState({
    this.currentLanguage = VoiceLanguage.telugu,
    this.isListening = false,
    this.isSpeaking = false,
    this.isProcessing = false,
    this.recognizedWords = '',
    this.messages = const [],
    this.activePlayingMessageId,
    this.errorMessage,
  });

  VoiceAssistantState copyWith({
    VoiceLanguage? currentLanguage,
    bool? isListening,
    bool? isSpeaking,
    bool? isProcessing,
    String? recognizedWords,
    List<VoiceMessage>? messages,
    String? activePlayingMessageId,
    String? errorMessage,
  }) {
    return VoiceAssistantState(
      currentLanguage: currentLanguage ?? this.currentLanguage,
      isListening: isListening ?? this.isListening,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      isProcessing: isProcessing ?? this.isProcessing,
      recognizedWords: recognizedWords ?? this.recognizedWords,
      messages: messages ?? this.messages,
      activePlayingMessageId: activePlayingMessageId,
      errorMessage: errorMessage,
    );
  }
}

class VoiceAssistantNotifier extends StateNotifier<VoiceAssistantState> {
  final VoiceService voiceService;
  final AgriAiAdvisoryService advisoryService;

  VoiceAssistantNotifier({
    required this.voiceService,
    required this.advisoryService,
  }) : super(const VoiceAssistantState()) {
    _initInitialGreeting();
  }

  void _initInitialGreeting() {
    final greeting = state.currentLanguage.greeting;
    final initialMessage = VoiceMessage(
      id: 'greeting-01',
      text: greeting,
      isUser: false,
      timestamp: DateTime.now(),
      language: state.currentLanguage,
    );
    state = state.copyWith(messages: [initialMessage]);
  }

  Future<void> setLanguage(VoiceLanguage language) async {
    await stopSpeaking();
    final greetingMessage = VoiceMessage(
      id: 'lang-${DateTime.now().millisecondsSinceEpoch}',
      text: language.greeting,
      isUser: false,
      timestamp: DateTime.now(),
      language: language,
    );

    state = state.copyWith(
      currentLanguage: language,
      messages: [...state.messages, greetingMessage],
      activePlayingMessageId: greetingMessage.id,
      isSpeaking: true,
    );

    await voiceService.speak(
      text: language.greeting,
      language: language,
      onComplete: () {
        if (mounted) {
          state = state.copyWith(isSpeaking: false, activePlayingMessageId: null);
        }
      },
    );
  }

  Future<void> toggleListening() async {
    if (state.isListening) {
      await stopListening();
      if (state.recognizedWords.trim().isNotEmpty) {
        await sendQuery(state.recognizedWords);
      }
    } else {
      await stopSpeaking();
      state = state.copyWith(isListening: true, recognizedWords: '');

      final started = await voiceService.startListening(
        language: state.currentLanguage,
        onResult: (words) {
          state = state.copyWith(recognizedWords: words);
        },
      );

      if (!started) {
        state = state.copyWith(
          isListening: false,
          errorMessage: 'Microphone not available or permission denied.',
        );
      }
    }
  }

  Future<void> stopListening() async {
    await voiceService.stopListening();
    state = state.copyWith(isListening: false);
  }

  Future<void> sendQuery(String queryText) async {
    final clean = queryText.trim();
    if (clean.isEmpty) return;

    await stopSpeaking();

    final userMsg = VoiceMessage(
      id: 'usr-${DateTime.now().millisecondsSinceEpoch}',
      text: clean,
      isUser: true,
      timestamp: DateTime.now(),
      language: state.currentLanguage,
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isProcessing: true,
      recognizedWords: '',
      isListening: false,
    );

    try {
      final answer = await advisoryService.getAdvisoryResponse(
        userQuery: clean,
        language: state.currentLanguage,
      );

      final assistantMsg = VoiceMessage(
        id: 'ast-${DateTime.now().millisecondsSinceEpoch}',
        text: answer,
        isUser: false,
        timestamp: DateTime.now(),
        language: state.currentLanguage,
      );

      state = state.copyWith(
        messages: [...state.messages, assistantMsg],
        isProcessing: false,
        isSpeaking: true,
        activePlayingMessageId: assistantMsg.id,
      );

      await voiceService.speak(
        text: answer,
        language: state.currentLanguage,
        onComplete: () {
          if (mounted) {
            state = state.copyWith(isSpeaking: false, activePlayingMessageId: null);
          }
        },
      );
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        errorMessage: 'Unable to get voice advisory: $e',
      );
    }
  }

  Future<void> speakMessage(String text, {required String messageId}) async {
    if (state.isSpeaking && state.activePlayingMessageId == messageId) {
      await stopSpeaking();
      return;
    }

    await stopSpeaking();
    state = state.copyWith(
      isSpeaking: true,
      activePlayingMessageId: messageId,
    );

    await voiceService.speak(
      text: text,
      language: state.currentLanguage,
      onComplete: () {
        if (mounted) {
          state = state.copyWith(isSpeaking: false, activePlayingMessageId: null);
        }
      },
    );
  }

  Future<void> stopSpeaking() async {
    await voiceService.stopSpeaking();
    state = state.copyWith(isSpeaking: false, activePlayingMessageId: null);
  }

  Future<void> readCropDiagnosisAloud(CropDiagnosisResult diagnosis) async {
    await stopSpeaking();

    String speechText;
    switch (state.currentLanguage) {
      case VoiceLanguage.telugu:
        speechText =
            'పంట పేరు: ${diagnosis.cropName}. '
            'రోగ నిర్ధారణ: ${diagnosis.diseaseName}. '
            'మొక్క ఆరోగ్య స్కోర్: ${diagnosis.healthScore} శాతం. '
            'తీవ్రత: ${diagnosis.severity}. '
            'సిఫార్సు చేసిన సేంద్రీయ నివారణ: ${diagnosis.organicTreatments.isNotEmpty ? diagnosis.organicTreatments.first : "వేప నూనె పిచికారీ"}. '
            'రసాయన మందు: ${diagnosis.chemicalTreatments.isNotEmpty ? diagnosis.chemicalTreatments.first : "తగిన శిలీంధ్ర నాశిని వాడండి"}. '
            'నివారణ చర్య: ${diagnosis.preventiveMeasures.isNotEmpty ? diagnosis.preventiveMeasures.first : "పొలంలో నీరు నిలువ లేకుండా చూడండి"}.';
        break;
      case VoiceLanguage.hindi:
        speechText =
            'फसल का नाम: ${diagnosis.cropName}। '
            'रोग की पहचान: ${diagnosis.diseaseName}। '
            'पौधे का स्वास्थ्य स्कोर: ${diagnosis.healthScore} प्रतिशत। '
            'गंभीरता: ${diagnosis.severity}। '
            'जैविक उपचार: ${diagnosis.organicTreatments.isNotEmpty ? diagnosis.organicTreatments.first : "नीम का तेल छिड़कें"}। '
            'रासायनिक नियंत्रण: ${diagnosis.chemicalTreatments.isNotEmpty ? diagnosis.chemicalTreatments.first : "उचित फफूंदनाशक का प्रयोग करें"}। '
            'निवारक उपाय: ${diagnosis.preventiveMeasures.isNotEmpty ? diagnosis.preventiveMeasures.first : "खेत से जलभराव निकालें"}।';
        break;
      case VoiceLanguage.english:
        speechText =
            'Crop: ${diagnosis.cropName}. '
            'Diagnosis: ${diagnosis.diseaseName}. '
            'Plant health score: ${diagnosis.healthScore} percent. '
            'Severity: ${diagnosis.severity}. '
            'Recommended organic remedy: ${diagnosis.organicTreatments.isNotEmpty ? diagnosis.organicTreatments.first : "Neem oil spray"}. '
            'Chemical control: ${diagnosis.chemicalTreatments.isNotEmpty ? diagnosis.chemicalTreatments.first : "Recommended fungicide spray"}. '
            'Preventive action: ${diagnosis.preventiveMeasures.isNotEmpty ? diagnosis.preventiveMeasures.first : "Ensure good farm drainage"}.';
        break;
    }

    state = state.copyWith(isSpeaking: true);

    await voiceService.speak(
      text: speechText,
      language: state.currentLanguage,
      onComplete: () {
        if (mounted) {
          state = state.copyWith(isSpeaking: false);
        }
      },
    );
  }
}

final voiceServiceProvider = Provider<VoiceService>((ref) {
  return VoiceService();
});

final agriAiAdvisoryServiceProvider = Provider<AgriAiAdvisoryService>((ref) {
  return const AgriAiAdvisoryService();
});

final voiceAssistantProvider =
    StateNotifierProvider<VoiceAssistantNotifier, VoiceAssistantState>((ref) {
  final voiceService = ref.watch(voiceServiceProvider);
  final advisoryService = ref.watch(agriAiAdvisoryServiceProvider);
  return VoiceAssistantNotifier(
    voiceService: voiceService,
    advisoryService: advisoryService,
  );
});
