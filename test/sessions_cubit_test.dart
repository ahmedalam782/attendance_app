import 'dart:async';

import 'package:attendance_app/core/api/base_response/result.dart';
import 'package:attendance_app/core/api/base_state/base_state.dart';
import 'package:attendance_app/features/sessions/domain/entities/session.dart';
import 'package:attendance_app/features/sessions/domain/params/create_session_params.dart';
import 'package:attendance_app/features/sessions/domain/params/update_session_status_params.dart';
import 'package:attendance_app/features/sessions/domain/repositories/sessions_repository.dart';
import 'package:attendance_app/features/sessions/domain/use_cases/create_session_use_case.dart';
import 'package:attendance_app/features/sessions/domain/use_cases/get_sessions_use_case.dart';
import 'package:attendance_app/features/sessions/domain/use_cases/update_session_status_use_case.dart';
import 'package:attendance_app/features/sessions/presentation/view_model/cubit/sessions_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeSessionsRepository implements SessionsRepository {
  final _controller = StreamController<List<Session>>.broadcast();

  @override
  Stream<List<Session>> watchSessions(String programId) => _controller.stream;

  void emitSessions(List<Session> list) => _controller.add(list);

  @override
  Future<Result<Session>> createSession(CreateSessionParams params) async {
    final session = Session(
      id: 's1',
      programId: params.programId,
      title: params.title,
      startAt: params.startAt,
      endAt: params.endAt,
      status: 'scheduled',
      lateAfterMinutes: params.lateAfterMinutes,
      attendanceCount: 0,
    );
    return Success(data: session);
  }

  @override
  Future<Result<void>> updateSessionStatus(
      UpdateSessionStatusParams params) async {
    return const Success();
  }

  void dispose() {
    _controller.close();
  }
}

void main() {
  late FakeSessionsRepository repository;
  late SessionsCubit cubit;

  setUp(() {
    repository = FakeSessionsRepository();
    cubit = SessionsCubit(
      GetSessionsUseCase(repository),
      CreateSessionUseCase(repository),
      UpdateSessionStatusUseCase(repository),
    );
  });

  tearDown(() async {
    await cubit.close();
    repository.dispose();
  });

  test('watchSessions updates state with stream emission', () async {
    cubit.watchSessions('prog_1');

    final testSessions = [
      Session(
        id: 's1',
        programId: 'prog_1',
        title: 'Lecture 1: Intro to Flutter',
        startAt: DateTime(2026, 9, 21, 10, 0),
        endAt: DateTime(2026, 9, 21, 12, 0),
        status: 'open',
      ),
    ];

    repository.emitSessions(testSessions);
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(cubit.state.sessions.length, 1);
    expect(cubit.state.sessions.first.title, 'Lecture 1: Intro to Flutter');
    expect(cubit.state.sessions.first.isOpen, isTrue);
  });

  test('createSession completes and updates state', () async {
    final params = CreateSessionParams(
      programId: 'prog_1',
      title: 'Session 2',
      startAt: DateTime(2026, 9, 22, 14, 0),
      endAt: DateTime(2026, 9, 22, 16, 0),
    );

    final success = await cubit.createSession(params);
    expect(success, isTrue);
    expect(cubit.state.createSessionState.state, StatusState.success);
    expect(cubit.state.createSessionState.data?.title, 'Session 2');

    cubit.resetCreateState();
    expect(cubit.state.createSessionState.state, StatusState.initial);
  });

  test('updateStatus completes and updates state', () async {
    const params = UpdateSessionStatusParams(
      programId: 'prog_1',
      sessionId: 's1',
      status: 'closed',
    );

    final success = await cubit.updateStatus(params);
    expect(success, isTrue);
    expect(cubit.state.updateStatusState.state, StatusState.success);

    cubit.resetUpdateState();
    expect(cubit.state.updateStatusState.state, StatusState.initial);
  });
}
