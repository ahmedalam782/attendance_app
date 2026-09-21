import 'package:injectable/injectable.dart';

import '../entities/attendance_record.dart';
import '../repositories/attendance_repository.dart';

@injectable
class WatchStudentAttendanceHistoryUseCase {
  const WatchStudentAttendanceHistoryUseCase(this._repository);

  final AttendanceRepository _repository;

  Stream<List<AttendanceRecord>> call(String studentId) =>
      _repository.watchStudentAttendanceHistory(studentId);
}
