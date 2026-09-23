import '../../domain/models/auth_user.dart';
import '../../domain/params/login_params.dart';
import '../../domain/params/register_params.dart';

/// Firebase-agnostic contract for auth remote calls.
abstract class AuthRemoteDataSource {
  Stream<AuthUser?> get users;

  Future<AuthUser> login(LoginParams params);

  Future<AuthUser> register(RegisterParams params);

  Future<void> logout();

  Future<void> sendPasswordResetEmail(String email, {String? languageCode});

  Future<AuthUser?> getCurrentUser();

  Future<AuthUser> redeemInstructorCode(String code);
}
