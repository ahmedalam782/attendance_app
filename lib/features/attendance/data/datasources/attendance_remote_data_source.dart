import '../../domain/params/record_attendance_params.dart';
import '../models/attendance_model.dart';

abstract class AttendanceRemoteDataSource {
  Future<AttendanceModel> recordAttendance(RecordAttendanceParams params);

  Stream<List<AttendanceModel>> watchSessionAttendance(
    String programId,
    String sessionId,
  );

  Stream<List<AttendanceModel>> watchStudentAttendanceHistory(String studentId);
}
