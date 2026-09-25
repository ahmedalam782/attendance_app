import 'package:injectable/injectable.dart';

import '../../../../core/api/base_response/result.dart';
import '../repositories/attendance_repository.dart';

@injectable
class DeleteAttendanceUseCase {
  const DeleteAttendanceUseCase(this._repository);

  final AttendanceRepository _repository;

  Future<Result<void>> call({
    required String programId,
    required String sessionId,
    required String studentId,
  }) {
    return _repository.deleteAttendance(
      programId: programId,
      sessionId: sessionId,
      studentId: studentId,
    );
  }
}
