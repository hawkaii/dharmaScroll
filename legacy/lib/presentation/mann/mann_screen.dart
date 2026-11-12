import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../core/theme/app_metrics.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_type.dart';
import '../../core/theme/theme_x.dart';
import '../../core/audio/voice_recorder.dart';
import '../../core/widgets/choice_chip_tag.dart';

/// Mann Darpan always lives in Ratri, whatever the system theme is doing.
///
/// It is the room where someone says the true thing at 1 a.m.; a bright
/// parchment screen is the wrong room for that.
class MannScreen extends StatefulWidget {
  const MannScreen({super.key});

  @override
  State<MannScreen> createState() => _MannScreenState();
}

class _MannScreenState extends State<MannScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 10),
  )..repeat(reverse: true);

  int? _mood;
  final VoiceRecorder _voice = VoiceRecorder();
  bool _recording = false;
  bool _hasNote = false;
  String? _notePath;
  bool _permissionDenied = false;

  static const List<({String label, String emoji})> _moods =
      <({String label, String emoji})>[
        (label: 'Low', emoji: '😔'),
        (label: 'Angry', emoji: '😤'),
        (label: 'Anxious', emoji: '😟'),
        (label: 'Happy', emoji: '😊'),
        (label: 'Confused', emoji: '🤔'),
      ];

  @override
  void dispose() {
    _breath.dispose();
    _voice.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_recording) {
      final String? path = await _voice.stop();
      setState(() {
        _recording = false;
        _notePath = path;
        _hasNote = path != null;
      });
      return;
    }
    final bool ok = await _voice.hasPermission();
    if (!ok) {
      setState(() => _permissionDenied = true);
      return;
    }
    // `start` returns null when the mic or encoder is unavailable (some
    // browsers); show the same "no mic" state instead of a fake recording.
    if (await _voice.start() == null) {
      if (mounted) setState(() => _permissionDenied = true);
      return;
    }
    if (!mounted) return;
    setState(() {
      _recording = true;
      _permissionDenied = false;
      _hasNote = false;
    });
  }

  Future<void> _playNote() async {
    if (_notePath == null) return;
    await _voice.play(_notePath!);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.dark,
      child: Builder(
        builder: (BuildContext context) {
          return DecoratedBox(
            decoration: BoxDecoration(color: context.colors.surfaceCanvas),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpace.s20,
                      AppSpace.s12,
                      AppSpace.s20,
                      AppSpace.s8,
                    ),
                    child: Row(
                      children: <Widget>[
                        Text(
                          'Journal',
                          style: AppType.l1.copyWith(
                            color: context.colors.inkMuted,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Mann Darpan',
                          style: AppType.t2.copyWith(color: context.colors.ink),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => context.push('/mann/crisis'),
                          child: Icon(
                            Icons.shield_outlined,
                            size: 18,
                            color: context.colors.inkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpace.s24,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Aaj ka din kaisa tha?',
                            textAlign: TextAlign.center,
                            style: AppType.d3.copyWith(
                              color: context.colors.gold,
                            ),
                          ),
                          const SizedBox(height: AppSpace.s8),
                          Text(
                            'Share a worry, a win, or anything in between.',
                            textAlign: TextAlign.center,
                            style: AppType.b3.copyWith(
                              color: context.colors.inkMuted,
                            ),
                          ),
                          const SizedBox(height: AppSpace.s20),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: AppSpace.s8,
                            runSpacing: AppSpace.s4,
                            children: <Widget>[
                              for (int i = 0; i < _moods.length; i++)
                                ChoiceChipTag(
                                  label:
                                      '${_moods[i].emoji} ${_moods[i].label}',
                                  selected: _mood == i,
                                  onTap: () => setState(
                                    () => _mood = _mood == i ? null : i,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: AppSpace.s16),
                          Lottie.asset(
                            'assets/lottie/diya_flame.json',
                            width: 96,
                            height: 96,
                            repeat: !MediaQuery.disableAnimationsOf(context),
                          ),
                          const SizedBox(height: AppSpace.s16),
                          GestureDetector(
                            onTap: _toggleRecording,
                            child: _BreathingMic(
                              animation: _breath,
                              recording: _recording,
                            ),
                          ),
                          const SizedBox(height: AppSpace.s20),
                          Text(
                            _recording
                                ? 'Recording… tap to stop'
                                : _hasNote
                                    ? 'Voice note ready'
                                    : 'Tap the mic to speak',
                            textAlign: TextAlign.center,
                            style: AppType.b3.copyWith(
                              color: _recording
                                  ? context.colors.danger
                                  : context.colors.inkMuted,
                            ),
                          ),
                          if (_permissionDenied) ...<Widget>[
                            const SizedBox(height: AppSpace.s8),
                            Text(
                              'Microphone permission is required.',
                              textAlign: TextAlign.center,
                              style: AppType.c1.copyWith(
                                color: context.colors.danger,
                              ),
                            ),
                          ],
                          if (_hasNote) ...<Widget>[
                            const SizedBox(height: AppSpace.s12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                TextButton.icon(
                                  onPressed: _playNote,
                                  icon: const Icon(Icons.play_arrow, size: 18),
                                  label: const Text('Play'),
                                ),
                                TextButton.icon(
                                  onPressed: () =>
                                      context.push('/mann/result'),
                                  icon: const Icon(Icons.arrow_forward, size: 18),
                                  label: const Text('Continue'),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: AppSpace.s8),
                          Text(
                            'Hindi, English or Hinglish.',
                            textAlign: TextAlign.center,
                            style: AppType.c1.copyWith(
                              color: context.colors.inkFaint,
                            ),
                          ),
                          const SizedBox(height: AppSpace.s16),
                          Text(
                            '🔒 Private. Sirf is phone par.',
                            textAlign: TextAlign.center,
                            style: AppType.c1.copyWith(
                              color: context.colors.inkFaint,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BreathingMic extends StatelessWidget {
  const _BreathingMic({required this.animation, this.recording = false});

  final Animation<double> animation;
  final bool recording;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        final double t = animation.value;
        final double ringScale = 1 + 0.16 * t;

        return SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Transform.scale(
                scale: ringScale,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: context.colors.gold.withValues(alpha: 0.28),
                      width: 2,
                    ),
                  ),
                ),
              ),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: recording
                      ? context.colors.danger
                      : context.colors.accentKesar,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: context.colors.border,
                    width: AppBorder.hairline,
                  ),
                ),
                child: Icon(
                  recording ? Icons.stop : Icons.mic,
                  size: 34,
                  color: context.colors.surfaceCanvas,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
