import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_metrics.dart';
import 'app_type.dart';

/// Two themes, hand-built.
///
/// The starter template derived everything from one seed with
/// `ColorScheme.fromSeed`; that algorithm desaturates toward neutral and would
/// turn this palette into brown-grey. The scheme is assembled explicitly from
/// [AppColors] instead, and Material's soft elevation is stripped globally so a
/// stray `Card` cannot contradict the hard-edged component language.
abstract final class AppTheme {
  static ThemeData get light => _build(AppColors.patra, Brightness.light);

  static ThemeData get dark => _build(AppColors.ratri, Brightness.dark);

  static ThemeData _build(AppColors c, Brightness brightness) {
    final ColorScheme scheme = AppColors.schemeFor(c, brightness);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.surfaceCanvas,
      canvasColor: c.surfaceCanvas,
      textTheme: AppType.textTheme(c),
      extensions: <ThemeExtension<dynamic>>[c, DevText.of(c)],
      // Material's ink splashes fight a hard offset shadow — they look like a
      // second, softer light source.
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      dividerTheme: DividerThemeData(
        thickness: AppBorder.thin,
        color: c.borderQuiet,
        space: AppSpace.s16,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: c.surfaceCanvas,
        foregroundColor: c.ink,
        centerTitle: false,
        titleTextStyle: AppType.t1.copyWith(color: c.ink),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: Colors.transparent,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}
