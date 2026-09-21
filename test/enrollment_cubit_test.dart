import 'dart:async';

import 'package:attendance_app/core/api/base_response/result.dart';
import 'package:attendance_app/core/api/base_state/base_state.dart';
import 'package:attendance_app/features/enrollment/domain/entities/csv_student_entry.dart';
import 'package:attendance_app/features/enrollment/domain/entities/enrolled_student.dart';
import 'package:attendance_app/features/enrollment/domain/repositories/enrollment_repository.dart';
import 'package:attendance_app/features/enrollment/domain/use_cases/add_student_to_program_use_case.dart';
import 'package:attendance_app/features/enrollment/domain/use_cases/import_students_csv_use_case.dart';
import 'package:attendance_app/features/enrollment/domain/use_cases/remove_student_from_program_use_case.dart';
import 'package:attendance_app/features/enrollment/domain/use_cases/watch_program_students_use_case.dart';
import 'package:attendance_app/features/enrollment/presentation/view_model/cubit/enrollment_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

class MockEnrollmentRepository implements EnrollmentRepository {
  final _controller = StreamController<List<EnrolledStudent>>.broadcast();
  List<EnrolledStudent> currentStudents = [];

  @override
  Stream<List<EnrolledStudent>> watchProgramStudents(String programId) {
    return _controller.stream;
  }

  void emitStudents(List<EnrolledStudent> students) {
    currentStudents = students;
    _controller.add(students);
  }

  @override
  Future<Result<EnrolledStudent>> addStudent({
    required String programId,
    required String studentId,
    required String name,
  }) async {
    final student = EnrolledStudent(
      id: studentId,
      name: name,
      joinedAt: DateTime.now(),
    );
    currentStudents.add(student);
    return Success(data: student);
  }

  @override
  Future<Result<void>> removeStudent({
    required String programId,
    required String studentId,
  }) async {
    currentStudents.removeWhere((s) => s.id == studentId);
    return const Success();
  }

  @override
  Future<Result<int>> batchEnrollStudents({
    required String programId,
    required List<CsvStudentEntry> students,
  }) async {
    for (final s in students) {
      if (s.isValid) {
        currentStudents.add(s.toEnrolledStudent());
      }
    }
    return Success(data: students.where((s) => s.isValid).length);
  }
}

void main() {
  late MockEnrollmentRepository repository;
  late EnrollmentCubit cubit;

  setUp(() {
    repository = MockEnrollmentRepository();
    cubit = EnrollmentCubit(
      WatchProgramStudentsUseCase(repository),
      AddStudentToProgramUseCase(repository),
      RemoveStudentFromProgramUseCase(repository),
      ImportStudentsCsvUseCase(repository),
    );
  });

  tearDown(() async {
    await cubit.close();
  });

  group('EnrollmentCubit', () {
    test('watchProgramStudents emits loading and then student list', () async {
      final sampleStudents = [
        EnrolledStudent(
          id: 'STU-001',
          name: 'Ahmed Hassan',
          joinedAt: DateTime(2026, 9, 1),
        ),
        EnrolledStudent(
          id: 'STU-002',
          name: 'Sara Omar',
          joinedAt: DateTime(2026, 9, 2),
        ),
      ];

      cubit.watchProgramStudents('prog_1');
      expect(cubit.state.status, StatusState.loading);

      repository.emitStudents(sampleStudents);
      await pumpEventQueue();

      expect(cubit.state.status, StatusState.success);
      expect(cubit.state.students.length, 2);
      expect(cubit.state.students.first.name, 'Ahmed Hassan');
    });

    test('searchQuery filters students by name or id', () async {
      final sampleStudents = [
        EnrolledStudent(
          id: 'STU-001',
          name: 'Ahmed Hassan',
          joinedAt: DateTime.now(),
        ),
        EnrolledStudent(
          id: 'STU-002',
          name: 'Sara Omar',
          joinedAt: DateTime.now(),
        ),
      ];

      cubit.watchProgramStudents('prog_1');
      repository.emitStudents(sampleStudents);
      await pumpEventQueue();

      cubit.updateSearchQuery('sara');
      expect(cubit.state.filteredStudents.length, 1);
      expect(cubit.state.filteredStudents.first.id, 'STU-002');

      cubit.updateSearchQuery('001');
      expect(cubit.state.filteredStudents.length, 1);
      expect(cubit.state.filteredStudents.first.name, 'Ahmed Hassan');
    });

    test('addStudent adds a student successfully', () async {
      final success = await cubit.addStudent(
        programId: 'prog_1',
        studentId: 'STU-003',
        name: 'Kareem Ali',
      );

      expect(success, isTrue);
      expect(cubit.state.actionSuccessMessage, 'student_added');
      expect(repository.currentStudents.any((s) => s.id == 'STU-003'), isTrue);
    });

    test('removeStudent removes a student successfully', () async {
      repository.currentStudents = [
        EnrolledStudent(
          id: 'STU-001',
          name: 'Ahmed Hassan',
          joinedAt: DateTime.now(),
        ),
      ];

      final success = await cubit.removeStudent(
        programId: 'prog_1',
        studentId: 'STU-001',
      );

      expect(success, isTrue);
      expect(cubit.state.actionSuccessMessage, 'student_removed');
      expect(repository.currentStudents.isEmpty, isTrue);
    });

    test('importStudentsFromCsv batch imports valid students', () async {
      final entries = [
        const CsvStudentEntry(id: 'STU-10', name: 'Ziad Nader', isValid: true),
        const CsvStudentEntry(id: 'STU-11', name: 'Nour Tarek', isValid: true),
        const CsvStudentEntry(id: '', name: 'Invalid One', isValid: false, error: 'missing_id'),
      ];

      final imported = await cubit.importStudentsFromCsv(
        programId: 'prog_1',
        students: entries,
      );

      expect(imported, 2);
      expect(cubit.state.actionSuccessMessage, 'imported_2');
      expect(repository.currentStudents.length, 2);
    });
  });
}
