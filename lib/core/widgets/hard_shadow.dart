import 'package:flutter/material.dart';

import '../theme/app_metrics.dart';
import '../theme/theme_x.dart';

/// A solid offset plate, not a blurred shadow.
///
/// The offset rect is painted as a sibling behind [child] instead of through
/// `BoxShadow`, which keeps the decorated child opaque (so it stays cacheable)
/// and makes the press animation a position change rather than a mask
/// re-raster. Never add a blur radius here — the whole visual language depends
/// on the edge being hard.
class HardShadow extends StatelessWidget {
  const HardShadow({
    super.key,
    this.offset = AppShadow.s7,
    this.radius = AppRadius.sm,
    this.color,
    required this.child,
  });

  final Offset offset;
  final double radius;
  final Color? color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Color shadow = color ?? context.colors.shadow;

    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Positioned(
          left: offset.dx,
          top: offset.dy,
          right: -offset.dx,
          bottom: -offset.dy,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: shadow,
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
