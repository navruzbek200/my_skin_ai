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
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          scaffoldBackgroundColor: AppColors.background,
          useMaterial3: true,
        ),
        routerConfig: appRouter,
      ),
    );
  }
}
