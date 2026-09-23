import 'dart:async';

import 'package:attendance_app/core/api/base_response/result.dart';
import 'package:attendance_app/core/api/errors/failure.dart';
import 'package:attendance_app/core/helper/logout_session.dart';
import 'package:attendance_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:attendance_app/features/auth/domain/models/auth_user.dart';
import 'package:attendance_app/features/auth/domain/params/login_params.dart';
import 'package:attendance_app/features/auth/domain/params/register_params.dart';
import 'package:attendance_app/features/auth/domain/use_cases/forgot_password_use_case.dart';
import 'package:attendance_app/features/auth/domain/use_cases/login_use_case.dart';
import 'package:attendance_app/features/auth/domain/use_cases/register_use_case.dart';
import 'package:attendance_app/features/auth/presentation/view_model/cubit/auth_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeAuthRepository implements AuthRepository {
  int loginCalls = 0;
  int logoutCalls = 0;
  final pendingLogin = Completer<Result<AuthUser>>();

  @override
  Stream<AuthUser?> get users => Stream.value(null);

  @override
  Future<Result<AuthUser>> login(LoginParams params) {
    loginCalls++;
    return pendingLogin.future;
  }

  @override
  Future<Result<AuthUser>> register(RegisterParams params) async =>
      Success(
        data: AuthUser(id: '1', email: params.email, name: params.name),
      );

  @override
  Future<Result<void>> logout() async {
    logoutCalls++;
    return const Success();
  }

  @override
  Future<Result<void>> sendPasswordResetEmail(String email, {String? languageCode}) async =>
      const Success();

  @override
  Future<Result<AuthUser?>> getCurrentUser() async => const Success(data: null);

  @override
  Future<Result<AuthUser>> redeemInstructorCode(String code) async =>
      const Success(
        data: AuthUser(id: '1', email: 'test@elevate.com', role: 'admin'),
      );
}

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  test(
    'prevents duplicate login requests and exposes Firebase errors',
    () async {
      final repository = FakeAuthRepository();
      final cubit = AuthCubit(
        LoginUseCase(repository),
        RegisterUseCase(repository),
        LogoutSession(prefs, repository),
      );
      final first = cubit.login(
        const LoginParams(email: 'student@example.com', password: 'secret'),
      );
      expect(cubit.state.busy, isTrue);
      await cubit.login(
        const LoginParams(email: 'student@example.com', password: 'secret'),
      );
      expect(repository.loginCalls, 1);
      repository.pendingLogin.complete(
        const Error(
          exception: AuthFailure(
            code: 'invalid-credential',
            errorMessage: 'invalid-credential',
          ),
        ),
      );
      await first;
      expect(cubit.state.busy, isFalse);
      expect(cubit.state.error, 'invalid-credential');
      cubit.clearError();
      expect(cubit.state.error, isNull);
      await cubit.close();
    },
  );

  test('registration and sign-out complete without a stale error', () async {
    final repository = FakeAuthRepository();
    final cubit = AuthCubit(
      LoginUseCase(repository),
      RegisterUseCase(repository),
      LogoutSession(prefs, repository),
    );
    await cubit.register(
      const RegisterParams(
        name: 'Student',
        phone: '+9647500000000',
        email: 'student@example.com',
        password: 'secret',
      ),
    );
    expect(cubit.state.busy, isFalse);
    expect(cubit.state.error, isNull);
    await cubit.logout();
    expect(repository.logoutCalls, 1);
    expect(cubit.state.loggedOut, isTrue);
    expect(cubit.state.error, isNull);
    await cubit.close();
  });

  test('sends password reset email successfully', () async {
    final repository = FakeAuthRepository();
    final cubit = AuthCubit(
      LoginUseCase(repository),
      RegisterUseCase(repository),
      LogoutSession(prefs, repository),
      ForgotPasswordUseCase(repository),
    );
    expect(cubit.state.passwordResetSent, isFalse);
    await cubit.sendPasswordResetEmail('student@example.com');
    expect(cubit.state.passwordResetSent, isTrue);
    expect(cubit.state.busy, isFalse);
    cubit.resetForgotPasswordState();
    expect(cubit.state.passwordResetSent, isFalse);
    await cubit.close();
  });
}
