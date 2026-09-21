import '../../../../core/api/base_response/result.dart';
import '../entities/csv_student_entry.dart';
import '../entities/enrolled_student.dart';

abstract class EnrollmentRepository {
  Stream<List<EnrolledStudent>> watchProgramStudents(String programId);

  Future<Result<EnrolledStudent>> addStudent({
    required String programId,
    required String studentId,
    required String name,
  });

  Future<Result<void>> removeStudent({
    required String programId,
    required String studentId,
  });

  Future<Result<int>> batchEnrollStudents({
    required String programId,
    required List<CsvStudentEntry> students,
  });
}
