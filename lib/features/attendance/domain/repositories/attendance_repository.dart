import '../../../../core/api/base_response/result.dart';
import '../entities/attendance_record.dart';
import '../params/record_attendance_params.dart';

abstract class AttendanceRepository {
  Future<Result<AttendanceRecord>> recordAttendance(
    RecordAttendanceParams params,
  );

  Stream<List<AttendanceRecord>> watchSessionAttendance(
    String programId,
    String sessionId,
  );

  Stream<List<AttendanceRecord>> watchStudentAttendanceHistory(
    String studentId,
  );
}
