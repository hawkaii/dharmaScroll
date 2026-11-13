import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';

/// Asks for the microphone. Kept apart from the voice session so the
/// explainer sheet and the permission prompt work the same for any session.
abstract interface class MicAccess {
  /// Shows the system prompt if needed. True when the mic may be used.
  Future<bool> request();
}

class DeviceMicAccess implements MicAccess {
  @override
  Future<bool> request() async {
    final AudioRecorder r = AudioRecorder();
    try {
      return await r.hasPermission().timeout(const Duration(seconds: 20));
    } catch (e) {
      debugPrint('MicAccess: $e');
      return false;
    } finally {
      try {
        await r.dispose();
      } catch (_) {}
    }
  }
}

/// For tests.
class FakeMicAccess implements MicAccess {
  FakeMicAccess({this.allow = true});

  final bool allow;
  int asked = 0;

  @override
  Future<bool> request() async {
    asked++;
    return allow;
  }
}

final Provider<MicAccess> micAccessProvider = Provider<MicAccess>(
  (Ref ref) => DeviceMicAccess(),
);
