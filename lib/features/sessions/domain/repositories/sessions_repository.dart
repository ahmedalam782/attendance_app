import '../../../../core/api/base_response/result.dart';
import '../entities/session.dart';
import '../params/create_session_params.dart';
import '../params/update_session_status_params.dart';

abstract class SessionsRepository {
  Stream<List<Session>> watchSessions(String programId);

  Future<Result<Session>> createSession(CreateSessionParams params);

  Future<Result<void>> updateSessionStatus(UpdateSessionStatusParams params);
}
