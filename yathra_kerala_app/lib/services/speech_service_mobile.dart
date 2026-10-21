import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  static final stt.SpeechToText _speech = stt.SpeechToText();
  static bool _isInitialized = false;

  static bool get isListening => _speech.isListening;
  static bool get isSupported => true;

  static Future<bool> init() async {
    if (!_isInitialized) {
      _isInitialized = await _speech.initialize(
        onError: (val) => debugPrint('SpeechToText error: ${val.errorMsg}'),
        onStatus: (val) => debugPrint('SpeechToText status: $val'),
      );
    }
    return _isInitialized;
  }

  static void startListening({
    required Function(String text, bool isFinal) onResult,
    VoidCallback? onEnd,
    Function(String error)? onError,
    String lang = 'en-IN',
  }) async {
    try {
      bool available = await init();
      if (!available) {
        onError?.call('Microphone permission or speech recognition not available.');
        return;
      }
      await _speech.listen(
        onResult: (result) {
          onResult(result.recognizedWords, result.finalResult);
          if (result.finalResult) {
            onEnd?.call();
          }
        },
        listenOptions: stt.SpeechListenOptions(
          localeId: lang,
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 4),
          cancelOnError: true,
        ),
      );
    } catch (e) {
      onError?.call(e.toString());
    }
  }

  static void stopListening() {
    try {
      if (_speech.isListening) {
        _speech.stop();
      }
    } catch (_) {}
  }
}
