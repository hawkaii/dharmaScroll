import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/rituals/providers.dart';
import '../../core/router.dart';
import '../../core/state/progress.dart';
import '../../data/fake_verses.dart';
import '../../design/effects.dart';
import '../../design/tokens.dart';
import '../../design/widgets.dart';
import '../shell/app_shell.dart';

/// Today: one primary action. The rail shows Hear, Walk, Speak.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  static const String beginLabel = "Begin today's ritual";
  static const String continueLabel = 'Continue the ritual';
  static const String againLabel = 'Light it again';
  static const String doneTitle = 'Today is lit.';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ProgressState p = ref.watch(progressProvider);
    final bool light = ref.watch(todayIsLightProvider);
    final List<String> calendarToday = ref.watch(todayInCalendarProvider);
    final DharmaColors c = context.c;

    final bool heard = p.steps.contains(RitualStep.hear);
    final bool walked = p.steps.contains(RitualStep.walk);
    final bool allDone = heard && walked;
    final bool back = p.cameBack && !p.ritualStarted;

    final String title = back
        ? 'You came back.'
        : allDone
        ? doneTitle
        : heard
        ? 'Five heard.\nNow take one step\non the path.'
        : light
        ? 'Good morning.'
        : 'Namaste.';
    final String sub = back
        ? 'The lamp was still warm.'
        : allDone
        ? 'Come back tomorrow.\nThe verses will wait.'
        : heard
        ? ''
        : 'Five verses are waiting.\nThen you may rest.';
    final String button = back
        ? againLabel
        : allDone
        ? 'Hear them again'
        : p.ritualStarted
        ? continueLabel
        : beginLabel;

    void go() {
      if (!heard || allDone) {
        context.push(Routes.hear);
      } else {
        context.push(Routes.walk);
      }
    }

    final int chapter = kFakeVerses[p.kept.length % kFakeVerses.length].chapter;
    return Backdrop(
      child: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints box) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                Sp.screenSide,
                Sp.s18,
                Sp.screenSide,
                Sp.s22,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: box.maxHeight - 40),
                child: IntrinsicHeight(
                  child: Column(
                    children: <Widget>[
                      TopLine(
                        left: 'Day ${p.streak < 1 ? 1 : p.streak}',
                        right: 'Adhyaya $chapter',
                      ),
                      const Spacer(),
                      Diya(size: 130, lit: !back),
                      const SizedBox(height: Sp.s18),
                      Semantics(
                        header: true,
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: DType.title(c.ink),
                        ),
                      ),
                      if (sub.isNotEmpty) ...<Widget>[
                        const SizedBox(height: Sp.s14),
                        Text(
                          sub,
                          textAlign: TextAlign.center,
                          style: DType.body(c.mute),
                        ),
                      ],
                      const SizedBox(height: Sp.s30),
                      _Rail(heard: heard, walked: walked, speakDone: false),
                      if (calendarToday.isNotEmpty) ...<Widget>[
                        const SizedBox(height: Sp.s22),
                        Semantics(
                          label:
                              'Today in your calendar: ${calendarToday.join(', ')}',
                          excludeSemantics: true,
                          child: Text(
                            calendarToday.join('  ·  '),
                            textAlign: TextAlign.center,
                            style: DType.body(c.accent, size: 17),
                          ),
                        ),
                      ],
                      const Spacer(),
                      PrimaryButton(label: button, onPressed: go),
                      const SizedBox(height: Sp.s14),
                      Text(
                        back
                            ? 'Your ${p.streak > 0 ? p.streak : 'earlier'} days are kept.'
                            : '${p.points} Moksh Points',
                        style: DType.body(c.faint, size: 16),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Rail extends StatelessWidget {
  const _Rail({
    required this.heard,
    required this.walked,
    required this.speakDone,
  });

  final bool heard;
  final bool walked;
  final bool speakDone;

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    final List<(String, String, bool)> steps = <(String, String, bool)>[
      ('Hear', 'conch', heard),
      ('Walk', 'path-stone', walked),
      ('Speak', 'flute', speakDone),
    ];
    final int active = steps.indexWhere(((String, String, bool) s) => !s.$3);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (int i = 0; i < steps.length; i++) ...<Widget>[
          if (i > 0)
            Padding(
              padding: const EdgeInsets.only(top: 28),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: 36,
                height: 1.5,
                color: steps[i - 1].$3 ? Tok.marigold : c.line,
              ),
            ),
          _RailNode(
            label: steps[i].$1,
            icon: steps[i].$2,
            done: steps[i].$3,
            active: i == active,
          ),
        ],
      ],
    );
  }
}

class _RailNode extends StatefulWidget {
  const _RailNode({
    required this.label,
    required this.icon,
    required this.done,
    required this.active,
  });

  final String label;
  final String icon;
  final bool done;
  final bool active;

  @override
  State<_RailNode> createState() => _RailNodeState();
}

class _RailNodeState extends State<_RailNode>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: Motion.breathe,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.active && !reduceMotion(context)) {
      if (!_c.isAnimating) _c.repeat(reverse: true);
    } else {
      _c.stop();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    final String state = widget.done
        ? 'done'
        : widget.active
        ? 'next'
        : 'later';
    return Semantics(
      label: '${widget.label}, $state',
      excludeSemantics: true,
      child: SizedBox(
        width: 64,
        child: Column(
          children: <Widget>[
            AnimatedBuilder(
              animation: _c,
              builder: (BuildContext context, Widget? child) {
                final double t = Curves.easeInOut.transform(_c.value);
                final bool lit = widget.done || widget.active;
                return Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.done
                        ? Tok.marigold.withValues(alpha: 0.16)
                        : null,
                    border: Border.all(
                      color: lit ? Tok.marigold : c.line,
                      width: lit ? 1.5 : 1,
                    ),
                    boxShadow: widget.active
                        ? <BoxShadow>[
                            BoxShadow(
                              color: Tok.marigold.withValues(
                                alpha: 0.18 + 0.2 * t,
                              ),
                              blurRadius: 10 + 8 * t,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(child: child),
                );
              },
              child: DIcon(
                widget.done ? 'check' : widget.icon,
                size: 26,
                color: widget.done || widget.active ? c.accent : c.faint,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.label.toUpperCase(),
              style: DType.eyebrow(widget.active ? c.accent : c.faint),
            ),
          ],
        ),
      ),
    );
  }
}
