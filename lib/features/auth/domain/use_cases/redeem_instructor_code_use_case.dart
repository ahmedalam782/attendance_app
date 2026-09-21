import 'package:injectable/injectable.dart';

import '../../../../core/api/base_response/result.dart';
import '../models/auth_user.dart';
import '../repositories/auth_repository.dart';

@injectable
class RedeemInstructorCodeUseCase {
  const RedeemInstructorCodeUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<AuthUser>> call(String code) {
    return _repository.redeemInstructorCode(code);
  }
}
