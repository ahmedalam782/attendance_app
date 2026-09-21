import 'package:injectable/injectable.dart';

import '../../../../core/api/base_response/result.dart';
import '../entities/attendance_record.dart';
import '../params/record_attendance_params.dart';
import '../repositories/attendance_repository.dart';

@injectable
class RecordAttendanceUseCase {
  const RecordAttendanceUseCase(this._repository);

  final AttendanceRepository _repository;

  Future<Result<AttendanceRecord>> call(RecordAttendanceParams params) =>
      _repository.recordAttendance(params);
}
