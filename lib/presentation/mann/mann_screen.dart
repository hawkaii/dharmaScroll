import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_metrics.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_type.dart';
import '../../core/theme/theme_x.dart';
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
    super.dispose();
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
                          const SizedBox(height: AppSpace.s32),
                          GestureDetector(
                            onTap: () => context.push('/mann/result'),
                            child: _BreathingMic(animation: _breath),
                          ),
                          const SizedBox(height: AppSpace.s20),
                          Text(
                            'Hold to speak · or type instead',
                            textAlign: TextAlign.center,
                            style: AppType.b3.copyWith(
                              color: context.colors.inkMuted,
                            ),
                          ),
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
  const _BreathingMic({required this.animation});

  final Animation<double> animation;

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
                  color: context.colors.accentKesar,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: context.colors.border,
                    width: AppBorder.hairline,
                  ),
                ),
                child: Icon(
                  Icons.mic,
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
