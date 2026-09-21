import 'package:injectable/injectable.dart';

import '../entities/enrolled_student.dart';
import '../repositories/enrollment_repository.dart';

@injectable
class WatchProgramStudentsUseCase {
  const WatchProgramStudentsUseCase(this._repository);

  final EnrollmentRepository _repository;

  Stream<List<EnrolledStudent>> call(String programId) {
    return _repository.watchProgramStudents(programId);
  }
}
