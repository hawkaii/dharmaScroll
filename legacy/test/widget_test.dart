import 'package:dharmascroll/app.dart';
import 'package:dharmascroll/app_providers.dart';
import 'package:dharmascroll/core/theme/app_theme.dart';
import 'package:dharmascroll/presentation/feed/feed_screen.dart';
import 'package:dharmascroll/presentation/feed/widgets/shloka_card.dart';
import 'package:dharmascroll/presentation/onboarding/onboarding_flow.dart';
import 'package:dharmascroll/presentation/today/today_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _app(SharedPreferences prefs) {
  return ProviderScope(
    overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
    child: MediaQuery(
      data: const MediaQueryData(disableAnimations: true),
      child: const DharmaScrollApp(),
    ),
  );
}

Future<SharedPreferences> _prefs({required bool onboarded}) async {
  SharedPreferences.setMockInitialValues(<String, Object>{
    if (onboarded) 'onboardingComplete': true,
  });
  return SharedPreferences.getInstance();
}

void main() {
  testWidgets('a first-run user lands on the welcome screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app(await _prefs(onboarded: false)));
    await tester.pumpAndSettle();

    expect(find.text(OnboardingFlow.welcomeTitle), findsOneWidget);
    expect(find.text('Begin'), findsOneWidget);
    expect(find.text(TodayScreen.beginLabel), findsNothing);
  });

  testWidgets('onboarding is three screens, shown once, then skipped', (
    WidgetTester tester,
  ) async {
    final SharedPreferences prefs = await _prefs(onboarded: false);
    await tester.pumpWidget(_app(prefs));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Begin'));
    await tester.pumpAndSettle();
    expect(find.text(OnboardingFlow.languageTitle), findsOneWidget);

    await tester.tap(find.text('English'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text(OnboardingFlow.reminderTitle), findsOneWidget);

    await tester.tap(find.text('Evening'));
    await tester.tap(find.text(OnboardingFlow.finishLabel));
    await tester.pumpAndSettle();

    // Done: Today is showing and the choices are on disk.
    expect(find.text(TodayScreen.beginLabel), findsOneWidget);
    expect(prefs.getBool('onboardingComplete'), isTrue);
    expect(prefs.getString('lang'), 'englishSanskrit');
    expect(prefs.getInt('remindAtMinutes'), 20 * 60 + 30);

    // A later launch with the same storage goes straight to Today.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(_app(prefs));
    await tester.pumpAndSettle();
    expect(find.text(OnboardingFlow.welcomeTitle), findsNothing);
    expect(find.text(TodayScreen.beginLabel), findsOneWidget);
  });

  testWidgets('onboarding and Today fit 320 dp at 200% text', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final SharedPreferences prefs = await _prefs(onboarded: false);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
        child: const MediaQuery(
          data: MediaQueryData(
            size: Size(320, 568),
            disableAnimations: true,
            textScaler: TextScaler.linear(2),
          ),
          child: DharmaScrollApp(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    for (final String label in <String>[
      'Begin',
      'Continue',
      OnboardingFlow.finishLabel,
    ]) {
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
    expect(find.text(TodayScreen.beginLabel), findsOneWidget);
  });

  testWidgets('a returning user lands on Today with three tabs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app(await _prefs(onboarded: true)));
    await tester.pumpAndSettle();

    expect(find.text(TodayScreen.beginLabel), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Yatra'), findsOneWidget);
    expect(find.text('You'), findsOneWidget);
    expect(find.text('Sangha'), findsOneWidget); // a link on Today, not a tab
    expect(find.text('Profile'), findsNothing);
  });

  testWidgets('Begin opens the verse feed', (WidgetTester tester) async {
    await tester.pumpWidget(_app(await _prefs(onboarded: true)));
    await tester.pumpAndSettle();

    await tester.tap(find.text(TodayScreen.beginLabel));
    await tester.pumpAndSettle();

    expect(find.byType(FeedScreen), findsOneWidget);
    expect(find.text('1 of ${FeedScreen.dailyLimit}'), findsOneWidget);
  });

  testWidgets('tapping a verse opens its sheet', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: const Scaffold(body: FeedScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ShlokaCard).first);
    await tester.pump(kDoubleTapTimeout);
    await tester.pumpAndSettle();
    expect(find.text('SHABDARTH'), findsOneWidget);
  });
}
