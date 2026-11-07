import 'package:flutter/material.dart';

import '../theme/app_metrics.dart';
import '../theme/app_type.dart';
import '../theme/theme_x.dart';

enum StampTone { gold, paper, field, success }

/// The printed label that makes a screen feel issued rather than rendered.
///
/// Static by design — never tappable, and at most one rotated stamp per screen.
class Stamp extends StatelessWidget {
  const Stamp(
    this.label, {
    super.key,
    this.tone = StampTone.gold,
    this.rotate = false,
  });

  final String label;
  final StampTone tone;
  final bool rotate;

  @override
  Widget build(BuildContext context) {
    final (Color fill, Color labelColor) = switch (tone) {
      StampTone.gold => (context.colors.gold, context.colors.onGold),
      StampTone.paper => (context.colors.surface, context.colors.ink),
      StampTone.field => (context.colors.field, context.colors.onField),
      StampTone.success => (context.colors.successTint, context.colors.success),
    };

    final Widget body = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.s12,
        vertical: AppSpace.s6,
      ),
      decoration: BoxDecoration(
        color: fill,
        border: Border.all(color: context.colors.border, width: AppBorder.hairline),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppType.m1.copyWith(color: labelColor),
      ),
    );

    if (!rotate) {
      return body;
    }
    return Transform.rotate(angle: -0.035, child: body);
  }
}

/// A tiny local wrapper so a rotated stamp keeps its hard shadow rotated with
/// it instead of staying axis-aligned.
class HardShadowStamp extends StatelessWidget {
  const HardShadowStamp({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Positioned(
          left: 4,
          top: 4,
          right: -4,
          bottom: -4,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: context.colors.shadow,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

/// A short mono label above a block. Use at most one per screen.
class Eyebrow extends StatelessWidget {
  const Eyebrow(this.label, {super.key, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: AppType.m1.copyWith(color: color ?? context.colors.accentKesar),
    );
  }
}
