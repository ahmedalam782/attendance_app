import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../../../../core/api/base_state/base_cubit.dart';
import '../../../../../core/api/base_state/base_state.dart';
import '../../../domain/entities/program.dart';
import '../../../domain/params/create_program_params.dart';
import '../../../domain/params/join_program_params.dart';
import '../../../domain/use_cases/create_program_use_case.dart';
import '../../../domain/use_cases/get_admin_programs_use_case.dart';
import '../../../domain/use_cases/get_student_programs_use_case.dart';
import '../../../domain/use_cases/join_program_by_code_use_case.dart';
import 'programs_state.dart';

@injectable
class ProgramsCubit extends BaseCubit<ProgramsState> {
  ProgramsCubit(
    this._getAdminPrograms,
    this._getStudentPrograms,
    this._createProgram,
    this._joinProgramByCode,
  ) : super(const ProgramsState());

  final GetAdminProgramsUseCase _getAdminPrograms;
  final GetStudentProgramsUseCase _getStudentPrograms;
  final CreateProgramUseCase _createProgram;
  final JoinProgramByCodeUseCase _joinProgramByCode;

  StreamSubscription<List<Program>>? _subscription;

  void watchAdminPrograms(String adminUid) {
    _subscription?.cancel();
    _subscription = _getAdminPrograms(adminUid).listen(
      (list) => emit(state.copyWith(programs: list)),
      onError: (_) {
        if (!isClosed) emit(state.copyWith(programs: const []));
      },
    );
  }

  void watchStudentPrograms(String studentUid) {
    _subscription?.cancel();
    _subscription = _getStudentPrograms(studentUid).listen(
      (list) => emit(state.copyWith(programs: list)),
      onError: (_) {
        if (!isClosed) emit(state.copyWith(programs: const []));
      },
    );
  }

  Future<bool> createProgram(CreateProgramParams params) async {
    if (state.isBusy) return false;
    var success = false;
    await emitFromResult<Program>(
      call: () => _createProgram(params),
      onUpdate: (next) {
        if (next.state == StatusState.success) success = true;
        emit(state.copyWith(createProgramState: next));
      },
    );
    return success;
  }

  Future<bool> joinProgram(JoinProgramParams params) async {
    if (state.isBusy) return false;
    var success = false;
    await emitFromResult<Program>(
      call: () => _joinProgramByCode(params),
      onUpdate: (next) {
        if (next.state == StatusState.success) success = true;
        emit(state.copyWith(joinProgramState: next));
      },
    );
    return success;
  }

  void resetCreateState() {
    emit(
      state.copyWith(
        createProgramState: const BaseState<Program>(state: StatusState.initial),
      ),
    );
  }

  void resetJoinState() {
    emit(
      state.copyWith(
        joinProgramState: const BaseState<Program>(state: StatusState.initial),
      ),
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
