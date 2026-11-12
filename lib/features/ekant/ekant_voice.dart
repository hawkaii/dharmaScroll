import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Speech to text for the room. Words are never recorded or stored.
abstract interface class EkantVoice {
  /// False when speech is not available here (no permission, no recogniser).
  Future<bool> start({
    required String localeId,
    required ValueChanged<String> onWords,
    required VoidCallback onDone,
  });

  Future<void> stop();
}

/// The platform recogniser, asked to stay on the phone (`onDevice`). Android
/// fails rather than send audio away when the offline pack is missing.
/// shortcut: on web, Chrome's recogniser may use the network; the web build
/// is a preview only.
class DeviceVoice implements EkantVoice {
  final SpeechToText _stt = SpeechToText();
  bool? _ready;

  @override
  Future<bool> start({
    required String localeId,
    required ValueChanged<String> onWords,
    required VoidCallback onDone,
  }) async {
    try {
      _ready ??= await _stt.initialize(
        onStatus: (String s) {
          if (s == SpeechToText.doneStatus) onDone();
        },
        onError: (_) => onDone(),
      );
      if (_ready != true) return false;
      await _stt.listen(
        onResult: (r) => onWords(r.recognizedWords),
        listenOptions: SpeechListenOptions(
          localeId: localeId,
          onDevice: !kIsWeb,
          partialResults: true,
          cancelOnError: true,
        ),
      );
      return true;
    } catch (e) {
      debugPrint('EkantVoice: $e');
      return false;
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _stt.stop();
    } catch (_) {}
  }
}

/// Null in tests: the mic button is hidden.
final Provider<EkantVoice?> ekantVoiceProvider = Provider<EkantVoice?>(
  (Ref ref) => DeviceVoice(),
);
