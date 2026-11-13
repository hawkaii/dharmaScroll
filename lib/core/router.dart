import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/ekant/crisis_screen.dart';
import '../features/ekant/ekant_screen.dart';
import '../presentation/hear/hear_screen.dart';
import '../presentation/kept/kept_screen.dart';
import '../presentation/kept/verse_screen.dart';
import '../presentation/mann/mann_screen.dart';
import '../presentation/milestone/milestone_screen.dart';
import '../presentation/points/wallet_screen.dart';
import '../presentation/onboarding/onboarding_flow.dart';
import '../presentation/practice/practice_screen.dart';
import '../presentation/shell/app_shell.dart';
import '../presentation/today/today_screen.dart';
import '../presentation/walk/complete_screen.dart';
import '../presentation/walk/walk_screen.dart';
import '../presentation/yatra/yatra_screen.dart';
import '../presentation/you/you_screen.dart';
import 'state/settings.dart';

abstract final class Routes {
  static const String onboarding = '/onboarding';
  static const String today = '/today';
  static const String yatra = '/yatra';
  static const String you = '/you';
  static const String hear = '/hear';
  static const String walk = '/walk';
  static const String complete = '/complete';
  static const String ekant = '/ekant';
  static const String milestone = '/milestone';
  static const String kept = '/kept';
  static const String wallet = '/wallet';
  static const String speak = '/speak';
  static const String crisis = '/crisis';
  static const String practice = '/practice';
  static const String buildPractice = '/practice/build';
  static String verse(String id) => '/verse/$id';
}

/// The quiet room and the crisis screen fade in; nothing slides.
Page<void> _fadePage(GoRouterState s, Widget child, Duration d) =>
    CustomTransitionPage<void>(
      key: s.pageKey,
      child: child,
      transitionDuration: d,
      reverseTransitionDuration: const Duration(milliseconds: 350),
      transitionsBuilder: (_, Animation<double> a, _, Widget child) =>
          FadeTransition(opacity: a, child: child),
    );

/// Onboarding is a top-level route; the redirect keeps a finished user out of
/// it and an unfinished one inside it.
final Provider<GoRouter> routerProvider = Provider<GoRouter>((Ref ref) {
  final ValueNotifier<int> refresh = ValueNotifier<int>(0);
  ref.listen<bool>(
    settingsProvider.select((Settings s) => s.onboarded),
    (bool? previous, bool next) => refresh.value++,
  );
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: Routes.today,
    refreshListenable: refresh,
    redirect: (BuildContext context, GoRouterState state) {
      final bool done = ref.read(settingsProvider).onboarded;
      final bool inOnboarding = state.matchedLocation == Routes.onboarding;
      if (!done && !inOnboarding) return Routes.onboarding;
      if (done && inOnboarding) return Routes.today;
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: Routes.onboarding,
        builder: (BuildContext c, GoRouterState s) => const OnboardingFlow(),
      ),
      GoRoute(
        path: Routes.hear,
        builder: (BuildContext c, GoRouterState s) => const HearScreen(),
      ),
      GoRoute(
        path: Routes.walk,
        builder: (BuildContext c, GoRouterState s) => const WalkScreen(),
      ),
      GoRoute(
        path: Routes.complete,
        builder: (BuildContext c, GoRouterState s) =>
            CompleteScreen(award: s.extra is int ? s.extra! as int : 0),
      ),
      GoRoute(
        path: Routes.ekant,
        pageBuilder: (BuildContext c, GoRouterState s) => _fadePage(
          s,
          const EkantScreen(),
          const Duration(milliseconds: 700),
        ),
      ),
      GoRoute(
        path: Routes.crisis,
        pageBuilder: (BuildContext c, GoRouterState s) => _fadePage(
          s,
          const CrisisScreen(),
          const Duration(milliseconds: 900),
        ),
      ),
      GoRoute(
        path: Routes.milestone,
        builder: (BuildContext c, GoRouterState s) => MilestoneScreen(
          days: s.extra is int
              ? s.extra! as int
              : int.tryParse(s.uri.queryParameters['days'] ?? '') ?? 7,
        ),
      ),
      GoRoute(
        path: Routes.kept,
        builder: (BuildContext c, GoRouterState s) => const KeptScreen(),
      ),
      GoRoute(
        path: '/verse/:id',
        builder: (BuildContext c, GoRouterState s) =>
            VerseScreen(id: s.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: Routes.speak,
        builder: (BuildContext c, GoRouterState s) => const MannScreen(),
      ),
      GoRoute(
        path: Routes.practice,
        builder: (BuildContext c, GoRouterState s) => const PracticeScreen(),
      ),
      GoRoute(
        path: Routes.buildPractice,
        builder: (BuildContext c, GoRouterState s) =>
            const BuildPracticeScreen(),
      ),
      GoRoute(
        path: Routes.wallet,
        builder: (BuildContext c, GoRouterState s) => const WalletScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (BuildContext c, GoRouterState s, StatefulNavigationShell n) =>
            AppShell(navigationShell: n),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: Routes.today,
                builder: (BuildContext c, GoRouterState s) =>
                    const TodayScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: Routes.yatra,
                builder: (BuildContext c, GoRouterState s) =>
                    const YatraScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: Routes.you,
                builder: (BuildContext c, GoRouterState s) => const YouScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
