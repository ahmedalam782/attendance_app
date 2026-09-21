import 'package:injectable/injectable.dart';

import '../../../../core/api/base_response/result.dart';
import '../models/auth_user.dart';
import '../params/phone_auth_params.dart';
import '../repositories/auth_repository.dart';

@injectable
class VerifyPhoneOtpUseCase {
  const VerifyPhoneOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<AuthUser>> call(PhoneOtpParams params) =>
      _repository.verifyPhoneOtp(params);
}
