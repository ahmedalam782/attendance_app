import '../../domain/entities/attendance_stats.dart';

abstract class ReportsRemoteDataSource {
  Future<AttendanceStats> getStats({String? programId});

  Future<List<SessionReportItem>> getSessionReports({String? programId});

  Future<String> exportCsv({
    String? programId,
    required String programTitle,
  });
}
