import '../../../../core/api/base_response/result.dart';
import '../entities/attendance_stats.dart';

abstract class ReportsRepository {
  Future<Result<AttendanceStats>> getStats({String? programId});

  Future<Result<List<SessionReportItem>>> getSessionReports({String? programId});

  Future<Result<String>> exportCsv({
    String? programId,
    required String programTitle,
  });
}
