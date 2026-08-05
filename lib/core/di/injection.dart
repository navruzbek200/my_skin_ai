import 'package:get_it/get_it.dart';
import 'package:real_beauty_ai/features/auth/data/auth_data_source.dart';
import 'package:real_beauty_ai/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:real_beauty_ai/features/auth/presentation/bloc/auth_cubit.dart';

final sl = GetIt.instance;

/// Register all app-level dependencies.
/// Call once in main() before runApp().
///
/// Scope guide:
///   app-level  → registered here as lazySingleton (AuthBloc, AuthCubit, source)
///   page-level → created inline in BlocProvider (CosmetologistsCubit, ProductsCubit)
void configureDependencies() {
  sl.registerLazySingleton<AuthDataSource>(() => FirebaseAuthDataSource());

  // AuthBloc is a singleton because the router reads its state directly.
  sl.registerLazySingleton<AuthBloc>(() => AuthBloc());
  sl.registerLazySingleton<AuthCubit>(() => AuthCubit(sl<AuthDataSource>()));
}
