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

/// One line of the Moksh Points history. Points only go up, so there is no
/// negative amount and no spend.
@immutable
class PointEntry {
  const PointEntry(this.day, this.reason, this.amount);

  /// `yyyy-mm-dd`.
  final String day;

  /// One of [ProgressNotifier.reasons].
  final String reason;
  final int amount;

  String encode() => '$day|$reason|$amount';

  static PointEntry? decode(String s) {
    final List<String> p = s.split('|');
    if (p.length != 3) return null;
    final int? n = int.tryParse(p[2]);
    return n == null ? null : PointEntry(p[0], p[1], n);
  }
}

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
    this.ledger = const <PointEntry>[],
    this.milestonesSeen = const <int>{},
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

  /// Points history, newest last.
  final List<PointEntry> ledger;

  /// Milestone day counts already celebrated.
  final Set<int> milestonesSeen;

  /// A milestone reached and not yet shown, else null.
  int? get pendingMilestone =>
      ProgressNotifier.milestones.contains(streak) &&
          !milestonesSeen.contains(streak)
      ? streak
      : null;

  /// Points earned today, by reason.
  List<PointEntry> get todayEntries =>
      ledger.where((PointEntry e) => e.day == today).toList();

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
  static const int speakPoints = 10;
  static const int sankalpPoints = 5;

  /// Day counts that open the milestone screen.
  static const List<int> milestones = <int>[7, 30, 100, 365];

  /// Why points were given. Shown in the wallet history.
  static const Map<String, String> reasons = <String, String>{
    'hear': 'Five verses heard',
    'walk': 'One step walked',
    'speak': 'Spoke your mind',
    'sankalp': 'Looked back on a Sankalp',
  };

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
      ledger: <PointEntry>[
        for (final String e in p.getStringList('p.ledger') ?? <String>[])
          ?PointEntry.decode(e),
      ],
      milestonesSeen: <int>{
        for (final String m in p.getStringList('p.ms') ?? <String>[])
          ?int.tryParse(m),
      },
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
    _p.setStringList(
      'p.ledger',
      s.ledger.map((PointEntry e) => e.encode()).toList(),
    );
    _p.setStringList('p.ms', s.milestonesSeen.map((int m) => '$m').toList());
  }

  void setHeard(int n) {
    if (n <= state.heard) return;
    state = _copy(heard: n.clamp(0, dailyVerses));
    _save();
  }

  /// Adds [amount] for [reason] once a day. Returns what was added.
  int award(String reason, int amount) {
    final String today = dayKey(_now());
    if (amount <= 0 ||
        state.ledger.any(
          (PointEntry e) => e.day == today && e.reason == reason,
        )) {
      return 0;
    }
    state = _copy(
      points: state.points + amount,
      ledger: _append(PointEntry(today, reason, amount)),
    );
    _save();
    return amount;
  }

  /// The ledger keeps the last 120 lines; the total lives in `points`.
  List<PointEntry> _append(PointEntry e) {
    final List<PointEntry> l = <PointEntry>[...state.ledger, e];
    return l.length > 120 ? l.sublist(l.length - 120) : l;
  }

  void markMilestoneSeen(int days) {
    if (state.milestonesSeen.contains(days)) return;
    state = _copy(milestonesSeen: <int>{...state.milestonesSeen, days});
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
      RitualStep.speak => speakPoints,
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
      ledger: _append(PointEntry(today, step.name, award)),
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
    int? heard,
    List<PointEntry>? ledger,
    Set<int>? milestonesSeen,
    Set<RitualStep>? steps,
    Set<String>? kept,
    List<String>? litDays,
    String? lastForgive,
    bool? cameBack,
  }) => ProgressState(
    streak: streak ?? state.streak,
    points: points ?? state.points,
    today: state.today,
    heard: heard ?? state.heard,
    steps: steps ?? state.steps,
    kept: kept ?? state.kept,
    litDays: litDays ?? state.litDays,
    lastForgive: lastForgive ?? state.lastForgive,
    cameBack: cameBack ?? state.cameBack,
    ledger: ledger ?? state.ledger,
    milestonesSeen: milestonesSeen ?? state.milestonesSeen,
  );
}

final NotifierProvider<ProgressNotifier, ProgressState> progressProvider =
    NotifierProvider<ProgressNotifier, ProgressState>(ProgressNotifier.new);
