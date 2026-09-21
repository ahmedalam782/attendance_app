import 'package:injectable/injectable.dart';

import '../../../../core/api/base_response/result.dart';
import '../entities/csv_student_entry.dart';
import '../repositories/enrollment_repository.dart';

@injectable
class ImportStudentsCsvUseCase {
  const ImportStudentsCsvUseCase(this._repository);

  final EnrollmentRepository _repository;

  Future<Result<int>> call({
    required String programId,
    required List<CsvStudentEntry> students,
  }) {
    final validStudents = students.where((s) => s.isValid).toList();
    if (validStudents.isEmpty) {
      return Future.value(const Success(data: 0));
    }
    return _repository.batchEnrollStudents(
      programId: programId,
      students: validStudents,
    );
  }
}
