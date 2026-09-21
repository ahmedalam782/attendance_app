import '../../domain/params/create_program_params.dart';
import '../../domain/params/join_program_params.dart';
import '../models/program_model.dart';

abstract class ProgramsRemoteDataSource {
  Stream<List<ProgramModel>> watchAdminPrograms(String adminUid);

  Stream<List<ProgramModel>> watchStudentPrograms(String studentUid);

  Future<ProgramModel> createProgram(CreateProgramParams params);

  Future<ProgramModel> joinProgramByCode(JoinProgramParams params);

  Future<ProgramModel> getProgramById(String programId);
}
