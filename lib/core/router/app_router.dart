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

final _protectedPaths = {
  '/home', '/quiz', '/scan-instructions', '/face-scan',
  '/analysis', '/results', '/account',
};
final _authOnlyPaths = {'/auth', '/intro'};

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final loggedIn = FirebaseAuth.instance.currentUser != null;
    final path = state.matchedLocation;
    if (!loggedIn && _protectedPaths.contains(path)) return '/auth';
    if (loggedIn && _authOnlyPaths.contains(path)) return '/home';
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
      pageBuilder: (context, state) => _fade(
        state,
        ScanInstructionsScreen(
          quizAnswers: state.extra as List<dynamic>,
        ),
      ),
    ),
    GoRoute(
      path: '/face-scan',
      pageBuilder: (context, state) => _fade(
        state,
        FaceScanScreen(quizAnswers: state.extra as List<dynamic>),
      ),
    ),
    GoRoute(
      path: '/analysis',
      pageBuilder: (context, state) => _fade(
        state,
        AnalysisScreen(answers: state.extra as List<dynamic>),
      ),
    ),
    GoRoute(
      path: '/results',
      pageBuilder: (context, state) => _fade(
        state,
        ResultsScreen(answers: state.extra as List<dynamic>),
      ),
    ),
    GoRoute(
      path: '/lesson-detail',
      pageBuilder: (context, state) => _fade(
        state,
        LessonDetailScreen(lesson: state.extra as Lesson),
      ),
    ),
    GoRoute(
      path: '/article-detail',
      pageBuilder: (context, state) => _fade(
        state,
        ArticleDetailScreen(article: state.extra as Article),
      ),
    ),
    GoRoute(
      path: '/cosmetolog-detail',
      pageBuilder: (context, state) => _fade(
        state,
        KosmetologDetailScreen(cosmetolog: state.extra as Cosmetolog),
      ),
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
