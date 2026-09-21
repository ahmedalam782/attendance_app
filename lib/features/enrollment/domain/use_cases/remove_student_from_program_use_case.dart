import 'package:injectable/injectable.dart';

import '../../../../core/api/base_response/result.dart';
import '../repositories/enrollment_repository.dart';

@injectable
class RemoveStudentFromProgramUseCase {
  const RemoveStudentFromProgramUseCase(this._repository);

  final EnrollmentRepository _repository;

  Future<Result<void>> call({
    required String programId,
    required String studentId,
  }) {
    return _repository.removeStudent(
      programId: programId,
      studentId: studentId,
    );
  }
}
