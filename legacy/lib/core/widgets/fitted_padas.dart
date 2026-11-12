import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_type.dart';

/// Renders a shloka one pada per line, at the largest size that fits.
///
/// A shloka may never be broken mid-word, and Sanskrit may never render below
/// 20 sp. So the size steps down 28 → 26 → 24 → 22 → 20 until the widest pada
/// fits the column; if even 20 sp overflows, the pada wraps rather than
/// shrinking further. This is why `padas` is a list in the model and not a
/// string with newlines: the layout engine must never choose the break.
class FittedPadas extends StatelessWidget {
  const FittedPadas({
    super.key,
    required this.padas,
    required this.color,
    this.align = TextAlign.center,
  });

  final List<String> padas;
  final Color color;
  final TextAlign align;

  static const List<double> steps = <double>[28, 26, 24, 22, 20];

  /// The largest step that fits [width] for these padas, never below 20.
  static double sizeFor(List<String> padas, double width, TextScaler scaler) {
    for (final double candidate in steps) {
      final TextStyle style = AppType.sktL.copyWith(fontSize: candidate);
      double widest = 0;
      for (final String pada in padas) {
        final TextPainter painter = TextPainter(
          text: TextSpan(text: pada, style: style),
          textDirection: TextDirection.ltr,
          textScaler: scaler,
        )..layout();
        widest = math.max(widest, painter.width);
      }
      if (widest <= width) {
        return candidate;
      }
    }
    return steps.last;
  }

  @override
  Widget build(BuildContext context) {
    final TextScaler scaler = MediaQuery.textScalerOf(context);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double size = sizeFor(padas, constraints.maxWidth, scaler);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            for (final String pada in padas)
              Text(
                pada,
                textAlign: align,
                style: AppType.sktL.copyWith(fontSize: size, color: color),
              ),
          ],
        );
      },
    );
  }
}
