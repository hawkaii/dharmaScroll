import 'package:flutter/material.dart';

/// Spacing, radii, strokes, shadow offsets and motion durations.
///
/// Premium system: 8 dp base unit, soft shadows, generous radii, minimal strokes.
abstract final class AppSpace {
  static const double s2 = 2;
  static const double s4 = 4;
  static const double s6 = 6;
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s32 = 32;
  static const double s40 = 40;
  static const double s48 = 48;
  static const double s56 = 56;
  static const double s64 = 64;

  /// Screen gutter on a 360–430 dp phone.
  static const double gutter = 16;
}

abstract final class AppRadius {
  static const double none = 0;

  /// Cards, buttons, inputs, sheet corners.
  static const double sm = 12;

  /// Pills, chips, avatars, mic.
  static const double pill = 999;
}

abstract final class AppBorder {
  static const double none = 0;
  static const double hairline = 1;

  /// Inputs only.
  static const double input = 1;
}

abstract final class AppShadow {
  /// No shadow — default for cards, rows, chips.
  static const List<BoxShadow> none = <BoxShadow>[];

  /// Soft shadow for liftable objects (buttons, floating sheets, modals).
  static const List<BoxShadow> soft = <BoxShadow>[
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  /// Elevated shadow for modals and sheets.
  static const List<BoxShadow> elevated = <BoxShadow>[
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];
}

abstract final class AppMotion {
  static const Duration instant = Duration(milliseconds: 80);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration page = Duration(milliseconds: 280);
  static const Duration sheet = Duration(milliseconds: 320);
  static const Duration reward = Duration(milliseconds: 480);

  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
  static const Curve emphasis = Curves.easeOutBack;

  static Duration resolve(BuildContext context, Duration duration) {
    return MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration;
  }
}