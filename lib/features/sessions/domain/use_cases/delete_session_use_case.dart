import 'package:injectable/injectable.dart';

import '../../../../core/api/base_response/result.dart';
import '../params/delete_session_params.dart';
import '../repositories/sessions_repository.dart';

@injectable
class DeleteSessionUseCase {
  const DeleteSessionUseCase(this._repository);

  final SessionsRepository _repository;

  Future<Result<void>> call(DeleteSessionParams params) =>
      _repository.deleteSession(params);
}
