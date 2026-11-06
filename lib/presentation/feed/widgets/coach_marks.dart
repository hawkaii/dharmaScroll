import 'package:flutter/material.dart';

import '../../../core/theme/app_metrics.dart';
import '../../../core/theme/app_type.dart';
import '../../../core/theme/theme_x.dart';

/// Four gestures, overlaid on the very first real card.
///
/// Sits at the top of the card, above the verse, exactly as the wireframe puts
/// it — so it explains the gestures without covering the thing it is explaining.
class CoachMarks extends StatelessWidget {
  const CoachMarks({super.key, required this.onDismiss});

  final VoidCallback onDismiss;

  static const List<({IconData icon, String label})> _rows =
      <({IconData icon, String label})>[
        (icon: Icons.keyboard_arrow_up, label: 'Swipe up for the next shloka'),
        (icon: Icons.auto_stories_outlined, label: 'Tap to go deeper'),
        (icon: Icons.bookmark_border, label: 'Double-tap to save'),
        (icon: Icons.mic_none, label: 'Hold the mic to share your day'),
      ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDismiss,
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          AppSpace.s16,
          AppSpace.s12,
          AppSpace.s16,
          0,
        ),
        padding: const EdgeInsets.fromLTRB(
          AppSpace.s16,
          AppSpace.s12,
          AppSpace.s16,
          AppSpace.s16,
        ),
        decoration: BoxDecoration(
          color: context.colors.field,
          border: Border.all(color: context.colors.border, width: AppBorder.b),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          boxShadow: const <BoxShadow>[],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'HOW DHARMASCROLL WORKS',
              style: AppType.m1.copyWith(color: context.colors.gold),
            ),
            const SizedBox(height: AppSpace.s8),
            for (final ({IconData icon, String label}) row in _rows)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpace.s4),
                child: Row(
                  children: <Widget>[
                    Icon(row.icon, size: 16, color: context.colors.gold),
                    const SizedBox(width: AppSpace.s8),
                    Expanded(
                      child: Text(
                        row.label,
                        style: AppType.b3.copyWith(
                          color: context.colors.onField,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Samajh gaya',
                style: AppType.l1.copyWith(color: context.colors.gold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
