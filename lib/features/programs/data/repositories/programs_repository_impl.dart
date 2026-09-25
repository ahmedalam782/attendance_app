import 'package:injectable/injectable.dart';

import '../../../../core/api/base_response/result.dart';
import '../../../../core/api/execute_firebase.dart';
import '../../domain/entities/program.dart';
import '../../domain/params/create_program_params.dart';
import '../../domain/params/join_program_params.dart';
import '../../domain/params/update_program_params.dart';
import '../../domain/repositories/programs_repository.dart';
import '../datasources/programs_remote_data_source.dart';

@Injectable(as: ProgramsRepository)
class ProgramsRepositoryImpl implements ProgramsRepository {
  ProgramsRepositoryImpl(this._remote);

  final ProgramsRemoteDataSource _remote;

  @override
  Stream<List<Program>> watchAdminPrograms(String adminUid) =>
      _remote.watchAdminPrograms(adminUid).map(
            (models) => models.map((m) => m.toEntity()).toList(),
          );

  @override
  Stream<List<Program>> watchStudentPrograms(String studentUid) =>
      _remote.watchStudentPrograms(studentUid).map(
            (models) => models.map((m) => m.toEntity()).toList(),
          );

  @override
  Future<Result<Program>> createProgram(CreateProgramParams params) =>
      executeFirebase(() async {
        final model = await _remote.createProgram(params);
        return model.toEntity();
      });

  @override
  Future<Result<Program>> joinProgramByCode(JoinProgramParams params) =>
      executeFirebase(() async {
        final model = await _remote.joinProgramByCode(params);
        return model.toEntity();
      });

  @override
  Future<Result<Program>> getProgramById(String programId) =>
      executeFirebase(() async {
        final model = await _remote.getProgramById(programId);
        return model.toEntity();
      });

  @override
  Future<Result<Program>> updateProgram(UpdateProgramParams params) =>
      executeFirebase(() async {
        final model = await _remote.updateProgram(params);
        return model.toEntity();
      });

  @override
  Future<Result<void>> deleteProgram(String programId) =>
      executeFirebase(() => _remote.deleteProgram(programId));
}
