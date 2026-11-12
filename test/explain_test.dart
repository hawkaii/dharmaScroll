import 'dart:convert';
import 'dart:io';

import 'package:dharmascroll/app.dart';
import 'package:dharmascroll/app_providers.dart';
import 'package:dharmascroll/core/rituals/providers.dart';
import 'package:dharmascroll/core/rituals/reminder_backend.dart';
import 'package:dharmascroll/core/state/settings.dart';
import 'package:dharmascroll/data/verse_repository.dart';
import 'package:dharmascroll/design/theme.dart';
import 'package:dharmascroll/domain/models/verse.dart';
import 'package:dharmascroll/features/explain/explain_sheet.dart';
import 'package:dharmascroll/features/explain/verse_explainer.dart';
import 'package:dharmascroll/features/explain/verse_notes.dart';
import 'package:dharmascroll/presentation/today/today_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

final RegExp _devanagari = RegExp(r'[\u0900-\u097F]');
final RegExp _devaWord = RegExp(r'^[\u0900-\u097F \-]+$');

class _FakeModel implements VerseExplainer {
  _FakeModel(this.reply);

  final DayReflection reply;
  int calls = 0;

  @override
  bool get usesModel => true;

  @override
  Future<DayReflection> explainForMyDay(
    String verseId, {
    String? userNote,
  }) async {
    calls++;
    return reply;
  }
}

void main() {
  final List<Verse> verses = parseVerses(
    File('assets/data/gita_v1.json').readAsStringSync(),
  );
  final String explainSource = File(kExplainAsset).readAsStringSync();
  final ExplainLibrary lib = parseExplain(explainSource);
  final Map<String, Verse> byId = <String, Verse>{
    for (final Verse v in verses) v.id: v,
  };
  Verse verse(String id) => byId[id]!;

  group('explain data', () {
    test('is marked as a draft', () {
      final Map<String, dynamic> doc =
          jsonDecode(explainSource) as Map<String, dynamic>;
      expect(doc['status'], 'draft, pending scholar review');
    });

    test('covers all 108 verses with both languages and word by word', () {
      expect(lib.verses.keys.toSet(), byId.keys.toSet());
      for (final Verse v in verses) {
        final VerseNotes n = lib.of(v.id)!;
        expect(n.simpleEn.trim(), isNotEmpty, reason: v.id);
        expect(_devanagari.hasMatch(n.simpleEn), isFalse, reason: v.id);
        expect(_devanagari.hasMatch(n.simpleHi), isTrue, reason: v.id);
        expect(n.words.length, greaterThanOrEqualTo(5), reason: v.id);
        for (final WordGloss w in n.words) {
          expect(
            _devaWord.hasMatch(w.deva),
            isTrue,
            reason: '${v.id} ${w.deva}',
          );
          expect(w.iast.trim(), isNotEmpty, reason: v.id);
          expect(w.meaning.trim(), isNotEmpty, reason: v.id);
        }
      }
    });

    test('related verses exist, are not the verse, and share a situation', () {
      for (final Verse v in verses) {
        final List<String> rel = lib.of(v.id)!.related;
        expect(rel.length, inInclusiveRange(2, 3), reason: v.id);
        expect(rel.toSet(), hasLength(rel.length), reason: v.id);
        for (final String id in rel) {
          expect(id, isNot(v.id));
          final Verse u = byId[id]!;
          expect(u.tags.toSet().intersection(v.tags.toSet()), isNotEmpty);
        }
      }
    });

    test('every chapter has a context line; other speakers say who', () {
      for (int ch = 1; ch <= 18; ch++) {
        for (final Language l in Language.values) {
          expect(lib.chapterContext(ch, l), isNotEmpty, reason: '$ch');
        }
      }
      for (final Verse v in verses) {
        final bool krishna = v.speaker == 'Krishna';
        final VerseNotes n = lib.of(v.id)!;
        if (!krishna) {
          expect(n.momentEn, isNotNull, reason: v.id);
          expect(n.momentHi, isNotNull, reason: v.id);
        }
      }
    });
  });

  group('OfflineExplainer', () {
    final OfflineExplainer offline = OfflineExplainer(verses);
    final Set<String> ids = byId.keys.toSet();

    test(
      'no note: speaker, listener and tags, pointing at the verse',
      () async {
        final DayReflection r = await offline.explainForMyDay('2.47');
        expect(r.text, startsWith('Krishna told Arjuna this for moments of'));
        expect(r.text, contains('work pressure'));
        expect(r.refs, <String>['2.47']);
        expect(r.fromModel, isFalse);
      },
    );

    test('a note that meets the verse names the situation', () async {
      final DayReflection r = await offline.explainForMyDay(
        '2.47',
        userNote: 'my exam is tomorrow',
      );
      expect(r.text, contains('It meets the exam stress you wrote about.'));
    });

    test('a note about something else points to a closer verse', () async {
      final DayReflection r = await offline.explainForMyDay(
        '2.47',
        userNote: 'I am so angry at my brother',
      );
      expect(r.refs, hasLength(2));
      expect(byId[r.refs[1]]!.adviceSafe, isTrue);
      expect(byId[r.refs[1]]!.tags, contains('anger'));
    });

    test('a story passage is never served as advice', () async {
      expect(verse('2.20').adviceSafe, isFalse);
      final DayReflection r = await offline.explainForMyDay(
        '2.20',
        userNote: 'work',
      );
      expect(r.text, OfflineExplainer.storyOnly);
      expect(byId[r.refs.single]!.adviceSafe, isTrue);
    });

    test('every offline reply passes the scripture guard', () async {
      for (final Verse v in verses) {
        for (final String? note in <String?>[null, 'exam', 'lonely', 'xyz']) {
          final DayReflection r = await offline.explainForMyDay(
            v.id,
            userNote: note,
          );
          expect(acceptReflection(r, ids), isTrue, reason: '${v.id} $note');
        }
      }
    });
  });

  group('the AI seam', () {
    final Set<String> ids = byId.keys.toSet();

    test('guard rejects scripture, quotes and unknown references', () {
      bool ok(String t, [List<String> refs = const <String>['2.47']]) =>
          acceptReflection(DayReflection(text: t, refs: refs), ids);
      expect(ok('Do one task well today and let the result go.'), isTrue);
      expect(ok('Gita 2.47 fits a day like this.'), isTrue);
      expect(ok('कर्मण्येवाधिकारस्ते'), isFalse);
      expect(ok('karmaṇyevādhikāraste mā phaleṣu'), isFalse);
      expect(ok('Krishna said "you have a right to work".'), isFalse);
      expect(ok('Gita 3.19 fits too.'), isFalse);
      expect(ok('Fine.', <String>['19.99']), isFalse);
      expect(ok(''), isFalse);
      expect(ok('a' * 281), isFalse);
    });

    test('a model reply that breaks the rule falls back to offline', () async {
      final _FakeModel model = _FakeModel(
        const DayReflection(text: 'मा फलेषु कदाचन', refs: <String>['2.47']),
      );
      final GuardedExplainer g = GuardedExplainer(
        model: model,
        offline: OfflineExplainer(verses),
      );
      final DayReflection r = await g.explainForMyDay('2.47');
      expect(model.calls, 1);
      expect(r.fromModel, isFalse);
      expect(r.text, startsWith('Krishna told Arjuna'));
    });

    test('a clean model reply is used and labelled', () async {
      final GuardedExplainer g = GuardedExplainer(
        model: _FakeModel(
          const DayReflection(
            text: 'Do the next small task well. Let tonight hold the result.',
            refs: <String>['2.47'],
          ),
        ),
        offline: OfflineExplainer(verses),
      );
      final DayReflection r = await g.explainForMyDay('2.47');
      expect(r.fromModel, isTrue);
    });

    test('story passages never reach the model', () async {
      final _FakeModel model = _FakeModel(
        const DayReflection(text: 'Anything.'),
      );
      await GuardedExplainer(
        model: model,
        offline: OfflineExplainer(verses),
      ).explainForMyDay('11.32');
      expect(model.calls, 0);
    });
  });

  group('explain sheet', () {
    Future<void> pumpSheet(WidgetTester tester, Verse v) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'onboardingComplete': true,
      });
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPrefsProvider.overrideWithValue(prefs),
            versesProvider.overrideWithValue(verses),
            explainLibraryProvider.overrideWith((Ref ref) async => lib),
          ],
          child: MaterialApp(
            theme: DharmaTheme.night,
            home: Scaffold(
              body: Builder(
                builder: (BuildContext context) => Center(
                  child: TextButton(
                    onPressed: () => showExplainSheet(context, v),
                    child: const Text('open'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    Future<void> tab(WidgetTester tester, ExplainSection s) async {
      final Finder f = find.bySemanticsLabel(s.label).last;
      await tester.ensureVisible(f);
      await tester.pumpAndSettle();
      await tester.tap(f);
      await tester.pumpAndSettle();
    }

    testWidgets('shows the five sections from local data', (
      WidgetTester tester,
    ) async {
      final Verse v = verse('2.47');
      final VerseNotes n = lib.of('2.47')!;
      await pumpSheet(tester, v);

      // The verse itself, from local data, and the simple meaning first.
      expect(find.text(v.padas.first), findsOneWidget);
      expect(find.text('IN SIMPLE WORDS'), findsOneWidget);
      expect(find.text(n.simpleEn), findsOneWidget);
      expect(find.text(ExplainSheet.draftNote), findsOneWidget);
      expect(find.text('Hold to listen'), findsOneWidget);
      expect(find.bySemanticsLabel('Share this verse'), findsOneWidget);

      await tab(tester, ExplainSection.words);
      expect(find.text(n.words.first.deva), findsOneWidget);
      expect(find.text(n.words.first.meaning), findsOneWidget);
      expect(
        find.bySemanticsLabel(
          '${n.words.first.iast}: ${n.words.first.meaning}',
        ),
        findsOneWidget,
      );

      await tab(tester, ExplainSection.moment);
      expect(find.text('Krishna speaks to Arjuna.'), findsOneWidget);
      expect(
        find.text(lib.chapterContext(2, Language.english)),
        findsOneWidget,
      );

      await tab(tester, ExplainSection.myDay);
      expect(find.text(ExplainSheet.offlineNote), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'my exam is tomorrow');
      await tester.tap(find.text(ExplainSheet.askLabel));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('It meets the exam stress you wrote about.'),
        findsOneWidget,
      );
    });

    testWidgets('a related verse opens in place, and back returns', (
      WidgetTester tester,
    ) async {
      await pumpSheet(tester, verse('2.47'));
      final String first = lib.of('2.47')!.related.first;
      await tab(tester, ExplainSection.related);
      await tester.tap(find.bySemanticsLabel('Open Gita $first'));
      await tester.pumpAndSettle();
      expect(find.text('GITA $first'), findsOneWidget);
      expect(find.text(lib.of(first)!.simpleEn), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Back to Gita 2.47'));
      await tester.pumpAndSettle();
      expect(find.text('GITA 2.47'), findsOneWidget);
    });

    testWidgets('another speaker gets its own moment line', (
      WidgetTester tester,
    ) async {
      await pumpSheet(tester, verse('18.78'));
      await tab(tester, ExplainSection.moment);
      expect(find.text(lib.of('18.78')!.momentEn!), findsOneWidget);
    });

    testWidgets('crisis words close the sheet with no reply', (
      WidgetTester tester,
    ) async {
      await pumpSheet(tester, verse('2.47'));
      await tab(tester, ExplainSection.myDay);
      await tester.enterText(find.byType(TextField), 'I want to die');
      await tester.tap(find.text(ExplainSheet.askLabel));
      await tester.pumpAndSettle();
      expect(find.byType(ExplainSheet), findsNothing);
      expect(find.textContaining('Krishna told'), findsNothing);
    });
  });

  testWidgets('the verse scroll has a quiet explain lamp', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'onboardingComplete': true,
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
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
          versesProvider.overrideWithValue(verses),
          explainLibraryProvider.overrideWith((Ref ref) async => lib),
          reminderBackendProvider.overrideWithValue(
            const NoopReminderBackend(),
          ),
          clockProvider.overrideWithValue(() => DateTime(2026, 11, 12, 12)),
        ],
        child: const DharmaScrollApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(TodayScreen.beginLabel));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Explain this verse'));
    await tester.pumpAndSettle();
    expect(find.byType(ExplainSheet), findsOneWidget);
    expect(find.text('IN SIMPLE WORDS'), findsOneWidget);
  });
}
