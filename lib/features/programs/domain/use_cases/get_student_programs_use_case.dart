import 'package:injectable/injectable.dart';

import '../entities/program.dart';
import '../repositories/programs_repository.dart';

@injectable
class GetStudentProgramsUseCase {
  const GetStudentProgramsUseCase(this._repository);

  final ProgramsRepository _repository;

  Stream<List<Program>> call(String studentUid) =>
      _repository.watchStudentPrograms(studentUid);
}
