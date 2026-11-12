import 'package:dharmascroll/core/feedback/haptic_service.dart';
import 'package:dharmascroll/core/feedback/sound_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSound implements SoundBackend {
  final List<String> log = <String>[];
  final List<double> loopVolumes = <double>[];
  bool throwOnPlay = false;

  @override
  Future<void> init() async => log.add('init');
  @override
  Future<void> preload(List<String> assets) async =>
      log.add('preload:${assets.length}');
  @override
  Future<void> playOnce(String asset, double volume) async {
    if (throwOnPlay) throw StateError('no codec');
    log.add('play:$asset');
  }

  @override
  Future<void> loopStart(String asset, double volume) async =>
      log.add('loopStart');
  @override
  Future<void> loopVolume(double volume) async => loopVolumes.add(volume);
  @override
  Future<void> loopStop() async => log.add('loopStop');
}

class _FakeHaptics implements HapticBackend {
  final List<String> log = <String>[];
  @override
  Future<void> selection() async => log.add('selection');
  @override
  Future<void> light() async => log.add('light');
  @override
  Future<void> medium() async => log.add('medium');
}

void main() {
  group('SoundService', () {
    test('plays a cue, and not when muted', () async {
      final _FakeSound b = _FakeSound();
      final SoundService s = SoundService(backend: b, needsGesture: false);
      await s.play(Sfx.tap);
      expect(b.log, <String>['play:audio/tap.m4a']);
      s.enabled = false;
      await s.play(Sfx.bell);
      expect(b.log.length, 1);
    });

    test('web: nothing loads or plays before a gesture', () async {
      final _FakeSound b = _FakeSound();
      final SoundService s = SoundService(backend: b, needsGesture: true);
      await s.attach(b);
      await s.play(Sfx.tap);
      await s.startDrone();
      expect(b.log, isEmpty);
      await s.unlock();
      expect(b.log, <String>['init', 'preload:${Sfx.values.length + 1}']);
      await s.play(Sfx.tap);
      expect(b.log.last, 'play:audio/tap.m4a');
    });

    test('a failing engine never throws', () async {
      final _FakeSound b = _FakeSound()..throwOnPlay = true;
      final SoundService s = SoundService(backend: b, needsGesture: false);
      await s.play(Sfx.tap);
    });

    testWidgets('drone fades in, ducks, fades out and stops', (
      WidgetTester tester,
    ) async {
      final _FakeSound b = _FakeSound();
      final SoundService s = SoundService(backend: b, needsGesture: false);
      await s.startDrone(level: 0.6, fadeIn: const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 500));
      expect(b.log, contains('loopStart'));
      expect(s.droneVolume, closeTo(0.6, 1e-6));
      // Rising, never above the target.
      expect(b.loopVolumes.first, lessThan(b.loopVolumes.last));
      expect(b.loopVolumes.every((double v) => v <= 0.6 + 1e-9), isTrue);

      s.duck(true);
      await tester.pump(const Duration(milliseconds: 300));
      expect(s.droneVolume, closeTo(0.3, 1e-6));

      await s.stopDrone(fadeOut: const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 300));
      expect(s.droneVolume, 0);
      expect(b.log.last, 'loopStop');
      expect(s.droneRunning, isFalse);
    });

    testWidgets('muting stops the drone at once', (WidgetTester tester) async {
      final _FakeSound b = _FakeSound();
      final SoundService s = SoundService(backend: b, needsGesture: false);
      await s.startDrone(fadeIn: const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 100));
      s.enabled = false;
      expect(b.log.last, 'loopStop');
      await tester.pump(const Duration(seconds: 1)); // no timer left behind
      await s.startDrone();
      expect(s.droneRunning, isFalse);
    });
  });

  group('HapticService', () {
    test('maps events to patterns', () {
      final _FakeHaptics b = _FakeHaptics();
      final HapticService h = HapticService(backend: b, isWeb: false);
      h
        ..tick()
        ..tap()
        ..keep();
      expect(b.log, <String>['selection', 'light', 'medium']);
    });

    test('off, and web, are silent', () {
      final _FakeHaptics b = _FakeHaptics();
      HapticService(backend: b, isWeb: false)
        ..enabled = false
        ..tick()
        ..crescendo();
      HapticService(backend: b, isWeb: true)
        ..tap()
        ..success();
      expect(b.log, isEmpty);
    });

    testWidgets('crescendo rises, and muting mid-pattern stops it', (
      WidgetTester tester,
    ) async {
      final _FakeHaptics b = _FakeHaptics();
      final HapticService h = HapticService(backend: b, isWeb: false);
      h.crescendo();
      await tester.pump(const Duration(milliseconds: 800));
      expect(b.log, <String>[
        'selection',
        'light',
        'light',
        'medium',
        'medium',
        'light',
      ]);

      b.log.clear();
      h.crescendo();
      await tester.pump(const Duration(milliseconds: 150));
      h.enabled = false;
      await tester.pump(const Duration(milliseconds: 800));
      expect(b.log, <String>['selection', 'light']);
    });
  });
}
