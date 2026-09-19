import 'package:injectable/injectable.dart';

import '../../../../core/api/base_response/result.dart';
import '../repositories/auth_repository.dart';
import '../models/auth_user.dart';
import '../params/register_params.dart';

@injectable
class RegisterUseCase {
  const RegisterUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<AuthUser>> call(RegisterParams params) =>
      _repository.register(params);
}
