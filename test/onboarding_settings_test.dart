import 'dart:convert';
import 'dart:io';

import 'package:dharmascroll/app.dart';
import 'package:dharmascroll/app_providers.dart';
import 'package:dharmascroll/core/auth/auth_service.dart';
import 'package:dharmascroll/core/practice/practice.dart';
import 'package:dharmascroll/core/rituals/panchang.dart';
import 'package:dharmascroll/core/rituals/providers.dart';
import 'package:dharmascroll/core/rituals/reminder_backend.dart';
import 'package:dharmascroll/core/rituals/rituals.dart';
import 'package:dharmascroll/data/verse_repository.dart';
import 'package:dharmascroll/design/info_sheet.dart';
import 'package:dharmascroll/design/lottie_art.dart';
import 'package:dharmascroll/presentation/practice/practice_builder.dart';
import 'package:dharmascroll/presentation/practice/practice_screen.dart';
import 'package:dharmascroll/presentation/practice/tradition_explainer.dart';
import 'package:dharmascroll/presentation/you/you_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'en.dart';

final DateTime _noon = DateTime(2026, 11, 12, 12);

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

Future<void> _pump(WidgetTester tester, SharedPreferences prefs) async {
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
        clockProvider.overrideWithValue(() => _noon),
      ],
      child: const DharmaScrollApp(),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester tester, Finder f) async {
  if (f.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      f,
      200,
      scrollable: find.byType(Scrollable).last,
    );
  }
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

/// Taps "Continue" through the hour and all five practice questions.
Future<void> _throughTheRest(WidgetTester tester) async {
  for (int i = 0; i < 3; i++) {
    await _tap(tester, find.text(en.continueLabel)); // city, tradition, hour
  }
  for (int i = 0; i < PracticeBuilder.questions - 1; i++) {
    await _tap(tester, find.text(en.continueLabel));
  }
  await _tap(tester, find.text(en.finishLabel));
}

Finder _info(String topic) =>
    find.byWidgetPredicate((Widget w) => w is InfoButton && w.topic == topic);

CityCalendar _delhi() {
  Map<String, Object?> read(String f) => (jsonDecode(
    File('assets/panchang/$f.json').readAsStringSync(),
  ) as Map<Object?, Object?>).cast();
  return CityCalendar.fromJson(
    read('new-delhi-in'),
    read('festivals').cast<String, String>(),
  );
}

/// The first two pages (language, text size), left as they are.
Future<void> _pastLanguage(WidgetTester tester) async {
  await _tap(tester, find.text(en.continueLabel));
  await _tap(tester, find.text(en.continueLabel));
}

/// Scrolls a lazy list until [f] is built.
Future<void> _see(WidgetTester tester, Finder f) async {
  if (f.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      f,
      200,
      scrollable: find.byType(Scrollable).last,
    );
  }
}

void main() {
  group('onboarding', () {
    testWidgets('a guest goes through with the defaults', (
      WidgetTester tester,
    ) async {
      final SharedPreferences prefs = await _prefs(onboarded: false);
      await _pump(tester, prefs);
      await _pastLanguage(tester);
      await _tap(tester, find.text(en.welcomeButton));
      await _tap(tester, find.text(en.signInGuest));
      expect(find.text(en.cityTitle), findsOneWidget);
      await _throughTheRest(tester);
      expect(find.text(en.todayBegin), findsOneWidget);
      expect(prefs.getString('authUser'), contains('guest'));
      expect(prefs.getStringList('rituals'), <String>['dailyGita']);
      expect(prefs.getString('deity'), Deity.none.name);
      expect(prefs.getString('cityId'), 'new-delhi-in');
      // No name, so no name in the greeting.
      expect(find.text('Namaste.'), findsOneWidget);
    });

    testWidgets('phone: number, then a six-number code', (
      WidgetTester tester,
    ) async {
      final SharedPreferences prefs = await _prefs(onboarded: false);
      await _pump(tester, prefs);
      await _pastLanguage(tester);
      await _tap(tester, find.text(en.welcomeButton));
      await _tap(tester, find.text(en.signInPhone));
      await tester.enterText(find.byType(TextField), '+91 12');
      await _tap(tester, find.text(en.sendCode));
      expect(find.text('That number looks too short.'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '+91 98765 43210');
      await _tap(tester, find.text(en.sendCode));
      expect(find.text('Code sent to +91 98765 43210'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '1234');
      await tester.pumpAndSettle();
      await _tap(tester, find.text(en.verify)); // still disabled
      expect(find.text(en.cityTitle), findsNothing);
      await tester.enterText(find.byType(TextField), '123456');
      await tester.pumpAndSettle();
      await _tap(tester, find.text(en.verify));
      expect(find.text(en.cityTitle), findsOneWidget);
      expect(prefs.getString('authUser'), contains('919876543210'));
    });

    testWidgets('every step says why it asks; the explainer opens', (
      WidgetTester tester,
    ) async {
      await _pump(tester, await _prefs(onboarded: false));
      await _pastLanguage(tester);
      await _tap(tester, find.text(en.welcomeButton));
      expect(find.text(en.whySignIn), findsOneWidget);
      await _tap(tester, find.text(en.signInGuest));
      expect(find.text(en.whyCity), findsOneWidget);
      await _tap(tester, find.text(en.continueLabel));
      expect(find.text(en.whyTradition), findsOneWidget);
      await _tap(tester, find.text(en.seeDifference));
      expect(find.text(TraditionCopy.title), findsOneWidget);
      expect(find.text(TraditionCopy.unsure), findsOneWidget);
      expect(find.byType(EkadashiTimeline), findsOneWidget);
      await _tap(tester, find.text('Got it'));
      expect(find.text(TraditionCopy.title), findsNothing);
      await _tap(tester, find.text(en.continueLabel));
      expect(find.text(en.whyHour), findsOneWidget);
      await _tap(tester, find.text(en.continueLabel));
      expect(find.text(PracticeBuilder.titles(en).first), findsOneWidget);
      // Back from the first question returns to the hour.
      await _tap(tester, find.text('Back'));
      expect(find.text(en.reminderTitle), findsOneWidget);
    });
  });

  group('practice', () {
    test('rules turn answers into rituals', () {
      const RulePracticeSuggester s = RulePracticeSuggester();
      expect(s.suggest(const PracticeAnswers()).rituals, <Ritual>{
        Ritual.dailyGita,
      });
      final PracticePlan all = s.suggest(
        const PracticeAnswers(
          fast: true,
          day: Deity.hanuman,
          duskLamp: true,
          sunrise: true,
          moonDays: true,
        ),
      );
      expect(all.rituals, <Ritual>{
        Ritual.dailyGita,
        Ritual.ekadashi,
        Ritual.diya,
        Ritual.sandhya,
        Ritual.purnima,
        Ritual.amavasya,
        Ritual.festivals,
      });
      expect(all.deity, Deity.hanuman);
      // Building again keeps what only the full list can switch on.
      expect(
        applyPlan(all, <Ritual>{Ritual.pradosh, Ritual.purnima}).rituals,
        contains(Ritual.pradosh),
      );
    });

    test('previews come from the real planner', () {
      final PreviewContext smarta = PreviewContext(
        cal: _delhi(),
        now: _noon,
        tradition: Tradition.smarta,
        gitaMinutes: 390,
      );
      final PlannedReminder ek = firstNote(
        smarta,
        rituals: <Ritual>{Ritual.ekadashi},
      )!;
      // Dev Uthani Ekadashi: Smarta 20 Nov, Vaishnava 21 Nov (AUDIT.md).
      expect(DateUtils.dateOnly(ek.wall), DateTime(2026, 11, 20));
      expect(ek.body, startsWith('Ekadashi begins at sunrise.'));
      final PreviewContext vaish = PreviewContext(
        cal: smarta.cal,
        now: _noon,
        tradition: Tradition.vaishnava,
        gitaMinutes: 390,
      );
      expect(
        DateUtils.dateOnly(
          firstNote(vaish, rituals: <Ritual>{Ritual.ekadashi})!.wall,
        ),
        DateTime(2026, 11, 21),
      );
      final PlannedReminder lamp = firstNote(
        smarta,
        rituals: <Ritual>{Ritual.diya},
      )!;
      expect(lamp.body, startsWith('Sunset at'));
      expect(whenLabel(lamp.wall, _noon), startsWith('Today, 5:'));
      expect(
        whenLabel(DateTime(2026, 11, 20, 6, 52), _noon),
        'Fri 20 Nov, 6:52 am',
      );
      final PlannedReminder monday = firstNote(smarta, deity: Deity.shiva)!;
      expect(monday.wall.weekday, DateTime.monday);
    });

    testWidgets('Your practice lists what is on and rebuilds', (
      WidgetTester tester,
    ) async {
      final SharedPreferences prefs = await _prefs(
        extra: <String, Object>{
          'rituals': <String>['dailyGita', 'purnima', 'pradosh'],
          'deity': 'shiva',
        },
      );
      await _pump(tester, prefs);
      await _tap(tester, find.text('YOU'));
      await _see(tester, find.text('4 on'));
      expect(find.text('4 on'), findsOneWidget);
      await _tap(tester, find.text(en.practiceRow));
      expect(find.text(PracticeScreen.title), findsOneWidget);
      expect(find.text('Daily Gita, 6:30 am'), findsOneWidget);
      expect(find.text(ritualMeaning(Ritual.purnima)), findsOneWidget);
      expect(find.text('Shiva, Monday'), findsOneWidget);
      // Tap one: what it means, and a way to turn it off.
      await _tap(tester, find.text('Purnima'));
      await _tap(tester, find.text('Turn this off'));
      expect(prefs.getStringList('rituals'), isNot(contains('purnima')));

      await _tap(tester, find.text(PracticeScreen.rebuild));
      expect(find.text(PracticeBuilder.titles(en).first), findsOneWidget);
      await _tap(tester, find.text('Yes, on Ekadashi'));
      await _tap(tester, find.text(en.continueLabel));
      // Shiva is already chosen from before.
      await _tap(tester, find.text('Tuesday'));
      for (int i = 0; i < 3; i++) {
        await _tap(tester, find.text(en.continueLabel));
      }
      await _tap(tester, find.text(BuildPracticeScreen.save));
      // Back on Your practice, with the new day listed.
      expect(find.text('Hanuman, Tuesday'), findsOneWidget);
      expect(prefs.getStringList('rituals')!.toSet(), <String>{
        'dailyGita',
        'ekadashi',
        'pradosh', // advanced, kept
      });
      expect(prefs.getString('deity'), 'hanuman');
    });
  });

  group('settings', () {
    testWidgets('every row has one plain line', (WidgetTester tester) async {
      await _pump(tester, await _prefs());
      await _tap(tester, find.text('YOU'));
      await _see(tester, find.text(en.practiceRowWhy));
      expect(find.text(en.practiceRowWhy), findsOneWidget);
      for (final String row in <String>[
        YouScreen.languageRow,
        en.textSizeRow,
        en.practiceRow,
        en.placeRow,
        en.soundRow,
        en.lookRow,
        en.accountRow,
      ]) {
        if (find.text(row).evaluate().isEmpty) {
          await tester.scrollUntilVisible(
            find.text(row),
            200,
            scrollable: find.byType(Scrollable).last,
          );
        }
        expect(find.text(row), findsOneWidget);
      }
    });

    testWidgets('sound and haptics switch on their own', (
      WidgetTester tester,
    ) async {
      final SharedPreferences prefs = await _prefs();
      await _pump(tester, prefs);
      await _tap(tester, find.text('YOU'));
      await _tap(tester, find.text(en.soundRow));
      await _tap(tester, find.text('Sound'));
      expect(prefs.getBool('soundHaptics'), isFalse);
      expect(prefs.getBool('haptics'), isNull);
      await _tap(tester, _info(en.hapticsLabel));
      expect(find.textContaining('the phone moves a tiny bit'), findsOneWidget);
    });

    testWidgets('an old sound-and-haptics switch carries over', (
      WidgetTester tester,
    ) async {
      final SharedPreferences prefs = await _prefs(
        extra: <String, Object>{'soundHaptics': false},
      );
      await _pump(tester, prefs);
      await _tap(tester, find.text('YOU'));
      await _tap(tester, find.text(en.soundRow));
      final Iterable<Switch> s = tester.widgetList<Switch>(find.byType(Switch));
      expect(s.map((Switch x) => x.value), <bool>[false, false]);
    });

    testWidgets('City and tradition opens the explainer from its i', (
      WidgetTester tester,
    ) async {
      await _pump(tester, await _prefs());
      await _tap(tester, find.text('YOU'));
      await _tap(tester, find.text(en.placeRow));
      await _tap(tester, _info('How you keep Ekadashi'));
      expect(find.text(TraditionCopy.title), findsOneWidget);
    });

    testWidgets('account: name, sign out keeps progress', (
      WidgetTester tester,
    ) async {
      final SharedPreferences prefs = await _prefs(
        extra: <String, Object>{
          'p.points': 40,
          FakeAuthService.kUser: jsonEncode(<String, Object?>{
            'id': 'x',
            'name': 'Asha',
            'method': 'google',
          }),
        },
      );
      await _pump(tester, prefs);
      expect(find.text('Namaste, Asha.'), findsOneWidget);
      await _tap(tester, find.text('YOU'));
      expect(find.text('Asha'), findsOneWidget);
      await _tap(tester, find.text('Asha'));
      await _tap(tester, find.text('Sign out'));
      expect(prefs.getString(FakeAuthService.kUser), isNull);
      expect(prefs.getInt('p.points'), 40);
      expect(find.text(en.signInGoogle), findsOneWidget);
    });
  });

  group('auth', () {
    test('the fake service keeps everything on the phone', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final FakeAuthService a = FakeAuthService(
        await SharedPreferences.getInstance(),
      );
      expect(a.current, isNull);
      await expectLater(
        a.verifyCode('919876543210', '12'),
        throwsA(isA<AuthException>()),
      );
      final AuthUser u = await a.verifyCode('919876543210', '123456');
      expect(a.current?.method, SignInMethod.phone);
      expect((await a.rename('  Meera ')).name, 'Meera');
      expect(a.current?.id, u.id);
      await a.signOut();
      expect(a.current, isNull);
    });
  });

  group('lottie', () {
    // Board v3 tokens; every colour in every file must be one of these.
    const Set<String> tokens = <String>{
      'ffc247', 'f28c28', 'f7d58b', 'e58ba3', //
      '4fb3ab', 'fbefd9', 'c9b2b8', '8f7a8c', 'ffb03b', 'fff3cf',
    };

    void colours(Object? j, Set<String> out) {
      if (j is Map) {
        final Object? c = j['c'];
        if ((j['ty'] == 'fl' || j['ty'] == 'st') && c is Map) {
          final List<Object?> k = c['k']! as List<Object?>;
          out.add(
            k
                .take(3)
                .map(
                  (Object? v) => ((v! as num) * 255)
                      .round()
                      .toRadixString(16)
                      .padLeft(2, '0'),
                )
                .join(),
          );
        }
        for (final Object? v in j.values) {
          colours(v, out);
        }
      } else if (j is List) {
        for (final Object? v in j) {
          colours(v, out);
        }
      }
    }

    for (final Art a in Art.values) {
      test('${a.file} parses, fits its frame, uses only tokens', () async {
        final String raw = File(a.asset).readAsStringSync();
        final LottieComposition comp = await LottieComposition.fromBytes(
          utf8.encode(raw),
        );
        expect(comp.duration, greaterThan(Duration.zero));
        expect(comp.bounds.width / comp.bounds.height, closeTo(a.aspect, 0.01));
        expect(a.still, inInclusiveRange(0, 1));
        final Set<String> used = <String>{};
        colours(jsonDecode(raw), used);
        expect(used.difference(tokens), isEmpty);
        // Small, and nothing the Flutter player draws badly.
        expect(raw.length, lessThan(40000));
        expect(raw, isNot(contains('"ef"'))); // effects
        expect(raw, isNot(contains('"masksProperties"')));
        expect(raw, isNot(contains('"x":"'))); // expressions
      });
    }
  });
}
