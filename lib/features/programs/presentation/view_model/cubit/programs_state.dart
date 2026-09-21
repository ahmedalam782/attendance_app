import '../../../../../core/api/base_state/base_state.dart';
import '../../../domain/entities/program.dart';

class ProgramsState {
  const ProgramsState({
    this.programs = const [],
    this.createProgramState = const BaseState<Program>(state: StatusState.initial),
    this.joinProgramState = const BaseState<Program>(state: StatusState.initial),
  });

  final List<Program> programs;
  final BaseState<Program> createProgramState;
  final BaseState<Program> joinProgramState;

  bool get isBusy =>
      createProgramState.state == StatusState.loading ||
      joinProgramState.state == StatusState.loading;

  ProgramsState copyWith({
    List<Program>? programs,
    BaseState<Program>? createProgramState,
    BaseState<Program>? joinProgramState,
  }) =>
      ProgramsState(
        programs: programs ?? this.programs,
        createProgramState: createProgramState ?? this.createProgramState,
        joinProgramState: joinProgramState ?? this.joinProgramState,
      );
}
