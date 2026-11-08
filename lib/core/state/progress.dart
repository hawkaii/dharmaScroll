import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app_providers.dart';

/// The user's live progress: streak, Moksh Points, and today's cards.
///
/// Backed by SharedPreferences so it survives a restart. This is deliberately
/// small — it is the one source of truth the Path, wallet, and lesson agree on.
class ProgressState {
  const ProgressState({
    this.streak = 0,
    this.points = 0,
    this.cardsToday = 0,
    this.dailyGoal = 5,
    this.completedVerses = 0,
  });

  final int streak;
  final int points;
  final int cardsToday;
  final int dailyGoal;
  final int completedVerses;

  double get dailyFraction =>
      dailyGoal == 0 ? 0 : (cardsToday / dailyGoal).clamp(0.0, 1.0);

  ProgressState copyWith({
    int? streak,
    int? points,
    int? cardsToday,
    int? dailyGoal,
    int? completedVerses,
  }) {
    return ProgressState(
      streak: streak ?? this.streak,
      points: points ?? this.points,
      cardsToday: cardsToday ?? this.cardsToday,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      completedVerses: completedVerses ?? this.completedVerses,
    );
  }
}

class ProgressNotifier extends Notifier<ProgressState> {
  static const String _kStreak = 'progress.streak';
  static const String _kPoints = 'progress.points';
  static const String _kCards = 'progress.cardsToday';
  static const String _kGoal = 'progress.dailyGoal';
  static const String _kVerses = 'progress.completedVerses';

  SharedPreferences get _prefs => ref.read(sharedPrefsProvider);

  @override
  ProgressState build() {
    final SharedPreferences prefs = ref.watch(sharedPrefsProvider);
    return ProgressState(
      streak: prefs.getInt(_kStreak) ?? 0,
      points: prefs.getInt(_kPoints) ?? 0,
      cardsToday: prefs.getInt(_kCards) ?? 0,
      dailyGoal: prefs.getInt(_kGoal) ?? 5,
      completedVerses: prefs.getInt(_kVerses) ?? 0,
    );
  }

  Future<void> _persist(ProgressState next) async {
    await _prefs.setInt(_kStreak, next.streak);
    await _prefs.setInt(_kPoints, next.points);
    await _prefs.setInt(_kCards, next.cardsToday);
    await _prefs.setInt(_kGoal, next.dailyGoal);
    await _prefs.setInt(_kVerses, next.completedVerses);
  }

  Future<void> addCard({int points = 2}) async {
    final ProgressState next = state.copyWith(
      cardsToday: state.cardsToday + 1,
      points: state.points + points,
    );
    state = next;
    await _persist(next);
  }

  Future<void> completeSession({int points = 10}) async {
    final ProgressState next = state.copyWith(
      cardsToday: state.cardsToday + 1,
      points: state.points + points,
      completedVerses: state.completedVerses + 1,
    );
    state = next;
    await _persist(next);
  }

  Future<void> setDailyGoal(int goal) async {
    final ProgressState next = state.copyWith(dailyGoal: goal);
    state = next;
    await _persist(next);
  }

  Future<void> setStreak(int streak) async {
    final ProgressState next = state.copyWith(streak: streak);
    state = next;
    await _persist(next);
  }
}

final NotifierProvider<ProgressNotifier, ProgressState> progressProvider =
    NotifierProvider<ProgressNotifier, ProgressState>(ProgressNotifier.new);
