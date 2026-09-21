import '../../domain/entities/csv_student_entry.dart';
import '../models/enrolled_student_model.dart';

abstract class EnrollmentRemoteDataSource {
  Stream<List<EnrolledStudentModel>> watchProgramStudents(String programId);

  Future<EnrolledStudentModel> addStudent({
    required String programId,
    required String studentId,
    required String name,
  });

  Future<void> removeStudent({
    required String programId,
    required String studentId,
  });

  Future<int> batchEnrollStudents({
    required String programId,
    required List<CsvStudentEntry> students,
  });
}
