import 'dart:ui';

class SpeechService {
  static bool get isListening => false;
  static bool get isSupported => false;

  static void startListening({
    required Function(String text, bool isFinal) onResult,
    VoidCallback? onEnd,
    Function(String error)? onError,
    String lang = 'en-IN',
  }) {
    onError?.call('Speech recognition is active on web platform.');
  }

  static void stopListening() {}
}
