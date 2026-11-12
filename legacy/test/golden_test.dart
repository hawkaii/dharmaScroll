@Tags(<String>['golden'])
library;

import 'package:dharmascroll/core/theme/app_theme.dart';
import 'package:dharmascroll/presentation/feed/feed_screen.dart';
import 'package:dharmascroll/presentation/feed/widgets/checkpoint_card.dart';
import 'package:dharmascroll/presentation/feed/widgets/shloka_card.dart';
import 'package:dharmascroll/presentation/library/library_screen.dart';
import 'package:dharmascroll/presentation/mann/crisis_screen.dart';
import 'package:dharmascroll/presentation/mann/mann_result_screen.dart';
import 'package:dharmascroll/presentation/mann/mann_screen.dart';
import 'package:dharmascroll/presentation/mp/wallet_screen.dart';
import 'package:dharmascroll/presentation/onboarding/onboarding_flow.dart';
import 'package:dharmascroll/presentation/profile/profile_screen.dart';
import 'package:dharmascroll/presentation/sankalp/sankalp_checkin.dart';
import 'package:dharmascroll/presentation/sankalp/sankalp_screen.dart';
import 'package:dharmascroll/presentation/share/share_card_editor.dart';
import 'package:dharmascroll/presentation/yatra/yatra_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dharmascroll/app_providers.dart';

/// Renders the app at phone size with the real bundled fonts so the PNGs are
/// judgeable. `flutter test --update-goldens` writes them under test/goldens/.
///
/// Tagged `golden` and excluded from CI: bitmap goldens depend on the host
/// architecture's rasteriser (these were generated on linux/arm64 and CI is
/// x86_64), so comparing them there produces diff noise rather than signal.
/// CI keeps the layout assertions in `screens_test.dart`, which are
/// architecture-independent.
Future<void> _loadFonts() async {
  const Map<String, List<String>> fonts = <String, List<String>>{
    'Archivo': <String>['assets/fonts/Archivo-Variable.ttf'],
    'InstrumentSans': <String>['assets/fonts/InstrumentSans-Variable.ttf'],
    'IBMPlexMono': <String>[
      'assets/fonts/IBMPlexMono-Regular.ttf',
      'assets/fonts/IBMPlexMono-Medium.ttf',
      'assets/fonts/IBMPlexMono-SemiBold.ttf',
    ],
    'TiroDevaSanskrit': <String>[
      'assets/fonts/TiroDevanagariSanskrit-Regular.ttf',
    ],
    'TiroDevaHindi': <String>['assets/fonts/TiroDevanagariHindi-Regular.ttf'],
    'NotoSansDevanagari': <String>[
      'assets/fonts/NotoSansDevanagari-Variable.ttf',
    ],
    // Without this every Icon renders as a tofu box in a golden.
    'MaterialIcons': <String>['fonts/MaterialIcons-Regular.otf'],
  };

  for (final MapEntry<String, List<String>> entry in fonts.entries) {
    final FontLoader loader = FontLoader(entry.key);
    for (final String path in entry.value) {
      loader.addFont(rootBundle.load(path));
    }
    await loader.load();
  }
}

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: child,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(_loadFonts);

  testWidgets('golden · feed', (WidgetTester tester) async {
    await _pump(tester, const Scaffold(body: FeedScreen()));
    await expectLater(
      find.byType(FeedScreen),
      matchesGoldenFile('goldens/feed.png'),
    );
  });

  testWidgets('golden · expand sheet', (WidgetTester tester) async {
    await _pump(tester, const Scaffold(body: FeedScreen()));
    tester.widget<ShlokaCard>(find.byType(ShlokaCard).first).onTap!();
    await tester.pumpAndSettle();
    // The sheet lives in the Navigator overlay, outside FeedScreen, so capture
    // the whole app or the golden shows the feed behind it.
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/sheet.png'),
    );
  });

  testWidgets('golden · onboarding splash', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
        child: MaterialApp(theme: AppTheme.light, home: const OnboardingFlow()),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(OnboardingFlow),
      matchesGoldenFile('goldens/onboarding.png'),
    );
  });

  testWidgets('golden · checkpoint', (WidgetTester tester) async {
    await _pump(tester, const Scaffold(body: CheckpointCard()));
    await expectLater(
      find.byType(CheckpointCard),
      matchesGoldenFile('goldens/checkpoint.png'),
    );
  });

  testWidgets('golden · wallet', (WidgetTester tester) async {
    await _pump(tester, const WalletScreen());
    await expectLater(
      find.byType(WalletScreen),
      matchesGoldenFile('goldens/wallet.png'),
    );
  });

  testWidgets('golden · yatra', (WidgetTester tester) async {
    await _pump(tester, const Scaffold(body: YatraScreen()));
    await expectLater(
      find.byType(YatraScreen),
      matchesGoldenFile('goldens/yatra.png'),
    );
  });

  testWidgets('golden · mann idle', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const Scaffold(body: MannScreen()),
      ),
    );
    // The breathing ring loops forever, so settle to a fixed frame instead.
    await tester.pump(const Duration(milliseconds: 1200));
    await expectLater(
      find.byType(MannScreen),
      matchesGoldenFile('goldens/mann.png'),
    );
  });

  testWidgets('golden · mann result', (WidgetTester tester) async {
    await _pump(tester, const MannResultScreen());
    await expectLater(
      find.byType(MannResultScreen),
      matchesGoldenFile('goldens/result.png'),
    );
  });

  testWidgets('golden · crisis', (WidgetTester tester) async {
    await _pump(tester, const CrisisScreen());
    await expectLater(
      find.byType(CrisisScreen),
      matchesGoldenFile('goldens/crisis.png'),
    );
  });

  testWidgets('golden · library', (WidgetTester tester) async {
    await _pump(tester, const LibraryScreen());
    await expectLater(
      find.byType(LibraryScreen),
      matchesGoldenFile('goldens/library.png'),
    );
  });

  testWidgets('golden · share card', (WidgetTester tester) async {
    await _pump(tester, const ShareCardEditor(verseId: '2.47'));
    await expectLater(
      find.byType(ShareCardEditor),
      matchesGoldenFile('goldens/share.png'),
    );
  });

  testWidgets('golden · sankalp', (WidgetTester tester) async {
    await _pump(tester, const SankalpScreen());
    await expectLater(
      find.byType(SankalpScreen),
      matchesGoldenFile('goldens/sankalp.png'),
    );
  });

  testWidgets('golden · check-in', (WidgetTester tester) async {
    await _pump(
      tester,
      // Render it where a sheet actually sits, so the golden reads as a sheet.
      const Scaffold(
        body: Align(
          alignment: Alignment.bottomCenter,
          child: SankalpCheckIn(promise: 'I\'ll speak calmly at home tonight.'),
        ),
      ),
    );
    await expectLater(
      find.byType(SankalpCheckIn),
      matchesGoldenFile('goldens/checkin.png'),
    );
  });

  testWidgets('golden · profile', (WidgetTester tester) async {
    await _pump(tester, const Scaffold(body: ProfileScreen()));
    await expectLater(
      find.byType(ProfileScreen),
      matchesGoldenFile('goldens/profile.png'),
    );
  });
}
