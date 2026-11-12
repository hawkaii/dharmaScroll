import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router.dart';
import '../../core/state/progress.dart';
import '../../design/effects.dart';
import '../../design/tokens.dart';
import '../../design/widgets.dart';

/// Lesson complete: lamp, feather fan, petals, points count-up, week lamps.
class CompleteScreen extends ConsumerWidget {
  const CompleteScreen({super.key, required this.award});

  /// Points earned by the step just walked, for the count-up start.
  final int award;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DharmaColors c = context.c;
    final ProgressState p = ref.watch(progressProvider);
    final List<bool> lamps = ref.read(progressProvider.notifier).weekLamps();
    final int lit = lamps.where((bool b) => b).length;
    return Scaffold(
      backgroundColor: c.bg,
      body: Backdrop(
        child: Stack(
          children: <Widget>[
            const Positioned.fill(child: Petals()),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  Sp.screenSide,
                  Sp.s30,
                  Sp.screenSide,
                  Sp.screenBottom,
                ),
                child: Column(
                  children: <Widget>[
                    Text('STEP WALKED', style: DType.eyebrow(c.faint)),
                    const Spacer(),
                    SizedBox(
                      height: 190,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: <Widget>[
                          const Positioned(
                            bottom: 60,
                            child: FeatherFan(height: 150),
                          ),
                          const Diya(size: 150),
                        ],
                      ),
                    ),
                    const SizedBox(height: Sp.s14),
                    Semantics(
                      header: true,
                      child: Text(
                        'The lamp is lit.',
                        textAlign: TextAlign.center,
                        style: DType.title(c.ink),
                      ),
                    ),
                    const SizedBox(height: Sp.s22),
                    Text('MOKSH POINTS', style: DType.eyebrow(c.accent)),
                    const SizedBox(height: 6),
                    Semantics(
                      label: '${p.points} Moksh Points',
                      excludeSemantics: true,
                      child: CountUp(
                        begin: p.points - award,
                        value: p.points,
                        style: DType.hero(c.verse),
                      ),
                    ),
                    const Spacer(),
                    StreakLamps(lit: lamps),
                    const SizedBox(height: Sp.s12),
                    Text(
                      'Day ${p.streak < 1 ? 1 : p.streak}  ·  '
                      '${lit == 1 ? 'one lamp' : '$lit lamps'} this week',
                      style: DType.body(c.mute, size: 16),
                    ),
                    const SizedBox(height: Sp.s30),
                    PrimaryButton(
                      label: 'Continue',
                      onPressed: () => context.go(Routes.today),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
