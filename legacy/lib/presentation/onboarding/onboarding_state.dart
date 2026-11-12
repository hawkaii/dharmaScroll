import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app_providers.dart';

enum OnboardingStep { splash, language, intent, goal }

enum LangPref { hindiSanskrit, englishSanskrit, hinglish }

enum Familiarity { newToGita, fewShlokas, studied }

enum IdentityGoal { casualSeeker, regularSadhak, seriousYogi, intenseTapasvi }

enum FeedIntent {
  lessPhone,
  stress,
  finishGita,
  anger,
  focus,
  career,
  relationships,
  grief,
  devotion,
  teachKids,
}

@immutable
class OnboardingState {
  const OnboardingState({
    this.step = OnboardingStep.splash,
    this.language = LangPref.hindiSanskrit,
    this.showTransliteration = true,
    this.intents = const <FeedIntent>{},
    this.familiarity = Familiarity.newToGita,
    this.goalMinutes = 10,
    this.remindAtMinutes = 6 * 60 + 30,
    this.identityGoal = IdentityGoal.casualSeeker,
    this.startStreakToday = true,
    this.completed = false,
  });

  final OnboardingStep step;
  final LangPref language;
  final bool showTransliteration;
  final Set<FeedIntent> intents;
  final Familiarity familiarity;
  final int goalMinutes;
  final int? remindAtMinutes;
  final IdentityGoal identityGoal;
  final bool startStreakToday;
  final bool completed;

  OnboardingState copyWith({
    OnboardingStep? step,
    LangPref? language,
    bool? showTransliteration,
    Set<FeedIntent>? intents,
    Familiarity? familiarity,
    int? goalMinutes,
    int? remindAtMinutes,
    IdentityGoal? identityGoal,
    bool? startStreakToday,
    bool clearReminder = false,
    bool? completed,
  }) {
    return OnboardingState(
      step: step ?? this.step,
      language: language ?? this.language,
      showTransliteration: showTransliteration ?? this.showTransliteration,
      intents: intents ?? this.intents,
      familiarity: familiarity ?? this.familiarity,
      goalMinutes: goalMinutes ?? this.goalMinutes,
      remindAtMinutes: clearReminder
          ? null
          : (remindAtMinutes ?? this.remindAtMinutes),
      identityGoal: identityGoal ?? this.identityGoal,
      startStreakToday: startStreakToday ?? this.startStreakToday,
      completed: completed ?? this.completed,
    );
  }
}

/// The first-run state machine.
///
/// Language is the only mandatory step: it is a preference, not a permission,
/// and it is one tap. Everything after it can be skipped, deferred, or
/// dismissed on first gesture.
class OnboardingNotifier extends Notifier<OnboardingState> {
  static const String _completedKey = 'onboardingComplete';
  static const String _reminderKey = 'remindAtMinutes';
  static const int maxIntents = 5;

  late final SharedPreferences _prefs;

  @override
  OnboardingState build() {
    _prefs = ref.read(sharedPrefsProvider);
    final String? lang = _prefs.getString('lang');
    return OnboardingState(
      completed: _prefs.getBool(_completedKey) ?? false,
      language: LangPref.values.firstWhere(
        (LangPref l) => l.name == lang,
        orElse: () => LangPref.hindiSanskrit,
      ),
      remindAtMinutes: _prefs.getInt(_reminderKey) ?? 6 * 60 + 30,
    );
  }

  void goTo(OnboardingStep step) => state = state.copyWith(step: step);

  void next() {
    final int index = OnboardingStep.values.indexOf(state.step);
    if (index < OnboardingStep.values.length - 1) {
      state = state.copyWith(step: OnboardingStep.values[index + 1]);
    }
  }

  void back() {
    final int index = OnboardingStep.values.indexOf(state.step);
    if (index > 0) {
      state = state.copyWith(step: OnboardingStep.values[index - 1]);
    }
  }

  void setLanguage(LangPref language) {
    state = state.copyWith(language: language);
    _prefs.setString('lang', language.name);
  }

  void setTransliteration(bool enabled) {
    state = state.copyWith(showTransliteration: enabled);
    _prefs.setBool('showTransliteration', enabled);
  }

  /// Multi-select, capped at five. The sixth tap is refused rather than
  /// silently dropping an earlier choice.
  bool toggleIntent(FeedIntent intent) {
    final Set<FeedIntent> next = <FeedIntent>{...state.intents};
    if (next.contains(intent)) {
      next.remove(intent);
      state = state.copyWith(intents: next);
      return true;
    }
    if (next.length >= maxIntents) {
      return false;
    }
    next.add(intent);
    state = state.copyWith(intents: next);
    return true;
  }

  void setFamiliarity(Familiarity familiarity) {
    state = state.copyWith(familiarity: familiarity);
  }

  void setGoal(int minutes) => state = state.copyWith(goalMinutes: minutes);

  void setIdentityGoal(IdentityGoal goal) {
    state = state.copyWith(identityGoal: goal);
    _prefs.setString('identityGoal', goal.name);
  }

  void setStartStreakToday(bool value) {
    state = state.copyWith(startStreakToday: value);
    _prefs.setBool('startStreakToday', value);
  }

  void setReminder(int? minutes) {
    state = minutes == null
        ? state.copyWith(clearReminder: true)
        : state.copyWith(remindAtMinutes: minutes);
    if (minutes == null) {
      _prefs.remove(_reminderKey);
    } else {
      _prefs.setInt(_reminderKey, minutes);
    }
  }

  void complete() {
    state = state.copyWith(completed: true);
    _prefs.setBool(_completedKey, true);
  }

  /// Skips intent and goal, keeping the language choice. Landing directly in
  /// the feed is the whole point of the 30-second promise.
  void finishEarly() {
    complete();
  }
}

final NotifierProvider<OnboardingNotifier, OnboardingState> onboardingProvider =
    NotifierProvider<OnboardingNotifier, OnboardingState>(
      OnboardingNotifier.new,
    );
