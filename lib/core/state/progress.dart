import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app_providers.dart';

/// The three steps of the daily ritual.
enum RitualStep { hear, walk, speak }

String dayKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime _parseDay(String s) {
  final List<String> p = s.split('-');
  return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
}

int _gapDays(DateTime from, DateTime to) => DateTime.utc(
  to.year,
  to.month,
  to.day,
).difference(DateTime.utc(from.year, from.month, from.day)).inDays;

@immutable
class ProgressState {
  const ProgressState({
    this.streak = 0,
    this.points = 0,
    this.today = '',
    this.heard = 0,
    this.steps = const <RitualStep>{},
    this.kept = const <String>{},
    this.litDays = const <String>[],
    this.lastForgive,
    this.cameBack = false,
  });

  final int streak;

  /// Moksh Points. They only go up.
  final int points;
  final String today;

  /// Verses heard today, 0..5.
  final int heard;
  final Set<RitualStep> steps;
  final Set<String> kept;

  /// Days a lamp was lit, newest last.
  final List<String> litDays;
  final String? lastForgive;

  /// True when the streak was broken and today is a return.
  final bool cameBack;

  RitualStep get nextStep => !steps.contains(RitualStep.hear)
      ? RitualStep.hear
      : !steps.contains(RitualStep.walk)
      ? RitualStep.walk
      : RitualStep.speak;

  bool get ritualStarted => heard > 0 || steps.isNotEmpty;
}

/// Streak and points. One missed day a week is forgiven silently.
class ProgressNotifier extends Notifier<ProgressState> {
  static const int dailyVerses = 5;
  static const int hearPoints = 10;
  static const int walkPoints = 30;

  SharedPreferences get _p => ref.read(sharedPrefsProvider);
  DateTime _now() => ref.read(clockProvider)();

  @override
  ProgressState build() {
    final SharedPreferences p = ref.watch(sharedPrefsProvider);
    final DateTime now = ref.read(clockProvider)();
    final String today = dayKey(now);
    final bool sameDay = p.getString('p.day') == today;
    final List<String> lit = p.getStringList('p.lit') ?? <String>[];
    final String? last = lit.isEmpty ? null : lit.last;
    final String? forgive = p.getString('p.forgive');

    int streak = p.getInt('p.streak') ?? 0;
    bool cameBack = false;
    if (last != null && last != today) {
      final int gap = _gapDays(_parseDay(last), now);
      if (gap > 1 && !(gap == 2 && _forgiveFree(forgive, now))) {
        streak = 0;
        cameBack = true;
      }
    }
    return ProgressState(
      streak: streak,
      points: p.getInt('p.points') ?? 0,
      today: today,
      heard: sameDay ? (p.getInt('p.heard') ?? 0) : 0,
      steps: sameDay
          ? (p.getStringList('p.steps') ?? <String>[])
                .map(
                  (String n) => RitualStep.values.firstWhere(
                    (RitualStep s) => s.name == n,
                  ),
                )
                .toSet()
          : <RitualStep>{},
      kept: (p.getStringList('p.kept') ?? <String>[]).toSet(),
      litDays: lit,
      lastForgive: forgive,
      cameBack: cameBack,
    );
  }

  bool _forgiveFree(String? forgive, DateTime now) =>
      forgive == null || _gapDays(_parseDay(forgive), now) >= 7;

  void _save() {
    final ProgressState s = state;
    _p.setInt('p.streak', s.streak);
    _p.setInt('p.points', s.points);
    _p.setString('p.day', s.today);
    _p.setInt('p.heard', s.heard);
    _p.setStringList('p.steps', s.steps.map((RitualStep e) => e.name).toList());
    _p.setStringList('p.kept', s.kept.toList());
    _p.setStringList('p.lit', s.litDays);
    if (s.lastForgive != null) _p.setString('p.forgive', s.lastForgive!);
  }

  void setHeard(int n) {
    if (n <= state.heard) return;
    state = ProgressState(
      streak: state.streak,
      points: state.points,
      today: state.today,
      heard: n.clamp(0, dailyVerses),
      steps: state.steps,
      kept: state.kept,
      litDays: state.litDays,
      lastForgive: state.lastForgive,
      cameBack: state.cameBack,
    );
    _save();
  }

  void keep(String verseId) {
    if (state.kept.contains(verseId)) return;
    state = _copy(kept: <String>{...state.kept, verseId});
    _save();
  }

  /// Marks a step done once a day. Returns points awarded (0 if done before).
  int completeStep(RitualStep step) {
    if (state.steps.contains(step)) return 0;
    final int award = switch (step) {
      RitualStep.hear => hearPoints,
      RitualStep.walk => walkPoints,
      RitualStep.speak => 0,
    };
    final DateTime now = _now();
    final String today = dayKey(now);
    int streak = state.streak;
    String? forgive = state.lastForgive;
    List<String> lit = state.litDays;
    if (!lit.contains(today)) {
      final int gap = lit.isEmpty ? 99 : _gapDays(_parseDay(lit.last), now);
      if (gap == 1) {
        streak += 1;
      } else if (gap == 2 && _forgiveFree(forgive, now)) {
        streak += 1;
        forgive = today;
      } else {
        streak = 1;
      }
      lit = <String>[...lit, today];
      if (lit.length > 14) lit = lit.sublist(lit.length - 14);
    }
    state = _copy(
      streak: streak,
      points: state.points + award,
      steps: <RitualStep>{...state.steps, step},
      litDays: lit,
      lastForgive: forgive,
      cameBack: false,
    );
    _save();
    return award;
  }

  /// Seven booleans, oldest first, ending today. Forgiven days stay lit.
  List<bool> weekLamps() {
    final DateTime now = _now();
    return <bool>[
      for (int i = 6; i >= 0; i--)
        state.litDays.contains(dayKey(now.subtract(Duration(days: i)))),
    ];
  }

  ProgressState _copy({
    int? streak,
    int? points,
    Set<RitualStep>? steps,
    Set<String>? kept,
    List<String>? litDays,
    String? lastForgive,
    bool? cameBack,
  }) => ProgressState(
    streak: streak ?? state.streak,
    points: points ?? state.points,
    today: state.today,
    heard: state.heard,
    steps: steps ?? state.steps,
    kept: kept ?? state.kept,
    litDays: litDays ?? state.litDays,
    lastForgive: lastForgive ?? state.lastForgive,
    cameBack: cameBack ?? state.cameBack,
  );
}

final NotifierProvider<ProgressNotifier, ProgressState> progressProvider =
    NotifierProvider<ProgressNotifier, ProgressState>(ProgressNotifier.new);
