import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:dharmascroll/app.dart';
import 'package:dharmascroll/app_providers.dart';
import 'package:dharmascroll/core/rituals/providers.dart';
import 'package:dharmascroll/core/rituals/reminder_backend.dart';
import 'package:dharmascroll/data/verse_repository.dart';
import 'package:dharmascroll/core/state/settings.dart';
import 'package:dharmascroll/design/tokens.dart';
import 'package:dharmascroll/design/widgets.dart';
import 'package:dharmascroll/domain/models/verse.dart';
import 'package:dharmascroll/presentation/language/language_picker.dart';
import 'package:dharmascroll/presentation/you/you_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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
        reminderBackendProvider.overrideWithValue(const NoopReminderBackend()),
        clockProvider.overrideWithValue(() => _noon),
      ],
      child: const DharmaScrollApp(),
    ),
  );
  await tester.pumpAndSettle();
}

final List<Verse> _verses = parseVerses(
  File('assets/data/gita_v1.json').readAsStringSync(),
);

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

/// The pixel scale the words are drawn at, read where the screens are.
double _scale(WidgetTester tester) =>
    MediaQuery.textScalerOf(tester.element(find.byType(Scaffold).first))
        .scale(10) /
    10;

void main() {
  group('language step', () {
    testWidgets('comes first, in each language\'s own script', (
      WidgetTester tester,
    ) async {
      await _pump(tester, await _prefs(onboarded: false));
      expect(find.text('English'), findsOneWidget);
      expect(find.text('हिन्दी'), findsOneWidget);
      for (final String name in <String>[
        'বাংলা',
        'मराठी',
        'తెలుగు',
        'தமிழ்',
        'ગુજરાતી',
        'ಕನ್ನಡ',
      ]) {
        expect(find.text(name), findsOneWidget);
      }
      // Six not ready, said plainly.
      expect(find.text(en.comingSoon), findsNWidgets(6));
      // Nothing before it, so no Back; but it can go on.
      expect(find.text(en.back), findsNothing);
      expect(find.text(en.welcomeButton), findsNothing);
      expect(find.text(en.continueLabel), findsOneWidget);
    });

    testWidgets('a language that is not ready cannot be picked', (
      WidgetTester tester,
    ) async {
      final SharedPreferences prefs = await _prefs(onboarded: false);
      await _pump(tester, prefs);
      await tester.ensureVisible(find.text('தமிழ்'));
      await tester.tap(find.text('தமிழ்'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(prefs.getString('lang'), isNull);
      expect(find.text(en.continueLabel), findsOneWidget);
    });

    testWidgets('Hindi changes the words at once and is kept', (
      WidgetTester tester,
    ) async {
      final SharedPreferences prefs = await _prefs(onboarded: false);
      await _pump(tester, prefs);
      await tester.tap(find.text('हिन्दी'));
      await tester.pumpAndSettle();
      expect(prefs.getString('lang'), 'hindi');
      expect(find.text(hi.continueLabel), findsOneWidget);
      expect(find.text(en.continueLabel), findsNothing);
      await _tap(tester, find.text(hi.continueLabel));
      // Text size page: in Hindi, with a Back and a Skip.
      expect(find.text(hi.textSizeTitle), findsOneWidget);
      expect(find.text(hi.back), findsOneWidget);
      expect(find.text(hi.skip), findsOneWidget);
      await _tap(tester, find.text(hi.continueLabel));
      expect(find.text(hi.welcomeButton), findsOneWidget);
      // Back goes back, then English again.
      await _tap(tester, find.text(hi.back));
      await _tap(tester, find.text(hi.back));
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();
      expect(find.text(en.continueLabel), findsOneWidget);
      expect(prefs.getString('lang'), 'english');
    });

    testWidgets('a phone set to Hindi starts with Hindi chosen', (
      WidgetTester tester,
    ) async {
      tester.platformDispatcher.localeTestValue = const Locale('hi', 'IN');
      addTearDown(tester.platformDispatcher.clearLocaleTestValue);
      await _pump(tester, await _prefs(onboarded: false));
      expect(find.text(hi.continueLabel), findsOneWidget);
    });

    testWidgets('every step has a Back, and all but the first a Skip', (
      WidgetTester tester,
    ) async {
      await _pump(tester, await _prefs(onboarded: false));
      await _tap(tester, find.text(en.continueLabel)); // text size
      await _tap(tester, find.text(en.continueLabel)); // welcome
      expect(find.text(en.back), findsOneWidget);
      await _tap(tester, find.text(en.welcomeButton)); // sign in
      expect(find.text(en.back), findsOneWidget);
      expect(find.text(en.skip), findsOneWidget);
      // Skip on sign in is the same as being a guest.
      await _tap(tester, find.text(en.skip));
      expect(find.text(en.whyCity), findsOneWidget);
      await _tap(tester, find.text(en.skip));
      expect(find.text(en.whyTradition), findsOneWidget);
      await _tap(tester, find.text(en.skip));
      expect(find.text(en.whyHour), findsOneWidget);
      await _tap(tester, find.text(en.skip));
      expect(find.text(en.practiceEyebrow(1, 5)), findsOneWidget);
    });
  });

  group('Hindi', () {
    testWidgets('the app speaks Hindi and verses show the Hindi meaning', (
      WidgetTester tester,
    ) async {
      final SharedPreferences prefs = await _prefs(
        extra: <String, Object>{'lang': 'hindi'},
      );
      await _pump(tester, prefs);
      expect(find.text(hi.todayBegin), findsOneWidget);
      expect(find.text(hi.tabYatra.toUpperCase()), findsOneWidget);
      expect(find.text(hi.railHear.toUpperCase()), findsOneWidget);
      await tester.tap(find.text(hi.todayBegin));
      await tester.pumpAndSettle();
      final Set<String> meaningsHi = _verses
          .map((Verse v) => v.meaningHi)
          .toSet();
      final Set<String> meaningsEn = _verses
          .map((Verse v) => v.meaningEn)
          .toSet();
      expect(
        find.byWidgetPredicate(
          (Widget w) => w is Text && meaningsHi.contains(w.data),
        ),
        findsWidgets,
      );
      expect(
        find.byWidgetPredicate(
          (Widget w) => w is Text && meaningsEn.contains(w.data),
        ),
        findsNothing,
      );
    });

    test('both translation files have the same keys, none left in English', () {
      Map<String, dynamic> read(String f) =>
          jsonDecode(File('lib/l10n/$f').readAsStringSync())
              as Map<String, dynamic>;
      final Map<String, dynamic> a = read('app_en.arb');
      final Map<String, dynamic> b = read('app_hi.arb');
      expect(b.keys.toSet(), a.keys.toSet());
      // Same text in both is fine only for these (a template with no words,
      // and a brand name in Latin letters).
      const Set<String> alike = <String>{'railSemantic', '@@locale'};
      for (final String k in a.keys) {
        if (k.startsWith('@') && k != '@@locale') continue;
        if (alike.contains(k)) continue;
        expect(b[k], isNot(a[k]), reason: 'not translated: $k');
      }
    });
  });

  group('settings', () {
    testWidgets('Language / भाषा row changes the language and stays', (
      WidgetTester tester,
    ) async {
      final SharedPreferences prefs = await _prefs();
      await _pump(tester, prefs);
      await _tap(tester, find.text('YOU'));
      expect(find.text(YouScreen.languageRow), findsOneWidget);
      expect(find.text('English'), findsOneWidget); // its value
      await _tap(tester, find.text(YouScreen.languageRow));
      await _tap(tester, find.text('हिन्दी'));
      expect(prefs.getString('lang'), 'hindi');
      // The row now speaks Hindi under it too.
      expect(find.text(hi.languageSheetWhy), findsOneWidget);
    });

    testWidgets('Text size row sets the size and the words grow', (
      WidgetTester tester,
    ) async {
      final SharedPreferences prefs = await _prefs();
      await _pump(tester, prefs);
      expect(_scale(tester), 1);
      await _tap(tester, find.text('YOU'));
      await _tap(tester, find.text(en.textSizeRow));
      await _tap(tester, find.text(en.textSizeExtraLarge));
      expect(prefs.getString('textSize'), 'extraLarge');
      expect(_scale(tester), TextSize.extraLarge.factor);
      await _tap(tester, find.text(en.textSizeNormal));
      expect(_scale(tester), 1);
    });

    testWidgets('the system size counts too, up to the same cap', (
      WidgetTester tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await _pump(tester, await _prefs());
      expect(_scale(tester), maxTextScale);
    });
  });

  group('extra large text', () {
    // 360 x 640 is the small end of phones still in use.
    for (final String lang in <String>['english', 'hindi']) {
      testWidgets('onboarding fits from first page to last ($lang)', (
        WidgetTester tester,
      ) async {
        final AppLocalizations l = lang == 'hindi' ? hi : en;
        await _pump(
          tester,
          await _prefs(
            onboarded: false,
            extra: <String, Object>{'lang': lang, 'textSize': 'extraLarge'},
          ),
          size: const Size(360, 640),
        );
        // Any overflow throws, and fails the test.
        await _tap(tester, find.text(l.continueLabel)); // language
        await _tap(tester, find.text(l.continueLabel)); // text size
        await _tap(tester, find.text(l.welcomeButton));
        await _tap(tester, find.text(l.signInPhone));
        await _tap(tester, find.text(l.otherWays));
        await _tap(tester, find.text(l.signInGuest));
        await _tap(tester, find.text(l.continueLabel)); // city
        await _tap(tester, find.text(l.continueLabel)); // tradition
        await _tap(tester, find.text(l.later15)); // hour
        await _tap(tester, find.text(l.continueLabel));
        for (int i = 0; i < 4; i++) {
          await _tap(tester, find.text(l.continueLabel));
        }
        await _tap(tester, find.text(l.finishLabel));
        expect(find.text(l.todayBegin), findsOneWidget);
      });
    }

    for (final String lang in <String>['english', 'hindi']) {
      testWidgets('Today, Yatra and You fit ($lang)', (
        WidgetTester tester,
      ) async {
        final AppLocalizations l = lang == 'hindi' ? hi : en;
        await _pump(
          tester,
          await _prefs(
            extra: <String, Object>{'lang': lang, 'textSize': 'extraLarge'},
          ),
          size: const Size(360, 640),
        );
        expect(find.text(l.todayBegin), findsOneWidget);
        expect(_scale(tester), TextSize.extraLarge.factor);
        await _tap(tester, find.text(l.tabYatra.toUpperCase()));
        await _tap(tester, find.text(l.tabYou.toUpperCase()));
        await _tap(tester, find.text(YouScreen.languageRow));
        expect(find.text('हिन्दी'), findsWidgets);
      });
    }

    testWidgets('a settings sheet fits too', (WidgetTester tester) async {
      await _pump(
        tester,
        await _prefs(extra: <String, Object>{'textSize': 'extraLarge'}),
        size: const Size(360, 640),
      );
      await _tap(tester, find.text(en.tabYou.toUpperCase()));
      for (final String row in <String>[
        en.soundRow,
        en.lookRow,
        en.placeRow,
        en.textSizeRow,
      ]) {
        await _tap(tester, find.text(row));
        await tester.tapAt(const Offset(10, 10)); // the scrim
        await tester.pumpAndSettle();
        // Back to the top of the list for the next row.
        await tester.fling(
          find.byType(ListView).first,
          const Offset(0, 2000),
          4000,
        );
        await tester.pumpAndSettle();
      }
    });
  });

  group('tap targets and contrast', () {
    testWidgets('buttons, Back and Skip are at least 48 dp; primary 56', (
      WidgetTester tester,
    ) async {
      await _pump(tester, await _prefs(onboarded: false));
      expect(
        tester.getSize(find.byType(PrimaryButton)).height,
        greaterThanOrEqualTo(56),
      );
      await _tap(tester, find.text(en.continueLabel));
      for (final String label in <String>[en.back, en.skip]) {
        final Size size = tester.getSize(
          find
              .ancestor(
                of: find.text(label),
                matching: find.byType(ConstrainedBox),
              )
              .first,
        );
        expect(size.height, greaterThanOrEqualTo(48), reason: label);
        expect(size.width, greaterThanOrEqualTo(48), reason: label);
      }
    });

    testWidgets('language tiles are large', (WidgetTester tester) async {
      await _pump(tester, await _prefs(onboarded: false));
      final Size size = tester.getSize(
        find
            .ancestor(
              of: find.text('हिन्दी'),
              matching: find.byType(AnimatedContainer),
            )
            .first,
      );
      expect(size.height, greaterThanOrEqualTo(72));
      expect(find.byType(LanguageTiles), findsOneWidget);
    });

    test('text colours reach WCAG AA (4.5) on every surface they sit on', () {
      double lum(Color c) {
        double f(double v) => v <= 0.03928
            ? v / 12.92
            : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
        return 0.2126 * f(c.r) + 0.7152 * f(c.g) + 0.0722 * f(c.b);
      }

      double ratio(Color a, Color b) {
        final double la = lum(a);
        final double lb = lum(b);
        return (la > lb ? la + 0.05 : lb + 0.05) /
            (la > lb ? lb + 0.05 : la + 0.05);
      }

      for (final DharmaColors m in <DharmaColors>[
        DharmaColors.night,
        DharmaColors.dawn,
      ]) {
        for (final Color bg in <Color>[m.bg, m.surface]) {
          for (final (String, Color) t in <(String, Color)>[
            ('ink', m.ink),
            ('mute', m.mute),
            ('faint', m.faint),
            ('accent', m.accent),
            ('verse', m.verse),
          ]) {
            expect(
              ratio(t.$2, bg),
              greaterThanOrEqualTo(4.5),
              reason:
                  '${t.$1} on ${bg.toARGB32().toRadixString(16)} '
                  '(light: ${m.isLight})',
            );
          }
        }
      }
      expect(ratio(Tok.btnInk, Tok.btnB), greaterThanOrEqualTo(4.5));
    });
  });
}
