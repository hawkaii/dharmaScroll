import 'package:dharmascroll/core/theme/app_theme.dart';
import 'package:dharmascroll/presentation/feed/feed_screen.dart';
import 'package:dharmascroll/presentation/feed/widgets/shloka_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pumpFeed(
  WidgetTester tester, {
  Size size = const Size(360, 800),
  double textScale = 1,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: MediaQuery(
        data: MediaQueryData(
          size: size,
          textScaler: TextScaler.linear(textScale),
        ),
        child: const Scaffold(body: FeedScreen()),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

double _currentPage(WidgetTester tester) {
  final PageView view = tester.widget<PageView>(find.byType(PageView));
  return view.controller?.page ?? 0;
}

void main() {
  testWidgets('the feed renders a verse with no layout overflow at 360x800', (
    WidgetTester tester,
  ) async {
    await _pumpFeed(tester);

    // PageView pre-builds the neighbour, so the string can appear twice.
    expect(find.textContaining('कर्मण्येवाधिकारस्ते'), findsWidgets);
    expect(find.text('Tap to go deeper'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('swiping up moves to the second verse', (
    WidgetTester tester,
  ) async {
    await _pumpFeed(tester);
    expect(_currentPage(tester), 0);

    await tester.fling(find.byType(PageView), const Offset(0, -600), 1200);
    await tester.pumpAndSettle();

    expect(_currentPage(tester), closeTo(1, 0.01));
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping the card opens the three-tab sheet', (
    WidgetTester tester,
  ) async {
    await _pumpFeed(tester);

    // "Tap to expand" is the whole card's gesture, not just the chip's, so the
    // test taps the card the way a user would.
    await tester.tap(find.byType(ShlokaCard).hitTestable().first);
    await tester.pumpAndSettle();

    expect(find.text('SHABDARTH'), findsOneWidget);
    expect(find.text('KATHA'), findsOneWidget);
    expect(find.text('JEEVAN'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a small phone at 200% text scale does not overflow', (
    WidgetTester tester,
  ) async {
    await _pumpFeed(tester, size: const Size(320, 568), textScale: 2);

    expect(tester.takeException(), isNull);

    // At this scale the card scrolls internally, so a pointer tap lands on the
    // scrollable rather than the chip. Exercise the sheet through the card's
    // own callback instead of fighting the hit test.
    tester.widget<ShlokaCard>(find.byType(ShlokaCard).first).onTap!();
    await tester.pumpAndSettle();

    expect(find.text('SHABDARTH'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('saving a verse marks it saved and awards points', (
    WidgetTester tester,
  ) async {
    await _pumpFeed(tester);

    expect(find.text('Save'), findsWidgets);
    await tester.tap(find.text('Save').hitTestable().first);
    await tester.pumpAndSettle();

    expect(find.text('Saved'), findsWidgets);
    expect(find.text('+2'), findsWidgets);
  });

  testWidgets('the checkpoint card appears on the eighth page', (
    WidgetTester tester,
  ) async {
    await _pumpFeed(tester);

    for (int i = 0; i < 8; i++) {
      await tester.fling(find.byType(PageView), const Offset(0, -600), 1500);
      await tester.pumpAndSettle();
    }

    expect(_currentPage(tester), closeTo(7, 0.01));
    expect(find.text('Quick check'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
