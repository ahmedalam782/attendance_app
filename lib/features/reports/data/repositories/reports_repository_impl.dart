import 'package:injectable/injectable.dart';

import '../../../../core/api/base_response/result.dart';
import '../../../../core/api/execute_firebase.dart';
import '../../domain/entities/attendance_stats.dart';
import '../../domain/repositories/reports_repository.dart';
import '../datasources/reports_remote_data_source.dart';

@Injectable(as: ReportsRepository)
class ReportsRepositoryImpl implements ReportsRepository {
  ReportsRepositoryImpl(this._remote);

  final ReportsRemoteDataSource _remote;

  @override
  Future<Result<AttendanceStats>> getStats({String? programId}) =>
      executeFirebase(() => _remote.getStats(programId: programId));

  @override
  Future<Result<List<SessionReportItem>>> getSessionReports({String? programId}) =>
      executeFirebase(() => _remote.getSessionReports(programId: programId));

  @override
  Future<Result<String>> exportCsv({
    String? programId,
    required String programTitle,
  }) =>
      executeFirebase(
        () => _remote.exportCsv(
          programId: programId,
          programTitle: programTitle,
        ),
      );
}
