import 'package:injectable/injectable.dart';

import '../../../../core/api/base_response/result.dart';
import '../entities/program.dart';
import '../params/join_program_params.dart';
import '../repositories/programs_repository.dart';

@injectable
class JoinProgramByCodeUseCase {
  const JoinProgramByCodeUseCase(this._repository);

  final ProgramsRepository _repository;

  Future<Result<Program>> call(JoinProgramParams params) =>
      _repository.joinProgramByCode(params);
}
