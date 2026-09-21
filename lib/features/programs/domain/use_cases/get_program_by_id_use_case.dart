import 'package:injectable/injectable.dart';

import '../../../../core/api/base_response/result.dart';
import '../entities/program.dart';
import '../repositories/programs_repository.dart';

@injectable
class GetProgramByIdUseCase {
  const GetProgramByIdUseCase(this._repository);

  final ProgramsRepository _repository;

  Future<Result<Program>> call(String programId) =>
      _repository.getProgramById(programId);
}
