import 'package:injectable/injectable.dart';

import '../../../../core/api/base_response/result.dart';
import '../entities/enrolled_student.dart';
import '../repositories/enrollment_repository.dart';

@injectable
class AddStudentToProgramUseCase {
  const AddStudentToProgramUseCase(this._repository);

  final EnrollmentRepository _repository;

  Future<Result<EnrolledStudent>> call({
    required String programId,
    required String studentId,
    required String name,
  }) {
    return _repository.addStudent(
      programId: programId,
      studentId: studentId,
      name: name,
    );
  }
}
