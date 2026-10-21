import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';

class SpeechService {
  static html.SpeechRecognition? _recognition;
  static bool _isListening = false;
  static bool get isListening => _isListening;

  static bool get isSupported {
    try {
      return html.SpeechRecognition.supported;
    } catch (_) {
      return false;
    }
  }

  static void startListening({
    required Function(String text, bool isFinal) onResult,
    VoidCallback? onEnd,
    Function(String error)? onError,
    String lang = 'en-IN',
  }) {
    if (!isSupported) {
      onError?.call('Microphone speech recognition is not supported in this browser.');
      return;
    }

    try {
      stopListening();
      _recognition = html.SpeechRecognition();
      _recognition!.continuous = false;
      _recognition!.interimResults = true;
      _recognition!.lang = lang;

      _recognition!.onStart.listen((_) {
        _isListening = true;
      });

      _recognition!.onResult.listen((html.SpeechRecognitionEvent event) {
        try {
          final results = event.results;
          if (results == null || results.isEmpty) return;

          String fullTranscript = '';
          bool isFinal = false;

          for (final res in results) {
            final len = res.length;
            if (len != null && len > 0) {
              final item = res.item(0);
              if (item != null && item.transcript != null) {
                fullTranscript += item.transcript!;
              }
            }
            if (res.isFinal == true) {
              isFinal = true;
            }
          }

          if (fullTranscript.trim().isNotEmpty) {
            onResult(fullTranscript.trim(), isFinal);
          }
        } catch (e) {
          debugPrint('Error parsing speech event: $e');
        }
      });

      _recognition!.onEnd.listen((_) {
        _isListening = false;
        onEnd?.call();
      });

      _recognition!.onError.listen((html.SpeechRecognitionError error) {
        _isListening = false;
        onError?.call(error.message ?? 'Speech recognition error');
      });

      _recognition!.start();
    } catch (e) {
      _isListening = false;
      onError?.call(e.toString());
    }
  }

  static void stopListening() {
    try {
      if (_recognition != null) {
        _recognition!.stop();
        _recognition = null;
      }
    } catch (_) {}
    _isListening = false;
  }
}
