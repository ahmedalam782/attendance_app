import 'package:injectable/injectable.dart';

import '../../../../../core/api/base_state/base_cubit.dart';
import '../../../../../core/api/base_state/base_state.dart';
import '../../../../../core/helper/logout_session.dart';
import '../../../domain/models/auth_user.dart';
import '../../../domain/params/login_params.dart';
import '../../../domain/params/register_params.dart';
import '../../../domain/use_cases/login_use_case.dart';
import '../../../domain/use_cases/register_use_case.dart';
import 'auth_states.dart';

@injectable
class AuthCubit extends BaseCubit<AuthStates> {
  AuthCubit(this._loginUseCase, this._registerUseCase, this._logoutSession)
    : super(const AuthStates());

  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutSession _logoutSession;

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

  void clearError() {
    if (state.busy) return;
    emit(const AuthStates());
  }
}
