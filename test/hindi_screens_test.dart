import 'dart:convert';
import 'dart:io';

import 'package:dharmascroll/app.dart';
import 'package:dharmascroll/app_providers.dart';
import 'package:dharmascroll/core/auth/auth_service.dart';
import 'package:dharmascroll/core/mann/verse_matcher.dart' show tagScores;
import 'package:dharmascroll/core/rituals/panchang.dart';
import 'package:dharmascroll/core/rituals/providers.dart';
import 'package:dharmascroll/core/rituals/reminder_backend.dart';
import 'package:dharmascroll/core/rituals/rituals.dart';
import 'package:dharmascroll/core/router.dart';
import 'package:dharmascroll/core/state/progress.dart';
import 'package:dharmascroll/data/verse_repository.dart';
import 'package:dharmascroll/domain/models/verse.dart';
import 'package:dharmascroll/features/ekant/ekant_engine.dart';
import 'package:dharmascroll/features/explain/explain_sheet.dart';
import 'package:dharmascroll/features/explain/verse_notes.dart';
import 'package:dharmascroll/features/ekant/voice_session.dart';
import 'package:dharmascroll/presentation/practice/tradition_explainer.dart';
import 'package:dharmascroll/presentation/share/share_card.dart';
import 'package:dharmascroll/presentation/share/share_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'en.dart';

/// Walks the screens that were localized after the language step and fails
/// when English is still on them, in Hindi; then does the same in Extra-large
/// text, where nothing may overflow.

final DateTime _noon = DateTime(2026, 11, 12, 12);
String _day(int back) => dayKey(_noon.subtract(Duration(days: back)));

final List<Verse> _verses = parseVerses(
  File('assets/data/gita_v1.json').readAsStringSync(),
);
final ExplainLibrary _lib = parseExplain(
  File('assets/data/gita_explain_v1.json').readAsStringSync(),
);

/// English that is allowed on a Hindi screen: names, the English meaning the
/// verse page offers on purpose, the transliteration, the word glosses (the
/// data has no Hindi for them yet) and the ASCII brand and place names.
final List<String> _allowedEnglish = () {
  final List<String> out = <String>[
    'DharmaScroll',
    'English',
    'Hinglish',
    'Google',
    'IAST',
    'DHARMASCROLL',
    'Language / भाषा',
  ];
  for (final Verse v in _verses) {
    out
      ..add(v.meaningEn)
      ..add(v.iast)
      ..addAll(v.iast.split('\n'));
  }
  for (final VerseNotes n in _lib.verses.values) {
    out
      ..add(n.simpleEn)
      ..addAll(<String>[
        for (final WordGloss g in n.words) ...<String>[g.iast, g.meaning],
      ]);
    if (n.momentEn != null) out.add(n.momentEn!);
  }
  for (final ({String en, String hi}) c in _lib.chapters.values) {
    out.add(c.en);
  }
  out.sort((String a, String b) => b.length.compareTo(a.length));
  return out;
}();

/// Every English ARB line that differs in Hindi, as a whole-text pattern.
final List<(String, RegExp)> _knownEnglish = () {
  final Map<String, dynamic> enArb = jsonDecode(
    File('lib/l10n/app_en.arb').readAsStringSync(),
  ) as Map<String, dynamic>;
  final Map<String, dynamic> hiArb = jsonDecode(
    File('lib/l10n/app_hi.arb').readAsStringSync(),
  ) as Map<String, dynamic>;
  final List<(String, RegExp)> out = <(String, RegExp)>[];
  for (final MapEntry<String, dynamic> e in enArb.entries) {
    if (e.key.startsWith('@') || e.value is! String) continue;
    final String en = e.value as String;
    if (en == hiArb[e.key] || en.length < 5) continue;
    // A line that is only a placeholder says nothing about its words.
    if (en.replaceAll(RegExp(r'\{\w+\}|\W'), '').length < 5) continue;
    if (en.contains(', select,') || en.contains(', plural,')) continue;
    final String source = RegExp.escape(en)
        .replaceAll(RegExp(r'\\\{\w+\\\}'), '.+');
    out.add((e.key, RegExp('^$source\$')));
  }
  return out;
}();

Future<SharedPreferences> _prefs([
  Map<String, Object> extra = const <String, Object>{},
  String lang = 'hindi',
  String size = 'normal',
]) async {
  SharedPreferences.setMockInitialValues(<String, Object>{
    'onboardingComplete': true,
    'lang': lang,
    'textSize': size,
    ...extra,
  });
  return SharedPreferences.getInstance();
}

Future<void> _pump(
  WidgetTester tester,
  SharedPreferences prefs, {
  Size size = const Size(390, 844),
}) async {
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
        versesProvider.overrideWithValue(_verses),
        explainLibraryProvider.overrideWith((Ref ref) async => _lib),
        reminderBackendProvider.overrideWithValue(const NoopReminderBackend()),
        clockProvider.overrideWithValue(() => _noon),
      ],
      child: const DharmaScrollApp(),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _go(WidgetTester tester, String route, {Object? extra}) async {
  final ProviderContainer container = ProviderScope.containerOf(
    tester.element(find.byType(DharmaScrollApp)),
  );
  container.read(routerProvider).go(route, extra: extra);
  await tester.pumpAndSettle();
}

/// Leaves the screen and lets the sound fade, so no timer is left running.
Future<void> _leave(WidgetTester tester) async {
  await _go(tester, Routes.today);
  await tester.pump(const Duration(seconds: 3));
}

Future<void> _tapText(WidgetTester tester, String text) async {
  final Finder f = find.text(text).first;
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

Future<void> _tapLabel(WidgetTester tester, String label) async {
  final Finder f = find.bySemanticsLabel(label);
  await tester.ensureVisible(f.first);
  await tester.tap(f.first);
  await tester.pumpAndSettle();
}

BuildContext _context(WidgetTester tester) =>
    tester.element(find.byType(Scaffold).first);

/// Everything the person can read or hear on screen right now.
List<String> _shown(WidgetTester tester) {
  final List<String> out = <String>[];
  for (final RichText r in tester.widgetList<RichText>(find.byType(RichText))) {
    out.add(r.text.toPlainText());
  }
  void walk(SemanticsNode n) {
    for (final String s in <String>[n.label, n.hint, n.value]) {
      if (s.trim().isNotEmpty) out.add(s);
    }
    n.visitChildren((SemanticsNode c) {
      walk(c);
      return true;
    });
  }

  final SemanticsOwner? owner = tester.binding.rootPipelineOwner.semanticsOwner;
  if (owner?.rootSemanticsNode != null) walk(owner!.rootSemanticsNode!);
  return out;
}

/// Fails with the screen name and the lines when English is left.
void _expectHindi(WidgetTester tester, String screen) {
  final List<String> left = <String>[];
  for (final String raw in _shown(tester)) {
    final String t = raw.trim();
    if (t.isEmpty) continue;
    for (final (String key, RegExp pattern) in _knownEnglish) {
      if (pattern.hasMatch(t.replaceAll('\n', ' '))) {
        left.add('$t   (ARB $key)');
      }
    }
    String rest = t;
    for (final String ok in _allowedEnglish) {
      rest = rest.replaceAll(ok, ' ');
    }
    if (RegExp('[A-Za-z]{3,}').hasMatch(rest)) left.add(t);
  }
  expect(left.toSet(), isEmpty, reason: 'English left on $screen');
}

void main() {
  group('Hindi screens have no English left', () {
    testWidgets('Today, Yatra, You, Hear, Wallet, Kept', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await _pump(
        tester,
        await _prefs(<String, Object>{
          'p.points': 40,
          'p.ledger': <String>['${_day(1)}|hear|10', '${_day(1)}|walk|30'],
          'p.kept': <String>['2.47', '6.5'],
          'p.streak': 3,
          'p.lit': <String>[_day(2), _day(1), _day(0)],
        }),
      );
      _expectHindi(tester, 'Today');
      await _go(tester, Routes.yatra);
      _expectHindi(tester, 'Yatra');
      await _go(tester, Routes.you);
      _expectHindi(tester, 'You');
      await _go(tester, Routes.wallet);
      _expectHindi(tester, 'Wallet');
      await _go(tester, Routes.kept);
      _expectHindi(tester, 'Kept');
      await _go(tester, Routes.verse('2.47'));
      _expectHindi(tester, 'Verse');

      await _go(tester, Routes.hear);
      _expectHindi(tester, 'Hear');
      for (int i = 0; i < 6; i++) {
        await tester.fling(find.byType(PageView), const Offset(0, -600), 3000);
        await tester.pumpAndSettle();
      }
      expect(find.text(hi.hearEndTitle), findsOneWidget);
      _expectHindi(tester, 'Hear end');
      handle.dispose();
    });

    testWidgets('explain sheet, all five tabs, and the share sheet', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await _pump(tester, await _prefs());
      await _go(tester, Routes.hear);
      await _tapLabel(tester, hi.explainVerse);
      for (final ExplainSection s in ExplainSection.values) {
        await _tapLabel(tester, hi.sectionLabel(s));
        _expectHindi(tester, 'Explain ${s.name}');
      }
      // The My day tab answers in Hindi.
      await tester.enterText(find.byType(TextField), 'परीक्षा की चिंता');
      await tester.tap(find.text(hi.exAskLabel));
      await tester.pumpAndSettle();
      _expectHindi(tester, 'Explain reply');
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      await _tapLabel(tester, hi.shareVerse);
      _expectHindi(tester, 'Share sheet');
      handle.dispose();
    });

    testWidgets('Walk: chant, meets, complete, milestone and checkpoint', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await _pump(
        tester,
        await _prefs(<String, Object>{
          'p.walks': 6,
          'p.day': _day(0),
          'p.heard': 5,
          'p.steps': <String>['hear'],
          'p.lit': <String>[_day(0)],
          'p.streak': 6,
          'p.points': 240,
        }),
      );
      await _go(tester, Routes.walk);
      // Every seventh stone asks to finish the verse first.
      expect(find.text(hi.finishVerseTitle), findsOneWidget);
      _expectHindi(tester, 'Finish the verse');
      final Finder hidden = find.bySemanticsLabel(RegExp('^छिपी पंक्ति'));
      for (int i = 0; i < 14 && hidden.evaluate().isNotEmpty; i++) {
        await tester.tap(hidden.first);
        await tester.pump();
      }
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      _expectHindi(tester, 'Meets you');
      expect(find.text(hi.thisOne), findsOneWidget);
      await tester.tap(find.text(hi.thisOne));
      await tester.pumpAndSettle();
      await _go(tester, Routes.complete, extra: 30);
      _expectHindi(tester, 'Complete');
      await _go(tester, Routes.milestone, extra: 7);
      _expectHindi(tester, 'Milestone');
      await tester.tap(find.text(hi.shareThisLight));
      await tester.pumpAndSettle();
      _expectHindi(tester, 'Milestone share');
      handle.dispose();
    });

    testWidgets('Walk: the chant page', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await _pump(tester, await _prefs());
      await _go(tester, Routes.walk);
      _expectHindi(tester, 'Chant');
      handle.dispose();
    });

    testWidgets('Mann Darpan, Sankalp and the look back', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await _pump(
        tester,
        await _prefs(<String, Object>{
          'p.day': _day(0),
          'p.heard': 5,
          'p.steps': <String>['hear', 'walk'],
          'sk.day': _day(1),
          'sk.text': 'आज एक काम पूरे मन से कीजिए।',
          'sk.verse': '2.47',
        }),
      );
      _expectHindi(tester, 'Today with a Sankalp waiting');
      await _go(tester, Routes.speak);
      _expectHindi(tester, 'Mann ask');
      await tester.tap(find.text(hi.typeInstead));
      await tester.pumpAndSettle();
      _expectHindi(tester, 'Mann type');
      await tester.enterText(
        find.byType(TextField),
        'मुझे कल परीक्षा की बहुत चिंता है',
      );
      await tester.pump();
      await tester.tap(find.text(hi.letVerseAnswer));
      await tester.pumpAndSettle();
      _expectHindi(tester, 'Mann answer');
      await tester.tap(find.text(hi.sealAsSankalp));
      await tester.pumpAndSettle();
      _expectHindi(tester, 'Sankalp sheet');
      await _leave(tester);
      handle.dispose();
    });

    testWidgets('Crisis, Practice, tradition explainer, Ekant', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await _pump(tester, await _prefs());
      await _go(tester, Routes.crisis);
      _expectHindi(tester, 'Crisis');
      await tester.tap(find.text(hi.crisisBreathe));
      await tester.pumpAndSettle();
      _expectHindi(tester, 'Crisis breathing');

      await _go(tester, Routes.practice);
      _expectHindi(tester, 'Practice');
      await tester.tap(find.text(hi.allReminders));
      await tester.pumpAndSettle();
      _expectHindi(tester, 'All reminders');
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      await _go(tester, Routes.buildPractice);
      _expectHindi(tester, 'Build practice');

      showTraditionExplainer(_context(tester));
      await tester.pumpAndSettle();
      _expectHindi(tester, 'Tradition explainer');
      await tester.tap(find.text(hi.gotIt));
      await tester.pumpAndSettle();

      await _go(tester, Routes.ekant);
      _expectHindi(tester, 'Ekant door');
      await tester.tap(find.text(hi.ekWrite));
      await tester.pumpAndSettle();
      _expectHindi(tester, 'Ekant chat');
      await _leave(tester);
      handle.dispose();
    });

    testWidgets('Ekant: a Hindi opening line gets a Hindi reply', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await _pump(tester, await _prefs());
      await _go(tester, Routes.ekant);
      await tester.tap(find.text(hi.ekWrite));
      await tester.pumpAndSettle();
      await tester.tap(find.text(hi.ekOpen1));
      await tester.pumpAndSettle();
      await tester.tap(find.text(hi.ekSend));
      await tester.pump(const Duration(seconds: 8));
      await tester.pumpAndSettle();
      _expectHindi(tester, 'Ekant reply');
      await _leave(tester);
      handle.dispose();
    });
  });

  group('Hindi words without a screen', () {
    test('every Hindi line is Hindi: no English words in app_hi.arb', () {
      final Map<String, dynamic> hiArb = jsonDecode(
        File('lib/l10n/app_hi.arb').readAsStringSync(),
      ) as Map<String, dynamic>;
      final Map<String, dynamic> enArb = jsonDecode(
        File('lib/l10n/app_en.arb').readAsStringSync(),
      ) as Map<String, dynamic>;
      // Brand and product names stay as they are written everywhere.
      final RegExp names = RegExp('DharmaScroll|Google|Tele-MANAS|AM|PM|AI');
      final List<String> bad = <String>[];
      for (final MapEntry<String, dynamic> e in hiArb.entries) {
        if (e.key.startsWith('@') || e.value is! String) continue;
        final String text = (e.value as String)
            .replaceAll(RegExp(r'\{[^}]*\}'), ' ')
            .replaceAll(RegExp(r'\b(select|plural|other|one|other)\b'), ' ')
            .replaceAll(
              RegExp('nightEarly|morning|noon|evening|night|yes'),
              ' ',
            )
            .replaceAll(names, ' ');
        if (RegExp('[A-Za-z]{3,}').hasMatch(text)) bad.add('${e.key}: $text');
      }
      expect(bad, isEmpty);
      expect(
        hiArb.keys.toSet().difference(enArb.keys.toSet()),
        isEmpty,
        reason: 'a Hindi line with no English twin',
      );
      expect(
        enArb.keys.toSet().difference(hiArb.keys.toSet()),
        isEmpty,
        reason: 'an English line with no Hindi twin',
      );
    });

    test('every city and country has a Hindi name', () {
      final List<dynamic> cities = jsonDecode(
        File('assets/panchang/cities.json').readAsStringSync(),
      ) as List<dynamic>;
      final Map<String, dynamic> hiNames = jsonDecode(
        File('assets/panchang/cities_hi.json').readAsStringSync(),
      ) as Map<String, dynamic>;
      final Map<String, dynamic> byCity =
          hiNames['cities'] as Map<String, dynamic>;
      final Map<String, dynamic> byCountry =
          hiNames['countries'] as Map<String, dynamic>;
      for (final dynamic c in cities) {
        final Map<String, dynamic> city = c as Map<String, dynamic>;
        expect(byCity[city['id']], isNotNull, reason: '${city['id']}');
        expect(
          RegExp('[A-Za-z]').hasMatch(byCity[city['id']] as String),
          isFalse,
        );
        if (city['country'] != 'IN') {
          expect(
            byCountry[city['country']],
            isNotNull,
            reason: '${city['country']}',
          );
        }
      }
      final PanchangCity delhi = PanchangCity.fromJson(
        cities.first as Map<String, dynamic>,
        nameHi: byCity['new-delhi-in'] as String,
      );
      expect(delhi.labelIn(hindi: true), 'नई दिल्ली');
      expect(delhi.labelIn(hindi: false), 'New Delhi');
    });

    test('sign-in errors are in Hindi', () {
      for (final AuthProblem p in AuthProblem.values) {
        expect(hi.authProblem(p), isNot(en.authProblem(p)));
      }
    });

    test('reminders and calendar lines are in Hindi, every one', () {
      Map<String, Object?> read(String f) => (jsonDecode(
        File('assets/panchang/$f.json').readAsStringSync(),
      ) as Map<Object?, Object?>).cast();
      final CityCalendar cal = CityCalendar.fromJson(
        read('new-delhi-in'),
        (read('festivals').cast<String, String>()),
      );
      final DateTime today = DateTime(2026, 11, 12);
      final List<PlannedReminder> plan = planReminders(
        l: hi,
        cal: cal,
        rituals: Ritual.values.toSet(),
        deity: Deity.shiva,
        tradition: Tradition.unsure,
        gitaMinutes: 7 * 60,
        today: today,
        nowWall: today,
        days: 120,
        cap: 400,
      );
      expect(plan, isNotEmpty);
      for (final PlannedReminder r in plan) {
        expect(
          RegExp('[A-Za-z]{3,}').hasMatch(r.body),
          isFalse,
          reason: r.body,
        );
      }
      // Each kind of line shows up at least once in four months.
      final String all = plan.map((PlannedReminder r) => r.body).join(' ');
      for (final String part in <String>[
        'एकादशी',
        'पारण',
        'पूर्णिमा',
        'सूर्योदय',
      ]) {
        expect(all, contains(part));
      }
      for (int day = 0; day < 120; day++) {
        for (final String label in todayLabels(
          hi,
          cal,
          cal.dayIndex(today)! + day,
          rituals: Ritual.values.toSet(),
          tradition: Tradition.unsure,
        )) {
          expect(
            RegExp('[A-Za-z]{3,}').hasMatch(label),
            isFalse,
            reason: label,
          );
        }
      }
      // Times read in Hindi: part of the day, then the clock.
      expect(fmtClock(hi, 17 * 60 + 21), 'शाम 5:21');
      expect(fmtRange(hi, 7 * 60 + 9, 9 * 60 + 13), 'सुबह 7:09 से सुबह 9:13');
    });

    test('Hindi opening lines and talk script are heard as feelings', () {
      final VerseMatcher matcher = VerseMatcher(_verses);
      for (final String line in <String>[
        ...hi.ekOpenings,
        ...FakeVoiceSession.scriptHi,
      ]) {
        expect(detectLang(line), EkantLang.hi, reason: line);
        expect(tagText(line), isNotEmpty, reason: line);
        expect(matcher.pick(tagText(line)).id, isNotEmpty);
      }
    });

    test('Mann Darpan hears Hindi', () {
      expect(tagScores('मुझे कल परीक्षा की बहुत चिंता है'), isNotEmpty);
      expect(
        tagScores('आज बहुत अकेलापन लग रहा है').keys,
        contains('loneliness'),
      );
      expect(tagScores('बहुत गुस्सा आ रहा है').keys, contains('anger'));
    });
  });

  group('Extra-large text on the newly localized screens', () {
    // 360 x 640 is the small end of phones still in use.
    for (final String lang in <String>['english', 'hindi']) {
      testWidgets('they all fit ($lang)', (WidgetTester tester) async {
        final AppLocalizations l = lang == 'hindi' ? hi : en;
        await _pump(
          tester,
          await _prefs(
            <String, Object>{
              'p.points': 240,
              'p.ledger': <String>['${_day(1)}|hear|10', '${_day(1)}|walk|30'],
              'p.kept': <String>['2.47', '6.5', '11.32'],
              'p.streak': 6,
              'p.lit': <String>[_day(2), _day(1), _day(0)],
              'p.walks': 6,
              'p.day': _day(0),
              'p.heard': 5,
              'p.steps': <String>['hear'],
              'sk.day': _day(1),
              'sk.text': 'एक काम पूरे मन से कीजिए।',
              'sk.verse': '2.47',
            },
            lang,
            'extraLarge',
          ),
          size: const Size(360, 640),
        );
        // A Flutter overflow is an exception: any one fails the test.
        for (final String route in <String>[
          Routes.yatra,
          Routes.you,
          Routes.wallet,
          Routes.kept,
          Routes.verse('2.47'),
          Routes.verse('11.32'),
          Routes.hear,
          Routes.walk, // the checkpoint, as six stones are walked
          Routes.complete,
          Routes.milestone,
          Routes.speak,
          Routes.crisis,
          Routes.practice,
          Routes.buildPractice,
          Routes.ekant,
        ]) {
          await _go(tester, route, extra: route == Routes.milestone ? 7 : 5);
          expect(tester.takeException(), isNull, reason: '$lang $route');
        }
        // The Ekant door, then writing.
        await _tapText(tester, l.ekWrite);
        // Mann: type, answer, seal.
        await _go(tester, Routes.speak);
        await _tapText(tester, l.typeInstead);
        // Under big text the box sits below the fold of a short phone.
        await tester.ensureVisible(find.byType(TextField, skipOffstage: false));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), 'परीक्षा');
        await tester.pump();
        await _tapText(tester, l.letVerseAnswer);
        expect(tester.takeException(), isNull, reason: '$lang mann answer');
        await _tapText(tester, l.sealAsSankalp);
        expect(tester.takeException(), isNull, reason: '$lang sankalp sheet');
        await _go(tester, Routes.today);
        expect(tester.takeException(), isNull, reason: '$lang today');
        // Sheets.
        showTraditionExplainer(_context(tester));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$lang explainer');
        await _tapText(tester, l.gotIt);
        showExplainSheet(_context(tester), _verses.first);
        await tester.pumpAndSettle();
        for (final ExplainSection s in ExplainSection.values) {
          await _tapText(tester, l.sectionLabel(s));
          expect(tester.takeException(), isNull, reason: '$lang ${s.name}');
        }
        await tester.tapAt(const Offset(10, 10));
        await tester.pumpAndSettle();
        showShareSheet(
          _context(tester),
          ShareContent(streak: 7, verse: _verses.first, meaning: 'x'),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$lang share');
      });
    }
  });
}
