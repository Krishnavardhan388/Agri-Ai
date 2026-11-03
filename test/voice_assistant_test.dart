import 'package:flutter_test/flutter_test.dart';
import 'package:agri_ai/features/voice_assistant/domain/voice_language.dart';
import 'package:agri_ai/features/voice_assistant/data/voice_service.dart';
import 'package:agri_ai/features/voice_assistant/data/agri_ai_advisory_service.dart';
import 'package:agri_ai/features/voice_assistant/state/voice_assistant_provider.dart';
import 'package:agri_ai/features/crop_doctor/domain/crop_diagnosis_result.dart';

void main() {
  group('AGRI MITRA Multilingual Voice Assistant Tests', () {
    late AgriAiAdvisoryService advisoryService;
    late VoiceService voiceService;

    setUp(() {
      advisoryService = const AgriAiAdvisoryService();
      voiceService = VoiceService();
    });

    test('VoiceLanguage domain model codes and greetings', () {
      expect(VoiceLanguage.telugu.code, 'te-IN');
      expect(VoiceLanguage.telugu.nativeName, 'తెలుగు');
      expect(VoiceLanguage.telugu.greeting, contains('అగ్రి మిత్ర'));

      expect(VoiceLanguage.hindi.code, 'hi-IN');
      expect(VoiceLanguage.hindi.nativeName, 'हिन्दी');
      expect(VoiceLanguage.hindi.greeting, contains('एग्री मित्रा'));

      expect(VoiceLanguage.english.code, 'en-IN');
      expect(VoiceLanguage.english.nativeName, 'English');
      expect(VoiceLanguage.english.greeting, contains('AGRI MITRA'));
    });

    test('VoiceMessage serialization to and from Map', () {
      final msg = VoiceMessage(
        id: 'msg-01',
        text: 'వరిలో అగ్గి తెగులు మందు ఏమిటి?',
        isUser: true,
        timestamp: DateTime(2026, 5, 1, 10, 30),
        language: VoiceLanguage.telugu,
      );

      final map = msg.toMap();
      expect(map['id'], 'msg-01');
      expect(map['isUser'], true);
      expect(map['language'], 'telugu');

      final restored = VoiceMessage.fromMap(map);
      expect(restored.id, 'msg-01');
      expect(restored.text, 'వరిలో అగ్గి తెగులు మందు ఏమిటి?');
      expect(restored.language, VoiceLanguage.telugu);
    });

    test('AgriAiAdvisoryService generates multilingual advisories', () async {
      // 1. Telugu Tomato Leaf Curl Query
      final teluguTomato = await advisoryService.getAdvisoryResponse(
        userQuery: 'టొమాటో ఆకు ముడుత తెగులు',
        language: VoiceLanguage.telugu,
      );
      expect(teluguTomato, contains('టొమాటో'));
      expect(teluguTomato, contains('ఇమిడాక్లోప్రిడ్'));

      // 2. Hindi Cotton Pink Bollworm Query
      final hindiCotton = await advisoryService.getAdvisoryResponse(
        userQuery: 'कपास में गुलाबी सुंडी नियंत्रण',
        language: VoiceLanguage.hindi,
      );
      expect(hindiCotton, contains('कपास'));
      expect(hindiCotton, contains('फेरोमोन'));

      // 3. English Paddy Blast Query
      final englishPaddy = await advisoryService.getAdvisoryResponse(
        userQuery: 'Paddy blast disease control',
        language: VoiceLanguage.english,
      );
      expect(englishPaddy, contains('Tricyclazole'));

      // 4. Fertilizer Query
      final fertilizerAdvisory = await advisoryService.getAdvisoryResponse(
        userQuery: 'Urea application dosage',
        language: VoiceLanguage.english,
      );
      expect(fertilizerAdvisory, contains('Urea'));
      expect(fertilizerAdvisory, contains('3 equal doses'));

      // 5. Mandi Market Rate Query
      final mandiAdvisory = await advisoryService.getAdvisoryResponse(
        userQuery: 'Today cotton mandi price',
        language: VoiceLanguage.english,
      );
      expect(mandiAdvisory, contains('7,450'));
    });

    test('VoiceAssistantNotifier state, language switching, and Q&A flow', () async {
      final notifier = VoiceAssistantNotifier(
        voiceService: voiceService,
        advisoryService: advisoryService,
      );

      // Initial state has Telugu greeting
      expect(notifier.state.currentLanguage, VoiceLanguage.telugu);
      expect(notifier.state.messages.isNotEmpty, true);
      expect(notifier.state.messages.first.text, contains('అగ్రి మిత్ర'));

      // Switch language to Hindi
      await notifier.setLanguage(VoiceLanguage.hindi);
      expect(notifier.state.currentLanguage, VoiceLanguage.hindi);

      // Send a query
      await notifier.sendQuery('कपास में सुंडी');
      expect(notifier.state.messages.length >= 3, true);

      final lastMsg = notifier.state.messages.last;
      expect(lastMsg.isUser, false);
      expect(lastMsg.language, VoiceLanguage.hindi);
      expect(lastMsg.text, contains('कपास'));
    });

    test('VoiceAssistantNotifier readCropDiagnosisAloud converts pathology report', () async {
      final notifier = VoiceAssistantNotifier(
        voiceService: voiceService,
        advisoryService: advisoryService,
      );

      final dummyDiagnosis = CropDiagnosisResult(
        id: 'diag-test-1',
        cropName: 'Cotton (పత్తి)',
        diseaseName: 'Pink Bollworm',
        scientificName: 'Pectinophora gossypiella',
        healthScore: 45,
        severity: 'Moderate',
        confidence: 0.94,
        symptoms: ['Boll rots', 'Premature opening'],
        organicTreatments: ['Install 8 Pheromone traps per acre', 'Spray Neem seed kernel extract 5%'],
        chemicalTreatments: ['Profenofos 50% EC @ 2 ml/L water'],
        preventiveMeasures: ['Deep summer ploughing'],
        diagnosedAt: DateTime.now(),
      );

      await notifier.readCropDiagnosisAloud(dummyDiagnosis);
      // Verify state was set to speaking during execution
      expect(notifier.state.currentLanguage, VoiceLanguage.telugu);
    });
  });
}
