import 'package:flutter/material.dart';

import '../theme/app_metrics.dart';
import '../theme/app_type.dart';
import '../theme/theme_x.dart';

/// The wallet, and the only number worth chasing.
///
/// Deliberately has no red "unclaimed" state: there is nothing to claim.
class MpPill extends StatelessWidget {
  const MpPill({
    super.key,
    required this.points,
    this.awarding = false,
    this.compact = false,
  });

  final int points;
  final bool awarding;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$points Moksh Points',
      child: AnimatedScale(
        scale: awarding ? 1.08 : 1,
        duration: AppMotion.resolve(context, AppMotion.fast),
        curve: AppMotion.emphasis,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? AppSpace.s8 : AppSpace.s12,
            vertical: AppSpace.s4,
          ),
          decoration: BoxDecoration(
            color: context.colors.field,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.spa, size: 13, color: context.colors.gold),
              const SizedBox(width: AppSpace.s4),
              Text(
                _format(points),
                style: AppType.m2.copyWith(
                  color: context.colors.gold,
                  fontSize: compact ? 12 : 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _format(int value) {
    final String digits = value.toString();
    if (digits.length <= 4) {
      return digits;
    }
    // Indian grouping above 99,999: 1,24,000.
    final String last3 = digits.substring(digits.length - 3);
    final String rest = digits.substring(0, digits.length - 3);
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < rest.length; i++) {
      if (i > 0 && (rest.length - i) % 2 == 0) {
        buffer.write(',');
      }
      buffer.write(rest[i]);
    }
    return '$buffer,$last3';
  }
}
