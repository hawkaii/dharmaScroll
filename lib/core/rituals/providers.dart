import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_providers.dart';
import '../state/settings.dart';
import 'panchang.dart';
import 'reminder_backend.dart';
import 'rituals.dart';

final Provider<ReminderBackend> reminderBackendProvider =
    Provider<ReminderBackend>(
      (Ref ref) =>
          kIsWeb ? const NoopReminderBackend() : LocalNotificationsBackend(),
    );

/// Bundled city list for the onboarding search.
final FutureProvider<List<PanchangCity>> citiesProvider =
    FutureProvider<List<PanchangCity>>((Ref ref) => loadCities(rootBundle));

final Provider<PanchangCity?> cityProvider = Provider<PanchangCity?>((Ref ref) {
  final String id = ref.watch(
    settingsProvider.select((Settings s) => s.cityId),
  );
  final List<PanchangCity> all =
      ref.watch(citiesProvider).value ?? const <PanchangCity>[];
  for (final PanchangCity c in all) {
    if (c.id == id) return c;
  }
  return null;
});

/// The chosen city's calendar. Null while loading or if the file is missing.
final FutureProvider<CityCalendar?> calendarProvider =
    FutureProvider<CityCalendar?>((Ref ref) async {
      final String id = ref.watch(
        settingsProvider.select((Settings s) => s.cityId),
      );
      try {
        return await loadCalendar(rootBundle, id);
      } on Object catch (e) {
        debugPrint('calendar $id: $e');
        return null;
      }
    });

/// Today's labels for the Today screen ("Ekadashi", "Pradosh 5:38-8:02 pm").
final Provider<List<String>> todayInCalendarProvider = Provider<List<String>>((
  Ref ref,
) {
  final CityCalendar? cal = ref.watch(calendarProvider).value;
  if (cal == null) return const <String>[];
  final Settings s = ref.watch(settingsProvider);
  final int? day = cal.dayIndex(ref.read(clockProvider)());
  if (day == null) return const <String>[];
  return todayLabels(cal, day, rituals: s.rituals, tradition: s.tradition);
});

/// Rebuilds the rolling 30-day schedule whenever a ritual setting changes and
/// each time the app opens. Watched once, from the app root.
final FutureProvider<void> reminderSyncProvider = FutureProvider<void>((
  Ref ref,
) async {
  final Settings s = ref.watch(settingsProvider);
  if (!s.onboarded) return;
  final CityCalendar? cal = await ref.watch(calendarProvider.future);
  final PanchangCity? city = ref.watch(cityProvider);
  if (cal == null || city == null) return;
  final DateTime now = cityNow(city.tz, ref.read(clockProvider)());
  final List<PlannedReminder> plan = planReminders(
    cal: cal,
    rituals: s.rituals,
    deity: s.deity,
    tradition: s.tradition,
    gitaMinutes: s.reminderMinutes,
    today: now,
    nowWall: now,
  );
  try {
    await ref.read(reminderBackendProvider).replaceAll(city.tz, plan);
  } on Object catch (e) {
    // Reminders are best effort: never break the app over them.
    debugPrint('reminders: $e');
  }
});
