import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:real_beauty_ai/features/account/presentation/pages/account_page.dart';
import 'package:real_beauty_ai/features/auth/presentation/pages/auth_page.dart';
import 'package:real_beauty_ai/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:real_beauty_ai/features/cosmetologists/presentation/pages/cosmetologist_detail_page.dart';
import 'package:real_beauty_ai/features/lessons/presentation/pages/article_detail_page.dart';
import 'package:real_beauty_ai/features/lessons/presentation/pages/lesson_detail_page.dart';
import 'package:real_beauty_ai/features/onboarding/presentation/pages/analysis_page.dart';
import 'package:real_beauty_ai/features/onboarding/presentation/pages/intro_page.dart';
import 'package:real_beauty_ai/features/onboarding/presentation/pages/quiz_page.dart';
import 'package:real_beauty_ai/features/onboarding/presentation/pages/results_page.dart';
import 'package:real_beauty_ai/features/onboarding/presentation/pages/splash_page.dart';
import 'package:real_beauty_ai/features/shell/main_shell.dart';
import 'package:real_beauty_ai/features/skin_scan/presentation/pages/face_scan_page.dart';
import 'package:real_beauty_ai/features/skin_scan/presentation/pages/scan_instructions_page.dart';
import 'package:real_beauty_ai/models/article.dart';
import 'package:real_beauty_ai/models/cosmetolog.dart';
import 'package:real_beauty_ai/models/lesson.dart';
import 'package:real_beauty_ai/core/router/route_args.dart';
import 'package:real_beauty_ai/models/skin_analysis_result.dart';

final _protectedPaths = {
  '/home', '/quiz', '/scan-instructions', '/face-scan',
  '/analysis', '/results', '/account',
};
final _authOnlyPaths = {'/auth', '/intro'};

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  refreshListenable: GoRouterRefreshStream(
    FirebaseAuth.instance.authStateChanges(),
  ),
  redirect: (context, state) {
    final loggedIn = FirebaseAuth.instance.currentUser != null;
    final path = state.matchedLocation;
    if (!loggedIn && _protectedPaths.contains(path)) return '/auth';
    if (loggedIn && _authOnlyPaths.contains(path)) return '/home';
    if (const {'/scan-instructions', '/face-scan', '/analysis', '/results'}.contains(path) &&
        state.extra is! List) {
      return '/home';
    }
    if (path == '/lesson-detail' && state.extra is! Lesson) { return '/home'; }
    if (path == '/article-detail' && state.extra is! Article) { return '/home'; }
    if (path == '/cosmetolog-detail' && state.extra is! Cosmetolog) { return '/home'; }
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
      path: '/scan-instructions',
      pageBuilder: (context, state) {
        final extra = state.extra;
        if (extra is! List) return _fade(state, const SplashScreen());
        return _fade(state, ScanInstructionsScreen(quizAnswers: extra));
      },
    ),
    GoRoute(
      path: '/face-scan',
      pageBuilder: (context, state) {
        final extra = state.extra;
        if (extra is! List) return _fade(state, const SplashScreen());
        return _fade(state, FaceScanScreen(quizAnswers: extra));
      },
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
      path: '/lesson-detail',
      pageBuilder: (context, state) {
        final extra = state.extra;
        if (extra is! Lesson) return _fade(state, const SplashScreen());
        return _fade(state, LessonDetailScreen(lesson: extra));
      },
    ),
    GoRoute(
      path: '/article-detail',
      pageBuilder: (context, state) {
        final extra = state.extra;
        if (extra is! Article) return _fade(state, const SplashScreen());
        return _fade(state, ArticleDetailScreen(article: extra));
      },
    ),
    GoRoute(
      path: '/cosmetolog-detail',
      pageBuilder: (context, state) {
        final extra = state.extra;
        if (extra is! Cosmetolog) return _fade(state, const SplashScreen());
        return _fade(state, KosmetologDetailScreen(cosmetolog: extra));
      },
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
