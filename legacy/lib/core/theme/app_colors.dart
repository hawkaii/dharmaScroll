import 'package:flutter/material.dart';

/// Premium palette: warm parchment, one accent (sindoor), soft shadows.
/// Neo-brutalist tokens retained as aliases for backward compatibility but
/// values are softened to the premium system.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.surfaceCanvas,
    required this.surface,
    required this.surfaceRaised,
    required this.surfaceSunken,
    required this.agedStart,
    required this.agedMid,
    required this.agedEnd,
    required this.field,
    required this.onField,
    required this.ink,
    required this.inkMuted,
    required this.inkFaint,
    required this.inkDisabled,
    required this.primary,
    required this.primaryPressed,
    required this.onPrimary,
    required this.accentKesar,
    required this.gold,
    required this.onGold,
    required this.success,
    required this.successTint,
    required this.danger,
    required this.dangerFill,
    required this.border,
    required this.borderQuiet,
    required this.shadow,
    required this.scrim,
  });

  final Color surfaceCanvas;
  final Color surface;
  final Color surfaceRaised;
  final Color surfaceSunken;
  final Color agedStart;
  final Color agedMid;
  final Color agedEnd;
  final Color field;
  final Color onField;
  final Color ink;
  final Color inkMuted;
  final Color inkFaint;
  final Color inkDisabled;
  final Color primary;
  final Color primaryPressed;
  final Color onPrimary;
  final Color accentKesar;
  final Color gold;
  final Color onGold;
  final Color success;
  final Color successTint;
  final Color danger;
  final Color dangerFill;
  final Color border;
  final Color borderQuiet;
  final Color shadow;
  final Color scrim;

  /// Patra — warm parchment, premium.
  static const AppColors patra = AppColors(
    surfaceCanvas: Color(0xFFF5ECD9),
    surface: Color(0xFFFBF6EA),
    surfaceRaised: Color(0xFFFBF6EA),
    surfaceSunken: Color(0xFFF0E6D0),
    agedStart: Color(0xFFF5ECD9),
    agedMid: Color(0xFFF0E6D0),
    agedEnd: Color(0xFFE8DCC4),
    field: Color(0xFF6E1F1A),
    onField: Color(0xFFF5ECD9),
    ink: Color(0xFF2A1C11),
    inkMuted: Color(0xFF5C4A3A),
    inkFaint: Color(0xFF8A7A6A),
    inkDisabled: Color(0xFFB0A090),
    primary: Color(0xFF6E1F1A),
    primaryPressed: Color(0xFF59160F),
    onPrimary: Color(0xFFF5ECD9),
    accentKesar: Color(0xFF6E1F1A),
    gold: Color(0xFF6E1F1A),
    onGold: Color(0xFFF5ECD9),
    success: Color(0xFF3F5C28),
    successTint: Color(0xFFE8F0DC),
    danger: Color(0xFF8E2418),
    dangerFill: Color(0xFF8E2418),
    border: Color(0x1F2A1C11),
    borderQuiet: Color(0x1F2A1C11),
    shadow: Color(0x14000000),
    scrim: Color(0x661A0F0A),
  );

  /// Ratri — dark room.
  static const AppColors ratri = AppColors(
    surfaceCanvas: Color(0xFF1F0F0A),
    surface: Color(0xFF2A150E),
    surfaceRaised: Color(0xFF2A150E),
    surfaceSunken: Color(0xFF1A0E08),
    agedStart: Color(0xFF1F0F0A),
    agedMid: Color(0xFF1A0E08),
    agedEnd: Color(0xFF150A07),
    field: Color(0xFFE8782A),
    onField: Color(0xFF1A0F0A),
    ink: Color(0xFFF3E7CF),
    inkMuted: Color(0xFFC9B38E),
    inkFaint: Color(0xFF9C8264),
    inkDisabled: Color(0xFF5C4432),
    primary: Color(0xFFE8782A),
    primaryPressed: Color(0xFFC95F17),
    onPrimary: Color(0xFF1A0F0A),
    accentKesar: Color(0xFFE8782A),
    gold: Color(0xFFE8782A),
    onGold: Color(0xFF1A0F0A),
    success: Color(0xFF9BC06A),
    successTint: Color(0xFF22301A),
    danger: Color(0xFFE4695A),
    dangerFill: Color(0xFFE4695A),
    border: Color(0x1FF3E7CF),
    borderQuiet: Color(0x1FF3E7CF),
    shadow: Color(0x1F000000),
    scrim: Color(0x8C000000),
  );

  static ColorScheme schemeFor(AppColors c, Brightness brightness) {
    return ColorScheme(
      brightness: brightness,
      primary: c.primary,
      onPrimary: c.onPrimary,
      primaryContainer: c.field,
      onPrimaryContainer: c.onField,
      secondary: c.gold,
      onSecondary: c.onGold,
      secondaryContainer: c.surfaceSunken,
      onSecondaryContainer: c.ink,
      tertiary: c.accentKesar,
      onTertiary: c.onPrimary,
      error: c.dangerFill,
      onError: const Color(0xFFFFF6EE),
      surface: c.surface,
      onSurface: c.ink,
      surfaceContainerLowest: c.surfaceCanvas,
      surfaceContainerLow: c.surface,
      surfaceContainer: c.surfaceRaised,
      surfaceContainerHigh: c.surfaceRaised,
      surfaceContainerHighest: c.surfaceSunken,
      onSurfaceVariant: c.inkMuted,
      outline: c.border,
      outlineVariant: c.borderQuiet,
      shadow: c.shadow,
      scrim: c.scrim,
      inverseSurface: c.ink,
      onInverseSurface: c.surfaceCanvas,
      inversePrimary: c.gold,
    );
  }

  @override
  AppColors copyWith({
    Color? surfaceCanvas, Color? surface, Color? surfaceRaised,
    Color? surfaceSunken, Color? agedStart, Color? agedMid, Color? agedEnd,
    Color? field, Color? onField, Color? ink, Color? inkMuted, Color? inkFaint,
    Color? inkDisabled, Color? primary, Color? primaryPressed, Color? onPrimary,
    Color? accentKesar, Color? gold, Color? onGold, Color? success,
    Color? successTint, Color? danger, Color? dangerFill, Color? border,
    Color? borderQuiet, Color? shadow, Color? scrim,
  }) {
    return AppColors(
      surfaceCanvas: surfaceCanvas ?? this.surfaceCanvas,
      surface: surface ?? this.surface,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      surfaceSunken: surfaceSunken ?? this.surfaceSunken,
      agedStart: agedStart ?? this.agedStart,
      agedMid: agedMid ?? this.agedMid,
      agedEnd: agedEnd ?? this.agedEnd,
      field: field ?? this.field,
      onField: onField ?? this.onField,
      ink: ink ?? this.ink,
      inkMuted: inkMuted ?? this.inkMuted,
      inkFaint: inkFaint ?? this.inkFaint,
      inkDisabled: inkDisabled ?? this.inkDisabled,
      primary: primary ?? this.primary,
      primaryPressed: primaryPressed ?? this.primaryPressed,
      onPrimary: onPrimary ?? this.onPrimary,
      accentKesar: accentKesar ?? this.accentKesar,
      gold: gold ?? this.gold,
      onGold: onGold ?? this.onGold,
      success: success ?? this.success,
      successTint: successTint ?? this.successTint,
      danger: danger ?? this.danger,
      dangerFill: dangerFill ?? this.dangerFill,
      border: border ?? this.border,
      borderQuiet: borderQuiet ?? this.borderQuiet,
      shadow: shadow ?? this.shadow,
      scrim: scrim ?? this.scrim,
    );
  }

  @override
  AppColors lerp(covariant ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t) ?? a;
    return AppColors(
      surfaceCanvas: mix(surfaceCanvas, other.surfaceCanvas),
      surface: mix(surface, other.surface),
      surfaceRaised: mix(surfaceRaised, other.surfaceRaised),
      surfaceSunken: mix(surfaceSunken, other.surfaceSunken),
      agedStart: mix(agedStart, other.agedStart),
      agedMid: mix(agedMid, other.agedMid),
      agedEnd: mix(agedEnd, other.agedEnd),
      field: mix(field, other.field),
      onField: mix(onField, other.onField),
      ink: mix(ink, other.ink),
      inkMuted: mix(inkMuted, other.inkMuted),
      inkFaint: mix(inkFaint, other.inkFaint),
      inkDisabled: mix(inkDisabled, other.inkDisabled),
      primary: mix(primary, other.primary),
      primaryPressed: mix(primaryPressed, other.primaryPressed),
      onPrimary: mix(onPrimary, other.onPrimary),
      accentKesar: mix(accentKesar, other.accentKesar),
      gold: mix(gold, other.gold),
      onGold: mix(onGold, other.onGold),
      success: mix(success, other.success),
      successTint: mix(successTint, other.successTint),
      danger: mix(danger, other.danger),
      dangerFill: mix(dangerFill, other.dangerFill),
      border: mix(border, other.border),
      borderQuiet: mix(borderQuiet, other.borderQuiet),
      shadow: mix(shadow, other.shadow),
      scrim: mix(scrim, other.scrim),
    );
  }
}
