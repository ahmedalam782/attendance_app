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
import '../../../domain/use_cases/delete_attendance_use_case.dart';
import '../../../domain/use_cases/record_attendance_use_case.dart';
import '../../../domain/use_cases/watch_session_attendance_use_case.dart';
import '../../../domain/use_cases/watch_student_attendance_history_use_case.dart';
import 'attendance_state.dart';

part 'attendance_cubit_scan.dart';
part 'attendance_cubit_manual.dart';

/// Façade cubit for attendance operations adhering to Al Faris architecture.
///
/// Features are split into part extensions:
/// - [AttendanceCubitScan]: QR scanning, validation, and self check-in
/// - [AttendanceCubitManual]: Manual and bulk attendance marking
@injectable
class AttendanceCubit extends BaseCubit<AttendanceState> {
  AttendanceCubit(
    this._recordAttendance,
    this._watchSessionAttendance,
    this._watchStudentHistory,
    this._tokenService,
    this._deleteAttendance,
  ) : super(const AttendanceState());

  final RecordAttendanceUseCase _recordAttendance;
  final WatchSessionAttendanceUseCase _watchSessionAttendance;
  final WatchStudentAttendanceHistoryUseCase _watchStudentHistory;
  final QrTokenService _tokenService;
  final DeleteAttendanceUseCase _deleteAttendance;

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

  void watchStudentHistory(String studentId) {
    _studentHistorySub?.cancel();
    _studentHistorySub = _watchStudentHistory(studentId).listen(
      (records) => emit(state.copyWith(history: records)),
      onError: (_) {
        if (!isClosed) emit(state.copyWith(history: const []));
      },
    );
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
