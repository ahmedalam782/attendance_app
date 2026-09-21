import 'package:injectable/injectable.dart';

import '../../../../core/api/base_response/result.dart';
import '../params/update_session_status_params.dart';
import '../repositories/sessions_repository.dart';

@injectable
class UpdateSessionStatusUseCase {
  const UpdateSessionStatusUseCase(this._repository);

  final SessionsRepository _repository;

  Future<Result<void>> call(UpdateSessionStatusParams params) =>
      _repository.updateSessionStatus(params);
}
