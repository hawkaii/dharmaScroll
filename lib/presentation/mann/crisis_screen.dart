import 'package:flutter/material.dart';

import '../../core/theme/app_metrics.dart';
import '../../core/theme/app_type.dart';
import '../../core/theme/theme_x.dart';

/// The one screen where the product stops being a product.
///
/// No border, no shadow, no gold, no brand mark, no motion, no points. Human
/// help should not look designed.
class CrisisScreen extends StatelessWidget {
  const CrisisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color paper = context.colors.surface;

    return Scaffold(
      backgroundColor: paper,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpace.s24,
            AppSpace.s16,
            AppSpace.s24,
            AppSpace.s24,
          ),
          child: ListView(
            children: <Widget>[
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.close, size: 20),
                  color: context.colors.inkMuted,
                  tooltip: 'Close',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 44,
                  ),
                ),
              ),
              const SizedBox(height: AppSpace.s24),
              // An icon, not an emoji: a crisis screen must never depend on a
              // device having a colour-emoji font installed.
              Icon(
                Icons.favorite_border,
                size: 30,
                color: context.colors.inkMuted,
              ),
              const SizedBox(height: AppSpace.s16),
              Text(
                'You don\'t have to carry this alone',
                style: AppType.d2.copyWith(color: context.colors.ink),
              ),
              const SizedBox(height: AppSpace.s12),
              Text(
                'What you shared sounds really heavy. Talking to someone trained '
                'can help right now.',
                style: AppType.b2.copyWith(color: context.colors.inkMuted),
              ),
              const SizedBox(height: AppSpace.s24),
              Container(
                padding: const EdgeInsets.all(AppSpace.s16),
                decoration: BoxDecoration(
                  border: Border.all(color: context.colors.danger, width: 2),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Tele-MANAS (free, 24×7)',
                      style: AppType.h1.copyWith(color: context.colors.ink),
                    ),
                    const SizedBox(height: AppSpace.s4),
                    Text(
                      '14416  or  1-800-891-4416',
                      style: AppType.m2.copyWith(
                        color: context.colors.danger,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpace.s12),
              SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: context.colors.dangerFill,
                    foregroundColor: const Color(0xFFFFF6EE),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                  child: Text('Call now', style: AppType.l1),
                ),
              ),
              const SizedBox(height: AppSpace.s8),
              SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.colors.ink,
                    side: BorderSide(color: context.colors.ink, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                  child: Text('Message someone I trust', style: AppType.l1),
                ),
              ),
              const SizedBox(height: AppSpace.s16),
              Container(
                padding: const EdgeInsets.all(AppSpace.s16),
                decoration: BoxDecoration(
                  color: context.colors.surfaceRaised,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  'If you\'re in immediate danger, call 112.',
                  style: AppType.b3.copyWith(color: context.colors.ink),
                ),
              ),
              const SizedBox(height: AppSpace.s24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Stay here with a calming chant',
                    style: AppType.b3.copyWith(color: context.colors.inkMuted),
                  ),
                  const SizedBox(width: AppSpace.s4),
                  Icon(
                    Icons.play_arrow_rounded,
                    size: 16,
                    color: context.colors.inkMuted,
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.s16),
              Text(
                'Aapse jo kaha, woh sirf aapke paas hai. Koi points nahi, koi '
                'record nahi.',
                textAlign: TextAlign.center,
                style: AppType.c1.copyWith(color: context.colors.inkFaint),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
