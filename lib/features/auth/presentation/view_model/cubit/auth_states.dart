import 'package:equatable/equatable.dart';

import '../../../../../core/api/base_state/base_state.dart';
import '../../../../../core/api/errors/failure.dart';
import '../../../domain/models/auth_user.dart';
import '../../../domain/params/phone_auth_params.dart';

class AuthStates extends Equatable {
  const AuthStates({
    this.authState = const BaseState<AuthUser>(state: StatusState.initial),
    this.logoutState = const BaseState<void>(state: StatusState.initial),
    this.forgotPasswordState = const BaseState<void>(state: StatusState.initial),
    this.phoneOtpState =
        const BaseState<PhoneOtpDispatch>(state: StatusState.initial),
  });

  final BaseState<AuthUser> authState;
  final BaseState<void> logoutState;
  final BaseState<void> forgotPasswordState;
  final BaseState<PhoneOtpDispatch> phoneOtpState;

  bool get busy =>
      authState.state == StatusState.loading ||
      logoutState.state == StatusState.loading ||
      forgotPasswordState.state == StatusState.loading ||
      phoneOtpState.state == StatusState.loading;

  bool get loggedOut => logoutState.state == StatusState.success;

  bool get passwordResetSent =>
      forgotPasswordState.state == StatusState.success;

  String? get phoneVerificationId {
    final data = phoneOtpState.data;
    if (data is PhoneOtpSent) return data.verificationId;
    return null;
  }

  bool get phoneOtpReady =>
      phoneOtpState.state == StatusState.success && phoneVerificationId != null;

  String? get error {
    final exception = authState.state == StatusState.failure
        ? authState.exception
        : logoutState.state == StatusState.failure
            ? logoutState.exception
            : forgotPasswordState.state == StatusState.failure
                ? forgotPasswordState.exception
                : phoneOtpState.state == StatusState.failure
                    ? phoneOtpState.exception
                    : null;
    if (exception == null) return null;
    if (exception is AuthFailure) return exception.code;
    return 'unknown';
  }

  AuthStates copyWith({
    BaseState<AuthUser>? authState,
    BaseState<void>? logoutState,
    BaseState<void>? forgotPasswordState,
    BaseState<PhoneOtpDispatch>? phoneOtpState,
  }) {
    return AuthStates(
      authState: authState ?? this.authState,
      logoutState: logoutState ?? this.logoutState,
      forgotPasswordState: forgotPasswordState ?? this.forgotPasswordState,
      phoneOtpState: phoneOtpState ?? this.phoneOtpState,
    );
  }

  @override
  List<Object?> get props =>
      [authState, logoutState, forgotPasswordState, phoneOtpState];
}
