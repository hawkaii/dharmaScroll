import 'dart:io';

import 'package:dharmascroll/app.dart';
import 'package:dharmascroll/app_providers.dart';
import 'package:dharmascroll/core/rituals/providers.dart';
import 'package:dharmascroll/core/rituals/reminder_backend.dart';
import 'package:dharmascroll/core/rituals/rituals.dart';
import 'package:dharmascroll/core/state/progress.dart';
import 'package:dharmascroll/data/verse_repository.dart';
import 'package:dharmascroll/design/theme.dart';
import 'package:dharmascroll/design/tokens.dart';
import 'package:dharmascroll/presentation/hear/hear_screen.dart';
import 'package:dharmascroll/presentation/onboarding/onboarding_flow.dart';
import 'package:dharmascroll/presentation/today/today_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<SharedPreferences> _prefs({
  bool onboarded = true,
  Map<String, Object> extra = const <String, Object>{},
}) async {
  SharedPreferences.setMockInitialValues(<String, Object>{
    if (onboarded) 'onboardingComplete': true,
    ...extra,
  });
  return SharedPreferences.getInstance();
}

Future<void> _pump(
  WidgetTester tester,
  SharedPreferences prefs, {
  DateTime? now,
}) async {
  // Reduce motion: no endless loops, so pumpAndSettle can finish.
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
        versesProvider.overrideWithValue(
          parseVerses(File('assets/data/gita_v1.json').readAsStringSync()),
        ),
        reminderBackendProvider.overrideWithValue(const NoopReminderBackend()),
        if (now != null) clockProvider.overrideWithValue(() => now),
      ],
      child: const DharmaScrollApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  final DateTime noon = DateTime(2026, 11, 12, 12);

  testWidgets('onboarding is 5 light screens, shown once', (
    WidgetTester tester,
  ) async {
    final SharedPreferences prefs = await _prefs(onboarded: false);
    await _pump(tester, prefs, now: noon);
    expect(find.text(OnboardingFlow.welcomeButton), findsOneWidget);

    await tester.tap(find.text(OnboardingFlow.welcomeButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text(OnboardingFlow.ritualButton));
    await tester.pumpAndSettle();
    // City: Delhi is chosen; search finds a diaspora city.
    expect(find.text('New Delhi'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'edison');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edison, US'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(OnboardingFlow.ritualButton));
    await tester.pumpAndSettle();
    // Tradition.
    await tester.tap(find.text('Vaishnava'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(OnboardingFlow.ritualButton));
    await tester.pumpAndSettle();
    expect(find.text(OnboardingFlow.finishLabel), findsOneWidget);

    await tester.tap(find.text(OnboardingFlow.finishLabel));
    await tester.pumpAndSettle();
    expect(find.text(TodayScreen.beginLabel), findsOneWidget);
    expect(prefs.getBool('onboardingComplete'), isTrue);
    expect(prefs.getInt('remindAtMinutes'), 6 * 60 + 30);
    expect(prefs.getString('cityId'), 'edison-us');
    expect(prefs.getString('tradition'), 'vaishnava');

    // A later launch with the same storage goes straight to Today.
    await tester.pumpWidget(const SizedBox.shrink());
    await _pump(tester, prefs, now: noon);
    expect(find.text(OnboardingFlow.welcomeButton), findsNothing);
    expect(find.text(TodayScreen.beginLabel), findsOneWidget);
  });

  testWidgets('You: the ritual picker switches rituals on and off', (
    WidgetTester tester,
  ) async {
    final SharedPreferences prefs = await _prefs();
    await _pump(tester, prefs, now: noon);
    await tester.tap(find.text('YOU'));
    await tester.pumpAndSettle();
    expect(find.text('1 on'), findsOneWidget); // Daily Gita by default
    await tester.tap(find.text('Rituals'));
    await tester.pumpAndSettle();
    expect(find.text('Morning sandhya'), findsOneWidget);
    await tester.tap(find.text('Purnima'));
    await tester.pumpAndSettle();
    expect(
      prefs.getStringList('rituals'),
      containsAll(<String>['dailyGita', 'purnima']),
    );
    await tester.tap(find.text('Daily Gita'));
    await tester.pumpAndSettle();
    expect(prefs.getStringList('rituals'), <String>['purnima']);
    await tester.scrollUntilVisible(
      find.text('Shiva, Monday'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Shiva, Monday'));
    await tester.pumpAndSettle();
    expect(prefs.getString('deity'), Deity.shiva.name);
  });

  testWidgets('Today names a ritual that falls today', (
    WidgetTester tester,
  ) async {
    final SharedPreferences prefs = await _prefs(
      extra: <String, Object>{
        'rituals': <String>['ekadashi', 'festivals'],
        'tradition': 'smarta',
      },
    );
    await _pump(tester, prefs, now: DateTime(2026, 12, 20, 9));
    // The calendar is a bundled asset: real IO, outside fake-async time.
    for (int i = 0; i < 50; i++) {
      if (find.text('Ekadashi  ·  Gita Jayanti').evaluate().isNotEmpty) break;
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump();
    }
    expect(find.text('Ekadashi  ·  Gita Jayanti'), findsOneWidget);
  });

  testWidgets('three tabs, no more', (WidgetTester tester) async {
    await _pump(tester, await _prefs(), now: noon);
    expect(find.text('TODAY'), findsOneWidget);
    expect(find.text('YATRA'), findsOneWidget);
    expect(find.text('YOU'), findsOneWidget);
  });

  testWidgets('five verses then the end page; the end completes Hear', (
    WidgetTester tester,
  ) async {
    final SharedPreferences prefs = await _prefs();
    await _pump(tester, prefs, now: noon);
    await tester.tap(find.text(TodayScreen.beginLabel));
    await tester.pumpAndSettle();

    for (int i = 1; i <= HearScreen.dailyLimit; i++) {
      expect(find.text('$i OF ${HearScreen.dailyLimit}'), findsOneWidget);
      expect(find.text('That is enough\nfor today.'), findsNothing);
      await tester.fling(find.byType(PageView), const Offset(0, -500), 2000);
      await tester.pumpAndSettle();
    }
    expect(find.text(HearScreen.endTitle), findsOneWidget);
    expect(find.text(HearScreen.nextLabel), findsOneWidget);
    // Nothing after the end page.
    await tester.fling(find.byType(PageView), const Offset(0, -500), 2000);
    await tester.pumpAndSettle();
    expect(find.text(HearScreen.endTitle), findsOneWidget);
    expect(prefs.getStringList('p.steps'), contains('hear'));
    await tester.tap(find.text(HearScreen.nextLabel));
    await tester.pumpAndSettle();
    expect(find.text('WALK  ·  STEP 1 OF 2'), findsOneWidget);
  });

  testWidgets('double-tap keeps a verse', (WidgetTester tester) async {
    final SharedPreferences prefs = await _prefs();
    await _pump(tester, prefs, now: noon);
    await tester.tap(find.text(TodayScreen.beginLabel));
    await tester.pumpAndSettle();
    final Offset at = tester.getCenter(find.byType(PageView));
    await tester.tapAt(at);
    await tester.pump(const Duration(milliseconds: 60));
    await tester.tapAt(at);
    await tester.pumpAndSettle();
    expect(find.text('KEPT'), findsOneWidget);
    expect(prefs.getStringList('p.kept'), isNotEmpty);
  });

  group('light mode rule', () {
    for (final (int hour, bool light) in <(int, bool)>[
      (4, false),
      (5, true),
      (9, true),
      (10, false),
      (21, false),
    ]) {
      testWidgets('Today at $hour:00 is ${light ? 'light' : 'night'}', (
        WidgetTester tester,
      ) async {
        await _pump(
          tester,
          await _prefs(),
          now: DateTime(2026, 11, 12, hour, 30),
        );
        final BuildContext ctx = tester.element(
          find.text(TodayScreen.beginLabel),
        );
        expect(ctx.c.isLight, light);
        expect(DharmaTheme.isDawnHour(DateTime(2026, 1, 1, hour)), light);
      });
    }

    testWidgets('Night setting forces dark, and Yatra stays dark', (
      WidgetTester tester,
    ) async {
      await _pump(
        tester,
        await _prefs(extra: <String, Object>{'appearance': 'night'}),
        now: DateTime(2026, 11, 12, 7),
      );
      expect(
        tester.element(find.text(TodayScreen.beginLabel)).c.isLight,
        isFalse,
      );
    });

    testWidgets('light applies on Today only', (WidgetTester tester) async {
      await _pump(tester, await _prefs(), now: DateTime(2026, 11, 12, 7));
      await tester.tap(find.text('YATRA'));
      await tester.pumpAndSettle();
      expect(tester.element(find.text('GITA YATRA')).c.isLight, isFalse);
    });
  });

  group('streak', () {
    ProviderContainer make(SharedPreferences p, DateTime now) {
      final ProviderContainer c = ProviderContainer(
        overrides: [
          sharedPrefsProvider.overrideWithValue(p),
          clockProvider.overrideWithValue(() => now),
        ],
      );
      addTearDown(c.dispose);
      return c;
    }

    test('one missed day in a week is forgiven, the next is not', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'p.streak': 5,
        'p.lit': <String>['2026-11-09'],
      });
      final SharedPreferences p = await SharedPreferences.getInstance();
      // Missed the 10th. Today is the 11th.
      final ProviderContainer c = make(p, DateTime(2026, 11, 11, 8));
      expect(c.read(progressProvider).cameBack, isFalse);
      c.read(progressProvider.notifier).completeStep(RitualStep.walk);
      expect(c.read(progressProvider).streak, 6);

      // Two days later, a second miss inside the same week resets quietly.
      final ProviderContainer d = make(p, DateTime(2026, 11, 13, 8));
      d.read(progressProvider.notifier).completeStep(RitualStep.walk);
      expect(d.read(progressProvider).streak, 1);
    });

    test('points only go up, steps award once', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final SharedPreferences p = await SharedPreferences.getInstance();
      final ProviderContainer c = make(p, DateTime(2026, 11, 11, 8));
      final ProgressNotifier n = c.read(progressProvider.notifier);
      expect(n.completeStep(RitualStep.walk), ProgressNotifier.walkPoints);
      expect(n.completeStep(RitualStep.walk), 0);
      expect(c.read(progressProvider).points, ProgressNotifier.walkPoints);
    });
  });
}
