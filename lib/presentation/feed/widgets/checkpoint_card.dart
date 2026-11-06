import 'package:flutter/material.dart';

import '../../../core/theme/app_metrics.dart';
import '../../../core/theme/app_type.dart';
import '../../../core/theme/theme_x.dart';
import '../../../core/widgets/paper_plate.dart';

/// Every seventh card becomes a checkpoint.
///
/// This is where the scroll turns into recall, and where most feed points come
/// from. A wrong answer costs nothing — punishing curiosity would punish the
/// only behaviour the product exists to create.
class CheckpointCard extends StatefulWidget {
  const CheckpointCard({super.key, this.onAnswered});

  final ValueChanged<bool>? onAnswered;

  @override
  State<CheckpointCard> createState() => _CheckpointCardState();
}

class _CheckpointCardState extends State<CheckpointCard> {
  static const List<String> _answers = <String>[
    'Proof of God',
    'A standard others follow',
    'Measurement of time',
  ];

  static const int _correct = 1;

  int? _chosen;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: context.colors.surfaceCanvas),
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpace.s20,
            AppSpace.s20,
            AppSpace.s20,
            AppSpace.s32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'CHECKPOINT · 1 OF 3',
                      style: AppType.m1.copyWith(
                        color: context.colors.inkMuted,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpace.s8,
                      vertical: AppSpace.s2,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.field,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Text(
                      '+5',
                      style: AppType.m1.copyWith(color: context.colors.gold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.s24),
              Text(
                'Quick check',
                style: AppType.d3.copyWith(color: context.colors.ink),
              ),
              const SizedBox(height: AppSpace.s4),
              Text(
                'From the shlokas you just read',
                style: AppType.b3.copyWith(color: context.colors.inkMuted),
              ),
              const SizedBox(height: AppSpace.s24),
              PaperPlate(
                shadow: AppShadow.none,
                color: context.colors.surfaceRaised,
                borderColor: context.colors.borderQuiet,
                borderWidth: 1,
                padding: const EdgeInsets.all(AppSpace.s16),
                child: Column(
                  children: <Widget>[
                    RichText(
                      text: TextSpan(
                        style: AppType.b1.copyWith(color: context.colors.ink),
                        children: <InlineSpan>[
                          const TextSpan(text: 'In 3.21, what does '),
                          TextSpan(
                            text: 'प्रमाणम्',
                            style: AppType.sktS.copyWith(
                              color: context.colors.field,
                            ),
                          ),
                          const TextSpan(text: ' mean?'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpace.s12),
              for (int i = 0; i < _answers.length; i++)
                _AnswerRow(
                  index: i,
                  label: _answers[i],
                  chosen: _chosen == i,
                  revealed: _chosen != null,
                  correct: i == _correct,
                  onTap: () {
                    if (_chosen != null) {
                      return;
                    }
                    setState(() => _chosen = i);
                    widget.onAnswered?.call(i == _correct);
                  },
                ),
              const SizedBox(height: AppSpace.s16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpace.s16),
                decoration: BoxDecoration(
                  color: context.colors.surfaceSunken,
                  border: Border.all(
                    color: context.colors.borderQuiet,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Reflect',
                      style: AppType.m1.copyWith(
                        color: context.colors.inkMuted,
                      ),
                    ),
                    const SizedBox(height: AppSpace.s6),
                    Text(
                      'Who in your life sets the standard you follow?',
                      style: AppType.b2.copyWith(color: context.colors.ink),
                    ),
                    const SizedBox(height: AppSpace.s8),
                    Text(
                      'Type a note · +8 MP',
                      style: AppType.c1.copyWith(
                        color: context.colors.accentKesar,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpace.s24),
              Center(
                child: Text(
                  'Continue scrolling ↑',
                  style: AppType.l1.copyWith(color: context.colors.inkMuted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnswerRow extends StatelessWidget {
  const _AnswerRow({
    required this.index,
    required this.label,
    required this.chosen,
    required this.revealed,
    required this.correct,
    required this.onTap,
  });

  final int index;
  final String label;
  final bool chosen;
  final bool revealed;
  final bool correct;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool showCorrect = revealed && correct;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.s8),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppMotion.resolve(context, AppMotion.fast),
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.s16,
            vertical: AppSpace.s12,
          ),
          decoration: BoxDecoration(
            color: showCorrect
                ? context.colors.successTint
                : context.colors.surface,
            border: Border.all(
              color: showCorrect
                  ? context.colors.success
                  : context.colors.border,
              width: showCorrect ? AppBorder.b : AppBorder.thin,
            ),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Row(
            children: <Widget>[
              Text(
                String.fromCharCode(65 + index),
                style: AppType.m2.copyWith(
                  color: showCorrect
                      ? context.colors.success
                      : context.colors.inkMuted,
                ),
              ),
              const SizedBox(width: AppSpace.s12),
              Expanded(
                child: Text(
                  label,
                  style: AppType.b2.copyWith(
                    color: context.colors.ink,
                    fontWeight: showCorrect ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              if (showCorrect)
                Icon(Icons.check, size: 18, color: context.colors.success),
            ],
          ),
        ),
      ),
    );
  }
}
