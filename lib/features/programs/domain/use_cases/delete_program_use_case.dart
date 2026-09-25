import 'package:injectable/injectable.dart';

import '../../../../core/api/base_response/result.dart';
import '../repositories/programs_repository.dart';

@injectable
class DeleteProgramUseCase {
  const DeleteProgramUseCase(this._repository);

  final ProgramsRepository _repository;

  Future<Result<void>> call(String programId) {
    return _repository.deleteProgram(programId);
  }
}
