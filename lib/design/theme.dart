import 'package:flutter/material.dart';

import 'tokens.dart';

abstract final class DharmaTheme {
  static ThemeData of(DharmaColors c) {
    final ColorScheme scheme = ColorScheme(
      brightness: c.isLight ? Brightness.light : Brightness.dark,
      primary: Tok.marigold,
      onPrimary: Tok.btnInk,
      secondary: Tok.saffron,
      onSecondary: Tok.btnInk,
      error: c.rose,
      onError: Tok.btnInk,
      surface: c.surface,
      onSurface: c.ink,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.bg,
      canvasColor: c.bg,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      fontFamily: DType.serif,
      textTheme: ThemeData(brightness: scheme.brightness).textTheme.apply(
        fontFamily: DType.serif,
        bodyColor: c.ink,
        displayColor: c.ink,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStatePropertyAll<Color>(
          c.isLight ? c.surface : Tok.btnInk,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (Set<WidgetState> s) =>
              s.contains(WidgetState.selected) ? Tok.saffron : c.raised,
        ),
        trackOutlineColor: const WidgetStatePropertyAll<Color>(
          Colors.transparent,
        ),
      ),
      extensions: <ThemeExtension<dynamic>>[c],
    );
  }

  static final ThemeData night = of(DharmaColors.night);
  static final ThemeData dawn = of(DharmaColors.dawn);

  /// Appearance=Auto: Today is light from 05:00 to 10:00 local time.
  static bool isDawnHour(DateTime now) => now.hour >= 5 && now.hour < 10;
}
