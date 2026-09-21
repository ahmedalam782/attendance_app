import 'package:injectable/injectable.dart';

import '../../../../core/api/base_response/result.dart';
import '../entities/attendance_stats.dart';
import '../repositories/reports_repository.dart';

@injectable
class GetProgramReportUseCase {
  const GetProgramReportUseCase(this._repository);

  final ReportsRepository _repository;

  Future<Result<AttendanceStats>> getStats({String? programId}) =>
      _repository.getStats(programId: programId);

  Future<Result<List<SessionReportItem>>> getSessionReports({String? programId}) =>
      _repository.getSessionReports(programId: programId);
}
