import 'package:dharmascroll/app.dart';
import 'package:dharmascroll/app_providers.dart';
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
    child: const DharmaScrollApp(),
  );
}

void main() {
  testWidgets('a first-run user lands on the splash, not the feed', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(await _boot(onboarded: false));
    await tester.pumpAndSettle();

    expect(find.text('DharmaScroll'), findsOneWidget);
    expect(find.text('Shuru karein · Begin'), findsOneWidget);
    expect(find.text('No sign-up needed'), findsOneWidget);
  });

  testWidgets('splash leads to the language step with its counter', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(await _boot(onboarded: false));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Shuru karein · Begin'));
    await tester.pumpAndSettle();

    expect(find.text('Kis bhasha mein padhein?'), findsOneWidget);
    expect(find.text('Step 1 of 3'), findsOneWidget);
  });

  testWidgets('the rail opens the share-card composer', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(await _boot(onboarded: true));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Share').hitTestable().first);
    await tester.pumpAndSettle();

    expect(find.text('Share card'), findsOneWidget);
    expect(find.text('PARCHMENT'), findsOneWidget);
  });

  testWidgets('a returning user lands in the shell with five tabs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(await _boot(onboarded: true));
    await tester.pumpAndSettle();

    expect(find.text('For You'), findsOneWidget);
    expect(find.text('Shloka'), findsOneWidget);
    expect(find.text('Yatra'), findsOneWidget);
    expect(find.text('Sangha'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}
