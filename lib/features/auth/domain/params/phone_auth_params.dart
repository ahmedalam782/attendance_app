import 'package:equatable/equatable.dart';

import '../models/auth_user.dart';

class PhoneAuthParams extends Equatable {
  const PhoneAuthParams({
    required this.phoneNumber,
    this.name,
  });

  /// E.164 format, e.g. +201012345678
  final String phoneNumber;
  final String? name;

  @override
  List<Object?> get props => [phoneNumber, name];
}

class PhoneOtpParams extends Equatable {
  const PhoneOtpParams({
    required this.verificationId,
    required this.smsCode,
    this.name,
  });

  final String verificationId;
  final String smsCode;
  final String? name;

  @override
  List<Object?> get props => [verificationId, smsCode, name];
}

/// Result of [AuthRemoteDataSource.sendPhoneOtp].
sealed class PhoneOtpDispatch extends Equatable {
  const PhoneOtpDispatch();
}

class PhoneOtpSent extends PhoneOtpDispatch {
  const PhoneOtpSent(this.verificationId);

  final String verificationId;

  @override
  List<Object?> get props => [verificationId];
}

class PhoneOtpAutoVerified extends PhoneOtpDispatch {
  const PhoneOtpAutoVerified(this.user);

  final AuthUser user;

  @override
  List<Object?> get props => [user];
}
