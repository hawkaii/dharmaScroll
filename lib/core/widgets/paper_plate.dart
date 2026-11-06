import 'package:flutter/material.dart';

import '../theme/app_metrics.dart';
import '../theme/theme_x.dart';
import 'hard_shadow.dart';

/// The generic parchment surface: every block that is not a verse or a button.
///
/// `shadow: AppShadow.none` is the default for anything that sits inside a
/// scroll and is not tappable — a feed card, a ledger row, a sheet interior.
/// Only liftable objects get the offset.
class PaperPlate extends StatelessWidget {
  const PaperPlate({
    super.key,
    this.color,
    this.borderColor,
    this.borderWidth = AppBorder.b,
    this.radius = AppRadius.sm,
    this.shadow = AppShadow.s7,
    this.padding = const EdgeInsets.all(AppSpace.s20),
    this.gradient,
    this.child,
  });

  /// The aged-parchment variant used by feed art and share cards.
  const PaperPlate.aged({
    super.key,
    this.borderColor,
    this.borderWidth = AppBorder.b,
    this.radius = AppRadius.sm,
    this.shadow = AppShadow.none,
    this.padding = const EdgeInsets.all(AppSpace.s20),
    this.child,
  }) : color = null,
       gradient = null;

  final Color? color;
  final Color? borderColor;
  final double borderWidth;
  final double radius;
  final Offset shadow;
  final EdgeInsetsGeometry padding;
  final Gradient? gradient;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final bool aged = gradient == null && color == null;
    final Color fill = color ?? context.colors.surface;

    final BoxDecoration decoration = BoxDecoration(
      color: aged ? null : fill,
      gradient: aged
          ? RadialGradient(
              center: const Alignment(0, -0.45),
              radius: 0.95,
              colors: <Color>[context.colors.agedStart, context.colors.agedEnd],
              stops: const <double>[0.15, 1],
            )
          : gradient,
      border: Border.all(
        color: borderColor ?? context.colors.border,
        width: borderWidth,
      ),
      borderRadius: BorderRadius.circular(radius),
    );

    final Widget body = DecoratedBox(
      decoration: decoration,
      child: Padding(padding: padding, child: child),
    );

    if (shadow == Offset.zero) {
      return body;
    }
    return HardShadow(offset: shadow, radius: radius, child: body);
  }
}
