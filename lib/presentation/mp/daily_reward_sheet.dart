import 'package:flutter/material.dart';

import '../../../core/theme/app_metrics.dart';
import '../../../core/theme/app_type.dart';
import '../../../core/theme/theme_x.dart';
import '../../../core/widgets/hard_button.dart';

/// The "you're done for today" moment, which most apps refuse to give.
///
/// Itemised, so the economy feels fair; restrained, so the reward is the
/// stopping rather than the confetti.
Future<void> showDailyRewardSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: context.colors.scrim,
    builder: (BuildContext ctx) => const _DailyRewardSheet(),
  );
}

class _DailyRewardSheet extends StatelessWidget {
  const _DailyRewardSheet();

  static const List<({String label, String delta})> _items =
      <({String label, String delta})>[
        (label: 'Shlokas read', delta: '+18'),
        (label: 'Checkpoints', delta: '+10'),
        (label: 'Daily goal', delta: '+15'),
      ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border.all(color: context.colors.border, width: AppBorder.hairline),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.sm),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpace.s24,
        AppSpace.s12,
        AppSpace.s24,
        AppSpace.s24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.colors.ink.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
          const SizedBox(height: AppSpace.s24),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: context.colors.gold,
              shape: BoxShape.circle,
              border: Border.all(
                color: context.colors.border,
                width: AppBorder.hairline,
              ),
            ),
            child: Icon(Icons.spa, size: 26, color: context.colors.onGold),
          ),
          const SizedBox(height: AppSpace.s16),
          Text(
            'Nitya Path complete',
            textAlign: TextAlign.center,
            style: AppType.d2.copyWith(color: context.colors.ink),
          ),
          const SizedBox(height: AppSpace.s4),
          Text(
            '13 days in a row',
            style: AppType.b3.copyWith(color: context.colors.inkMuted),
          ),
          const SizedBox(height: AppSpace.s20),
          Row(
            children: <Widget>[
              for (int i = 0; i < 7; i++)
                Expanded(
                  child: Container(
                    height: 38,
                    margin: const EdgeInsets.only(right: AppSpace.s4),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: i < 6
                          ? context.colors.gold
                          : context.colors.surfaceSunken,
                      border: Border.all(
                        color: context.colors.border,
                        width: i < 6 ? AppBorder.hairline : 1,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      const <String>['M', 'T', 'W', 'T', 'F', 'S', 'S'][i],
                      style: AppType.m1.copyWith(
                        fontSize: 10,
                        letterSpacing: 0.2,
                        color: i < 6
                            ? context.colors.onGold
                            : context.colors.inkFaint,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpace.s20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpace.s16,
              vertical: AppSpace.s8,
            ),
            decoration: BoxDecoration(
              color: context.colors.surfaceRaised,
              border: Border.all(color: context.colors.borderQuiet, width: 1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Column(
              children: <Widget>[
                for (final ({String label, String delta}) item in _items)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpace.s6),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            item.label,
                            style: AppType.b2.copyWith(
                              color: context.colors.ink,
                            ),
                          ),
                        ),
                        Text(
                          item.delta,
                          style: AppType.m2.copyWith(
                            color: context.colors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.only(top: AppSpace.s8),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: context.colors.borderQuiet,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'Today',
                          style: AppType.h1.copyWith(color: context.colors.ink),
                        ),
                      ),
                      Text(
                        '+43 MP',
                        style: AppType.m2.copyWith(
                          color: context.colors.accentKesar,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.s16),
          HardButton(
            label: 'Share my streak',
            block: true,
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(height: AppSpace.s12),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Text(
              'Keep scrolling — no more points today, just peace.',
              textAlign: TextAlign.center,
              style: AppType.c1.copyWith(color: context.colors.inkMuted),
            ),
          ),
        ],
      ),
    );
  }
}
