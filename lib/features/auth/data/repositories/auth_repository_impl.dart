import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/api/base_response/result.dart';
import '../../../../core/api/execute_firebase.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/models/auth_user.dart';
import '../../domain/params/login_params.dart';
import '../../domain/params/phone_auth_params.dart';
import '../../domain/params/register_params.dart';
import '../datasources/auth_remote_data_source.dart';
import '../datasources/user_profile_remote_data_source.dart';

@Injectable(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._profiles);

  final AuthRemoteDataSource _remote;
  final UserProfileRemoteDataSource _profiles;

  @override
  Stream<AuthUser?> get users => _remote.users;

  @override
  Future<Result<AuthUser>> login(LoginParams params) => executeFirebase(() async {
    final user = await _remote.login(params);
    await _syncProfileSafely(() => _profiles.syncProfile(user));
    return user;
  });

  @override
  Future<Result<AuthUser>> register(RegisterParams params) =>
      executeFirebase(() async {
        final user = await _remote.register(params);
        await _syncProfileSafely(() => _profiles.createProfile(user));
        return user;
      });

  @override
  Future<Result<PhoneOtpDispatch>> sendPhoneOtp(PhoneAuthParams params) =>
      executeFirebase(() async {
        final dispatch = await _remote.sendPhoneOtp(params);
        if (dispatch is PhoneOtpAutoVerified) {
          await _syncProfileSafely(() => _profiles.syncProfile(dispatch.user));
        }
        return dispatch;
      });

  @override
  Future<Result<AuthUser>> verifyPhoneOtp(PhoneOtpParams params) =>
      executeFirebase(() async {
        final user = await _remote.verifyPhoneOtp(params);
        await _syncProfileSafely(() => _profiles.syncProfile(user));
        return user;
      });

  @override
  Future<Result<void>> logout() => executeFirebase(_remote.logout);

  @override
  Future<Result<void>> sendPasswordResetEmail(String email, {String? languageCode}) =>
      executeFirebase(
        () => _remote.sendPasswordResetEmail(email, languageCode: languageCode),
      );

  @override
  Future<Result<AuthUser?>> getCurrentUser() =>
      executeFirebase(_remote.getCurrentUser);

  @override
  Future<Result<AuthUser>> redeemInstructorCode(String code) =>
      executeFirebase(() => _remote.redeemInstructorCode(code));

  /// Auth must succeed even if Firestore profile sync fails (channel/network).
  Future<void> _syncProfileSafely(Future<void> Function() sync) async {
    try {
      await sync();
    } catch (error, stackTrace) {
      if (kDebugMode) {
        log(
          'Profile sync skipped after auth success: $error',
          stackTrace: stackTrace,
        );
      }
    }
  }
}
