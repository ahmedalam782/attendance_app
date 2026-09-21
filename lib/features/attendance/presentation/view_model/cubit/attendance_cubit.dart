import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/api/base_response/result.dart';
import '../../../../../core/api/base_state/base_cubit.dart';
import '../../../../../core/api/base_state/base_state.dart';
import '../../../../../core/crypto/qr_token_service.dart';
import '../../../../../core/languages/locale_keys.g.dart';
import '../../../../sessions/domain/entities/session.dart';
import '../../../domain/entities/attendance_record.dart';
import '../../../domain/params/record_attendance_params.dart';
import '../../../domain/use_cases/record_attendance_use_case.dart';
import '../../../domain/use_cases/watch_session_attendance_use_case.dart';
import '../../../domain/use_cases/watch_student_attendance_history_use_case.dart';
import 'attendance_state.dart';

@injectable
class AttendanceCubit extends BaseCubit<AttendanceState> {
  AttendanceCubit(
    this._recordAttendance,
    this._watchSessionAttendance,
    this._watchStudentHistory,
    this._tokenService,
  ) : super(const AttendanceState());

  final RecordAttendanceUseCase _recordAttendance;
  final WatchSessionAttendanceUseCase _watchSessionAttendance;
  final WatchStudentAttendanceHistoryUseCase _watchStudentHistory;
  final QrTokenService _tokenService;

  StreamSubscription<List<AttendanceRecord>>? _sessionAttendanceSub;
  StreamSubscription<List<AttendanceRecord>>? _studentHistorySub;

  DateTime? _lastScanTime;
  String? _lastScannedId;

  void setActiveSession(Session? session) {
    _sessionAttendanceSub?.cancel();
    emit(state.copyWith(
      activeSession: () => session,
      records: const [],
      lastFeedback: () => null,
    ));

    if (session != null) {
      _sessionAttendanceSub = _watchSessionAttendance(
        session.programId,
        session.id,
      ).listen(
        (records) => emit(state.copyWith(records: records)),
        onError: (_) {
          if (!isClosed) emit(state.copyWith(records: const []));
        },
      );
    }
  }

  void watchSessionAttendance(String programId, String sessionId) {
    _sessionAttendanceSub?.cancel();
    emit(state.copyWith(records: const []));
    _sessionAttendanceSub = _watchSessionAttendance(programId, sessionId).listen(
      (records) => emit(state.copyWith(records: records)),
      onError: (_) {
        if (!isClosed) emit(state.copyWith(records: const []));
      },
    );
  }

  Future<void> recordManualAttendance(RecordAttendanceParams params) async {
    final result = await _recordAttendance(params);
    if (result is Success<AttendanceRecord> && result.data != null) {
      final updatedRecords = state.records
          .where((r) => r.studentId != params.studentId)
          .toList()
        ..add(result.data!);
      emit(state.copyWith(records: updatedRecords));
    }
  }

  Future<int> markUnmarkedStudentsAbsent({
    required String programId,
    required String sessionId,
    required List<String> studentIds,
    required Map<String, String> studentNames,
    required String scannedBy,
  }) async {
    var markedCount = 0;
    final now = DateTime.now();
    for (final studentId in studentIds) {
      final name = studentNames[studentId] ?? studentId;
      final params = RecordAttendanceParams(
        programId: programId,
        sessionId: sessionId,
        studentId: studentId,
        studentName: name,
        scannedBy: scannedBy,
        status: 'absent',
        method: 'auto',
        scannedAt: now,
      );
      final result = await _recordAttendance(params);
      if (result is Success<AttendanceRecord> && result.data != null) {
        markedCount++;
      }
    }
    return markedCount;
  }

  void watchStudentHistory(String studentId) {
    _studentHistorySub?.cancel();
    _studentHistorySub = _watchStudentHistory(studentId).listen(
      (records) => emit(state.copyWith(history: records)),
      onError: (_) {
        if (!isClosed) emit(state.copyWith(history: const []));
      },
    );
  }

  Future<void> processScannedCode(
    String rawCode, {
    required String scannedBy,
  }) async {
    final session = state.activeSession;
    if (session == null) {
      _emitFeedback(
        ScanFeedbackType.invalid,
        '',
        LocaleKeys.attendance_no_open_sessions.tr(),
      );
      return;
    }

    final now = DateTime.now();

    // Decode and verify Ed25519 QR signature offline
    final payload = await _tokenService.verifyToken(rawCode);
    if (payload == null) {
      _emitFeedback(
        ScanFeedbackType.invalid,
        '',
        LocaleKeys.attendance_invalid_qr.tr(),
      );
      return;
    }

    // Check duplicate in memory first
    final isAlreadyScanned = state.records.any(
      (r) => r.studentId == payload.studentId,
    );
    if (isAlreadyScanned) {
      if (_lastScannedId == rawCode &&
          state.lastFeedback?.type == ScanFeedbackType.duplicate &&
          _lastScanTime != null &&
          now.difference(_lastScanTime!).inMilliseconds < 1500) {
        return;
      }
      _lastScanTime = now;
      _lastScannedId = rawCode;
      _emitFeedback(
        ScanFeedbackType.duplicate,
        payload.studentName,
        LocaleKeys.attendance_already_scanned.tr(),
      );
      return;
    }

    _lastScanTime = now;
    _lastScannedId = rawCode;

    // Determine status (Present vs Late based on session grace period)
    final lateCutoff = session.startAt.add(
      Duration(minutes: session.lateAfterMinutes),
    );
    final isLate = now.isAfter(lateCutoff);
    final status = isLate ? 'late' : 'present';

    final params = RecordAttendanceParams(
      programId: session.programId,
      sessionId: session.id,
      studentId: payload.studentId,
      studentName: payload.studentName,
      scannedBy: scannedBy,
      status: status,
      method: 'qr',
      scannedAt: now,
    );

    emit(state.copyWith(
      recordState:
          const BaseState<AttendanceRecord>(state: StatusState.loading),
    ));

    final result = await _recordAttendance(params);

    switch (result) {
      case Success<AttendanceRecord>(data: final record):
        final updatedRecords = record != null &&
                !state.records.any((r) => r.id == record.id)
            ? [...state.records, record]
            : state.records;
        emit(state.copyWith(
          recordState: BaseState<AttendanceRecord>(
            state: StatusState.success,
            data: record,
          ),
          records: updatedRecords,
        ));
        _emitFeedback(
          isLate ? ScanFeedbackType.late : ScanFeedbackType.present,
          payload.studentName,
          isLate
              ? LocaleKeys.attendance_success_late.tr()
              : LocaleKeys.attendance_success_present.tr(),
        );
      case Error<AttendanceRecord>(exception: final failure):
        emit(state.copyWith(
          recordState: BaseState<AttendanceRecord>(
            state: StatusState.failure,
            exception: failure,
          ),
        ));
        _emitFeedback(
          ScanFeedbackType.duplicate,
          payload.studentName,
          LocaleKeys.attendance_already_scanned.tr(),
        );
      case Cancelled<AttendanceRecord>():
        emit(state.copyWith(
          recordState:
              const BaseState<AttendanceRecord>(state: StatusState.initial),
        ));
    }
  }

  Future<bool> processSelfCheckIn({
    required String rawCode,
    required String studentId,
    required String studentName,
    required List<String> enrolledProgramIds,
  }) async {
    final now = DateTime.now();

    // 1. Verify dynamic session token (time windowed & signed)
    final dynamicPayload =
        await _tokenService.verifyDynamicSessionToken(rawCode, now: now);
    if (dynamicPayload == null) {
      _emitFeedback(
        ScanFeedbackType.invalid,
        '',
        LocaleKeys.self_check_in_expired_qr.tr(),
      );
      return false;
    }

    // 2. Verify student is enrolled in the program
    if (!enrolledProgramIds.contains(dynamicPayload.programId)) {
      _emitFeedback(
        ScanFeedbackType.invalid,
        '',
        LocaleKeys.self_check_in_not_enrolled_in_program.tr(),
      );
      return false;
    }

    // 3. Check duplicate check-in in existing history
    final alreadyCheckedIn = state.history.any(
      (r) =>
          r.sessionId == dynamicPayload.sessionId && r.studentId == studentId,
    );
    if (alreadyCheckedIn) {
      _emitFeedback(
        ScanFeedbackType.duplicate,
        dynamicPayload.sessionTitle,
        LocaleKeys.self_check_in_already_checked_in.tr(),
      );
      return false;
    }

    // 4. Record attendance
    final params = RecordAttendanceParams(
      programId: dynamicPayload.programId,
      sessionId: dynamicPayload.sessionId,
      studentId: studentId,
      studentName: studentName,
      scannedBy: studentId,
      status: 'present',
      method: 'self',
      scannedAt: now,
    );

    final result = await _recordAttendance(params);
    switch (result) {
      case Success<AttendanceRecord>(data: final record):
        if (record != null) {
          final updatedHistory = [record, ...state.history];
          emit(state.copyWith(history: updatedHistory));
        }
        _emitFeedback(
          ScanFeedbackType.present,
          dynamicPayload.sessionTitle,
          LocaleKeys.self_check_in_self_success_present.tr(),
        );
        return true;
      case Error<AttendanceRecord>(exception: final failure):
        _emitFeedback(
          ScanFeedbackType.invalid,
          '',
          failure?.toString() ?? 'Failed to record attendance',
        );
        return false;
      case Cancelled<AttendanceRecord>():
        return false;
    }
  }

  void _emitFeedback(
    ScanFeedbackType type,
    String studentName,
    String message,
  ) {
    emit(state.copyWith(
      lastFeedback: () => ScanFeedback(
        type: type,
        studentName: studentName,
        message: message,
        timestamp: DateTime.now(),
      ),
    ));
  }

  void clearFeedback() {
    emit(state.copyWith(lastFeedback: () => null));
  }

  @override
  Future<void> close() {
    _sessionAttendanceSub?.cancel();
    _studentHistorySub?.cancel();
    return super.close();
  }
}
