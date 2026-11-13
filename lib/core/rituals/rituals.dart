import '../../l10n/app_localizations.dart';
import '../../l10n/ritual_words.dart';
import 'panchang.dart';

/// The short, fixed list a person can switch on (no builder in the MVP).
enum Ritual {
  dailyGita,
  sandhya,
  diya,
  ekadashi,
  purnima,
  amavasya,
  pradosh,
  sankashti,
  festivals,
}

/// One deity day at most: the weekday it falls on and the line sent.
enum Deity {
  none(0),
  shiva(DateTime.monday),
  hanuman(DateTime.tuesday),
  vishnu(DateTime.thursday),
  shani(DateTime.saturday);

  const Deity(this.weekday);
  final int weekday;
}

/// Which Ekadashi rule to follow. `unsure` shows both when they differ.
enum Tradition { smarta, vaishnava, unsure }

/// A reminder at a local wall-clock time in the person's city.
class PlannedReminder {
  const PlannedReminder(this.id, this.wall, this.body);

  /// Stable per (day, slot) so a refresh replaces rather than duplicates.
  final int id;

  /// Y/m/d h:m in the city's zone; the backend attaches the zone.
  final DateTime wall;
  final String body;
}

String fmtTime(int m) {
  final int h = (m ~/ 60) % 12 == 0 ? 12 : (m ~/ 60) % 12;
  return '$h:${(m % 60).toString().padLeft(2, '0')}';
}

bool _isAm(int m) => (m ~/ 60) % 24 < 12;

/// Part of the day, for the languages that name it ("शाम 5:21").
String _period(int m) {
  final int h = (m ~/ 60) % 24;
  if (h < 4) return 'nightEarly';
  if (h < 12) return 'morning';
  if (h < 16) return 'noon';
  if (h < 19) return 'evening';
  return 'night';
}

/// "5:21 pm" in English, "शाम 5:21" in Hindi.
String fmtClock(AppLocalizations l, int m) => l.clockAt(_period(m), fmtTime(m));

/// "7:09-9:13 am" in English when both ends share am or pm.
String fmtRange(AppLocalizations l, int a, int b) => l.clockRange(
  _isAm(a) == _isAm(b) ? 'yes' : 'no',
  fmtTime(a),
  fmtClock(l, a),
  fmtClock(l, b),
);

/// Pradosh kaal runs from sunset for a fifth of the night (as Drik Panchang
/// shows it: 5:31-8:09 pm in Delhi on Diwali 2026).
int pradoshEnd(CityCalendar cal, int day) {
  final int ss = cal.sunset[day];
  final int next = day + 1 < cal.days ? cal.sunrise[day + 1] : cal.sunrise[day];
  return ss + ((next + 1440 - ss) / 5).round();
}

/// Ekadashi events that apply to a [Tradition], de-duplicated by fast day.
List<CalEvent> ekadashiFor(List<CalEvent> all, Tradition t) {
  final Set<int> want = switch (t) {
    Tradition.smarta => <int>{Ev.ekadashiSmarta},
    Tradition.vaishnava => <int>{Ev.ekadashiVaishnava},
    Tradition.unsure => <int>{Ev.ekadashiSmarta, Ev.ekadashiVaishnava},
  };
  final List<CalEvent> out = <CalEvent>[];
  for (final CalEvent e in all) {
    if (!e.unverified && want.contains(e.type)) out.add(e);
  }
  return out;
}

bool _festivalFor(CalEvent e, Tradition t) =>
    e.b == 0 ||
    t == Tradition.unsure ||
    (e.b == Ev.ekadashiVaishnava) == (t == Tradition.vaishnava);

/// Everything that falls on [day] for the enabled rituals, as short labels.
List<String> todayLabels(
  AppLocalizations l,
  CityCalendar cal,
  int day, {
  required Set<Ritual> rituals,
  required Tradition tradition,
}) {
  final List<String> out = <String>[];
  if (rituals.contains(Ritual.ekadashi)) {
    // Fast day, and the parana day of a fast kept earlier.
    final List<CalEvent> fast = ekadashiFor(cal.on(day), tradition);
    if (fast.isNotEmpty) {
      // Only one of the two rules lands here: say which.
      out.add(
        tradition == Tradition.unsure && fast.length == 1
            ? l.labelEkadashiRule(
                fast.first.type == Ev.ekadashiSmarta
                    ? l.traditionSmarta
                    : l.traditionVaishnava,
              )
            : l.ritualEkadashi,
      );
    }
    for (int back = 1; back <= 3; back++) {
      for (final CalEvent e in ekadashiFor(cal.on(day - back), tradition)) {
        if (e.paranaOffset == back) {
          out.add(l.labelParana(fmtRange(l, e.a, e.b)));
        }
      }
    }
  }
  for (final CalEvent e in cal.on(day)) {
    if (e.unverified) continue;
    switch (e.type) {
      case Ev.purnima when rituals.contains(Ritual.purnima):
        out.add(l.ritualPurnima);
      case Ev.amavasya when rituals.contains(Ritual.amavasya):
        out.add(l.ritualAmavasya);
      case Ev.pradosh when rituals.contains(Ritual.pradosh):
        out.add(
          l.labelPradosh(fmtRange(l, cal.sunset[day], pradoshEnd(cal, day))),
        );
      case Ev.sankashti when rituals.contains(Ritual.sankashti):
        out.add(l.ritualSankashti);
      case Ev.festival
          when rituals.contains(Ritual.festivals) && _festivalFor(e, tradition):
        out.add(l.festival(e.a));
    }
  }
  return out.toSet().toList();
}

/// The reminders for the next [days] days from [today] (a date in the city),
/// skipping anything at or before [nowWall] (the current time in the city).
List<PlannedReminder> planReminders({
  required AppLocalizations l,
  required CityCalendar cal,
  required Set<Ritual> rituals,
  required Deity deity,
  required Tradition tradition,
  required int gitaMinutes,
  required DateTime today,
  required DateTime nowWall,
  int days = 30,
  int cap = 60,
}) {
  final int? first = cal.dayIndex(today);
  if (first == null) return const <PlannedReminder>[];
  final List<PlannedReminder> out = <PlannedReminder>[];

  void add(int day, int slot, int minutes, String body) {
    final DateTime d = cal.dateOf(day);
    final DateTime wall = DateTime(d.year, d.month, d.day, 0, minutes);
    if (wall.isAfter(nowWall)) {
      out.add(PlannedReminder(day * 32 + slot, wall, body));
    }
  }

  // Start 3 days back: a fast kept yesterday has its parana today.
  for (
    int day = first < 3 ? 0 : first - 3;
    day < first + days && day < cal.days;
    day++
  ) {
    final int sr = cal.sunrise[day];
    final int ss = cal.sunset[day];
    final DateTime date = cal.dateOf(day);
    if (rituals.contains(Ritual.dailyGita)) {
      add(day, 0, gitaMinutes, l.noteGita);
    }
    if (rituals.contains(Ritual.sandhya)) {
      add(
        day,
        1,
        sr + 10,
        l.noteSandhya(fmtClock(l, sr)),
      );
    }
    if (rituals.contains(Ritual.diya)) {
      add(
        day,
        2,
        ss - 10,
        l.noteDiya(fmtClock(l, ss)),
      );
    }
    if (deity != Deity.none && date.weekday == deity.weekday) {
      add(day, 3, deity == Deity.hanuman ? sr + 30 : ss - 10, switch (deity) {
        Deity.shiva => l.noteShiva(fmtClock(l, ss)),
        Deity.hanuman => l.noteHanuman,
        Deity.vishnu => l.noteVishnu(fmtClock(l, ss)),
        Deity.shani => l.noteShani(fmtClock(l, ss)),
        Deity.none => '',
      });
    }
    for (final CalEvent e in cal.on(day)) {
      if (e.unverified) continue;
      switch (e.type) {
        case Ev.purnima when rituals.contains(Ritual.purnima):
          add(day, 4, ss - 15, l.notePurnima);
        case Ev.amavasya when rituals.contains(Ritual.amavasya):
          add(day, 5, sr + 30, l.noteAmavasya);
        case Ev.pradosh when rituals.contains(Ritual.pradosh):
          add(
            day,
            6,
            ss,
            l.notePradosh(fmtRange(l, ss, pradoshEnd(cal, day))),
          );
        case Ev.sankashti when rituals.contains(Ritual.sankashti) && e.a > 0:
          add(day, 7, e.a - 15, l.noteSankashti(fmtClock(l, e.a)));
        case Ev.festival
            when rituals.contains(Ritual.festivals) &&
                _festivalFor(e, tradition):
          add(
            day,
            8,
            sr + 30,
            l.noteFestival(l.festival(e.a)),
          );
      }
    }
    if (rituals.contains(Ritual.ekadashi)) {
      final List<CalEvent> fast = ekadashiFor(cal.on(day), tradition);
      for (final CalEvent e in fast) {
        // Both rules on one day: one reminder, no label.
        if (fast.length == 2 && e.type == Ev.ekadashiVaishnava) continue;
        final String rule = tradition == Tradition.unsure && fast.length == 1
            ? l.ruleSuffix(
                e.type == Ev.ekadashiSmarta
                    ? l.traditionSmarta
                    : l.traditionVaishnava,
              )
            : '';
        final int pday = day + e.paranaOffset;
        final String when = e.paranaOffset == 1
            ? l.dayTomorrow.toLowerCase()
            : l.whenOnDay(l.weekday(cal.dateOf(pday).weekday));
        final int slot = e.type == Ev.ekadashiSmarta ? 9 : 10;
        add(
          day,
          slot,
          sr,
          l.noteEkadashi(rule, when, fmtRange(l, e.a, e.b)),
        );
        if (pday < cal.days) {
          add(
            pday,
            slot + 2,
            e.a,
            l.noteParana(fmtRange(l, e.a, e.b)),
          );
        }
      }
    }
  }
  out.sort((PlannedReminder a, PlannedReminder b) => a.wall.compareTo(b.wall));
  // iOS keeps only 64 pending: keep the soonest.
  return out.length > cap ? out.sublist(0, cap) : out;
}
