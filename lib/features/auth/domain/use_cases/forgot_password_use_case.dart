import 'package:injectable/injectable.dart';

import '../../../../core/api/base_response/result.dart';
import '../repositories/auth_repository.dart';

@injectable
class ForgotPasswordUseCase {
  const ForgotPasswordUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<void>> call(String email, {String? languageCode}) =>
      _repository.sendPasswordResetEmail(
        email.trim(),
        languageCode: languageCode,
      );
}
