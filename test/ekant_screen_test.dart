import 'dart:io';

import 'package:dharmascroll/core/rituals/providers.dart';
import 'package:dharmascroll/core/rituals/reminder_backend.dart';
import 'package:dharmascroll/app.dart';
import 'package:dharmascroll/app_providers.dart';
import 'package:dharmascroll/data/verse_repository.dart';
import 'package:dharmascroll/features/ekant/crisis_screen.dart';
import 'package:dharmascroll/features/ekant/chat_history.dart';
import 'package:dharmascroll/features/ekant/chat_service.dart';
import 'package:dharmascroll/features/ekant/ekant_screen.dart';
import 'package:dharmascroll/features/ekant/ekant_sitting.dart';
import 'package:dharmascroll/features/ekant/ekant_voice.dart';
import 'package:dharmascroll/features/ekant/kept_notes.dart';
import 'package:dharmascroll/presentation/today/today_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'en.dart';

Future<void> _openRoom(
  WidgetTester tester,
  MemoryKeptNotesStore store, [
  MemoryChatHistoryStore? history,
]) async {
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues(<String, Object>{
    'onboardingComplete': true,
  });
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
        versesProvider.overrideWithValue(
          parseVerses(File('assets/data/gita_v1.json').readAsStringSync()),
        ),
        clockProvider.overrideWithValue(() => DateTime(2026, 11, 12, 20)),
        reminderBackendProvider.overrideWithValue(const NoopReminderBackend()),
        keptNotesStoreProvider.overrideWithValue(store),
        ekantVoiceProvider.overrideWithValue(null),
        chatHistoryStoreProvider.overrideWithValue(
          history ?? MemoryChatHistoryStore(),
        ),
      ],
      child: const DharmaScrollApp(),
    ),
  );
  await tester.pumpAndSettle();
  expect(find.byType(TodayScreen), findsOneWidget);
  final Finder link = find.text('Ekant, a quiet room');
  await tester.ensureVisible(link);
  await tester.tap(link);
  await tester.pumpAndSettle();
  await tester.tap(find.text(en.ekWrite));
  await tester.pumpAndSettle();
  expect(find.text(en.ekPrompt), findsOneWidget);
}

Future<void> _say(WidgetTester tester, String words) async {
  await tester.enterText(find.byType(TextField), words);
  await tester.pump();
  await tester.tap(find.text(en.ekSend));
  // The reply streams in over a few seconds of fake time.
  await tester.pump(const Duration(seconds: 6));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a sitting stops after 8 turns, then the words fade', (
    WidgetTester tester,
  ) async {
    final MemoryKeptNotesStore store = MemoryKeptNotesStore();
    final MemoryChatHistoryStore history = MemoryChatHistoryStore();
    await _openRoom(tester, store, history);

    for (int i = 1; i <= EkantSitting.maxTurns; i++) {
      expect(find.byType(TextField), findsOneWidget, reason: 'turn $i');
      await _say(tester, 'Work is heavy, turn $i');
      // The thread keeps every turn; older ones scroll out of view.
      expect(
        history.messages.where((m) => m.role == ChatRole.user).last.text,
        'Work is heavy, turn $i',
      );
      expect(
        find.textContaining('GITA '),
        findsWidgets,
        reason: 'the latest reply carries a verse card',
      );
      expect(find.text('$i OF 8'), findsOneWidget);
    }
    // The cap: no more writing, only rest.
    expect(find.byType(TextField), findsNothing);
    expect(find.text(en.ekEnough), findsOneWidget);
    await tester.tap(find.text(en.ekRest));
    await tester.pumpAndSettle();

    // The close: one verse to carry and every word of the sitting.
    expect(find.text('A VERSE TO CARRY'), findsOneWidget);
    expect(find.text('Work is heavy, turn 1'), findsOneWidget);
    expect(history.messages, isNotEmpty);
    await tester.tap(find.text(en.ekFade));
    // Reduce motion is on here, so Flutter runs the fade 20 times faster
    // (80 ms); it still fades rather than cutting.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 40));
    final double mid = tester
        .widget<Opacity>(
          find
              .ancestor(
                of: find.byKey(const ValueKey<String>('ekant-words')),
                matching: find.byType(Opacity),
              )
              .first,
        )
        .opacity;
    expect(mid, inExclusiveRange(0, 1), reason: 'the words are fading');
    await tester.pump(EkantScreen.fade);
    await tester.pumpAndSettle();

    expect(find.text('Rest now.'), findsOneWidget);
    expect(find.textContaining('Work is heavy'), findsNothing);
    expect(store.notes, isEmpty);
    expect(
      history.messages,
      isEmpty,
      reason: 'letting it fade clears the thread',
    );

    await tester.tap(find.text(en.ekReturn));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1)); // the drone fades out
    expect(find.byType(TodayScreen), findsOneWidget);
  });

  testWidgets('Keep saves the words on the phone', (WidgetTester tester) async {
    final MemoryKeptNotesStore store = MemoryKeptNotesStore();
    await _openRoom(tester, store);
    await _say(tester, 'I am so angry at my brother');
    await tester.tap(find.text(en.ekRest));
    await tester.pumpAndSettle();
    await tester.tap(find.text(en.ekKeep));
    await tester.pumpAndSettle();

    expect(store.notes.single.words, <String>['I am so angry at my brother']);
    expect(find.textContaining('Kept on this phone only'), findsOneWidget);
    await tester.tap(find.text(en.ekReturn));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1)); // the drone fades out
  });

  testWidgets('crisis words open the crisis screen, with no verse', (
    WidgetTester tester,
  ) async {
    final MemoryKeptNotesStore store = MemoryKeptNotesStore();
    await _openRoom(tester, store);
    await _say(tester, 'I want to kill myself');

    expect(find.byType(CrisisScreen), findsOneWidget);
    expect(find.text(en.crisisTitle), findsOneWidget);
    expect(find.text(en.crisisCall), findsOneWidget);
    expect(find.textContaining('112'), findsWidgets);
    expect(find.textContaining('GITA'), findsNothing);
    expect(find.textContaining('Moksh'), findsNothing);
    expect(store.notes, isEmpty);

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(TodayScreen), findsOneWidget);
  });
}
