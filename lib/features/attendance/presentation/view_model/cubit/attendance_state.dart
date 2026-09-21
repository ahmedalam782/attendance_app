import '../../../../../core/api/base_state/base_state.dart';
import '../../../../sessions/domain/entities/session.dart';
import '../../../domain/entities/attendance_record.dart';

enum ScanFeedbackType { present, late, duplicate, invalid }

class ScanFeedback {
  const ScanFeedback({
    required this.type,
    required this.studentName,
    required this.message,
    required this.timestamp,
  });

  final ScanFeedbackType type;
  final String studentName;
  final String message;
  final DateTime timestamp;

  bool get isSuccess =>
      type == ScanFeedbackType.present || type == ScanFeedbackType.late;
}

class AttendanceState {
  const AttendanceState({
    this.activeSession,
    this.records = const [],
    this.history = const [],
    this.recordState =
        const BaseState<AttendanceRecord>(state: StatusState.initial),
    this.lastFeedback,
  });

  final Session? activeSession;
  final List<AttendanceRecord> records;
  final List<AttendanceRecord> history;
  final BaseState<AttendanceRecord> recordState;
  final ScanFeedback? lastFeedback;

  int get pendingSyncCount => records.where((r) => r.isPendingSync).length;
  int get scanCount => records.length;
  bool get isScanningBusy => recordState.state == StatusState.loading;

  AttendanceState copyWith({
    Session? Function()? activeSession,
    List<AttendanceRecord>? records,
    List<AttendanceRecord>? history,
    BaseState<AttendanceRecord>? recordState,
    ScanFeedback? Function()? lastFeedback,
  }) =>
      AttendanceState(
        activeSession:
            activeSession != null ? activeSession() : this.activeSession,
        records: records ?? this.records,
        history: history ?? this.history,
        recordState: recordState ?? this.recordState,
        lastFeedback:
            lastFeedback != null ? lastFeedback() : this.lastFeedback,
      );
}
