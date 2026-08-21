import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:real_beauty_ai/core/di/injection.dart';
import 'package:real_beauty_ai/core/l10n/app_language.dart';
import 'package:real_beauty_ai/core/l10n/locale_cubit.dart';
import 'package:real_beauty_ai/core/router/app_router.dart';
import 'package:real_beauty_ai/core/theme/colors.dart';
import 'package:real_beauty_ai/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_beauty_ai/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:real_beauty_ai/l10n/app_localizations.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  // Seeded from the phone's language, so a first run on a Russian phone opens
  // in Russian rather than in the template language. A stored choice wins over
  // that — see [LocaleCubit].
  late final LocaleCubit _locale = LocaleCubit(
    deviceLocale: PlatformDispatcher.instance.locale,
  );

  @override
  void dispose() {
    _locale.close();
    super.dispose();
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
