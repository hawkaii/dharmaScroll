import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/feed/feed_screen.dart';
import '../../presentation/library/library_screen.dart';
import '../../presentation/mp/wallet_screen.dart';
import '../../presentation/sankalp/sankalp_screen.dart';
import '../../presentation/share/share_card_editor.dart';
import '../../presentation/mann/crisis_screen.dart';
import '../../presentation/mann/mann_result_screen.dart';
import '../../presentation/mann/mann_screen.dart';
import '../../presentation/onboarding/onboarding_flow.dart';
import '../../presentation/onboarding/onboarding_state.dart';
import '../../presentation/profile/profile_screen.dart';
import '../../presentation/sangha/sangha_screen.dart';
import '../../presentation/shell/app_shell.dart';
import '../../presentation/yatra/yatra_screen.dart';

abstract final class Routes {
  static const String shloka = '/shloka';
  static const String yatra = '/yatra';
  static const String mann = '/mann';
  static const String sangha = '/sangha';
  static const String profile = '/profile';
  static const String onboarding = '/onboarding';
  static const String library = '/library';
  static const String shareCard = '/share-card/:verseId';
  static const String sankalp = '/sankalp';
  static const String wallet = 'wallet';
}

/// The route graph.
///
/// Onboarding is a top-level destination rather than a shell branch, and the
/// redirect below bounces a completed user out of it on every navigation —
/// including a back gesture — so `/onboarding` is not a place you can return to.
final Provider<GoRouter> routerProvider = Provider<GoRouter>((Ref ref) {
  final ValueNotifier<int> refresh = ValueNotifier<int>(0);
  ref.listen<bool>(
    onboardingProvider.select((OnboardingState s) => s.completed),
    (bool? previous, bool next) => refresh.value++,
  );
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: Routes.shloka,
    refreshListenable: refresh,
    redirect: (BuildContext context, GoRouterState state) {
      final bool completed = ref.read(onboardingProvider).completed;
      final String location = state.matchedLocation;
      final bool inOnboarding = location.startsWith(Routes.onboarding);

      if (!completed && !inOnboarding) {
        return Routes.onboarding;
      }
      if (completed && inOnboarding) {
        return Routes.shloka;
      }
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: Routes.onboarding,
        builder: (BuildContext context, GoRouterState state) =>
            const OnboardingFlow(),
      ),
      GoRoute(
        path: Routes.library,
        builder: (BuildContext context, GoRouterState state) =>
            const LibraryScreen(),
      ),
      GoRoute(
        path: Routes.shareCard,
        builder: (BuildContext context, GoRouterState state) =>
            ShareCardEditor(verseId: state.pathParameters['verseId']!),
      ),
      GoRoute(
        path: Routes.sankalp,
        builder: (BuildContext context, GoRouterState state) =>
            const SankalpScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (
          BuildContext context,
          GoRouterState state,
          StatefulNavigationShell navigationShell,
        ) => AppShell(navigationShell: navigationShell),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: Routes.shloka,
                builder: (BuildContext context, GoRouterState state) =>
                    const FeedScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: Routes.yatra,
                builder: (BuildContext context, GoRouterState state) =>
                    const YatraScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: Routes.mann,
                builder: (BuildContext context, GoRouterState state) =>
                    const MannScreen(),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'result',
                    builder: (BuildContext context, GoRouterState state) =>
                        const MannResultScreen(),
                  ),
                  GoRoute(
                    path: 'crisis',
                    builder: (BuildContext context, GoRouterState state) =>
                        const CrisisScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: Routes.sangha,
                builder: (BuildContext context, GoRouterState state) =>
                    const SanghaScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: Routes.profile,
                builder: (BuildContext context, GoRouterState state) =>
                    const ProfileScreen(),
                routes: <RouteBase>[
                  GoRoute(
                    path: Routes.wallet,
                    builder: (BuildContext context, GoRouterState state) =>
                        const WalletScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
