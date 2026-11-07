import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_metrics.dart';
import '../theme/theme_x.dart';

/// Premium surface: soft corners, optional soft shadow, no hard borders.
class PaperPlate extends StatelessWidget {
  const PaperPlate({
    super.key,
    this.color,
    this.borderColor,
    this.borderWidth = AppBorder.none,
    this.radius = AppRadius.sm,
    this.shadow = AppShadow.none,
    this.padding = const EdgeInsets.all(AppSpace.s16),
    this.child,
  });

  final Color? color;
  final Color? borderColor;
  final double borderWidth;
  final double radius;
  final List<BoxShadow> shadow;
  final EdgeInsetsGeometry padding;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final Color fill = color ?? context.colors.surface;

    final BoxDecoration decoration = BoxDecoration(
      color: fill,
      border: borderWidth > 0
          ? Border.all(
              color: borderColor ?? context.colors.border,
              width: borderWidth,
            )
          : null,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: shadow.isEmpty ? null : shadow,
    );

    return DecoratedBox(
      decoration: decoration,
      child: Padding(padding: padding, child: child),
    );
  }
}