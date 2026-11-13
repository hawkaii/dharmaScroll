import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app_providers.dart';
import '../../core/auth/auth_service.dart';
import '../../core/rituals/providers.dart';
import '../../core/router.dart';
import '../../core/state/progress.dart';
import '../../design/effects.dart';
import '../../design/tokens.dart';
import '../../design/widgets.dart';
import '../../domain/models/verse.dart';
import '../../l10n/l10n.dart';
import '../points/wallet_screen.dart';
import '../sankalp/sankalp_sheet.dart';
import '../shell/app_shell.dart';

/// Today: one primary action. The rail shows Hear, Walk, Speak.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ProgressState p = ref.watch(progressProvider);
    final bool light = ref.watch(todayIsLightProvider);
    final List<String> calendarToday = ref.watch(todayInCalendarProvider);
    final DharmaColors c = context.c;
    final AppLocalizations l = context.l;
    final String name = ref.watch(authProvider)?.name ?? '';

    final bool heard = p.steps.contains(RitualStep.hear);
    final bool walked = p.steps.contains(RitualStep.walk);
    final bool spoke = p.steps.contains(RitualStep.speak);
    final bool allDone = heard && walked && spoke;
    final bool back = p.cameBack && !p.ritualStarted;

    final String title = back
        ? l.todayCameBack
        : allDone
        ? l.todayDoneTitle
        : walked
        ? l.todayWalkedTitle
        : heard
        ? l.todayHeardTitle
        : light
        ? (name.isEmpty ? l.greetMorning : l.greetMorningName(name))
        : (name.isEmpty ? l.greetNamaste : l.greetNamasteName(name));
    final String sub = back
        ? l.todaySubBack
        : allDone
        ? l.todaySubDone
        : walked
        ? l.todaySubWalked
        : heard
        ? ''
        : l.todaySubStart;
    final String button = back
        ? l.todayAgain
        : allDone
        ? l.todayHearAgain
        : p.ritualStarted
        ? l.todayContinue
        : l.todayBegin;

    void go() {
      if (!heard || allDone) {
        context.push(Routes.hear);
      } else if (!walked) {
        context.push(Routes.walk);
      } else {
        context.push(Routes.speak);
      }
    }

    final List<Verse> verses = ref.watch(versesProvider);
    final int chapter = verses[p.kept.length % verses.length].chapter;
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
                        left: l.topDay(p.streak < 1 ? 1 : p.streak),
                        right: l.topAdhyaya(chapter),
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
                      _Rail(heard: heard, walked: walked, speakDone: spoke),
                      if (calendarToday.isNotEmpty) ...<Widget>[
                        const SizedBox(height: Sp.s22),
                        Semantics(
                          label: l.calendarToday(calendarToday.join(', ')),
                          excludeSemantics: true,
                          child: Text(
                            calendarToday.join('  ·  '),
                            textAlign: TextAlign.center,
                            style: DType.body(c.accent, size: 17),
                          ),
                        ),
                      ],
                      const SankalpLookBack(),
                      const Spacer(),
                      PrimaryButton(label: button, onPressed: go),
                      const SizedBox(height: Sp.s14),
                      // Points and Ekant share one line, so Sankalp and the
                      // calendar line still fit above the button.
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: Sp.s18,
                        children: <Widget>[
                          if (back)
                            Text(
                              p.streak > 0
                                  ? l.daysKept(p.streak)
                                  : l.earlierDaysKept,
                              textAlign: TextAlign.center,
                              style: DType.body(c.faint, size: 17),
                            )
                          else
                            IntrinsicWidth(
                              child: TextAction(
                                label: l.pointsAction(p.points),
                                onPressed: () =>
                                    showTodayPointsSheet(context, p),
                              ),
                            ),
                          IntrinsicWidth(
                            child: TextAction(
                              label: l.ekantAction,
                              onPressed: () => context.push(Routes.ekant),
                            ),
                          ),
                        ],
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
    final AppLocalizations l = context.l;
    final List<(String, String, bool)> steps = <(String, String, bool)>[
      (l.railHear, 'conch', heard),
      (l.railWalk, 'path-stone', walked),
      (l.railSpeak, 'flute', speakDone),
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
                width: 24,
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
    final AppLocalizations l = context.l;
    final String state = widget.done
        ? l.railDone
        : widget.active
        ? l.railNext
        : l.railLater;
    return Semantics(
      label: l.railSemantic(widget.label, state),
      excludeSemantics: true,
      child: SizedBox(
        width: 76,
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
              maxLines: 1,
              textAlign: TextAlign.center,
              style: DType.eyebrow(widget.active ? c.accent : c.mute),
            ),
          ],
        ),
      ),
    );
  }
}
