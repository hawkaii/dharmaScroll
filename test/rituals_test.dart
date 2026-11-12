import 'dart:convert';
import 'dart:io';

import 'package:dharmascroll/core/rituals/panchang.dart';
import 'package:dharmascroll/core/rituals/reminder_backend.dart';
import 'package:dharmascroll/core/rituals/rituals.dart';
import 'package:flutter_test/flutter_test.dart';

CityCalendar _load(String id) {
  Map<String, Object?> read(String f) => (jsonDecode(
    File('assets/panchang/$f.json').readAsStringSync(),
  ) as Map<Object?, Object?>).cast();
  return CityCalendar.fromJson(
    read(id),
    read('festivals').cast<String, String>(),
  );
}

CalEvent _ev(CityCalendar cal, DateTime date, int type) =>
    cal.on(cal.dayIndex(date)!).firstWhere((CalEvent e) => e.type == type);

void main() {
  final CityCalendar delhi = _load('new-delhi-in');
  final CityCalendar edison = _load('edison-us');

  test('Delhi: Mokshada Ekadashi and Gita Jayanti are 20 Dec 2026', () {
    final int d = delhi.dayIndex(DateTime(2026, 12, 20))!;
    expect(
      delhi.on(d).where((CalEvent e) => e.type <= 2 && !e.unverified),
      hasLength(2), // Smarta and Vaishnava agree in Delhi
    );
    final CalEvent gita = delhi
        .on(d)
        .firstWhere((CalEvent e) => e.type == Ev.festival);
    expect(delhi.festivalName(gita), 'Gita Jayanti');
    // Parana on Monday 21 Dec, 7:09 to 9:13 (Drik: 7:10 to 9:13).
    final CalEvent ek = _ev(delhi, DateTime(2026, 12, 20), Ev.ekadashiSmarta);
    expect(ek.paranaOffset, 1);
    expect(fmtRange(ek.a, ek.b), '7:09-9:13 am');
  });

  test('Delhi: Purnima 23 Dec 2026 and sunrise decode', () {
    expect(_ev(delhi, DateTime(2026, 12, 23), Ev.purnima).type, Ev.purnima);
    final int d = delhi.dayIndex(DateTime(2026, 12, 21))!;
    expect(delhi.sunrise[d], closeTo(7 * 60 + 10, 2));
    expect(delhi.sunset[d], closeTo(17 * 60 + 29, 2));
  });

  test('a DST change shows up as a one hour jump in sunrise', () {
    final int d = edison.dayIndex(DateTime(2027, 3, 14))!;
    expect(edison.sunrise[d] - edison.sunrise[d - 1], closeTo(60, 3));
  });

  test('Edison: Smarta Ekadashi 19 Dec, Vaishnava 20 Dec (Drik)', () {
    expect(
      _ev(edison, DateTime(2026, 12, 19), Ev.ekadashiSmarta).type,
      Ev.ekadashiSmarta,
    );
    expect(
      _ev(edison, DateTime(2026, 12, 20), Ev.ekadashiVaishnava).type,
      Ev.ekadashiVaishnava,
    );
  });

  test('unverified dates are never shown or scheduled', () {
    final int d = delhi.dayIndex(DateTime(2027, 8, 24))!;
    final List<String> labels = todayLabels(
      delhi,
      d,
      rituals: Ritual.values.toSet(),
      tradition: Tradition.smarta,
    );
    expect(labels, isNot(contains('Janmashtami')));
  });

  test(
    'today labels: fast day, parana day, nothing for a switched-off ritual',
    () {
      final Set<Ritual> on = <Ritual>{Ritual.ekadashi, Ritual.festivals};
      final int fast = delhi.dayIndex(DateTime(2026, 12, 20))!;
      expect(
        todayLabels(delhi, fast, rituals: on, tradition: Tradition.smarta),
        <String>['Ekadashi', 'Gita Jayanti'],
      );
      expect(
        todayLabels(delhi, fast + 1, rituals: on, tradition: Tradition.smarta),
        <String>['Parana 7:09-9:13 am'],
      );
      expect(
        todayLabels(
          delhi,
          fast,
          rituals: <Ritual>{Ritual.purnima},
          tradition: Tradition.smarta,
        ),
        isEmpty,
      );
    },
  );

  test('Delhi plan: Ekadashi copy, parana reminder, calm tone', () {
    final List<PlannedReminder> plan = planReminders(
      cal: delhi,
      rituals: <Ritual>{Ritual.ekadashi, Ritual.dailyGita},
      deity: Deity.none,
      tradition: Tradition.smarta,
      gitaMinutes: 6 * 60 + 30,
      today: DateTime(2026, 12, 18),
      nowWall: DateTime(2026, 12, 18, 8),
    );
    final PlannedReminder fast = plan.firstWhere(
      (PlannedReminder r) => r.body.startsWith('Ekadashi begins'),
    );
    expect(fast.wall.day, 20);
    expect(
      fast.body,
      'Ekadashi begins at sunrise. Break the fast tomorrow 7:09-9:13 am.',
    );
    final PlannedReminder parana = plan.firstWhere(
      (PlannedReminder r) => r.body.startsWith('Parana window'),
    );
    expect(parana.wall, DateTime(2026, 12, 21, 7, 9));
    for (final PlannedReminder r in plan) {
      expect(r.body, isNot(contains('!')));
      expect(r.wall.isAfter(DateTime(2026, 12, 18, 8)), isTrue);
    }
    expect(plan.length, lessThanOrEqualTo(60));
  });

  test('Edison plan: wall times become the right instants across DST', () {
    // Sunrise 19 Dec 2026 is EST (UTC-5); a July wall time would be EDT.
    final List<PlannedReminder> winter = planReminders(
      cal: edison,
      rituals: <Ritual>{Ritual.sandhya},
      deity: Deity.none,
      tradition: Tradition.smarta,
      gitaMinutes: 0,
      today: DateTime(2026, 12, 19),
      nowWall: DateTime(2026, 12, 19),
      days: 1,
    );
    final int sr = edison.sunrise[edison.dayIndex(DateTime(2026, 12, 19))!];
    expect(winter.single.wall, DateTime(2026, 12, 19, 0, sr + 10));
    final DateTime utc = zonedInstant(
      'America/New_York',
      winter.single.wall,
    ).toUtc();
    expect(
      utc,
      DateTime.utc(2026, 12, 19, 0, sr + 10).add(const Duration(hours: 5)),
    );

    final DateTime summer = zonedInstant(
      'America/New_York',
      DateTime(2027, 7, 1, 6),
    ).toUtc();
    expect(summer, DateTime.utc(2027, 7, 1, 10)); // EDT, UTC-4

    // The same wall clock in Delhi is a different instant.
    expect(
      zonedInstant('Asia/Kolkata', DateTime(2027, 7, 1, 6)).toUtc(),
      DateTime.utc(2027, 7, 1, 0, 30),
    );
  });

  test('cityNow converts the device clock into the city zone', () {
    expect(
      cityNow('America/New_York', DateTime.utc(2026, 12, 19, 12)),
      DateTime(2026, 12, 19, 7),
    );
  });

  test('a unsure rule shows the right label when the two differ', () {
    final int d = edison.dayIndex(DateTime(2026, 12, 19))!;
    expect(
      todayLabels(
        edison,
        d,
        rituals: <Ritual>{Ritual.ekadashi},
        tradition: Tradition.unsure,
      ),
      <String>['Ekadashi (Smarta)'],
    );
  });
}
