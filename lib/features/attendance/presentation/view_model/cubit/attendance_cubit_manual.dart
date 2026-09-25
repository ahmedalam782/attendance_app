part of 'attendance_cubit.dart';

/// Manual and bulk attendance recording methods for [AttendanceCubit].
extension AttendanceCubitManual on AttendanceCubit {
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

  Future<bool> deleteAttendance({
    required String programId,
    required String sessionId,
    required String studentId,
  }) async {
    final result = await _deleteAttendance(
      programId: programId,
      sessionId: sessionId,
      studentId: studentId,
    );
    if (result is Success<void>) {
      final updatedRecords = state.records
          .where((r) => r.studentId != studentId)
          .toList();
      emit(state.copyWith(records: updatedRecords));
      return true;
    }
    return false;
  }
}
