import '../../../../../core/api/base_state/base_state.dart';
import '../../../domain/entities/session.dart';

class SessionsState {
  const SessionsState({
    this.sessions = const [],
    this.createSessionState = const BaseState<Session>(state: StatusState.initial),
    this.updateStatusState = const BaseState<void>(state: StatusState.initial),
  });

  final List<Session> sessions;
  final BaseState<Session> createSessionState;
  final BaseState<void> updateStatusState;

  bool get isBusy =>
      createSessionState.state == StatusState.loading ||
      updateStatusState.state == StatusState.loading;

  SessionsState copyWith({
    List<Session>? sessions,
    BaseState<Session>? createSessionState,
    BaseState<void>? updateStatusState,
  }) =>
      SessionsState(
        sessions: sessions ?? this.sessions,
        createSessionState: createSessionState ?? this.createSessionState,
        updateStatusState: updateStatusState ?? this.updateStatusState,
      );
}
