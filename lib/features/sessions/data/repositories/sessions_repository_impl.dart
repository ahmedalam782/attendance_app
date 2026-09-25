import 'package:injectable/injectable.dart';

import '../../../../core/api/base_response/result.dart';
import '../../../../core/api/execute_firebase.dart';
import '../../domain/entities/session.dart';
import '../../domain/params/create_session_params.dart';
import '../../domain/params/delete_session_params.dart';
import '../../domain/params/update_session_params.dart';
import '../../domain/params/update_session_status_params.dart';
import '../../domain/repositories/sessions_repository.dart';
import '../datasources/sessions_remote_data_source.dart';

@Injectable(as: SessionsRepository)
class SessionsRepositoryImpl implements SessionsRepository {
  SessionsRepositoryImpl(this._remote);

  final SessionsRemoteDataSource _remote;

  @override
  Stream<List<Session>> watchSessions(String programId) =>
      _remote.watchSessions(programId).map(
            (models) => models.map((m) => m.toEntity()).toList(),
          );

  @override
  Future<Result<Session>> createSession(CreateSessionParams params) =>
      executeFirebase(() async {
        final model = await _remote.createSession(params);
        return model.toEntity();
      });

  @override
  Future<Result<void>> updateSessionStatus(UpdateSessionStatusParams params) =>
      executeFirebase(() async {
        await _remote.updateSessionStatus(params);
      });

  @override
  Future<Result<void>> deleteSession(DeleteSessionParams params) =>
      executeFirebase(() async {
        await _remote.deleteSession(params);
      });

  @override
  Future<Result<Session>> updateSession(UpdateSessionParams params) =>
      executeFirebase(() async {
        final model = await _remote.updateSession(params);
        return model.toEntity();
      });
}
