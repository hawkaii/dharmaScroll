import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Spoken words to text, on the device's own recogniser. Every call is
/// guarded: no recogniser, no permission or no network just means
/// "not available", and Mann Darpan falls back to a voice note and typing.
class SpeechInput {
  static SpeechInput instance = SpeechInput();

  final SpeechToText _stt = SpeechToText();
  bool? _ready;

  Future<bool> available() async {
    if (_ready != null) return _ready!;
    try {
      _ready = await _stt.initialize(
        onError: (e) => debugPrint('SpeechInput error: ${e.errorMsg}'),
      );
    } catch (e) {
      debugPrint('SpeechInput.initialize failed: $e');
      _ready = false;
    }
    return _ready!;
  }

  /// Streams the words heard so far to [onWords] until [stop].
  Future<bool> start(String localeId, ValueChanged<String> onWords) async {
    if (!await available()) return false;
    try {
      await _stt.listen(
        onResult: (SpeechRecognitionResult r) => onWords(r.recognizedWords),
        listenOptions: SpeechListenOptions(
          localeId: localeId,
          listenFor: const Duration(minutes: 2),
          pauseFor: const Duration(seconds: 6),
          partialResults: true,
          cancelOnError: true,
          listenMode: ListenMode.dictation,
        ),
      );
      return true;
    } catch (e) {
      debugPrint('SpeechInput.start failed: $e');
      return false;
    }
  }

  Future<void> stop() async {
    try {
      await _stt.stop();
    } catch (e) {
      debugPrint('SpeechInput.stop failed: $e');
    }
  }
}
