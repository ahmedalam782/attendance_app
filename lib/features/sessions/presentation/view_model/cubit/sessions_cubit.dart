import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../../../../core/api/base_state/base_cubit.dart';
import '../../../../../core/api/base_state/base_state.dart';
import '../../../domain/entities/session.dart';
import '../../../domain/params/create_session_params.dart';
import '../../../domain/params/delete_session_params.dart';
import '../../../domain/params/update_session_params.dart';
import '../../../domain/params/update_session_status_params.dart';
import '../../../domain/use_cases/create_session_use_case.dart';
import '../../../domain/use_cases/delete_session_use_case.dart';
import '../../../domain/use_cases/get_sessions_use_case.dart';
import '../../../domain/use_cases/update_session_status_use_case.dart';
import '../../../domain/use_cases/update_session_use_case.dart';
import 'sessions_state.dart';

@injectable
class SessionsCubit extends BaseCubit<SessionsState> {
  SessionsCubit(
    this._getSessions,
    this._createSession,
    this._updateSessionStatus,
    this._deleteSession,
    this._updateSession,
  ) : super(const SessionsState());

  final GetSessionsUseCase _getSessions;
  final CreateSessionUseCase _createSession;
  final UpdateSessionStatusUseCase _updateSessionStatus;
  final DeleteSessionUseCase _deleteSession;
  final UpdateSessionUseCase _updateSession;

  StreamSubscription<List<Session>>? _subscription;

  void watchSessions(String programId) {
    _subscription?.cancel();
    _subscription = _getSessions(programId).listen(
      (list) => emit(state.copyWith(sessions: list)),
      onError: (_) {
        if (!isClosed) emit(state.copyWith(sessions: const []));
      },
    );
  }

  Future<bool> createSession(CreateSessionParams params) async {
    if (state.isBusy) return false;
    var success = false;
    await emitFromResult<Session>(
      call: () => _createSession(params),
      onUpdate: (next) {
        if (next.state == StatusState.success) success = true;
        emit(state.copyWith(createSessionState: next));
      },
    );
    return success;
  }

  Future<bool> updateStatus(UpdateSessionStatusParams params) async {
    if (state.isBusy) return false;
    var success = false;
    await emitFromResult<void>(
      call: () => _updateSessionStatus(params),
      onUpdate: (next) {
        if (next.state == StatusState.success) success = true;
        emit(state.copyWith(updateStatusState: next));
      },
    );
    return success;
  }

  Future<bool> deleteSession(DeleteSessionParams params) async {
    if (state.isBusy) return false;
    var success = false;
    await emitFromResult<void>(
      call: () => _deleteSession(params),
      onUpdate: (next) {
        if (next.state == StatusState.success) success = true;
        emit(state.copyWith(deleteSessionState: next));
      },
    );
    return success;
  }

  Future<bool> updateSession(UpdateSessionParams params) async {
    if (state.isBusy) return false;
    var success = false;
    await emitFromResult<Session>(
      call: () => _updateSession(params),
      onUpdate: (next) {
        if (next.state == StatusState.success) success = true;
        emit(state.copyWith(updateSessionState: next));
      },
    );
    return success;
  }

  void resetCreateState() {
    emit(
      state.copyWith(
        createSessionState: const BaseState<Session>(state: StatusState.initial),
      ),
    );
  }

  void resetUpdateState() {
    emit(
      state.copyWith(
        updateStatusState: const BaseState<void>(state: StatusState.initial),
      ),
    );
  }

  void resetDeleteState() {
    emit(
      state.copyWith(
        deleteSessionState: const BaseState<void>(state: StatusState.initial),
      ),
    );
  }

  void resetUpdateSessionState() {
    emit(
      state.copyWith(
        updateSessionState: const BaseState<Session>(state: StatusState.initial),
      ),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
