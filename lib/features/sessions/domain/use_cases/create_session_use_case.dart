import 'package:injectable/injectable.dart';

import '../../../../core/api/base_response/result.dart';
import '../entities/session.dart';
import '../params/create_session_params.dart';
import '../repositories/sessions_repository.dart';

@injectable
class CreateSessionUseCase {
  const CreateSessionUseCase(this._repository);

  final SessionsRepository _repository;

  Future<Result<Session>> call(CreateSessionParams params) =>
      _repository.createSession(params);
}
