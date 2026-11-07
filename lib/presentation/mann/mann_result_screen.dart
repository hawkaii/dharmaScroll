import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_metrics.dart';
import '../../core/theme/app_type.dart';
import '../../core/theme/theme_x.dart';
import '../../core/widgets/hard_button.dart';
import '../../core/widgets/fitted_padas.dart';
import '../../core/widgets/parchment.dart';

/// Night question, morning answer.
///
/// The result arrives in parchment even though the question was asked in Ratri:
/// the cross-dissolve between the two is the whole emotional beat.
class MannResultScreen extends StatelessWidget {
  const MannResultScreen({super.key});

  static const String _why =
      'You put in real effort, and one opinion made it feel worthless. Krishna '
      'separates the effort, which is yours, from the verdict, which isn\'t — and '
      'warns against the next trap: "kuch karne ka fayda nahi."';

  static const List<({String title, String body})>
  _actions = <({String title, String body})>[
    (
      title: 'Name your effort.',
      body:
          'Write three things you did well on that project. They stay true '
          'whatever the review said.',
    ),
    (
      title: 'Ask, don\'t absorb.',
      body: 'Tomorrow, ask your manager for one specific thing to improve.',
    ),
    (
      title: 'Repair at home.',
      body:
          'The anger reached Mummy, not the manager. A two-line sorry tonight.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surfaceCanvas,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const ParchmentBackground(),
          SafeArea(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpace.s20,
                    AppSpace.s8,
                    AppSpace.s20,
                    AppSpace.s8,
                  ),
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.close, size: 20),
                        color: context.colors.ink,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 44,
                          minHeight: 44,
                        ),
                        tooltip: 'Close',
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'FOR YOUR DAY',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppType.m1.copyWith(
                              color: context.colors.inkMuted,
                            ),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.volume_up_outlined,
                        size: 20,
                        color: context.colors.ink,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpace.s24,
                      AppSpace.s8,
                      AppSpace.s24,
                      AppSpace.s24,
                    ),
                    children: <Widget>[
                      Center(
                        child: Text(
                          'ADHYAY 2 · SHLOKA 47',
                          style: AppType.m1.copyWith(
                            color: context.colors.inkMuted,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpace.s16),
                      FittedPadas(
                        padas: const <String>[
                          'कर्मण्येवाधिकारस्ते मा फलेषु कदाचन।',
                          'मा कर्मफलहेतुर्भूर्मा ते सङ्गोऽस्त्वकर्मणि॥',
                        ],
                        color: context.colors.field,
                      ),
                      const SizedBox(height: AppSpace.s12),
                      Text(
                        'Your right is to your work, never to its fruits.',
                        textAlign: TextAlign.center,
                        style: AppType.b3.copyWith(
                          color: context.colors.inkMuted,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: AppSpace.s20),
                      Container(
                        padding: const EdgeInsets.all(AppSpace.s16),
                        decoration: BoxDecoration(
                          color: context.colors.surfaceRaised,
                          border: Border(
                            left: BorderSide(
                              color: context.colors.field,
                              width: AppBorder.hairline,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Why this shloka',
                              style: AppType.h1.copyWith(
                                color: context.colors.field,
                              ),
                            ),
                            const SizedBox(height: AppSpace.s8),
                            Text(
                              _why,
                              style: AppType.b2.copyWith(
                                color: context.colors.ink,
                                height: 1.55,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpace.s24),
                      Text(
                        'For the next 24 hours',
                        style: AppType.t2.copyWith(color: context.colors.ink),
                      ),
                      const SizedBox(height: AppSpace.s12),
                      for (int i = 0; i < _actions.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpace.s12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                '${i + 1}',
                                style: AppType.d3.copyWith(
                                  color: context.colors.field.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpace.s12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      _actions[i].title,
                                      style: AppType.h1.copyWith(
                                        color: context.colors.ink,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpace.s2),
                                    Text(
                                      _actions[i].body,
                                      style: AppType.b3.copyWith(
                                        color: context.colors.inkMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: AppSpace.s8),
                      GestureDetector(
                        onTap: () => context.push('/sankalp'),
                        child: Container(
                          padding: const EdgeInsets.all(AppSpace.s16),
                          decoration: BoxDecoration(
                            color: context.colors.gold,
                            border: Border.all(
                              color: context.colors.border,
                              width: AppBorder.hairline,
                            ),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                '✦ TODAY\'S SANKALP',
                                style: AppType.m1.copyWith(
                                  color: context.colors.onGold.withValues(
                                    alpha: 0.8,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpace.s6),
                              Text(
                                '"I\'ll speak calmly at home tonight."',
                                style: AppType.h1.copyWith(
                                  color: context.colors.onGold,
                                ),
                              ),
                              const SizedBox(height: AppSpace.s6),
                              Text(
                                'Remind 9 pm',
                                style: AppType.m2.copyWith(
                                  color: context.colors.onGold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpace.s16),
                      if (MediaQuery.textScalerOf(context).scale(1) > 1.3)
                        Column(
                          children: <Widget>[
                            HardButton(
                              label: 'Another shloka',
                              variant: HardButtonVariant.secondary,
                              block: true,
                              onPressed: () {},
                            ),
                            const SizedBox(height: AppSpace.s8),
                            HardButton(
                              label: 'What do I do?',
                              block: true,
                              onPressed: () {},
                            ),
                          ],
                        )
                      else
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: HardButton(
                                label: 'Another shloka',
                                variant: HardButtonVariant.secondary,
                                block: true,
                                onPressed: () {},
                              ),
                            ),
                            const SizedBox(width: AppSpace.s12),
                            Expanded(
                              child: HardButton(
                                label: 'What do I do?',
                                block: true,
                                onPressed: () {},
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: AppSpace.s12),
                      Center(
                        child: Text(
                          'Saved privately to your journal',
                          style: AppType.c1.copyWith(
                            color: context.colors.inkFaint,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
