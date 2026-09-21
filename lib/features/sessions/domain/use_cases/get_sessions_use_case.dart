import 'package:injectable/injectable.dart';

import '../entities/session.dart';
import '../repositories/sessions_repository.dart';

@injectable
class GetSessionsUseCase {
  const GetSessionsUseCase(this._repository);

  final SessionsRepository _repository;

  Stream<List<Session>> call(String programId) =>
      _repository.watchSessions(programId);
}
