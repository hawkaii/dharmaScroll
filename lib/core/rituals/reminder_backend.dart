import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'rituals.dart';

/// Where planned reminders go. The real one talks to the OS; tests and the web
/// build use [NoopReminderBackend].
abstract class ReminderBackend {
  /// Ask for notification permission (Android 13+, iOS). True when granted.
  Future<bool> requestPermission();

  /// Cancel everything pending and schedule [items] at their wall-clock time
  /// in the IANA zone [tzName].
  Future<void> replaceAll(String tzName, List<PlannedReminder> items);
}

class NoopReminderBackend implements ReminderBackend {
  const NoopReminderBackend();

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<void> replaceAll(String tzName, List<PlannedReminder> items) async {}
}

/// The instant a wall-clock reminder fires, DST-correct for the zone.
tz.TZDateTime zonedInstant(String tzName, DateTime wall) {
  if (!_tzReady) {
    tzdata.initializeTimeZones();
    _tzReady = true;
  }
  return tz.TZDateTime(
    tz.getLocation(tzName),
    wall.year,
    wall.month,
    wall.day,
    wall.hour,
    wall.minute,
  );
}

bool _tzReady = false;

/// The current wall-clock time in a zone, from a device clock reading.
DateTime cityNow(String tzName, DateTime deviceNow) {
  if (!_tzReady) {
    tzdata.initializeTimeZones();
    _tzReady = true;
  }
  final tz.TZDateTime t = tz.TZDateTime.from(
    deviceNow.toUtc(),
    tz.getLocation(tzName),
  );
  return DateTime(t.year, t.month, t.day, t.hour, t.minute);
}

class LocalNotificationsBackend implements ReminderBackend {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  Future<void>? _ready;

  Future<void> _init() => _ready ??= () async {
    if (!_tzReady) {
      tzdata.initializeTimeZones();
      _tzReady = true;
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
  }();

  @override
  Future<bool> requestPermission() async {
    await _init();
    final bool? android = await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    final bool? ios = await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, sound: true);
    return (android ?? ios) ?? false;
  }

  @override
  Future<void> replaceAll(String tzName, List<PlannedReminder> items) async {
    await _init();
    await _plugin.cancelAll();
    const NotificationDetails details = NotificationDetails(
      android: AndroidNotificationDetails(
        'rituals',
        'Ritual reminders',
        channelDescription: 'Quiet reminders for the rituals you chose.',
      ),
      iOS: DarwinNotificationDetails(),
    );
    for (final PlannedReminder r in items) {
      await _plugin.zonedSchedule(
        id: r.id,
        title: 'DharmaScroll',
        body: r.body,
        scheduledDate: zonedInstant(tzName, r.wall),
        notificationDetails: details,
        // Inexact: no exact-alarm permission; a few minutes' drift is fine.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }
}
