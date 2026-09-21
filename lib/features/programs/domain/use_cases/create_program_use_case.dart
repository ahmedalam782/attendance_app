import 'package:injectable/injectable.dart';

import '../../../../core/api/base_response/result.dart';
import '../entities/program.dart';
import '../params/create_program_params.dart';
import '../repositories/programs_repository.dart';

@injectable
class CreateProgramUseCase {
  const CreateProgramUseCase(this._repository);

  final ProgramsRepository _repository;

  Future<Result<Program>> call(CreateProgramParams params) =>
      _repository.createProgram(params);
}
