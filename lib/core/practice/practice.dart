import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_providers.dart';
import '../rituals/panchang.dart';
import '../rituals/providers.dart';
import '../rituals/reminder_backend.dart';
import '../rituals/rituals.dart';
import '../state/settings.dart';

/// What "Build my practice" asks, in plain answers.
@immutable
class PracticeAnswers {
  const PracticeAnswers({
    this.fast = false,
    this.day = Deity.none,
    this.duskLamp = false,
    this.sunrise = false,
    this.moonDays = false,
  });

  /// From what is on now, so asking again starts where you are.
  factory PracticeAnswers.from(Settings s) => PracticeAnswers(
    fast: s.rituals.contains(Ritual.ekadashi),
    day: s.deity,
    duskLamp: s.rituals.contains(Ritual.diya),
    sunrise: s.rituals.contains(Ritual.sandhya),
    moonDays: s.rituals.contains(Ritual.purnima),
  );

  /// Keeps an Ekadashi fast.
  final bool fast;

  /// A weekday lamp for one deity, or none.
  final Deity day;

  /// Lights a lamp at dusk.
  final bool duskLamp;

  /// Wants a quiet minute at sunrise.
  final bool sunrise;

  /// Full moon, new moon and the big festival days.
  final bool moonDays;

  PracticeAnswers copyWith({
    bool? fast,
    Deity? day,
    bool? duskLamp,
    bool? sunrise,
    bool? moonDays,
  }) => PracticeAnswers(
    fast: fast ?? this.fast,
    day: day ?? this.day,
    duskLamp: duskLamp ?? this.duskLamp,
    sunrise: sunrise ?? this.sunrise,
    moonDays: moonDays ?? this.moonDays,
  );
}

/// The rituals and deity day that answers turn into.
@immutable
class PracticePlan {
  const PracticePlan(this.rituals, this.deity);
  final Set<Ritual> rituals;
  final Deity deity;
}

/// The seam for a smarter helper later (an AI that reads a sentence like
/// "I fast on Mondays for Shiva"). Today it is a few plain rules.
abstract interface class PracticeSuggester {
  PracticePlan suggest(PracticeAnswers a);
}

class RulePracticeSuggester implements PracticeSuggester {
  const RulePracticeSuggester();

  @override
  PracticePlan suggest(PracticeAnswers a) => PracticePlan(<Ritual>{
    Ritual.dailyGita,
    if (a.fast) Ritual.ekadashi,
    if (a.duskLamp) Ritual.diya,
    if (a.sunrise) Ritual.sandhya,
    if (a.moonDays) ...<Ritual>[
      Ritual.purnima,
      Ritual.amavasya,
      Ritual.festivals,
    ],
  }, a.day);
}

final Provider<PracticeSuggester> practiceSuggesterProvider =
    Provider<PracticeSuggester>((Ref ref) => const RulePracticeSuggester());

/// Rituals only the "All reminders" list switches. The builder never asks
/// about them, so building again keeps them as they were.
const Set<Ritual> advancedOnly = <Ritual>{Ritual.pradosh, Ritual.sankashti};

/// The plan to save: the suggestion, plus any advanced ritual already on.
PracticePlan applyPlan(PracticePlan plan, Set<Ritual> current) => PracticePlan(
  <Ritual>{...plan.rituals, ...current.intersection(advancedOnly)},
  plan.deity,
);

/// One line per ritual, for a child, reverent. Glosses each word once.
String ritualMeaning(Ritual r) => switch (r) {
  Ritual.dailyGita => 'Five verses from the Gita, at the hour you chose.',
  Ritual.sandhya => 'A quiet minute to greet the sun as it rises.',
  Ritual.diya => 'A soft reminder to light a lamp as the day ends.',
  Ritual.ekadashi =>
    'Ekadashi is the eleventh day of the moon. Many people fast. '
        'We also tell you when to eat again. That is called parana.',
  Ritual.purnima => 'Purnima is the night the moon is full and round.',
  Ritual.amavasya =>
    'Amavasya is the night with no moon. A time to remember family '
        'who came before.',
  Ritual.pradosh =>
    'Pradosh is dusk on the thirteenth day of the moon, kept for Shiva.',
  Ritual.sankashti =>
    'Sankashti is a fast for Ganesha. It ends when the moon rises.',
  Ritual.festivals =>
    'Big days like Diwali and Holi, on the right date for your city.',
};

/// Short card text for a deity day.
String deityMeaning(Deity d) => switch (d) {
  Deity.none => 'No special day for now.',
  Deity.shiva => 'Monday is for Shiva. A lamp at sunset.',
  Deity.hanuman => 'Tuesday is for Hanuman. The Chalisa in the morning.',
  Deity.vishnu => 'Thursday is for Vishnu, the teacher of teachers.',
  Deity.shani => 'Saturday is for Shani. A quiet lamp at sunset.',
};

/// What a preview needs to know: the city's calendar and the time there.
@immutable
class PreviewContext {
  const PreviewContext({
    required this.cal,
    required this.now,
    required this.tradition,
    required this.gitaMinutes,
  });

  final CityCalendar cal;

  /// The current wall-clock time in the city.
  final DateTime now;
  final Tradition tradition;
  final int gitaMinutes;
}

/// Null until the city's calendar has loaded.
final Provider<PreviewContext?> previewContextProvider =
    Provider<PreviewContext?>((Ref ref) {
      final CityCalendar? cal = ref.watch(calendarProvider).value;
      final PanchangCity? city = ref.watch(cityProvider);
      if (cal == null || city == null) return null;
      final Settings s = ref.watch(settingsProvider);
      return PreviewContext(
        cal: cal,
        now: cityNow(city.tz, ref.read(clockProvider)()),
        tradition: s.tradition,
        gitaMinutes: s.reminderMinutes,
      );
    });

/// The first reminder a choice would send, from the real reminder planner,
/// so the preview always says what will really happen.
PlannedReminder? firstNote(
  PreviewContext ctx, {
  Set<Ritual> rituals = const <Ritual>{},
  Deity deity = Deity.none,
}) {
  final List<PlannedReminder> plan = planReminders(
    cal: ctx.cal,
    rituals: rituals,
    deity: deity,
    tradition: ctx.tradition,
    gitaMinutes: ctx.gitaMinutes,
    today: ctx.now,
    nowWall: ctx.now,
    days: 40,
  );
  // Slots 11 and 12 are parana notes for a fast kept before today; a
  // preview should show the fast itself.
  for (final PlannedReminder r in plan) {
    if (r.id % 32 != 11 && r.id % 32 != 12) return r;
  }
  return null;
}

const List<String> _wd = <String>[
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat',
  'Sun',
];
const List<String> _mon = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// "Today, 5:21 pm", "Tomorrow, 6:52 am", "Fri 20 Nov, 6:52 am".
String whenLabel(DateTime wall, DateTime now) {
  final DateTime d = DateTime(wall.year, wall.month, wall.day);
  final int days = d.difference(DateTime(now.year, now.month, now.day)).inDays;
  final String day = switch (days) {
    0 => 'Today',
    1 => 'Tomorrow',
    _ => '${_wd[wall.weekday - 1]} ${wall.day} ${_mon[wall.month - 1]}',
  };
  return '$day, ${fmtClock(wall.hour * 60 + wall.minute)}';
}
