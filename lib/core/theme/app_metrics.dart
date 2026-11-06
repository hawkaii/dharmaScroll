import 'package:flutter/material.dart';

/// Spacing, radii, strokes, shadow offsets and motion durations.
///
/// All compile-time constants, so they are plain classes rather than theme
/// extensions: wrapping them would buy a `Theme.of` lookup for nothing.
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
  static const double s56 = 56;

  /// Screen gutter on a 360–430 dp phone.
  static const double gutter = 20;
}

abstract final class AppRadius {
  static const double none = 0;

  /// Stamps and mono labels. HTML `radius: 2`.
  static const double xs = 2;

  /// Cards and buttons. HTML `.bt`, `.wc`, `.plate` all use 7 px.
  static const double sm = 7;

  /// Chips and MP badges. HTML `.ch`, `.mp` use 9 px.
  static const double md = 9;

  /// Sheet top corners. HTML `.sheet` uses 14 px.
  static const double lg = 14;
  static const double pill = 999;
}

abstract final class AppBorder {
  static const double hairline = 1;
  static const double thin = 2;

  /// The default structural stroke. HTML `--b: 3px solid`.
  static const double b = 3;

  /// Modals and the crisis card, where 3 dp would not separate at all.
  static const double heavy = 4;
}

abstract final class AppShadow {
  static const Offset none = Offset.zero;

  /// Stamps, chips, small inset blocks. HTML `4px 4px 0`.
  static const Offset s4 = Offset(4, 4);

  /// Buttons, plates, the mic. HTML `--sh: 7px 7px 0`.
  static const Offset s7 = Offset(7, 7);

  /// While a control is held down. HTML `:active` uses 3px with translate(4,4).
  static const Offset press = Offset(3, 3);

  /// Depth reserved around a lifted object so a tight parent cannot clip it.
  static const double reserve = 7;
}

abstract final class AppMotion {
  static const Duration instant = Duration(milliseconds: 90);
  static const Duration fast = Duration(milliseconds: 160);
  static const Duration normal = Duration(milliseconds: 280);
  static const Duration slow = Duration(milliseconds: 480);
  static const Duration burst = Duration(milliseconds: 900);

  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
  static const Curve emphasis = Curves.easeOutBack;

  /// Every animated duration goes through here, so a single OS flag can still
  /// the whole app without a second code path.
  static Duration resolve(BuildContext context, Duration duration) {
    return MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration;
  }
}
