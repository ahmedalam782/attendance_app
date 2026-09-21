import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/api/base_response/result.dart';
import '../../../../../core/api/base_state/base_state.dart';
import '../../../domain/entities/csv_student_entry.dart';
import '../../../domain/entities/enrolled_student.dart';
import '../../../domain/use_cases/add_student_to_program_use_case.dart';
import '../../../domain/use_cases/import_students_csv_use_case.dart';
import '../../../domain/use_cases/remove_student_from_program_use_case.dart';
import '../../../domain/use_cases/watch_program_students_use_case.dart';
import 'enrollment_state.dart';

@injectable
class EnrollmentCubit extends Cubit<EnrollmentState> {
  EnrollmentCubit(
    this._watchStudents,
    this._addStudent,
    this._removeStudent,
    this._importCsv,
  ) : super(const EnrollmentState());

  final WatchProgramStudentsUseCase _watchStudents;
  final AddStudentToProgramUseCase _addStudent;
  final RemoveStudentFromProgramUseCase _removeStudent;
  final ImportStudentsCsvUseCase _importCsv;

  StreamSubscription? _sub;
  String? _currentProgramId;

  void watchProgramStudents(String programId) {
    if (_currentProgramId == programId && _sub != null) return;
    _currentProgramId = programId;
    _sub?.cancel();

    emit(state.copyWith(status: StatusState.loading, clearActionMessages: true));
    _sub = _watchStudents(programId).listen(
      (students) {
        emit(
          state.copyWith(
            status: StatusState.success,
            students: students,
            clearActionMessages: true,
          ),
        );
      },
      onError: (err) {
        emit(
          state.copyWith(
            status: StatusState.failure,
            actionError: err.toString(),
          ),
        );
      },
    );
  }

  void updateSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  Future<bool> addStudent({
    required String programId,
    required String studentId,
    required String name,
  }) async {
    emit(state.copyWith(isActionLoading: true, clearActionMessages: true));

    final result = await _addStudent(
      programId: programId,
      studentId: studentId,
      name: name,
    );

    if (result is Success<EnrolledStudent>) {
      emit(
        state.copyWith(
          isActionLoading: false,
          actionSuccessMessage: 'student_added',
        ),
      );
      return true;
    } else if (result is Error<EnrolledStudent>) {
      emit(
        state.copyWith(
          isActionLoading: false,
          actionError: result.exception?.toString(),
        ),
      );
      return false;
    }
    emit(state.copyWith(isActionLoading: false));
    return false;
  }

  Future<bool> removeStudent({
    required String programId,
    required String studentId,
  }) async {
    emit(state.copyWith(isActionLoading: true, clearActionMessages: true));

    final result = await _removeStudent(
      programId: programId,
      studentId: studentId,
    );

    if (result is Success<void>) {
      emit(
        state.copyWith(
          isActionLoading: false,
          actionSuccessMessage: 'student_removed',
        ),
      );
      return true;
    } else if (result is Error<void>) {
      emit(
        state.copyWith(
          isActionLoading: false,
          actionError: result.exception?.toString(),
        ),
      );
      return false;
    }
    emit(state.copyWith(isActionLoading: false));
    return false;
  }

  Future<int> importStudentsFromCsv({
    required String programId,
    required List<CsvStudentEntry> students,
  }) async {
    emit(state.copyWith(isActionLoading: true, clearActionMessages: true));

    final result = await _importCsv(
      programId: programId,
      students: students,
    );

    if (result is Success<int>) {
      final count = result.data ?? 0;
      emit(
        state.copyWith(
          isActionLoading: false,
          actionSuccessMessage: 'imported_$count',
        ),
      );
      return count;
    } else if (result is Error<int>) {
      emit(
        state.copyWith(
          isActionLoading: false,
          actionError: result.exception?.toString(),
        ),
      );
      return 0;
    }
    emit(state.copyWith(isActionLoading: false));
    return 0;
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
