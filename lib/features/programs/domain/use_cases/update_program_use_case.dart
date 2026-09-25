import 'package:injectable/injectable.dart';

import '../../../../core/api/base_response/result.dart';
import '../entities/program.dart';
import '../params/update_program_params.dart';
import '../repositories/programs_repository.dart';

@injectable
class UpdateProgramUseCase {
  const UpdateProgramUseCase(this._repository);

  final ProgramsRepository _repository;

  Future<Result<Program>> call(UpdateProgramParams params) {
    return _repository.updateProgram(params);
  }
}
