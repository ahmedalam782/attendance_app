import 'package:injectable/injectable.dart';

import '../../../../core/api/base_response/result.dart';
import '../../../../core/api/execute_firebase.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/params/record_attendance_params.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/attendance_remote_data_source.dart';

@Injectable(as: AttendanceRepository)
class AttendanceRepositoryImpl implements AttendanceRepository {
  AttendanceRepositoryImpl(this._remote);

  final AttendanceRemoteDataSource _remote;

  @override
  Future<Result<AttendanceRecord>> recordAttendance(
    RecordAttendanceParams params,
  ) =>
      executeFirebase(() async {
        final model = await _remote.recordAttendance(params);
        return model.toEntity();
      });

  @override
  Stream<List<AttendanceRecord>> watchSessionAttendance(
    String programId,
    String sessionId,
  ) =>
      _remote.watchSessionAttendance(programId, sessionId).map(
            (models) => models.map((m) => m.toEntity()).toList(),
          );

  @override
  Stream<List<AttendanceRecord>> watchStudentAttendanceHistory(
    String studentId,
  ) =>
      _remote.watchStudentAttendanceHistory(studentId).map(
            (models) => models.map((m) => m.toEntity()).toList(),
          );

  @override
  Future<Result<void>> deleteAttendance({
    required String programId,
    required String sessionId,
    required String studentId,
  }) =>
      executeFirebase(() => _remote.deleteAttendance(
            programId: programId,
            sessionId: sessionId,
            studentId: studentId,
          ));
}
