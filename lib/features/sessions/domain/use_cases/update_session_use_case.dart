import 'package:injectable/injectable.dart';

import '../../../../core/api/base_response/result.dart';
import '../entities/session.dart';
import '../params/update_session_params.dart';
import '../repositories/sessions_repository.dart';

@injectable
class UpdateSessionUseCase {
  const UpdateSessionUseCase(this._repository);

  final SessionsRepository _repository;

  Future<Result<Session>> call(UpdateSessionParams params) =>
      _repository.updateSession(params);
}
