import '../../../../core/api/base_response/result.dart';
import '../entities/program.dart';
import '../params/create_program_params.dart';
import '../params/join_program_params.dart';
import '../params/update_program_params.dart';

abstract class ProgramsRepository {
  Stream<List<Program>> watchAdminPrograms(String adminUid);

  Stream<List<Program>> watchStudentPrograms(String studentUid);

  Future<Result<Program>> createProgram(CreateProgramParams params);

  Future<Result<Program>> joinProgramByCode(JoinProgramParams params);

  Future<Result<Program>> getProgramById(String programId);

  Future<Result<Program>> updateProgram(UpdateProgramParams params);

  Future<Result<void>> deleteProgram(String programId);
}
