import 'package:injectable/injectable.dart';

import '../../../../core/api/base_response/result.dart';
import '../repositories/reports_repository.dart';

@injectable
class ExportAttendanceCsvUseCase {
  const ExportAttendanceCsvUseCase(this._repository);

  final ReportsRepository _repository;

  Future<Result<String>> call({
    String? programId,
    required String programTitle,
  }) =>
      _repository.exportCsv(
        programId: programId,
        programTitle: programTitle,
      );
}
