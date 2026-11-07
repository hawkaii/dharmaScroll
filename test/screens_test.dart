import 'package:dharmascroll/core/theme/app_theme.dart';
import 'package:dharmascroll/presentation/library/library_screen.dart';
import 'package:dharmascroll/presentation/mann/crisis_screen.dart';
import 'package:dharmascroll/presentation/mann/mann_result_screen.dart';
import 'package:dharmascroll/presentation/mp/daily_reward_sheet.dart';
import 'package:dharmascroll/presentation/mp/wallet_screen.dart';
import 'package:dharmascroll/presentation/profile/profile_screen.dart';
import 'package:dharmascroll/presentation/sankalp/sankalp_checkin.dart';
import 'package:dharmascroll/presentation/sankalp/sankalp_screen.dart';
import 'package:dharmascroll/presentation/share/share_card_editor.dart';
import 'package:dharmascroll/presentation/sangha/sangha_screen.dart';
import 'package:dharmascroll/presentation/yatra/yatra_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pumpScreen(
  WidgetTester tester,
  Widget screen, {
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
        child: screen,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  final Map<String, Widget> screens = <String, Widget>{
    'wallet': const WalletScreen(),
    'library': const LibraryScreen(),
    'crisis': const CrisisScreen(),
    'mann result': const MannResultScreen(),
    'profile': const Scaffold(body: ProfileScreen()),
    'sangha': const Scaffold(body: SanghaScreen()),
    'yatra': const Scaffold(body: YatraScreen()),
    'share card': const ShareCardEditor(verseId: '2.47'),
    'sankalp': const SankalpScreen(),
    'check-in': const Scaffold(
      body: SankalpCheckIn(promise: 'I\'ll speak calmly at home tonight.'),
    ),
  };

  for (final MapEntry<String, Widget> entry in screens.entries) {
    testWidgets('${entry.key} lays out on a 360 dp phone', (
      WidgetTester tester,
    ) async {
      await _pumpScreen(tester, entry.value);
      expect(tester.takeException(), isNull);
    });

    testWidgets('${entry.key} survives 320 dp at 200% text scale', (
      WidgetTester tester,
    ) async {
      await _pumpScreen(
        tester,
        entry.value,
        size: const Size(320, 568),
        textScale: 2,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('the daily reward sheet opens and itemises the day', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (BuildContext context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => showDailyRewardSheet(context),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Nitya Path complete'), findsOneWidget);
    expect(find.text('+43 MP'), findsOneWidget);
    expect(
      find.text('Keep scrolling — no more points today, just peace.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('the crisis screen shows both helpline numbers', (
    WidgetTester tester,
  ) async {
    await _pumpScreen(tester, const CrisisScreen());

    expect(find.text('You don\'t have to carry this alone'), findsOneWidget);
    expect(find.text('14416  or  1-800-891-4416'), findsOneWidget);
    expect(find.textContaining('call 112'), findsOneWidget);
  });
}
