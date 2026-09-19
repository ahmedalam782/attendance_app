import 'package:injectable/injectable.dart';

import '../../../../core/api/base_response/result.dart';
import '../repositories/auth_repository.dart';
import '../models/auth_user.dart';
import '../params/login_params.dart';

@injectable
class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<AuthUser>> call(LoginParams params) =>
      _repository.login(params);
}
