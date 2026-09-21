import '../../domain/params/create_session_params.dart';
import '../../domain/params/update_session_status_params.dart';
import '../models/session_model.dart';

abstract class SessionsRemoteDataSource {
  Stream<List<SessionModel>> watchSessions(String programId);

  Future<SessionModel> createSession(CreateSessionParams params);

  Future<void> updateSessionStatus(UpdateSessionStatusParams params);
}
