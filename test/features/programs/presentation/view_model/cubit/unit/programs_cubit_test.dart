import 'dart:async';

import 'package:attendance_app/core/api/base_response/result.dart';
import 'package:attendance_app/core/api/base_state/base_state.dart';
import 'package:attendance_app/features/programs/domain/entities/program.dart';
import 'package:attendance_app/features/programs/domain/params/create_program_params.dart';
import 'package:attendance_app/features/programs/domain/params/join_program_params.dart';
import 'package:attendance_app/features/programs/domain/repositories/programs_repository.dart';
import 'package:attendance_app/features/programs/domain/use_cases/create_program_use_case.dart';
import 'package:attendance_app/features/programs/domain/use_cases/get_admin_programs_use_case.dart';
import 'package:attendance_app/features/programs/domain/use_cases/get_student_programs_use_case.dart';
import 'package:attendance_app/features/programs/domain/use_cases/join_program_by_code_use_case.dart';
import 'package:attendance_app/features/programs/presentation/view_model/cubit/programs_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeProgramsRepository implements ProgramsRepository {
  final _adminController = StreamController<List<Program>>.broadcast();
  final _studentController = StreamController<List<Program>>.broadcast();

  final List<Program> adminPrograms = [];
  final List<Program> studentPrograms = [];

  @override
  Stream<List<Program>> watchAdminPrograms(String adminUid) =>
      _adminController.stream;

  @override
  Stream<List<Program>> watchStudentPrograms(String studentUid) =>
      _studentController.stream;

  void emitAdmin(List<Program> list) => _adminController.add(list);
  void emitStudent(List<Program> list) => _studentController.add(list);

  @override
  Future<Result<Program>> createProgram(CreateProgramParams params) async {
    final program = Program(
      id: 'p1',
      title: params.title,
      type: params.type,
      ownerId: params.ownerId,
      inviteCode: 'TEST12',
    );
    return Success(data: program);
  }

  @override
  Future<Result<Program>> joinProgramByCode(JoinProgramParams params) async {
    final program = Program(
      id: 'p1',
      title: 'Joined Program',
      type: 'course',
      ownerId: 'admin1',
      inviteCode: params.inviteCode,
    );
    return Success(data: program);
  }

  @override
  Future<Result<Program>> getProgramById(String programId) async {
    return const Success(
      data: Program(
        id: 'p1',
        title: 'Program 1',
        type: 'course',
        ownerId: 'admin1',
        inviteCode: 'TEST12',
      ),
    );
  }

  void dispose() {
    _adminController.close();
    _studentController.close();
  }
}

void main() {
  late FakeProgramsRepository repository;
  late ProgramsCubit cubit;

  setUp(() {
    repository = FakeProgramsRepository();
    cubit = ProgramsCubit(
      GetAdminProgramsUseCase(repository),
      GetStudentProgramsUseCase(repository),
      CreateProgramUseCase(repository),
      JoinProgramByCodeUseCase(repository),
    );
  });

  tearDown(() async {
    await cubit.close();
    repository.dispose();
  });

  test('watchAdminPrograms emits programs to state', () async {
    cubit.watchAdminPrograms('admin_123');

    final testPrograms = [
      const Program(
        id: 'p1',
        title: 'Flutter Bootcamp',
        type: 'bootcamp',
        ownerId: 'admin_123',
        inviteCode: 'FLUT12',
      ),
    ];

    repository.emitAdmin(testPrograms);
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(cubit.state.programs.length, 1);
    expect(cubit.state.programs.first.title, 'Flutter Bootcamp');
  });

  test('createProgram calls use case and sets success state', () async {
    const params = CreateProgramParams(
      title: 'New Course',
      type: 'course',
      ownerId: 'admin_123',
      inviteCode: '',
    );

    final success = await cubit.createProgram(params);
    expect(success, isTrue);
    expect(cubit.state.createProgramState.state, StatusState.success);
    expect(cubit.state.createProgramState.data?.title, 'New Course');

    cubit.resetCreateState();
    expect(cubit.state.createProgramState.state, StatusState.initial);
  });

  test('joinProgram calls use case and sets success state', () async {
    const params = JoinProgramParams(
      inviteCode: 'TEST12',
      studentId: 'student_1',
      studentName: 'Alice',
    );

    final success = await cubit.joinProgram(params);
    expect(success, isTrue);
    expect(cubit.state.joinProgramState.state, StatusState.success);

    cubit.resetJoinState();
    expect(cubit.state.joinProgramState.state, StatusState.initial);
  });
}
