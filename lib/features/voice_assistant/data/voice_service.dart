import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../domain/voice_language.dart';

class VoiceService {
  FlutterTts? _tts;
  SpeechToText? _speech;
  bool _speechInitialized = false;

  VoiceService({FlutterTts? tts, SpeechToText? speech}) {
    _tts = tts;
    _speech = speech;
  }

  FlutterTts get tts {
    _tts ??= FlutterTts();
    return _tts!;
  }

  SpeechToText get speech {
    _speech ??= SpeechToText();
    return _speech!;
  }

  Future<void> initTts() async {
    try {
      final t = tts;
      await t.setSpeechRate(0.48); // Slightly slower for clear rural understanding
      await t.setPitch(1.0);
      await t.setVolume(1.0);
      await t.awaitSpeakCompletion(true);
    } catch (_) {}
  }

  Future<bool> initSpeech() async {
    if (_speechInitialized) return true;
    try {
      final s = speech;
      _speechInitialized = await s.initialize(
        onError: (_) {},
        onStatus: (_) {},
      );
      return _speechInitialized;
    } catch (_) {
      _speechInitialized = false;
      return false;
    }
  }

  Future<bool> speak({
    required String text,
    required VoiceLanguage language,
    Function()? onComplete,
  }) async {
    try {
      final t = tts;
      await t.setLanguage(language.code);
      if (onComplete != null) {
        t.setCompletionHandler(onComplete);
      }
      final result = await t.speak(text);
      return result == 1;
    } catch (_) {
      // In tests or unsupported environments, invoke callback immediately
      onComplete?.call();
      return true;
    }
  }

  Future<void> stopSpeaking() async {
    try {
      await tts.stop();
    } catch (_) {}
  }

  Future<void> pauseSpeaking() async {
    try {
      await tts.pause();
    } catch (_) {}
  }

  Future<bool> startListening({
    required Function(String words) onResult,
    required VoiceLanguage language,
  }) async {
    final ready = await initSpeech();
    if (!ready) return false;

    try {
      await speech.listen(
        onResult: (result) {
          if (result.recognizedWords.isNotEmpty) {
            onResult(result.recognizedWords);
          }
        },
        listenOptions: SpeechListenOptions(
          localeId: language.code,
          listenFor: const Duration(seconds: 15),
          pauseFor: const Duration(seconds: 3),
        ),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> stopListening() async {
    try {
      if (speech.isListening) {
        await speech.stop();
      }
    } catch (_) {}
  }

  bool get isListening {
    try {
      return speech.isListening;
    } catch (_) {
      return false;
    }
  }
}
