import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// The four platform patterns Flutter exposes. Swapped for a fake in tests.
abstract class HapticBackend {
  Future<void> selection();
  Future<void> light();
  Future<void> medium();
}

class SystemHapticBackend implements HapticBackend {
  const SystemHapticBackend();
  @override
  Future<void> selection() => HapticFeedback.selectionClick();
  @override
  Future<void> light() => HapticFeedback.lightImpact();
  @override
  Future<void> medium() => HapticFeedback.mediumImpact();
}

/// Every haptic in the app, in one place (HANDOFF section 9).
///
/// Platform patterns only (`HapticFeedback`): no extra package, no VIBRATE
/// permission. Composite patterns (success, crescendo) are timed sequences of
/// those. On web every call is a no-op, because `navigator.vibrate` needs a
/// user activation and logs a console warning without one.
/// shortcut: no amplitude control, so the crescendo is a rising run of
/// light-to-medium taps; add the `vibration` package only if a device test
/// shows it feels flat.
class HapticService {
  HapticService({HapticBackend? backend, bool? isWeb})
    : _backend = backend ?? const SystemHapticBackend(),
      _isWeb = isWeb ?? kIsWeb;

  static final HapticService instance = HapticService();

  final HapticBackend _backend;
  final bool _isWeb;

  /// Off when the You > Sound & haptics switch is off.
  bool enabled = true;

  bool get _on => enabled && !_isWeb;

  void _fire(Future<void> Function() f) {
    if (!_on) return;
    try {
      f().catchError((Object e) => debugPrint('haptic failed: $e'));
    } catch (e) {
      debugPrint('haptic failed: $e');
    }
  }

  /// Pick an option, verse snap, tab change, one chant line.
  void tick() => _fire(_backend.selection);

  /// Primary button.
  void tap() => _fire(_backend.light);

  /// End of the day, the quiet ones.
  void soft() => _fire(_backend.light);

  /// Breath pulse in Chant along.
  void pulse() => _fire(_backend.light);

  /// Double-tap keep.
  void keep() => _fire(_backend.medium);

  /// Step walked: one firm tap, one soft after it.
  void success() => _sequence(<(int, Future<void> Function())>[
    (0, _backend.medium),
    (140, _backend.light),
  ]);

  /// Lesson complete: a short rising run, about 0.7 s, matching the feather
  /// fan opening.
  void crescendo() => _sequence(<(int, Future<void> Function())>[
    (0, _backend.selection),
    (120, _backend.light),
    (240, _backend.light),
    (370, _backend.medium),
    (520, _backend.medium),
    (700, _backend.light),
  ]);

  void _sequence(List<(int, Future<void> Function())> steps) {
    if (!_on) return;
    for (final (int ms, Future<void> Function() f) in steps) {
      if (ms == 0) {
        _fire(f);
      } else {
        // Re-checks `enabled` when it fires, so muting mid-pattern stops it.
        Timer(Duration(milliseconds: ms), () => _fire(f));
      }
    }
  }
}
