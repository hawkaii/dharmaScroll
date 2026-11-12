import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../core/router/app_router.dart';
import '../../core/state/progress.dart';
import '../../core/theme/app_metrics.dart';
import '../../core/theme/app_type.dart';
import '../../core/theme/theme_x.dart';
import '../../core/widgets/hard_button.dart';

/// Today: one primary action, the day's ritual (Hear, Walk, Speak).
///
/// Styling is a placeholder on the existing tokens until design board v3 is
/// approved; the structure and copy follow board v2.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  static const String beginLabel = "Begin today's ritual";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ProgressState progress = ref.watch(progressProvider);
    final bool reduceMotion = MediaQuery.disableAnimationsOf(context);

    return SafeArea(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpace.s24,
              AppSpace.s16,
              AppSpace.s24,
              AppSpace.s24,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - AppSpace.s40,
              ),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        'DAY ${progress.streak < 1 ? 1 : progress.streak}',
                        style: AppType.m1.copyWith(
                          color: context.colors.inkMuted,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${progress.points} MP',
                        style: AppType.m1.copyWith(
                          color: context.colors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpace.s32),
                  ExcludeSemantics(
                    child: Lottie.asset(
                      'assets/lottie/diya_flame.json',
                      width: 120,
                      height: 120,
                      animate: !reduceMotion,
                    ),
                  ),
                  const SizedBox(height: AppSpace.s24),
                  Text(
                    'Namaste.',
                    textAlign: TextAlign.center,
                    style: AppType.d2.copyWith(color: context.colors.ink),
                  ),
                  const SizedBox(height: AppSpace.s8),
                  Text(
                    'Five verses are waiting.\nThen you may rest.',
                    textAlign: TextAlign.center,
                    style: AppType.b1.copyWith(color: context.colors.inkMuted),
                  ),
                  const SizedBox(height: AppSpace.s24),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: AppSpace.s8,
                    children: <Widget>[
                      _Step(
                        label: 'Hear',
                        done: progress.cardsToday >= progress.dailyGoal,
                        onTap: () => context.push(Routes.shloka),
                      ),
                      _Step(
                        label: 'Walk',
                        done: false,
                        onTap: () => context.push(Routes.lesson),
                      ),
                      _Step(
                        label: 'Speak',
                        done: false,
                        onTap: () => context.push(Routes.mann),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpace.s40),
                  HardButton(
                    label: beginLabel,
                    block: true,
                    variant: HardButtonVariant.gold,
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      context.push(Routes.shloka);
                    },
                  ),
                  const SizedBox(height: AppSpace.s8),
                  TextButton(
                    onPressed: () => context.push(Routes.sangha),
                    child: Text(
                      'Sangha',
                      style: AppType.c1.copyWith(
                        color: context.colors.inkMuted,
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

/// One of the three quiet ritual marks. Tapping jumps to that step.
class _Step extends StatelessWidget {
  const _Step({required this.label, required this.done, required this.onTap});

  final String label;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color tint = done ? context.colors.primary : context.colors.inkFaint;
    return Semantics(
      button: true,
      label: done ? '$label, done' : label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.s8,
            vertical: AppSpace.s12,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                done ? Icons.circle : Icons.circle_outlined,
                size: 10,
                color: tint,
              ),
              const SizedBox(width: AppSpace.s6),
              Text(label.toUpperCase(), style: AppType.m1.copyWith(color: tint)),
            ],
          ),
        ),
      ),
    );
  }
}
