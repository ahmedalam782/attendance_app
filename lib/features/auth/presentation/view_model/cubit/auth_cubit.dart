import 'package:injectable/injectable.dart';

import '../../../../../core/api/base_response/result.dart';
import '../../../../../core/api/base_state/base_cubit.dart';
import '../../../../../core/api/base_state/base_state.dart';
import '../../../../../core/dependency_injection/injectable_config.dart';
import '../../../../../core/helper/logout_session.dart';
import '../../../domain/models/auth_user.dart';
import '../../../domain/params/login_params.dart';
import '../../../domain/params/register_params.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/use_cases/forgot_password_use_case.dart';
import '../../../domain/use_cases/get_current_user_use_case.dart';
import '../../../domain/use_cases/login_use_case.dart';
import '../../../domain/use_cases/redeem_instructor_code_use_case.dart';
import '../../../domain/use_cases/register_use_case.dart';
import 'auth_states.dart';

@injectable
class AuthCubit extends BaseCubit<AuthStates> {
  AuthCubit(
    this._loginUseCase,
    this._registerUseCase,
    this._logoutSession, [
    ForgotPasswordUseCase? forgotPasswordUseCase,
    GetCurrentUserUseCase? getCurrentUserUseCase,
    RedeemInstructorCodeUseCase? redeemInstructorCodeUseCase,
  ])  : _forgotPasswordUseCase = forgotPasswordUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _redeemInstructorCodeUseCase = redeemInstructorCodeUseCase,
        super(const AuthStates());

  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutSession _logoutSession;
  final ForgotPasswordUseCase? _forgotPasswordUseCase;
  final GetCurrentUserUseCase? _getCurrentUserUseCase;
  final RedeemInstructorCodeUseCase? _redeemInstructorCodeUseCase;

  ForgotPasswordUseCase _resolveForgotPasswordUseCase() {
    final useCase = _forgotPasswordUseCase;
    if (useCase != null) return useCase;
    if (getIt.isRegistered<ForgotPasswordUseCase>()) {
      return getIt<ForgotPasswordUseCase>();
    }
    if (getIt.isRegistered<AuthRepository>()) {
      return ForgotPasswordUseCase(getIt<AuthRepository>());
    }
    throw StateError('No AuthRepository or ForgotPasswordUseCase registered in GetIt.');
  }

  GetCurrentUserUseCase _resolveGetCurrentUserUseCase() {
    final useCase = _getCurrentUserUseCase;
    if (useCase != null) return useCase;
    if (getIt.isRegistered<GetCurrentUserUseCase>()) {
      return getIt<GetCurrentUserUseCase>();
    }
    if (getIt.isRegistered<AuthRepository>()) {
      return GetCurrentUserUseCase(getIt<AuthRepository>());
    }
    throw StateError('No AuthRepository or GetCurrentUserUseCase registered in GetIt.');
  }

  RedeemInstructorCodeUseCase _resolveRedeemInstructorCodeUseCase() {
    final useCase = _redeemInstructorCodeUseCase;
    if (useCase != null) return useCase;
    if (getIt.isRegistered<RedeemInstructorCodeUseCase>()) {
      return getIt<RedeemInstructorCodeUseCase>();
    }
    if (getIt.isRegistered<AuthRepository>()) {
      return RedeemInstructorCodeUseCase(getIt<AuthRepository>());
    }
    throw StateError('No AuthRepository or RedeemInstructorCodeUseCase registered in GetIt.');
  }

  Future<AuthUser?> checkSession() async {
    try {
      final useCase = _resolveGetCurrentUserUseCase();
      final result = await useCase();
      if (result is Success<AuthUser?> && result.data != null) {
        emit(
          state.copyWith(
            authState: BaseState<AuthUser>(
              state: StatusState.success,
              data: result.data,
            ),
          ),
        );
        return result.data;
      }
    } catch (_) {}
    return null;
  }

  Future<void> login(LoginParams params) async {
    if (state.busy) return;
    await emitFromResult<AuthUser>(
      call: () => _loginUseCase(params),
      onUpdate: (next) => emit(
        state.copyWith(
          authState: next,
          logoutState: const BaseState<void>(state: StatusState.initial),
        ),
      ),
    );
  }

  Future<void> register(RegisterParams params) async {
    if (state.busy) return;
    await emitFromResult<AuthUser>(
      call: () => _registerUseCase(params),
      onUpdate: (next) => emit(
        state.copyWith(
          authState: next,
          logoutState: const BaseState<void>(state: StatusState.initial),
        ),
      ),
    );
  }

  Future<void> logout() async {
    if (state.busy) return;
    await emitFromResult<void>(
      call: _logoutSession.logout,
      onUpdate: (next) => emit(
        state.copyWith(
          logoutState: next,
          authState: const BaseState<AuthUser>(state: StatusState.initial),
        ),
      ),
    );
  }

  Future<void> sendPasswordResetEmail(String email, {String? languageCode}) async {
    if (state.busy) return;
    final useCase = _resolveForgotPasswordUseCase();
    await emitFromResult<void>(
      call: () => useCase(email, languageCode: languageCode),
      onUpdate: (next) => emit(
        state.copyWith(
          forgotPasswordState: next,
        ),
      ),
    );
  }

  void resetForgotPasswordState() {
    emit(
      state.copyWith(
        forgotPasswordState:
            const BaseState<void>(state: StatusState.initial),
      ),
    );
  }

  void clearError() {
    if (state.busy) return;
    emit(const AuthStates());
  }

  Future<bool> redeemInstructorCode(String code) async {
    if (state.busy) return false;
    final useCase = _resolveRedeemInstructorCodeUseCase();
    var success = false;
    await emitFromResult<AuthUser>(
      call: () => useCase(code),
      onUpdate: (next) {
        if (next.state == StatusState.success) {
          success = true;
        }
        emit(state.copyWith(authState: next));
      },
    );
    return success;
  }
}
