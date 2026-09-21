import 'package:injectable/injectable.dart';

import '../entities/program.dart';
import '../repositories/programs_repository.dart';

@injectable
class GetAdminProgramsUseCase {
  const GetAdminProgramsUseCase(this._repository);

  final ProgramsRepository _repository;

  Stream<List<Program>> call(String adminUid) =>
      _repository.watchAdminPrograms(adminUid);
}
