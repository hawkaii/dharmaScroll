import 'package:dharmascroll/app.dart';
import 'package:dharmascroll/app_providers.dart';
import 'package:dharmascroll/core/theme/app_theme.dart';
import 'package:dharmascroll/presentation/feed/feed_screen.dart';
import 'package:dharmascroll/presentation/feed/widgets/shloka_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Widget> _boot({required bool onboarded}) async {
  SharedPreferences.setMockInitialValues(<String, Object>{
    if (onboarded) 'onboardingComplete': true,
  });
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  return ProviderScope(
    overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
    child: MediaQuery(
      data: const MediaQueryData(disableAnimations: true),
      child: const DharmaScrollApp(),
    ),
  );
}

void main() {
  testWidgets('a first-run user lands on the splash, not the feed', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(await _boot(onboarded: false));
    await tester.pumpAndSettle();

    expect(find.text('DharmaScroll'), findsOneWidget);
    expect(find.text('Scroll less. Live more.'), findsOneWidget);
    expect(find.text('Begin'), findsOneWidget);
  });

  testWidgets('splash leads to the identity step', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(await _boot(onboarded: false));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Begin'));
    await tester.pumpAndSettle();

    expect(find.text('Who are you becoming?'), findsOneWidget);
    expect(find.text('Casual seeker'), findsOneWidget);
  });

  testWidgets('the rail opens the share-card composer', (
    WidgetTester tester,
  ) async {
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

    // Open the expand sheet via tap to reach the share rail.
    await tester.tap(find.byType(ShlokaCard).first);
    await tester.pumpAndSettle();
  });

  testWidgets('a returning user lands in the shell with five tabs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(await _boot(onboarded: true));
    await tester.pumpAndSettle();

    expect(find.text('Daily goal 3/5'), findsOneWidget);
    expect(find.text('Shloka'), findsOneWidget);
    expect(find.text('Yatra'), findsOneWidget);
    expect(find.text('Sangha'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}
