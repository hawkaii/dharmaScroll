import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// One-shot cues, each cut from a real CC0 recording by
/// `tools/sound_gen/build.py`. Sources: `assets/audio/CREDITS.md`.
enum Sfx {
  tap('tap', 0.55), // finger-cymbal touch
  tok('tok', 0.6), // mokugyo, wooden temple block
  bowl('bowl', 0.7), // ghanta, one ring
  bell('bell', 0.9), // Indian temple bell
  bellLow('bell_low', 0.7), // large temple bell
  shimmer('shimmer', 0.6), // small bronze bells, rising
  chime('chime', 0.7), // tingsha, ting-ting
  conch('conch', 0.75), // shankha blow
  swipe('swipe', 0.5); // page turn

  const Sfx(this.file, this.gain);
  final String file;

  /// Per-cue level, 0 to 1. Gentle by default; the device volume does the rest.
  final double gain;
  String get asset => 'audio/$file.m4a';
}

/// Seamless 8 s tanpura loop, Sa = C# (WAV, so there is no encoder gap at
/// the seam).
const String kDroneAsset = 'audio/drone.wav';

/// What the service needs from an audio engine. Swapped for a fake in tests.
abstract class SoundBackend {
  Future<void> init();
  Future<void> preload(List<String> assets);
  Future<void> playOnce(String asset, double volume);
  Future<void> loopStart(String asset, double volume);
  Future<void> loopVolume(double volume);
  Future<void> loopStop();
}

class _SilentBackend implements SoundBackend {
  @override
  Future<void> init() async {}
  @override
  Future<void> preload(List<String> assets) async {}
  @override
  Future<void> playOnce(String asset, double volume) async {}
  @override
  Future<void> loopStart(String asset, double volume) async {}
  @override
  Future<void> loopVolume(double volume) async {}
  @override
  Future<void> loopStop() async {}
}

/// All app audio: preloaded one-shots, plus one looping ambient layer with
/// fades and ducking.
///
/// - Mute: [enabled] (You > Sound & haptics). Off stops the drone at once.
/// - Web: nothing plays or loads until [unlock] runs from a pointer event, so
///   no request is made before a user gesture.
/// - Silent mode: handled in [AudioplayersBackend.init] (iOS silent switch).
/// - Until [attach] is called the backend is silent, so tests and any code
///   that runs before `main` finishes cannot touch a plugin.
class SoundService {
  SoundService({SoundBackend? backend, bool? needsGesture})
    : _backend = backend ?? _SilentBackend(),
      _unlocked = !(needsGesture ?? kIsWeb);

  static final SoundService instance = SoundService();

  /// Ambient bed sits at half level while a voice (the user's) is in front.
  static const double ambientDuck = 0.5;
  static const double cueDuck = 0.6;
  static const Duration _step = Duration(milliseconds: 40);

  SoundBackend _backend;
  bool _unlocked;
  bool _enabled = true;
  bool _ducked = false;

  bool _wantLoop = false; // the caller wants the drone audible
  bool _loopOpen = false; // the backend loop is running
  double _level = 0; // requested drone level, before ducking
  double _shown = 0; // volume actually sent to the backend
  Timer? _fade;

  bool get enabled => _enabled;
  set enabled(bool v) {
    _enabled = v;
    if (!v) _killLoop();
  }

  bool get unlocked => _unlocked;
  bool get droneRunning => _loopOpen;
  double get droneVolume => _shown;

  /// Swap in the real engine (called from `main`).
  Future<void> attach(SoundBackend backend) async {
    _backend = backend;
    if (_unlocked) await _prepare();
  }

  /// Call from a pointer-down. A no-op after the first time, and off web.
  Future<void> unlock() async {
    if (_unlocked) return;
    _unlocked = true;
    await _prepare();
  }

  Future<void> _prepare() => _guard(() async {
    await _backend.init();
    await _backend.preload(<String>[
      for (final Sfx s in Sfx.values) s.asset,
      kDroneAsset,
    ]);
  });

  Future<void> play(Sfx s) async {
    if (!_enabled || !_unlocked) return;
    await _guard(
      () => _backend.playOnce(s.asset, s.gain * (_ducked ? cueDuck : 1)),
    );
  }

  /// Fade the drone in. Calling again only changes the level.
  Future<void> startDrone({
    double level = 0.5,
    Duration fadeIn = const Duration(milliseconds: 700),
  }) async {
    if (!_enabled || !_unlocked) return;
    _level = level;
    _wantLoop = true;
    if (!_loopOpen) {
      _loopOpen = true;
      _shown = 0;
      await _guard(() => _backend.loopStart(kDroneAsset, 0));
    }
    _fadeTo(fadeIn);
  }

  /// Fade the drone out, then stop it.
  Future<void> stopDrone({
    Duration fadeOut = const Duration(milliseconds: 500),
  }) async {
    if (!_wantLoop) return;
    _wantLoop = false;
    _fadeTo(fadeOut);
  }

  /// Move the level without a fade (breath swell while chanting).
  void setDroneLevel(double level) {
    final bool moved = (level - _level).abs() >= 0.01; // spare the plugin
    _level = level;
    if (moved && _loopOpen && _wantLoop && _fade == null) _apply(_target);
  }

  /// Lower the drone and the cues while a voice is in front of them.
  void duck(bool on) {
    if (_ducked == on) return;
    _ducked = on;
    if (_loopOpen && _wantLoop) _fadeTo(const Duration(milliseconds: 200));
  }

  double get _target => _wantLoop ? _level * (_ducked ? ambientDuck : 1) : 0;

  void _fadeTo(Duration d) {
    _fade?.cancel();
    final double from = _shown;
    final int steps = d.inMilliseconds ~/ _step.inMilliseconds;
    if (steps <= 1) {
      _fade = null;
      _apply(_target);
      return;
    }
    int i = 0;
    _fade = Timer.periodic(_step, (Timer t) {
      i++;
      // Re-read the target each step so a level change mid-fade is followed.
      _apply(from + (_target - from) * (i / steps));
      if (i >= steps) {
        t.cancel();
        _fade = null;
        _apply(_target);
      }
    });
  }

  void _apply(double v) {
    _shown = v.clamp(0.0, 1.0);
    if (!_wantLoop && _shown <= 0.001 && _loopOpen) {
      _loopOpen = false;
      _guard(_backend.loopStop);
    } else if (_loopOpen) {
      _guard(() => _backend.loopVolume(_shown));
    }
  }

  void _killLoop() {
    _fade?.cancel();
    _fade = null;
    _wantLoop = false;
    _shown = 0;
    if (_loopOpen) {
      _loopOpen = false;
      _guard(_backend.loopStop);
    }
  }

  Future<void> _guard(Future<void> Function() f) async {
    try {
      await f();
    } catch (e) {
      // A missing codec, a locked browser, no plugin: sound is never worth a
      // crash.
      debugPrint('SoundService: $e');
    }
  }
}

/// The real engine. One preloaded player per cue (low-latency mode) and one
/// looping player for the drone.
/// shortcut: untested on a device (no hardware here); if a cue cuts off on
/// rapid repeats, give hot cues a small AudioPool.
class AudioplayersBackend implements SoundBackend {
  final Map<String, AudioPlayer> _shots = <String, AudioPlayer>{};
  AudioPlayer? _loop;

  @override
  Future<void> init() async {
    if (kIsWeb) return;
    // iOS: the ambient category, so the silent switch mutes us and other
    // audio keeps playing. Android has no silent switch for the media stream
    // and a ringtone usage would steal audio focus on every tap, so there we
    // mix with others and follow the media volume.
    final bool ios = defaultTargetPlatform == TargetPlatform.iOS;
    await AudioPlayer.global.setAudioContext(
      AudioContextConfig(
        respectSilence: ios,
        focus: ios
            ? AudioContextConfigFocus.gain
            : AudioContextConfigFocus.mixWithOthers,
      ).build(),
    );
  }

  Future<AudioPlayer> _shot(String asset) async {
    final AudioPlayer? have = _shots[asset];
    if (have != null) return have;
    final AudioPlayer p = AudioPlayer();
    _shots[asset] = p;
    await p.setReleaseMode(ReleaseMode.stop);
    await p.setPlayerMode(PlayerMode.lowLatency);
    await p.setSource(AssetSource(asset));
    return p;
  }

  @override
  Future<void> preload(List<String> assets) async {
    for (final String a in assets) {
      if (a == kDroneAsset) {
        await AudioCache.instance.load(a);
      } else {
        await _shot(a);
      }
    }
  }

  @override
  Future<void> playOnce(String asset, double volume) async {
    final AudioPlayer p = await _shot(asset);
    await p.setVolume(volume);
    await p.stop();
    await p.resume();
  }

  @override
  Future<void> loopStart(String asset, double volume) async {
    final AudioPlayer p = _loop ??= AudioPlayer();
    await p.setReleaseMode(ReleaseMode.loop);
    await p.play(AssetSource(asset), volume: volume);
  }

  @override
  Future<void> loopVolume(double volume) async => _loop?.setVolume(volume);

  @override
  Future<void> loopStop() async => _loop?.stop();
}
