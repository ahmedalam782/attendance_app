import '../../../../core/api/base_response/result.dart';
import '../models/auth_user.dart';
import '../params/login_params.dart';
import '../params/register_params.dart';

abstract class AuthRepository {
  Stream<AuthUser?> get users;

  Future<Result<AuthUser>> login(LoginParams params);

  Future<Result<AuthUser>> register(RegisterParams params);

  Future<Result<void>> logout();

  Future<Result<void>> sendPasswordResetEmail(String email, {String? languageCode});
}
