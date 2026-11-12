import 'package:flutter/material.dart';

import '../theme/app_metrics.dart';

/// Soft shadow for liftable objects (buttons, floating sheets, modals).
/// Replaces the old hard offset shadow.
class SoftShadow extends StatelessWidget {
  const SoftShadow({
    super.key,
    this.shadow = AppShadow.soft,
    this.radius = AppRadius.sm,
    required this.child,
  });

  final List<BoxShadow> shadow;
  final double radius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (shadow.isEmpty) return child;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: shadow,
      ),
      child: child,
    );
  }
}