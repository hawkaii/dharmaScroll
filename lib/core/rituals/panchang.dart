import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// One bundled city (assets/panchang/cities.json).
@immutable
class PanchangCity {
  const PanchangCity({
    required this.id,
    required this.name,
    required this.country,
    required this.tz,
    this.nameHi,
    this.countryHi,
  });

  factory PanchangCity.fromJson(
    Map<String, Object?> j, {
    String? nameHi,
    String? countryHi,
  }) => PanchangCity(
    id: j['id']! as String,
    name: j['name']! as String,
    country: j['country']! as String,
    tz: j['tz']! as String,
    nameHi: nameHi,
    countryHi: countryHi,
  );

  final String id;
  final String name;
  final String country;

  /// IANA zone, e.g. `Asia/Kolkata` or `America/New_York`.
  final String tz;

  /// The city's name in Devanagari, when the bundle has it.
  final String? nameHi;

  /// The country's name in Devanagari (not set for India).
  final String? countryHi;

  String get label => country == 'IN' ? name : '$name, $country';

  /// The name as the chosen language writes it.
  String nameIn({required bool hindi}) => hindi ? (nameHi ?? name) : name;

  /// Name, and the country when it is not India, in the chosen language.
  String labelIn({required bool hindi}) => !hindi
      ? label
      : country == 'IN'
      ? nameIn(hindi: true)
      : '${nameIn(hindi: true)}, ${countryHi ?? country}';
}

/// Event codes written by tools/panchang/generate.py.
abstract final class Ev {
  static const int ekadashiSmarta = 1;
  static const int ekadashiVaishnava = 2;
  static const int purnima = 3;
  static const int amavasya = 4;
  static const int pradosh = 5;
  static const int sankashti = 6;
  static const int festival = 7;
}

@immutable
class CalEvent {
  const CalEvent(this.day, this.type, this.a, this.b, this.flag);

  /// Day index from [CityCalendar.start].
  final int day;
  final int type;

  /// Ekadashi: parana start (minutes). Sankashti: moonrise. Festival: id.
  final int a;

  /// Ekadashi: parana end (minutes). Gita Jayanti: Ekadashi rule (1 or 2).
  final int b;
  final int flag;

  /// Not confirmed against Drik Panchang: never shown or scheduled.
  bool get unverified => flag & 1 == 1;

  /// Ekadashi: days from the fast to the parana day.
  int get paranaOffset => flag >> 1;
}

/// A city's precomputed calendar: sunrise, sunset and ritual dates, all in the
/// city's local wall-clock time.
class CityCalendar {
  CityCalendar({
    required this.start,
    required this.days,
    required this.sunrise,
    required this.sunset,
    required this.events,
    required this.festivalNames,
  });

  factory CityCalendar.fromJson(
    Map<String, Object?> j,
    Map<String, String> festivalNames,
  ) {
    final int n = j['n']! as int;
    final List<int> deltas = _deltas(j['sun']! as String);
    final List<int> sr = <int>[j['sr0']! as int];
    final List<int> ss = <int>[j['ss0']! as int];
    for (int i = 0; i < n - 1; i++) {
      sr.add(sr.last + deltas[i]);
      ss.add(ss.last + deltas[n - 1 + i]);
    }
    final Map<int, List<CalEvent>> byDay = <int, List<CalEvent>>{};
    for (final Object? e in j['ev']! as List<Object?>) {
      final List<int> v = (e! as List<Object?>).cast<int>();
      byDay
          .putIfAbsent(v[0], () => <CalEvent>[])
          .add(CalEvent(v[0], v[1], v[2], v[3], v[4]));
    }
    final List<int> ymd = (j['start']! as String)
        .split('-')
        .map(int.parse)
        .toList();
    return CityCalendar(
      start: DateTime.utc(ymd[0], ymd[1], ymd[2]),
      days: n,
      sunrise: sr,
      sunset: ss,
      events: byDay,
      festivalNames: festivalNames,
    );
  }

  /// One char per day, or `{delta;` for a jump (a DST change).
  static List<int> _deltas(String s) {
    final List<int> out = <int>[];
    for (int i = 0; i < s.length; i++) {
      if (s[i] == '{') {
        final int end = s.indexOf(';', i);
        out.add(int.parse(s.substring(i + 1, end)));
        i = end;
      } else {
        out.add(s.codeUnitAt(i) - 0x50);
      }
    }
    return out;
  }

  /// Day 0, as a UTC date (only y/m/d matter).
  final DateTime start;
  final int days;

  /// Minutes after local midnight, by day index.
  final List<int> sunrise;
  final List<int> sunset;
  final Map<int, List<CalEvent>> events;
  final Map<String, String> festivalNames;

  /// Day index of a calendar date, or null outside the shipped range.
  int? dayIndex(DateTime date) {
    final int d = DateTime.utc(
      date.year,
      date.month,
      date.day,
    ).difference(start).inDays;
    return d < 0 || d >= days ? null : d;
  }

  DateTime dateOf(int day) =>
      DateTime(start.year, start.month, start.day + day);

  List<CalEvent> on(int day) => events[day] ?? const <CalEvent>[];

  String festivalName(CalEvent e) => festivalNames['${e.a}'] ?? 'Festival';
}

Future<List<PanchangCity>> loadCities(AssetBundle bundle) async {
  final List<Object?> raw = jsonDecode(
    await bundle.loadString('assets/panchang/cities.json', cache: false),
  ) as List<Object?>;
  Map<String, Object?> hi = const <String, Object?>{};
  try {
    hi = (jsonDecode(
      await bundle.loadString('assets/panchang/cities_hi.json', cache: false),
    ) as Map<Object?, Object?>).cast();
  } on Object catch (e) {
    debugPrint('cities_hi: $e');
  }
  final Map<Object?, Object?> names =
      (hi['cities'] as Map<Object?, Object?>?) ?? const <Object?, Object?>{};
  final Map<Object?, Object?> countries =
      (hi['countries'] as Map<Object?, Object?>?) ?? const <Object?, Object?>{};
  return <PanchangCity>[
    for (final Object? c in raw)
      PanchangCity.fromJson(
        (c! as Map<Object?, Object?>).cast(),
        nameHi: names[(c as Map<Object?, Object?>)['id']] as String?,
        countryHi: countries[c['country']] as String?,
      ),
  ];
}

Future<CityCalendar> loadCalendar(AssetBundle bundle, String cityId) async {
  final Map<String, String> names = (jsonDecode(
    await bundle.loadString('assets/panchang/festivals.json', cache: false),
  ) as Map<Object?, Object?>).cast<String, String>();
  final Map<String, Object?> j = (jsonDecode(
    await bundle.loadString('assets/panchang/$cityId.json', cache: false),
  ) as Map<Object?, Object?>).cast();
  return CityCalendar.fromJson(j, names);
}
