import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:real_beauty_ai/core/di/injection.dart';
import 'package:real_beauty_ai/features/account/presentation/pages/account_page.dart';
import 'package:real_beauty_ai/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_beauty_ai/features/auth/presentation/pages/auth_page.dart';
import 'package:real_beauty_ai/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:real_beauty_ai/features/onboarding/presentation/pages/analysis_page.dart';
import 'package:real_beauty_ai/features/onboarding/presentation/pages/intro_page.dart';
import 'package:real_beauty_ai/features/onboarding/presentation/pages/quiz_page.dart';
import 'package:real_beauty_ai/features/onboarding/presentation/pages/results_page.dart';
import 'package:real_beauty_ai/features/onboarding/presentation/pages/splash_page.dart';
import 'package:real_beauty_ai/features/shell/main_shell.dart';
import 'package:real_beauty_ai/features/sources/presentation/pages/sources_page.dart';
import 'package:real_beauty_ai/core/router/route_args.dart';
import 'package:real_beauty_ai/models/skin_analysis_result.dart';

final _protectedPaths = {
  '/home', '/quiz', '/analysis', '/results', '/account',
};
final _authOnlyPaths = {'/auth', '/intro'};

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  // Guards read AuthBloc, not FirebaseAuth: the bloc is the single source of
  // session truth, and it already mirrors authStateChanges().
  refreshListenable: GoRouterRefreshStream(sl<AuthBloc>().stream),
  redirect: (context, state) {
    final session = sl<AuthBloc>().state;
    final loggedIn = session.isAuthenticated;
    final path = state.matchedLocation;
    if (!loggedIn && _protectedPaths.contains(path)) return '/auth';
    if (loggedIn && _authOnlyPaths.contains(path)) return '/home';
    if (path == '/analysis' && state.extra is! AnalysisArgs) { return '/home'; }
    if (path == '/results' && state.extra is! SkinAnalysisResult) { return '/home'; }
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => _fade(state, const SplashScreen()),
    ),
    GoRoute(
      path: '/intro',
      pageBuilder: (context, state) => _fade(state, const IntroScreen()),
    ),
    GoRoute(
      path: '/auth',
      pageBuilder: (context, state) => _fade(state, const AuthScreen()),
    ),
    GoRoute(
      path: '/forgot',
      pageBuilder: (context, state) =>
          _fade(state, const ForgotPasswordScreen()),
    ),
    GoRoute(
      path: '/home',
      pageBuilder: (context, state) {
        final idx = state.extra is int ? state.extra as int : 0;
        return _fade(state, MainShell(initialIndex: idx));
      },
    ),
    GoRoute(
      path: '/quiz',
      pageBuilder: (context, state) => _fade(state, const QuizScreen()),
    ),
    GoRoute(
      path: '/analysis',
      pageBuilder: (context, state) {
        final extra = state.extra;
        if (extra is! AnalysisArgs) return _fade(state, const SplashScreen());
        return _fade(state, AnalysisScreen(args: extra));
      },
    ),
    GoRoute(
      path: '/results',
      pageBuilder: (context, state) {
        final extra = state.extra;
        if (extra is! SkinAnalysisResult) return _fade(state, const SplashScreen());
        return _fade(state, ResultsScreen(result: extra));
      },
    ),
    GoRoute(
      path: '/sources',
      pageBuilder: (context, state) => _fade(state, const SourcesScreen()),
    ),
    GoRoute(
      path: '/account',
      pageBuilder: (context, state) => _fade(state, const AccountScreen()),
    ),
  ],
);

CustomTransitionPage<void> _fade(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    transitionsBuilder: (_, animation, _, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
