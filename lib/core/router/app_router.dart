import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:histar_mobile/features/auth/auth_state.dart';
import 'package:histar_mobile/features/shell/main_shell.dart';
import 'package:histar_mobile/features/screens/admin_screen.dart';
import 'package:histar_mobile/features/screens/chat_screen.dart';
import 'package:histar_mobile/features/screens/checkout_b2c_screen.dart';
import 'package:histar_mobile/features/screens/explore_screen.dart';
import 'package:histar_mobile/features/screens/heritage_detail_screen.dart';
import 'package:histar_mobile/features/screens/home_screen.dart';
import 'package:histar_mobile/features/screens/leaderboard_screen.dart';
import 'package:histar_mobile/features/screens/login_screen.dart';
import 'package:histar_mobile/features/screens/mode_select_screen.dart';
import 'package:histar_mobile/features/screens/onboarding_screen.dart';
import 'package:histar_mobile/features/screens/pricing_screen.dart';
import 'package:histar_mobile/features/screens/profile_screen.dart';
import 'package:histar_mobile/features/screens/quest_detail_screen.dart';
import 'package:histar_mobile/features/screens/quests_screen.dart';
import 'package:histar_mobile/features/screens/scan_screen.dart';
import 'package:histar_mobile/features/screens/settings_screen.dart';
import 'package:histar_mobile/features/screens/splash_screen.dart';
import 'package:histar_mobile/features/screens/teacher_screen.dart';
import 'package:histar_mobile/features/screens/tour360_screen.dart';
import 'package:histar_mobile/features/screens/verify_email_screen.dart';
import 'package:histar_mobile/shared/providers.dart';

final _rootKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  // Do NOT watch auth here — that recreates GoRouter on every state change and
  // can leave the app stuck on /splash. Refresh via _AuthListenable instead.
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/splash',
    refreshListenable: _AuthListenable(ref),
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);

      if (!auth.bootstrapped) {
        return state.matchedLocation == '/splash' ? null : '/splash';
      }

      final loc = state.matchedLocation;

      // Always leave splash once session restore finished.
      if (loc == '/splash') {
        if (!auth.isAuthenticated) return '/onboarding';
        if (auth.user!.needsEmailVerification) return '/verify-email';
        if (auth.appMode == null) return '/mode-select';
        return '/home';
      }

      final loggingIn =
          loc == '/login' || loc == '/register' || loc == '/onboarding';

      if (!auth.isAuthenticated) {
        return loggingIn ? null : '/onboarding';
      }

      if (auth.user!.needsEmailVerification &&
          loc != '/verify-email' &&
          !loc.startsWith('/settings')) {
        return '/verify-email';
      }

      if (loggingIn) {
        if (auth.appMode == null) return '/mode-select';
        return '/home';
      }

      if (auth.appMode == null &&
          loc != '/mode-select' &&
          loc != '/verify-email') {
        return '/mode-select';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (_, __) => const LoginScreen(registerMode: true),
      ),
      GoRoute(path: '/verify-email', builder: (_, __) => const VerifyEmailScreen()),
      GoRoute(path: '/mode-select', builder: (_, __) => const ModeSelectScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/explore', builder: (_, __) => const ExploreScreen()),
              GoRoute(
                path: '/explore/:id',
                builder: (_, state) =>
                    HeritageDetailScreen(locationId: state.pathParameters['id']!),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/quests', builder: (_, __) => const QuestsScreen()),
              GoRoute(
                path: '/quests/:id',
                builder: (_, state) =>
                    QuestDetailScreen(questId: state.pathParameters['id']!),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/leaderboard', builder: (_, __) => const LeaderboardScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
            ],
          ),
        ],
      ),
      GoRoute(path: '/scan', builder: (_, __) => const ScanScreen()),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
      GoRoute(path: '/pricing', builder: (_, __) => const PricingScreen()),
      GoRoute(
        path: '/checkout/b2c',
        builder: (_, state) => CheckoutB2cScreen(
          returnToPath: state.uri.queryParameters['next'] ?? '/home',
        ),
      ),
      GoRoute(path: '/admin', builder: (_, __) => const AdminScreen()),
      GoRoute(path: '/teacher', builder: (_, __) => const TeacherScreen()),
      GoRoute(
        path: '/tour/360/:locationId',
        builder: (_, state) =>
            Tour360Screen(locationId: state.pathParameters['locationId']!),
      ),
      GoRoute(
        path: '/chat/:characterId',
        builder: (_, state) =>
            ChatScreen(characterId: state.pathParameters['characterId']!),
      ),
    ],
  );
});

/// Bridges Riverpod auth changes into GoRouter refresh.
class _AuthListenable extends ChangeNotifier {
  _AuthListenable(this._ref) {
    _ref.listen<AuthState>(authControllerProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;
}
