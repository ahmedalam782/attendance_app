import 'dart:async';

import 'package:attendance_app/core/api/base_response/result.dart';
import 'package:attendance_app/core/crypto/qr_token_service.dart';
import 'package:attendance_app/features/attendance/domain/entities/attendance_record.dart';
import 'package:attendance_app/features/attendance/domain/params/record_attendance_params.dart';
import 'package:attendance_app/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:attendance_app/features/attendance/domain/use_cases/delete_attendance_use_case.dart';
import 'package:attendance_app/features/attendance/domain/use_cases/record_attendance_use_case.dart';
import 'package:attendance_app/features/attendance/domain/use_cases/watch_session_attendance_use_case.dart';
import 'package:attendance_app/features/attendance/domain/use_cases/watch_student_attendance_history_use_case.dart';
import 'package:attendance_app/features/attendance/presentation/view_model/cubit/attendance_cubit.dart';
import 'package:attendance_app/features/attendance/presentation/view_model/cubit/attendance_state.dart';
import 'package:attendance_app/features/sessions/domain/entities/session.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAttendanceRepository implements AttendanceRepository {
  final _sessionController = StreamController<List<AttendanceRecord>>.broadcast();
  final _historyController = StreamController<List<AttendanceRecord>>.broadcast();

  final List<AttendanceRecord> recorded = [];

  @override
  Future<Result<AttendanceRecord>> recordAttendance(
    RecordAttendanceParams params,
  ) async {
    final record = AttendanceRecord(
      id: '${params.sessionId}_${params.studentId}',
      programId: params.programId,
      sessionId: params.sessionId,
      studentId: params.studentId,
      studentName: params.studentName,
      scannedAt: params.actualScannedAt,
      scannedBy: params.scannedBy,
      method: params.method,
      status: params.status,
    );
    recorded.add(record);
    _sessionController.add(List.from(recorded));
    return Success(data: record);
  }

  @override
  Future<Result<void>> deleteAttendance({
    required String programId,
    required String sessionId,
    required String studentId,
  }) async {
    recorded.removeWhere((r) => r.sessionId == sessionId && r.studentId == studentId);
    _sessionController.add(List.from(recorded));
    return const Success();
  }

  @override
  Stream<List<AttendanceRecord>> watchSessionAttendance(
    String programId,
    String sessionId,
  ) =>
      _sessionController.stream;

  @override
  Stream<List<AttendanceRecord>> watchStudentAttendanceHistory(
    String studentId,
  ) =>
      _historyController.stream;

  void dispose() {
    _sessionController.close();
    _historyController.close();
  }
}

void main() {
  late FakeAttendanceRepository repository;
  late QrTokenService tokenService;
  late AttendanceCubit cubit;

  setUp(() {
    repository = FakeAttendanceRepository();
    tokenService = QrTokenService();
    cubit = AttendanceCubit(
      RecordAttendanceUseCase(repository),
      WatchSessionAttendanceUseCase(repository),
      WatchStudentAttendanceHistoryUseCase(repository),
      tokenService,
      DeleteAttendanceUseCase(repository),
    );
  });

  tearDown(() async {
    await cubit.close();
    repository.dispose();
  });

  group('QrTokenService Ed25519 Cryptography', () {
    test('generates and verifies valid token correctly', () async {
      final token = await tokenService.generateToken(
        studentId: 'std_42',
        studentName: 'Ahmed Alam',
      );

      expect(token, isNotEmpty);
      expect(token.contains('.'), isTrue);

      final payload = await tokenService.verifyToken(token);
      expect(payload, isNotNull);
      expect(payload!.studentId, 'std_42');
      expect(payload.studentName, 'Ahmed Alam');
    });

    test('rejects tampered or malformed token', () async {
      final token = await tokenService.generateToken(
        studentId: 'std_42',
        studentName: 'Ahmed Alam',
      );

      // Corrupt signature part
      final parts = token.split('.');
      final corruptedToken = '${parts[0]}.corrupted_signature';

      final payload = await tokenService.verifyToken(corruptedToken);
      expect(payload, isNull);
    });
  });

  group('AttendanceCubit', () {
    test('scanning without active session emits invalid feedback', () async {
      final token = await tokenService.generateToken(
        studentId: 'std_1',
        studentName: 'Student One',
      );

      await cubit.processScannedCode(token, scannedBy: 'admin_1');

      expect(cubit.state.lastFeedback, isNotNull);
      expect(cubit.state.lastFeedback!.type, ScanFeedbackType.invalid);
    });

    test('records attendance as present when on time', () async {
      final session = Session(
        id: 'session_1',
        programId: 'prog_1',
        title: 'Morning Class',
        startAt: DateTime.now().subtract(const Duration(minutes: 5)),
        endAt: DateTime.now().add(const Duration(hours: 1)),
        lateAfterMinutes: 15,
      );

      cubit.setActiveSession(session);

      final token = await tokenService.generateToken(
        studentId: 'std_1',
        studentName: 'Alice',
      );

      await cubit.processScannedCode(token, scannedBy: 'admin_1');

      expect(cubit.state.lastFeedback, isNotNull);
      expect(cubit.state.lastFeedback!.type, ScanFeedbackType.present);
      expect(repository.recorded.length, 1);
      expect(repository.recorded.first.status, 'present');
      expect(repository.recorded.first.studentName, 'Alice');
    });

    test('records attendance as late when past grace threshold', () async {
      final session = Session(
        id: 'session_2',
        programId: 'prog_1',
        title: 'Afternoon Class',
        startAt: DateTime.now().subtract(const Duration(minutes: 30)),
        endAt: DateTime.now().add(const Duration(hours: 1)),
        lateAfterMinutes: 15, // 30 > 15 -> late
      );

      cubit.setActiveSession(session);

      final token = await tokenService.generateToken(
        studentId: 'std_2',
        studentName: 'Bob',
      );

      await cubit.processScannedCode(token, scannedBy: 'admin_1');

      expect(cubit.state.lastFeedback, isNotNull);
      expect(cubit.state.lastFeedback!.type, ScanFeedbackType.late);
      expect(repository.recorded.length, 1);
      expect(repository.recorded.first.status, 'late');
    });

    test('detects duplicate scans for the same session', () async {
      final session = Session(
        id: 'session_1',
        programId: 'prog_1',
        title: 'Class',
        startAt: DateTime.now().subtract(const Duration(minutes: 5)),
        endAt: DateTime.now().add(const Duration(hours: 1)),
        lateAfterMinutes: 15,
      );

      cubit.setActiveSession(session);

      final token = await tokenService.generateToken(
        studentId: 'std_1',
        studentName: 'Alice',
      );

      await cubit.processScannedCode(token, scannedBy: 'admin_1');
      expect(cubit.state.lastFeedback!.type, ScanFeedbackType.present);

      // Second scan with same student
      await cubit.processScannedCode(token, scannedBy: 'admin_1');
      expect(cubit.state.lastFeedback!.type, ScanFeedbackType.duplicate);
    });

    test('recordManualAttendance stores manual record and updates records state', () async {
      await cubit.recordManualAttendance(
        const RecordAttendanceParams(
          programId: 'prog_1',
          sessionId: 'session_1',
          studentId: 'std_manual',
          studentName: 'Charlie',
          scannedBy: 'admin_1',
          status: 'excused',
          method: 'manual',
        ),
      );

      expect(repository.recorded.length, 1);
      expect(repository.recorded.first.studentName, 'Charlie');
      expect(repository.recorded.first.status, 'excused');
      expect(repository.recorded.first.isManual, isTrue);
      expect(cubit.state.records.length, 1);
      expect(cubit.state.records.first.id, 'session_1_std_manual');
    });

    test('processSelfCheckIn records self attendance with valid dynamic token', () async {
      final token = await tokenService.generateDynamicSessionToken(
        sessionId: 'session_dyn_1',
        programId: 'prog_dyn_1',
        sessionTitle: 'Dynamic Live Session',
        windowSeconds: 20,
      );

      final success = await cubit.processSelfCheckIn(
        rawCode: token,
        studentId: 'student_99',
        studentName: 'Zara',
        enrolledProgramIds: ['prog_dyn_1'],
      );

      expect(success, isTrue);
      expect(cubit.state.lastFeedback!.type, ScanFeedbackType.present);
      expect(repository.recorded.length, 1);
      expect(repository.recorded.first.method, 'self');
      expect(repository.recorded.first.studentId, 'student_99');
      expect(cubit.state.history.length, 1);
    });

    test('processSelfCheckIn rejects student not enrolled in the program', () async {
      final token = await tokenService.generateDynamicSessionToken(
        sessionId: 'session_dyn_1',
        programId: 'prog_other',
        sessionTitle: 'Other Class',
        windowSeconds: 20,
      );

      final success = await cubit.processSelfCheckIn(
        rawCode: token,
        studentId: 'student_99',
        studentName: 'Zara',
        enrolledProgramIds: ['prog_dyn_1'],
      );

      expect(success, isFalse);
      expect(cubit.state.lastFeedback!.type, ScanFeedbackType.invalid);
      expect(repository.recorded.isEmpty, isTrue);
    });
  });
}
