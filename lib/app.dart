import 'dart:async';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:real_beauty_ai/core/di/injection.dart';
import 'package:real_beauty_ai/core/l10n/app_language.dart';
import 'package:real_beauty_ai/core/l10n/locale_cubit.dart';
import 'package:real_beauty_ai/core/router/app_router.dart';
import 'package:real_beauty_ai/core/theme/colors.dart';
import 'package:real_beauty_ai/core/utils/logger.dart';
import 'package:real_beauty_ai/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_beauty_ai/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:real_beauty_ai/l10n/app_localizations.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  // Seeded from the phone's language, so a first run on a Russian phone opens
  // in Russian rather than in the template language. A stored choice wins over
  // that — see [LocaleCubit].
  late final LocaleCubit _locale = LocaleCubit(
    deviceLocale: PlatformDispatcher.instance.locale,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // `didChangeAppLifecycleState` only fires on a *transition* — backgrounded
    // then resumed. A revocation made in Settings while the app was fully
    // closed would otherwise go unnoticed until the person happened to
    // background and foreground the app again after reopening it. Checking
    // once here as well closes that gap: cold start is a transition too, just
    // one the observer cannot see for itself.
    unawaited(_signOutIfAppleRevoked());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _locale.close();
    super.dispose();
  }

  /// Catches a Sign in with Apple authorisation the person revoked while the
  /// app was closed or backgrounded.
  ///
  /// Revoking happens in iOS Settings, not in the app, and Apple pushes
  /// nothing to the device when it does — the Firebase session carries on
  /// working indefinitely, so somebody who has told iOS they no longer want
  /// this app connected to their Apple ID would stay silently signed in.
  /// Checked from two places: [initState], for a revocation made while the
  /// app was fully closed, and here, for one made while it sat in the
  /// background — `didChangeAppLifecycleState` only fires on that second
  /// transition, so cold start would otherwise go unchecked until the app
  /// happened to be backgrounded and resumed once after reopening.
  ///
  /// Only an explicit `revoked` answer signs anybody out; a failed check or an
  /// unknown state leaves the session alone, so a network blip cannot log
  /// somebody out of a working account.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    unawaited(_signOutIfAppleRevoked());
  }

  Future<void> _signOutIfAppleRevoked() async {
    final auth = sl<AuthBloc>();
    if (!auth.state.isAuthenticated) return;
    final cubit = sl<AuthCubit>();
    if (!cubit.isAppleOnlyUser) return;
    if (!await cubit.isAppleCredentialRevoked()) return;
    AppLogger.info('Apple authorisation revoked — signing out');
    await cubit.logout();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Session state — read by the router guards, so it is created eagerly
        // rather than lazily.
        BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>(), lazy: false),
        BlocProvider<AuthCubit>(create: (_) => sl<AuthCubit>()),
        BlocProvider<LocaleCubit>.value(value: _locale),
      ],
      // Only the locale is watched here. Rebuilding MaterialApp is the one
      // thing that has to happen on a language change, and nothing else in this
      // tree is cheap enough to rebuild for any other reason.
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) => MaterialApp.router(
          title: 'My Skin AI',
          debugShowCheckedModeBanner: false,
          locale: locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLanguage.supportedLocales,
          // Light only, deliberately. Every screen is designed against a light
          // background with hard-coded colours; letting the system flip us to
          // dark would recolour framework widgets (dialogs, text fields, the
          // keyboard bar) while our own surfaces stayed white. Pinning the mode
          // is what makes that impossible rather than merely unlikely.
          themeMode: ThemeMode.light,
          theme: _theme,
          routerConfig: appRouter,
          // Screens here are built from fixed-height pills, 44x76 week-strip
          // cells and a five-item bottom bar — geometry that does not stretch.
          // At the 2.0x the system allows, those overflow into black-and-yellow
          // stripes. Clamping at 1.3 keeps larger type working for the people
          // who need it while staying inside what the layouts can absorb.
          builder: (context, child) {
            final scaler = MediaQuery.textScalerOf(context).clamp(
              minScaleFactor: 1.0,
              maxScaleFactor: 1.3,
            );
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: scaler),
              child: child ?? const SizedBox.shrink(),
            );
          },
        ),
      ),
    );
  }
}

/// Framework defaults pulled onto the app's own tokens.
///
/// Material's stock focus ring, ripple and dialog surfaces are what a
/// `showDialog` or a `TextField` falls back to, and left alone they arrive in
/// Material's purple rather than in ours.
ThemeData get _theme {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    primary: AppColors.cta,
    surface: AppColors.surface,
    error: AppColors.danger,
  );
  return ThemeData(
    brightness: Brightness.light,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    useMaterial3: true,
    splashColor: AppColors.primary.withValues(alpha: 0.10),
    highlightColor: AppColors.primary.withValues(alpha: 0.06),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.cta,
      contentTextStyle: TextStyle(color: Colors.white),
    ),
  );
}
