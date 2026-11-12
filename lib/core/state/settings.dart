import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app_providers.dart';
import '../../design/widgets.dart';
import '../feedback/sound_service.dart';

enum Language { hindi, english, hinglish }

enum Appearance { auto, night }

@immutable
class Settings {
  const Settings({
    this.onboarded = false,
    this.reminderMinutes = 6 * 60 + 30,
    this.language = Language.hinglish,
    this.soundHaptics = true,
    this.appearance = Appearance.auto,
  });

  final bool onboarded;
  final int reminderMinutes;
  final Language language;
  final bool soundHaptics;
  final Appearance appearance;

  Settings copyWith({
    bool? onboarded,
    int? reminderMinutes,
    Language? language,
    bool? soundHaptics,
    Appearance? appearance,
  }) => Settings(
    onboarded: onboarded ?? this.onboarded,
    reminderMinutes: reminderMinutes ?? this.reminderMinutes,
    language: language ?? this.language,
    soundHaptics: soundHaptics ?? this.soundHaptics,
    appearance: appearance ?? this.appearance,
  );
}

/// The five things the You tab can change, plus the once-only onboarding flag.
class SettingsNotifier extends Notifier<Settings> {
  static const String kOnboarded = 'onboardingComplete';
  static const String kReminder = 'remindAtMinutes';
  static const String kLang = 'lang';
  static const String kSound = 'soundHaptics';
  static const String kAppearance = 'appearance';

  SharedPreferences get _p => ref.read(sharedPrefsProvider);

  @override
  Settings build() {
    final SharedPreferences p = ref.watch(sharedPrefsProvider);
    final Settings s = Settings(
      onboarded: p.getBool(kOnboarded) ?? false,
      reminderMinutes: p.getInt(kReminder) ?? 6 * 60 + 30,
      language: Language.values.firstWhere(
        (Language l) => l.name == p.getString(kLang),
        orElse: () => Language.hinglish,
      ),
      soundHaptics: p.getBool(kSound) ?? true,
      appearance: Appearance.values.firstWhere(
        (Appearance a) => a.name == p.getString(kAppearance),
        orElse: () => Appearance.auto,
      ),
    );
    Haptics.enabled = s.soundHaptics;
    SoundService.instance.enabled = s.soundHaptics;
    return s;
  }

  void setReminder(int minutes) {
    state = state.copyWith(reminderMinutes: minutes);
    _p.setInt(kReminder, minutes);
  }

  void setLanguage(Language l) {
    state = state.copyWith(language: l);
    _p.setString(kLang, l.name);
  }

  void setSoundHaptics(bool v) {
    Haptics.enabled = v;
    SoundService.instance.enabled = v;
    // Let the person hear and feel what they just switched on.
    if (v) {
      Haptics.tick();
      SoundService.instance.play(Sfx.tap);
    }
    state = state.copyWith(soundHaptics: v);
    _p.setBool(kSound, v);
  }

  void setAppearance(Appearance a) {
    state = state.copyWith(appearance: a);
    _p.setString(kAppearance, a.name);
  }

  void completeOnboarding() {
    state = state.copyWith(onboarded: true);
    _p.setBool(kOnboarded, true);
  }
}

final NotifierProvider<SettingsNotifier, Settings> settingsProvider =
    NotifierProvider<SettingsNotifier, Settings>(SettingsNotifier.new);
