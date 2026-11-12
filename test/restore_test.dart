import 'dart:io';
import 'dart:typed_data';

import 'package:dharmascroll/app.dart';
import 'package:dharmascroll/app_providers.dart';
import 'package:dharmascroll/core/share/share_service.dart';
import 'package:dharmascroll/core/state/progress.dart';
import 'package:dharmascroll/data/verse_repository.dart';
import 'package:dharmascroll/presentation/kept/verse_screen.dart';
import 'package:dharmascroll/presentation/milestone/milestone_screen.dart';
import 'package:dharmascroll/presentation/share/share_sheet.dart';
import 'package:dharmascroll/presentation/today/today_screen.dart';
import 'package:dharmascroll/presentation/walk/complete_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeShare extends ShareService {
  final List<(Uint8List, String, String)> calls =
      <(Uint8List, String, String)>[];

  @override
  Future<bool> sharePng(Uint8List png, String name, String text) async {
    calls.add((png, name, text));
    return true;
  }
}

final DateTime noon = DateTime(2026, 11, 12, 12);

String _day(int back) => dayKey(noon.subtract(Duration(days: back)));

Future<SharedPreferences> _prefs([
  Map<String, Object> extra = const <String, Object>{},
]) async {
  SharedPreferences.setMockInitialValues(<String, Object>{
    'onboardingComplete': true,
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
        clockProvider.overrideWithValue(() => noon),
      ],
      child: const DharmaScrollApp(),
    ),
  );
  await tester.pumpAndSettle();
}

/// Taps Share and lets the real PNG encoder run outside the fake clock.
Future<void> _shareNow(WidgetTester tester) async {
  await tester.runAsync(() async {
    await tester.tap(find.text(ShareSheet.shareLabel));
    for (int i = 0; i < 20; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
  });
  await tester.pumpAndSettle();
}

void main() {
  late _FakeShare share;
  setUp(() {
    share = _FakeShare();
    ShareService.instance = share;
  });

  testWidgets('a verse in the Hear scroll shares as a PNG card', (
    WidgetTester tester,
  ) async {
    await _pump(tester, await _prefs());
    await tester.tap(find.text(TodayScreen.beginLabel));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Share this verse').first);
    await tester.pumpAndSettle();
    expect(find.text('Temple night'), findsOneWidget);

    await _shareNow(tester);
    expect(share.calls, hasLength(1));
    final (Uint8List png, String name, String text) = share.calls.single;
    // PNG signature, and a real 1080 x 1920 image.
    expect(png.sublist(0, 4), <int>[0x89, 0x50, 0x4E, 0x47]);
    expect(ByteData.sublistView(png).getUint32(16), 1080);
    expect(ByteData.sublistView(png).getUint32(20), 1920);
    expect(name, 'dharmascroll-gita-2-47');
    expect(text, contains('2.47'));
  });

  testWidgets('kept verses open into the verse, which can be shared', (
    WidgetTester tester,
  ) async {
    await _pump(
      tester,
      await _prefs(<String, Object>{
        'p.kept': <String>['2.47', '6.5'],
      }),
    );
    await tester.tap(find.text('YOU'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Kept verses, 2'));
    await tester.pumpAndSettle();
    expect(find.text('GITA 6.5'), findsOneWidget);
    expect(find.text('GITA 2.47'), findsOneWidget);

    await tester.tap(find.text('GITA 2.47'));
    await tester.pumpAndSettle();
    expect(find.text('GO DEEPER'), findsOneWidget);
    await tester.tap(find.text(VerseScreen.shareLabel));
    await tester.pumpAndSettle();
    await _shareNow(tester);
    expect(share.calls.single.$2, 'dharmascroll-gita-2-47');
  });

  testWidgets('day 7: walking the step opens the milestone, once', (
    WidgetTester tester,
  ) async {
    final SharedPreferences prefs = await _prefs(<String, Object>{
      'p.streak': 6,
      'p.points': 240,
      'p.lit': <String>[for (int i = 6; i >= 1; i--) _day(i)],
      'p.day': _day(0),
      'p.heard': 5,
      'p.steps': <String>['hear'],
    });
    await _pump(tester, prefs);
    await tester.tap(find.text(TodayScreen.continueLabel));
    await tester.pumpAndSettle();

    // Hold the chant ring until it fills.
    final TestGesture hold = await tester.startGesture(
      tester.getCenter(find.bySemanticsLabel(RegExp('^Chant along'))),
    );
    for (int i = 0; i < 14; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    await hold.up();
    await tester.pumpAndSettle();
    await tester.tap(find.text('This one'));
    await tester.pumpAndSettle();
    expect(find.text('The lamp is lit.'), findsOneWidget);
    expect(find.text(CompleteScreen.shareLabel), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('7'), findsOneWidget);
    expect(find.text(MilestoneScreen.title), findsOneWidget);
    expect(find.text('A WEEK OF LIGHT'), findsOneWidget);
    expect(prefs.getStringList('p.ms'), contains('7'));
    expect(prefs.getInt('p.streak'), 7);

    await tester.tap(find.text(MilestoneScreen.shareLabel));
    await tester.pumpAndSettle();
    expect(find.text('Lamp, night'), findsOneWidget);
    await _shareNow(tester);
    expect(share.calls.single.$2, 'dharmascroll-7-days');
  });

  testWidgets('wallet lists where points came from', (
    WidgetTester tester,
  ) async {
    await _pump(
      tester,
      await _prefs(<String, Object>{
        'p.points': 40,
        'p.ledger': <String>['${_day(1)}|hear|10', '${_day(1)}|walk|30'],
      }),
    );
    await tester.tap(find.text('YOU'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Moksh Points, 40'));
    await tester.pumpAndSettle();
    expect(find.text('YESTERDAY'), findsOneWidget);
    expect(find.text('One step walked'), findsOneWidget);
    expect(find.text('+30'), findsOneWidget);
  });
}
