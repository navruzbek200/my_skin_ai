import 'package:get_it/get_it.dart';
import 'package:real_beauty_ai/features/auth/data/auth_data_source.dart';
import 'package:real_beauty_ai/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:real_beauty_ai/features/skin_analysis/data/skin_analysis_remote_data_source.dart';
import 'package:real_beauty_ai/features/skin_analysis/data/skin_analysis_repository_impl.dart';
import 'package:real_beauty_ai/features/skin_analysis/domain/skin_analysis_repository.dart';

final sl = GetIt.instance;

/// Register all app-level dependencies.
/// Call once in main() before runApp().
///
/// Scope guide:
///   app-level  → registered here as lazySingleton (AuthCubit, AuthDataSource)
///   page-level → created inline in BlocProvider (CosmetologistsCubit, ProductsCubit)
void configureDependencies() {
  sl.registerLazySingleton<AuthDataSource>(() => FirebaseAuthDataSource());
  sl.registerLazySingleton<AuthCubit>(() => AuthCubit(sl<AuthDataSource>()));

  sl.registerLazySingleton<SkinAnalysisRemoteDataSource>(
    () => SkinAnalysisRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<SkinAnalysisRepository>(
    () => SkinAnalysisRepositoryImpl(sl<SkinAnalysisRemoteDataSource>()),
  );
}
