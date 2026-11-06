import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Type metrics, colour-free.
///
/// Sizes, weights, heights and tracking never change between light and Ratri —
/// only colour does. Keeping colour out means one definition per style,
/// applied once by the theme.
///
/// Archivo, Instrument Sans and Noto Sans Devanagari ship as variable fonts.
/// Flutter does **not** map [FontWeight] onto the `wght` axis, so every style on
/// a variable family must also carry a [FontVariation] — otherwise w900 renders
/// at w400 and the display type looks like default UI text.
abstract final class AppType {
  static const String display = 'Archivo';
  static const String ui = 'InstrumentSans';
  static const String mono = 'IBMPlexMono';
  static const String skt = 'TiroDevaSanskrit';
  static const String hindi = 'TiroDevaHindi';
  static const String hindiUi = 'NotoSansDevanagari';

  static const List<String> latinFallback = <String>['NotoSansDevanagari'];
  static const List<String> devaFallback = <String>[
    'TiroDevaHindi',
    'NotoSansDevanagari',
  ];

  static const List<FontVariation> _w400 = <FontVariation>[
    FontVariation('wght', 400),
  ];
  static const List<FontVariation> _w500 = <FontVariation>[
    FontVariation('wght', 500),
  ];
  static const List<FontVariation> _w600 = <FontVariation>[
    FontVariation('wght', 600),
  ];
  static const List<FontVariation> _w700 = <FontVariation>[
    FontVariation('wght', 700),
  ];
  static const List<FontVariation> _w800 = <FontVariation>[
    FontVariation('wght', 800),
  ];
  static const List<FontVariation> _w900 = <FontVariation>[
    FontVariation('wght', 900),
  ];

  // ── Display ────────────────────────────────────────────────────────────────
  static const TextStyle d1 = TextStyle(
    fontFamily: display,
    fontSize: 40,
    height: 1.1,
    fontWeight: FontWeight.w900,
    fontVariations: _w900,
    letterSpacing: -0.8,
  );

  static const TextStyle d2 = TextStyle(
    fontFamily: display,
    fontSize: 32,
    height: 1.12,
    fontWeight: FontWeight.w800,
    fontVariations: _w800,
    letterSpacing: -0.5,
  );

  static const TextStyle d3 = TextStyle(
    fontFamily: display,
    fontSize: 26,
    height: 1.23,
    fontWeight: FontWeight.w800,
    fontVariations: _w800,
    letterSpacing: -0.3,
  );

  static const TextStyle t1 = TextStyle(
    fontFamily: display,
    fontSize: 22,
    height: 1.27,
    fontWeight: FontWeight.w700,
    fontVariations: _w700,
    letterSpacing: -0.1,
  );

  static const TextStyle t2 = TextStyle(
    fontFamily: display,
    fontSize: 18,
    height: 1.33,
    fontWeight: FontWeight.w700,
    fontVariations: _w700,
  );

  // ── UI and reading body ────────────────────────────────────────────────────
  static const TextStyle h1 = TextStyle(
    fontFamily: ui,
    fontSize: 17,
    height: 1.53,
    fontWeight: FontWeight.w600,
    fontVariations: _w600,
  );

  static const TextStyle b1 = TextStyle(
    fontFamily: ui,
    fontSize: 17,
    height: 1.65,
    fontWeight: FontWeight.w400,
    fontVariations: _w400,
  );

  static const TextStyle b2 = TextStyle(
    fontFamily: ui,
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w400,
    fontVariations: _w400,
  );

  static const TextStyle b3 = TextStyle(
    fontFamily: ui,
    fontSize: 14,
    height: 1.5,
    fontWeight: FontWeight.w400,
    fontVariations: _w400,
  );

  static const TextStyle l1 = TextStyle(
    fontFamily: ui,
    fontSize: 13,
    height: 1.38,
    fontWeight: FontWeight.w500,
    fontVariations: _w500,
    letterSpacing: 0.06,
  );

  static const TextStyle c1 = TextStyle(
    fontFamily: ui,
    fontSize: 12,
    height: 1.33,
    fontWeight: FontWeight.w400,
    fontVariations: _w400,
    letterSpacing: 0.12,
  );

  // ── Printed labels and numbers (static weights) ────────────────────────────
  static const TextStyle m1 = TextStyle(
    fontFamily: mono,
    fontSize: 11,
    height: 1.27,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.5,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
  );

  static const TextStyle m2 = TextStyle(
    fontFamily: mono,
    fontSize: 13,
    height: 1.38,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.26,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
  );

  // ── Devanagari ─────────────────────────────────────────────────────────────
  /// The verse. 28 sp with 1.55 leading: enough air for matras above and below
  /// the headstroke without breaking the four-pada block into separate thoughts.
  static const TextStyle sktL = TextStyle(
    fontFamily: skt,
    fontFamilyFallback: devaFallback,
    fontSize: 28,
    height: 1.55,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const TextStyle sktM = TextStyle(
    fontFamily: skt,
    fontFamilyFallback: devaFallback,
    fontSize: 24,
    height: 1.58,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// The floor. Sanskrit never renders below 20 sp.
  static const TextStyle sktS = TextStyle(
    fontFamily: skt,
    fontFamilyFallback: devaFallback,
    fontSize: 20,
    height: 1.6,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const TextStyle iast = TextStyle(
    fontFamily: ui,
    // Instrument Sans is missing the IAST diacritics (ṇ, ṣ, ṛ). Tiro Sanskrit
    // carries the full transliteration set, so it is the fallback here even
    // though the body face is the UI sans.
    fontFamilyFallback: <String>['TiroDevaSanskrit', 'NotoSansDevanagari'],
    fontSize: 13,
    height: 1.69,
    fontWeight: FontWeight.w400,
    fontVariations: _w400,
    letterSpacing: 0.13,
    fontStyle: FontStyle.italic,
  );

  static const TextStyle hiRead = TextStyle(
    fontFamily: hindi,
    fontSize: 17,
    height: 1.76,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );

  static const TextStyle hiUi = TextStyle(
    fontFamily: hindiUi,
    fontSize: 15,
    height: 1.47,
    fontWeight: FontWeight.w500,
    fontVariations: _w500,
    letterSpacing: 0,
  );

  /// Material's 15 slots, mapped honestly and coloured for the active theme.
  static TextTheme textTheme(AppColors c) {
    return TextTheme(
      displayLarge: d1.copyWith(color: c.ink),
      displayMedium: d2.copyWith(color: c.ink),
      displaySmall: d3.copyWith(color: c.ink),
      headlineLarge: t1.copyWith(color: c.ink),
      headlineMedium: t2.copyWith(color: c.ink),
      headlineSmall: h1.copyWith(color: c.ink),
      titleLarge: t1.copyWith(color: c.ink),
      titleMedium: h1.copyWith(color: c.ink),
      titleSmall: l1.copyWith(color: c.inkMuted),
      bodyLarge: b1.copyWith(color: c.ink),
      bodyMedium: b2.copyWith(color: c.ink),
      bodySmall: b3.copyWith(color: c.inkMuted),
      labelLarge: l1.copyWith(color: c.ink),
      labelMedium: m2.copyWith(color: c.inkMuted),
      labelSmall: m1.copyWith(color: c.inkMuted),
    );
  }
}

/// The Devanagari slots, coloured.
///
/// `TextTheme`'s fifteen names are for Latin roles; mapping shloka, Hindi
/// reading and transliteration onto them would be a lie that costs a rename
/// later. A typed extension stays honest and still swaps with the theme.
@immutable
class DevText extends ThemeExtension<DevText> {
  const DevText({
    required this.shloka,
    required this.shlokaCompact,
    required this.verse,
    required this.word,
    required this.iast,
    required this.hindi,
    required this.hindiUi,
  });

  final TextStyle shloka;
  final TextStyle shlokaCompact;
  final TextStyle verse;
  final TextStyle word;
  final TextStyle iast;
  final TextStyle hindi;
  final TextStyle hindiUi;

  factory DevText.of(AppColors c) {
    return DevText(
      shloka: AppType.sktL.copyWith(color: c.field),
      shlokaCompact: AppType.sktM.copyWith(color: c.field),
      verse: AppType.sktM.copyWith(color: c.field),
      word: AppType.sktS.copyWith(color: c.field),
      iast: AppType.iast.copyWith(color: c.inkMuted),
      hindi: AppType.hiRead.copyWith(color: c.ink),
      hindiUi: AppType.hiUi.copyWith(color: c.ink),
    );
  }

  @override
  DevText copyWith({
    TextStyle? shloka,
    TextStyle? shlokaCompact,
    TextStyle? verse,
    TextStyle? word,
    TextStyle? iast,
    TextStyle? hindi,
    TextStyle? hindiUi,
  }) {
    return DevText(
      shloka: shloka ?? this.shloka,
      shlokaCompact: shlokaCompact ?? this.shlokaCompact,
      verse: verse ?? this.verse,
      word: word ?? this.word,
      iast: iast ?? this.iast,
      hindi: hindi ?? this.hindi,
      hindiUi: hindiUi ?? this.hindiUi,
    );
  }

  @override
  DevText lerp(covariant ThemeExtension<DevText>? other, double t) {
    if (other is! DevText) {
      return this;
    }
    TextStyle mix(TextStyle a, TextStyle b) => TextStyle.lerp(a, b, t) ?? a;
    return DevText(
      shloka: mix(shloka, other.shloka),
      shlokaCompact: mix(shlokaCompact, other.shlokaCompact),
      verse: mix(verse, other.verse),
      word: mix(word, other.word),
      iast: mix(iast, other.iast),
      hindi: mix(hindi, other.hindi),
      hindiUi: mix(hindiUi, other.hindiUi),
    );
  }
}
