import 'package:injectable/injectable.dart';

import '../../../../core/api/base_response/result.dart';
import '../../../../core/api/execute_firebase.dart';
import '../../domain/entities/csv_student_entry.dart';
import '../../domain/entities/enrolled_student.dart';
import '../../domain/repositories/enrollment_repository.dart';
import '../datasources/enrollment_remote_data_source.dart';

@Injectable(as: EnrollmentRepository)
class EnrollmentRepositoryImpl implements EnrollmentRepository {
  EnrollmentRepositoryImpl(this._remote);

  final EnrollmentRemoteDataSource _remote;

  @override
  Stream<List<EnrolledStudent>> watchProgramStudents(String programId) {
    return _remote.watchProgramStudents(programId);
  }

  @override
  Future<Result<EnrolledStudent>> addStudent({
    required String programId,
    required String studentId,
    required String name,
  }) =>
      executeFirebase(() async {
        return _remote.addStudent(
          programId: programId,
          studentId: studentId,
          name: name,
        );
      });

  @override
  Future<Result<void>> removeStudent({
    required String programId,
    required String studentId,
  }) =>
      executeFirebase(() async {
        await _remote.removeStudent(
          programId: programId,
          studentId: studentId,
        );
      });

  @override
  Future<Result<int>> batchEnrollStudents({
    required String programId,
    required List<CsvStudentEntry> students,
  }) =>
      executeFirebase(() async {
        return _remote.batchEnrollStudents(
          programId: programId,
          students: students,
        );
      });
}
