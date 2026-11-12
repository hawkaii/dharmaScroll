import 'panchang.dart';

/// The short, fixed list a person can switch on (no builder in the MVP).
enum Ritual {
  dailyGita('Daily Gita', 'Five verses at your chosen hour.'),
  sandhya('Morning sandhya', 'A quiet minute after sunrise.'),
  diya('Evening diya', 'A reminder shortly before sunset.'),
  ekadashi('Ekadashi', 'The fast day, and when to break it.'),
  purnima('Purnima', 'The full moon evening.'),
  amavasya('Amavasya', 'The new moon day.'),
  pradosh('Pradosh', 'The twilight window before night.'),
  sankashti('Sankashti', 'Chaturthi, with moonrise.'),
  festivals('Festivals', 'About thirty major days.');

  const Ritual(this.label, this.hint);
  final String label;
  final String hint;
}

/// One deity day at most: the weekday it falls on and the line sent.
enum Deity {
  none('None', 0),
  shiva('Shiva, Monday', DateTime.monday),
  hanuman('Hanuman, Tuesday', DateTime.tuesday),
  vishnu('Vishnu or Guru, Thursday', DateTime.thursday),
  shani('Shani, Saturday', DateTime.saturday);

  const Deity(this.label, this.weekday);
  final String label;
  final int weekday;
}

/// Which Ekadashi rule to follow. `unsure` shows both when they differ.
enum Tradition {
  smarta('Smarta'),
  vaishnava('Vaishnava'),
  unsure('Not sure');

  const Tradition(this.label);
  final String label;
}

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

String _ampm(int m) => (m ~/ 60) % 24 < 12 ? 'am' : 'pm';

String fmtClock(int m) => '${fmtTime(m)} ${_ampm(m)}';

String fmtRange(int a, int b) => _ampm(a) == _ampm(b)
    ? '${fmtTime(a)}-${fmtTime(b)} ${_ampm(b)}'
    : '${fmtClock(a)}-${fmtClock(b)}';

const List<String> _weekday = <String>[
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

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
            ? 'Ekadashi (${fast.first.type == Ev.ekadashiSmarta ? 'Smarta' : 'Vaishnava'})'
            : 'Ekadashi',
      );
    }
    for (int back = 1; back <= 3; back++) {
      for (final CalEvent e in ekadashiFor(cal.on(day - back), tradition)) {
        if (e.paranaOffset == back) out.add('Parana ${fmtRange(e.a, e.b)}');
      }
    }
  }
  for (final CalEvent e in cal.on(day)) {
    if (e.unverified) continue;
    switch (e.type) {
      case Ev.purnima when rituals.contains(Ritual.purnima):
        out.add('Purnima');
      case Ev.amavasya when rituals.contains(Ritual.amavasya):
        out.add('Amavasya');
      case Ev.pradosh when rituals.contains(Ritual.pradosh):
        out.add('Pradosh ${fmtRange(cal.sunset[day], pradoshEnd(cal, day))}');
      case Ev.sankashti when rituals.contains(Ritual.sankashti):
        out.add('Sankashti');
      case Ev.festival
          when rituals.contains(Ritual.festivals) && _festivalFor(e, tradition):
        out.add(cal.festivalName(e));
    }
  }
  return out.toSet().toList();
}

/// The reminders for the next [days] days from [today] (a date in the city),
/// skipping anything at or before [nowWall] (the current time in the city).
List<PlannedReminder> planReminders({
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
      add(day, 0, gitaMinutes, 'Five verses are ready. Take your time.');
    }
    if (rituals.contains(Ritual.sandhya)) {
      add(
        day,
        1,
        sr + 10,
        'Sunrise at ${fmtClock(sr)}. A quiet minute for the morning sandhya, if you like.',
      );
    }
    if (rituals.contains(Ritual.diya)) {
      add(
        day,
        2,
        ss - 10,
        'Sunset at ${fmtClock(ss)}. The evening lamp, whenever you are ready.',
      );
    }
    if (deity != Deity.none && date.weekday == deity.weekday) {
      add(day, 3, deity == Deity.hanuman ? sr + 30 : ss - 10, switch (deity) {
        Deity.shiva =>
          'Monday. A lamp for Shiva at sunset, ${fmtClock(ss)}, if you like.',
        Deity.hanuman => 'Tuesday. The Chalisa this morning, if you like.',
        Deity.vishnu =>
          'Thursday. A lamp for Vishnu at sunset, ${fmtClock(ss)}, if you like.',
        Deity.shani =>
          'Saturday. A quiet lamp at sunset, ${fmtClock(ss)}, if you like.',
        Deity.none => '',
      });
    }
    for (final CalEvent e in cal.on(day)) {
      if (e.unverified) continue;
      switch (e.type) {
        case Ev.purnima when rituals.contains(Ritual.purnima):
          add(
            day,
            4,
            ss - 15,
            'Purnima tonight. The full moon rises near sunset.',
          );
        case Ev.amavasya when rituals.contains(Ritual.amavasya):
          add(
            day,
            5,
            sr + 30,
            'Amavasya today. A lamp for those who came before, if you like.',
          );
        case Ev.pradosh when rituals.contains(Ritual.pradosh):
          add(
            day,
            6,
            ss,
            'Pradosh today. Pradosh kaal ${fmtRange(ss, pradoshEnd(cal, day))}.',
          );
        case Ev.sankashti when rituals.contains(Ritual.sankashti) && e.a > 0:
          add(
            day,
            7,
            e.a - 15,
            'Sankashti tonight. Moonrise ${fmtClock(e.a)}.',
          );
        case Ev.festival
            when rituals.contains(Ritual.festivals) &&
                _festivalFor(e, tradition):
          add(
            day,
            8,
            sr + 30,
            '${cal.festivalName(e)} is today. A quiet, bright day to you.',
          );
      }
    }
    if (rituals.contains(Ritual.ekadashi)) {
      final List<CalEvent> fast = ekadashiFor(cal.on(day), tradition);
      for (final CalEvent e in fast) {
        // Both rules on one day: one reminder, no label.
        if (fast.length == 2 && e.type == Ev.ekadashiVaishnava) continue;
        final String rule = tradition == Tradition.unsure && fast.length == 1
            ? ' (${e.type == Ev.ekadashiSmarta ? 'Smarta' : 'Vaishnava'})'
            : '';
        final int pday = day + e.paranaOffset;
        final String when = e.paranaOffset == 1
            ? 'tomorrow'
            : 'on ${_weekday[cal.dateOf(pday).weekday - 1]}';
        final int slot = e.type == Ev.ekadashiSmarta ? 9 : 10;
        add(
          day,
          slot,
          sr,
          'Ekadashi$rule begins at sunrise. Break the fast $when ${fmtRange(e.a, e.b)}.',
        );
        if (pday < cal.days) {
          add(
            pday,
            slot + 2,
            e.a,
            'Parana window: ${fmtRange(e.a, e.b)}. Break the fast gently.',
          );
        }
      }
    }
  }
  out.sort((PlannedReminder a, PlannedReminder b) => a.wall.compareTo(b.wall));
  // iOS keeps only 64 pending: keep the soonest.
  return out.length > cap ? out.sublist(0, cap) : out;
}
