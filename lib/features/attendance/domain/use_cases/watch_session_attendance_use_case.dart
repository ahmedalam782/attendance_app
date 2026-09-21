import 'package:injectable/injectable.dart';

import '../entities/attendance_record.dart';
import '../repositories/attendance_repository.dart';

@injectable
class WatchSessionAttendanceUseCase {
  const WatchSessionAttendanceUseCase(this._repository);

  final AttendanceRepository _repository;

  Stream<List<AttendanceRecord>> call(String programId, String sessionId) =>
      _repository.watchSessionAttendance(programId, sessionId);
}
