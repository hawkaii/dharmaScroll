import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show WidgetsBinding;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app_providers.dart';
import '../../design/widgets.dart';
import '../feedback/sound_service.dart';
import '../rituals/rituals.dart';

enum Language { hindi, english, hinglish }

enum Appearance { auto, night }

/// How big the words are. The app multiplies the system text size by this.
enum TextSize {
  normal(1),
  large(1.2),
  extraLarge(1.4);

  const TextSize(this.factor);

  final double factor;
}

/// Hindi when the phone is set to Hindi, otherwise English.
Language deviceLanguage() =>
    WidgetsBinding.instance.platformDispatcher.locale.languageCode == 'hi'
    ? Language.hindi
    : Language.english;

@immutable
class Settings {
  const Settings({
    this.onboarded = false,
    this.reminderMinutes = 6 * 60 + 30,
    this.language = Language.english,
    this.textSize = TextSize.normal,
    this.sound = true,
    this.haptics = true,
    this.appearance = Appearance.auto,
    this.cityId = defaultCityId,
    this.tradition = Tradition.unsure,
    this.rituals = const <Ritual>{Ritual.dailyGita},
    this.deity = Deity.none,
  });

  /// Delhi, until the person picks a city.
  static const String defaultCityId = 'new-delhi-in';

  final bool onboarded;
  final int reminderMinutes;
  final Language language;
  final TextSize textSize;
  final bool sound;
  final bool haptics;
  final Appearance appearance;
  final String cityId;
  final Tradition tradition;
  final Set<Ritual> rituals;
  final Deity deity;

  Settings copyWith({
    bool? onboarded,
    int? reminderMinutes,
    Language? language,
    TextSize? textSize,
    bool? sound,
    bool? haptics,
    Appearance? appearance,
    String? cityId,
    Tradition? tradition,
    Set<Ritual>? rituals,
    Deity? deity,
  }) => Settings(
    onboarded: onboarded ?? this.onboarded,
    reminderMinutes: reminderMinutes ?? this.reminderMinutes,
    language: language ?? this.language,
    textSize: textSize ?? this.textSize,
    sound: sound ?? this.sound,
    haptics: haptics ?? this.haptics,
    appearance: appearance ?? this.appearance,
    cityId: cityId ?? this.cityId,
    tradition: tradition ?? this.tradition,
    rituals: rituals ?? this.rituals,
    deity: deity ?? this.deity,
  );
}

/// What You > Settings can change, plus the once-only onboarding flag.
class SettingsNotifier extends Notifier<Settings> {
  static const String kOnboarded = 'onboardingComplete';
  static const String kReminder = 'remindAtMinutes';
  static const String kLang = 'lang';
  static const String kTextSize = 'textSize';

  /// Kept from 0.2.0, when one switch did sound and haptics together.
  static const String kSound = 'soundHaptics';
  static const String kHaptics = 'haptics';
  static const String kAppearance = 'appearance';
  static const String kCity = 'cityId';
  static const String kTradition = 'tradition';
  static const String kRituals = 'rituals';
  static const String kDeity = 'deity';

  SharedPreferences get _p => ref.read(sharedPrefsProvider);

  @override
  Settings build() {
    final SharedPreferences p = ref.watch(sharedPrefsProvider);
    final Settings s = Settings(
      onboarded: p.getBool(kOnboarded) ?? false,
      reminderMinutes: p.getInt(kReminder) ?? 6 * 60 + 30,
      language: Language.values.firstWhere(
        (Language l) => l.name == p.getString(kLang),
        // First launch: follow the phone's language.
        orElse: deviceLanguage,
      ),
      textSize: TextSize.values.firstWhere(
        (TextSize t) => t.name == p.getString(kTextSize),
        orElse: () => TextSize.normal,
      ),
      sound: p.getBool(kSound) ?? true,
      haptics: p.getBool(kHaptics) ?? p.getBool(kSound) ?? true,
      appearance: Appearance.values.firstWhere(
        (Appearance a) => a.name == p.getString(kAppearance),
        orElse: () => Appearance.auto,
      ),
      cityId: p.getString(kCity) ?? Settings.defaultCityId,
      tradition: Tradition.values.firstWhere(
        (Tradition t) => t.name == p.getString(kTradition),
        orElse: () => Tradition.unsure,
      ),
      rituals: p.containsKey(kRituals)
          ? <Ritual>{
              for (final String n in p.getStringList(kRituals)!)
                for (final Ritual r in Ritual.values)
                  if (r.name == n) r,
            }
          : const <Ritual>{Ritual.dailyGita},
      deity: Deity.values.firstWhere(
        (Deity d) => d.name == p.getString(kDeity),
        orElse: () => Deity.none,
      ),
    );
    Haptics.enabled = s.haptics;
    SoundService.instance.enabled = s.sound;
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

  void setTextSize(TextSize t) {
    state = state.copyWith(textSize: t);
    _p.setString(kTextSize, t.name);
  }

  void setSound(bool v) {
    SoundService.instance.enabled = v;
    // Let the person hear what they just switched on.
    if (v) SoundService.instance.play(Sfx.tap);
    state = state.copyWith(sound: v);
    _p.setBool(kSound, v);
  }

  void setHaptics(bool v) {
    Haptics.enabled = v;
    // Let the person feel what they just switched on.
    if (v) Haptics.tick();
    state = state.copyWith(haptics: v);
    _p.setBool(kHaptics, v);
  }

  void setAppearance(Appearance a) {
    state = state.copyWith(appearance: a);
    _p.setString(kAppearance, a.name);
  }

  void setCity(String id) {
    state = state.copyWith(cityId: id);
    _p.setString(kCity, id);
  }

  void setTradition(Tradition t) {
    state = state.copyWith(tradition: t);
    _p.setString(kTradition, t.name);
  }

  void setRitual(Ritual r, {required bool on}) {
    final Set<Ritual> next = <Ritual>{...state.rituals};
    on ? next.add(r) : next.remove(r);
    state = state.copyWith(rituals: next);
    _p.setStringList(kRituals, <String>[for (final Ritual x in next) x.name]);
  }

  /// Saves what "Build my practice" chose, in one go.
  void setPractice(Set<Ritual> rituals, Deity deity) {
    state = state.copyWith(rituals: rituals, deity: deity);
    _p.setStringList(kRituals, <String>[
      for (final Ritual x in rituals) x.name,
    ]);
    _p.setString(kDeity, deity.name);
  }

  void setDeity(Deity d) {
    state = state.copyWith(deity: d);
    _p.setString(kDeity, d.name);
  }

  void completeOnboarding() {
    state = state.copyWith(onboarded: true);
    _p.setBool(kOnboarded, true);
  }
}

final NotifierProvider<SettingsNotifier, Settings> settingsProvider =
    NotifierProvider<SettingsNotifier, Settings>(SettingsNotifier.new);
