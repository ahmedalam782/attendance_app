import 'package:injectable/injectable.dart';

import '../../../../core/api/base_response/result.dart';
import '../params/phone_auth_params.dart';
import '../repositories/auth_repository.dart';

@injectable
class SendPhoneOtpUseCase {
  const SendPhoneOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<PhoneOtpDispatch>> call(PhoneAuthParams params) =>
      _repository.sendPhoneOtp(params);
}
