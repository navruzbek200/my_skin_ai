import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_beauty_ai/core/di/injection.dart';
import 'package:real_beauty_ai/core/router/app_router.dart';
import 'package:real_beauty_ai/core/theme/colors.dart';
import 'package:real_beauty_ai/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_beauty_ai/features/auth/presentation/bloc/auth_cubit.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Session state — read by the router guards, so it is created eagerly
        // rather than lazily.
        BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>(), lazy: false),
        BlocProvider<AuthCubit>(create: (_) => sl<AuthCubit>()),
      ],
      child: MaterialApp.router(
        title: 'My Skin AI',
        debugShowCheckedModeBanner: false,
        // Light only, deliberately. Every screen is designed against a light
        // background with hard-coded colours; letting the system flip us to
        // dark would recolour framework widgets (dialogs, text fields, the
        // keyboard bar) while our own surfaces stayed white. Pinning the mode
        // is what makes that impossible rather than merely unlikely.
        themeMode: ThemeMode.light,
        theme: ThemeData(
          brightness: Brightness.light,
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          scaffoldBackgroundColor: AppColors.background,
          useMaterial3: true,
        ),
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
    );
  }
}
