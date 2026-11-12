import 'package:flutter/material.dart';

/// The single source of design values (board v3, docs/design-board-v3/HANDOFF.md).
/// No other file may contain a `Color(0x...)` literal.

/// Colours for one mode. Read through `context.c`.
@immutable
class DharmaColors extends ThemeExtension<DharmaColors> {
  const DharmaColors({
    required this.bg,
    required this.surface,
    required this.raised,
    required this.line,
    required this.ink,
    required this.mute,
    required this.faint,
    required this.accent,
    required this.verse,
    required this.rose,
    required this.peacock,
    required this.glowTop,
    required this.glowBottom,
    required this.mandalaOpacity,
    required this.isLight,
  });

  final Color bg;
  final Color surface;
  final Color raised;
  final Color line;
  final Color ink;
  final Color mute;
  final Color faint;

  /// Icons, active tab, eyebrow text.
  final Color accent;

  /// Sanskrit text colour.
  final Color verse;
  final Color rose;
  final Color peacock;
  final Color glowTop;
  final Color glowBottom;
  final double mandalaOpacity;
  final bool isLight;

  static const DharmaColors night = DharmaColors(
    bg: Color(0xFF1A0F24),
    surface: Color(0xFF2A1A38),
    raised: Color(0xFF3A2548),
    line: Color(0x1FFBEFD9),
    ink: Color(0xFFFBEFD9),
    mute: Color(0xFFC9B2B8),
    faint: Color(0xFF8F7A8C),
    accent: Tok.marigold,
    verse: Tok.gold,
    rose: Color(0xFFE58BA3),
    peacock: Color(0xFF4FB3AB),
    glowTop: Color(0x38F28C28),
    glowBottom: Color(0x1AE58BA3),
    mandalaOpacity: 0.06,
    isLight: false,
  );

  static const DharmaColors dawn = DharmaColors(
    bg: Color(0xFFFBF3E2),
    surface: Color(0xFFF2E4C8),
    raised: Color(0xFFEBD9B8),
    line: Color(0x242B1A33),
    ink: Color(0xFF2B1A33),
    mute: Color(0xFF6B5565),
    faint: Color(0xFF7A6070),
    accent: Color(0xFFB85A0B),
    verse: Color(0xFF8A5A00),
    rose: Color(0xFFE58BA3),
    peacock: Color(0xFF2F8E87),
    glowTop: Color(0x8CF6B93B),
    glowBottom: Color(0x2EE58BA3),
    mandalaOpacity: 0.09,
    isLight: true,
  );

  @override
  DharmaColors copyWith() => this;

  @override
  DharmaColors lerp(ThemeExtension<DharmaColors>? other, double t) {
    if (other is! DharmaColors) return this;
    return t < 0.5 ? this : other;
  }
}

/// Values that do not change with mode.
abstract final class Tok {
  static const Color marigold = Color(0xFFFFC247);
  static const Color saffron = Color(0xFFF28C28);
  static const Color gold = Color(0xFFF7D58B);
  static const Color btnInk = Color(0xFF2B1300);
  static const Color btnA = Color(0xFFFFC85A);
  static const Color btnB = Color(0xFFF28C28);
  static const Color btnEdge = Color(0xFFB8650C);
  static const Color btnHighlight = Color(0x80FFFFFF);
  static const Color flame = Color(0xFFFFB03B);
  static const Color flameCore = Color(0xFFFFF3CF);
  static const Color flameDim = Color(0xFF6C4A2A);
  static const Color petalRose = Color(0xFFE58BA3);
  static const double lampOff = 0.45;
}

abstract final class Sp {
  static const double s6 = 6;
  static const double s12 = 12;
  static const double s14 = 14;
  static const double s18 = 18;
  static const double s22 = 22;
  static const double s30 = 30;
  static const double s34 = 34;
  static const double screenSide = 26;
  static const double screenTop = 54;
  static const double screenBottom = 30;
}

abstract final class Rad {
  static const double row = 18;
  static const double card = 22;
  static const double button = 28;
}

abstract final class Motion {
  static const Curve spring = Cubic(.22, 1.2, .36, 1);
  static const Curve easeOut = Curves.easeOut;
  static const Duration press = Duration(milliseconds: 90);
  static const Duration select = Duration(milliseconds: 150);
  static const Duration snap = Duration(milliseconds: 380);
  static const Duration listenIn = Duration(milliseconds: 350);
  static const Duration listenOut = Duration(milliseconds: 250);
  static const Duration keepBloom = Duration(milliseconds: 900);
  static const Duration pulse = Duration(milliseconds: 4800);
  static const Duration flicker = Duration(milliseconds: 2600);
  static const Duration breathe = Duration(milliseconds: 3600);
  static const Duration ignite = Duration(milliseconds: 600);
  static const Duration lampStagger = Duration(milliseconds: 140);
  static const Duration countUp = Duration(milliseconds: 1200);
  static const Duration fan = Duration(milliseconds: 1100);
  static const Duration petals = Duration(seconds: 7);
  static const Duration lotus = Duration(milliseconds: 1400);
}

/// Text styles. Sizes are the board's; the system scale applies on top.
abstract final class DType {
  static const String serifDeva = 'NotoSerifDevanagari';
  static const String serif = 'EBGaramond';
  static const String sans = 'Inter';
  static const List<FontFeature> _lining = <FontFeature>[
    FontFeature.liningFigures(),
  ];

  static TextStyle verse(Color c, {double size = 25}) =>
      TextStyle(fontFamily: serifDeva, fontSize: size, height: 1.62, color: c);
  static TextStyle translit(Color c) => TextStyle(
    fontFamily: serif,
    fontFeatures: _lining,
    fontStyle: FontStyle.italic,
    fontSize: 14.5,
    height: 1.5,
    color: c,
  );
  static TextStyle meaning(Color c) => TextStyle(
    fontFamily: serif,
    fontFeatures: _lining,
    fontSize: 21,
    height: 1.38,
    color: c,
  );
  static TextStyle title(Color c, {bool compact = false}) => TextStyle(
    fontFamily: serif,
    fontFeatures: _lining,
    fontSize: compact ? 32 : 36,
    height: 1.12,
    color: c,
  );
  static TextStyle body(Color c, {double size = 19}) => TextStyle(
    fontFamily: serif,
    fontFeatures: _lining,
    fontSize: size,
    height: 1.45,
    color: c,
  );
  static TextStyle eyebrow(Color c) => TextStyle(
    fontFamily: sans,
    fontSize: 10.5,
    letterSpacing: 10.5 * 0.2,
    fontWeight: FontWeight.w500,
    color: c,
  );
  static TextStyle button(Color c) => TextStyle(
    fontFamily: sans,
    fontSize: 15,
    letterSpacing: 15 * 0.03,
    fontWeight: FontWeight.w600,
    color: c,
  );
  static TextStyle hero(Color c, {double size = 88}) => TextStyle(
    fontFamily: serif,
    fontFeatures: _lining,
    fontSize: size,
    height: 1,
    color: c,
  );
  static TextStyle ref(Color c) => TextStyle(
    fontFamily: sans,
    fontSize: 10.5,
    letterSpacing: 10.5 * 0.2,
    color: c,
  );
}

extension DharmaColorsX on BuildContext {
  DharmaColors get c =>
      Theme.of(this).extension<DharmaColors>() ?? DharmaColors.night;
}
