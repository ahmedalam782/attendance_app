// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../features/auth/data/datasources/auth_remote_data_source.dart'
    as _i107;
import '../../features/auth/data/datasources/user_profile_remote_data_source.dart'
    as _i1041;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/domain/use_cases/login_use_case.dart' as _i1038;
import '../../features/auth/domain/use_cases/register_use_case.dart' as _i1010;
import '../../features/auth/firebase/datasources/firebase_auth_remote_data_source.dart'
    as _i613;
import '../../features/auth/firebase/datasources/firestore_user_profile_remote_data_source.dart'
    as _i205;
import '../../features/auth/presentation/view_model/cubit/auth_cubit.dart'
    as _i796;
import '../helper/logout_session.dart' as _i932;
import 'register_module.dart' as _i291;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => registerModule.prefs,
      preResolve: true,
    );
    gh.lazySingleton<_i59.FirebaseAuth>(() => registerModule.firebaseAuth);
    gh.lazySingleton<_i974.FirebaseFirestore>(
      () => registerModule.firebaseFirestore,
    );
    gh.factory<_i107.AuthRemoteDataSource>(
      () => _i613.FirebaseAuthRemoteDataSource(gh<_i59.FirebaseAuth>()),
    );
    gh.factory<_i1041.UserProfileRemoteDataSource>(
      () => _i205.FirestoreUserProfileRemoteDataSource(
        gh<_i974.FirebaseFirestore>(),
      ),
    );
    gh.factory<_i787.AuthRepository>(
      () => _i153.AuthRepositoryImpl(
        gh<_i107.AuthRemoteDataSource>(),
        gh<_i1041.UserProfileRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i932.LogoutSession>(
      () => _i932.LogoutSession(
        gh<_i460.SharedPreferences>(),
        gh<_i787.AuthRepository>(),
      ),
    );
    gh.factory<_i1038.LoginUseCase>(
      () => _i1038.LoginUseCase(gh<_i787.AuthRepository>()),
    );
    gh.factory<_i1010.RegisterUseCase>(
      () => _i1010.RegisterUseCase(gh<_i787.AuthRepository>()),
    );
    gh.factory<_i796.AuthCubit>(
      () => _i796.AuthCubit(
        gh<_i1038.LoginUseCase>(),
        gh<_i1010.RegisterUseCase>(),
        gh<_i932.LogoutSession>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}
