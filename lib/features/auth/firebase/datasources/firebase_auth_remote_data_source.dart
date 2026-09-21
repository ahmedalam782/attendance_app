import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

import '../../data/datasources/auth_remote_data_source.dart';
import '../../domain/models/auth_user.dart';
import '../../domain/params/login_params.dart';
import '../../domain/params/phone_auth_params.dart';
import '../../domain/params/register_params.dart';

@Injectable(as: AuthRemoteDataSource)
class FirebaseAuthRemoteDataSource implements AuthRemoteDataSource {
  FirebaseAuthRemoteDataSource(this._auth);

  final FirebaseAuth _auth;

  Future<String> _resolveRole(User user) async {
    try {
      final tokenResult = await user.getIdTokenResult();
      final claimRole = tokenResult.claims?['role'] as String?;
      if (claimRole != null && claimRole.isNotEmpty) {
        return claimRole;
      }
    } catch (_) {}
    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final role = doc.data()?['role'] as String?;
        if (role != null && role.isNotEmpty) return role;
      }
    } catch (_) {}
    return 'student';
  }

  Future<AuthUser> _mapUserWithRole(
    User user, {
    String? fallbackName,
  }) async {
    final role = await _resolveRole(user);
    final phone = user.phoneNumber;
    final name = user.displayName?.trim().isNotEmpty == true
        ? user.displayName
        : (fallbackName?.trim().isNotEmpty == true ? fallbackName!.trim() : null);
    return AuthUser(
      id: user.uid,
      email: user.email ?? '',
      name: name,
      phoneNumber: phone,
      role: role,
    );
  }

  @override
  Stream<AuthUser?> get users => _auth.userChanges().asyncMap(
        (user) => user == null ? null : _mapUserWithRole(user),
      );

  @override
  Future<AuthUser> login(LoginParams params) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: params.email.trim(),
      password: params.password,
    );
    return _mapUserWithRole(credential.user!);
  }

  @override
  Future<AuthUser> register(RegisterParams params) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: params.email.trim(),
      password: params.password,
    );
    try {
      await credential.user!.updateDisplayName(params.name.trim());
    } on FirebaseAuthException {
      // Account is usable even if display name update fails.
    }
    final user = _auth.currentUser ?? credential.user!;
    return _mapUserWithRole(user, fallbackName: params.name);
  }

  @override
  Future<PhoneOtpDispatch> sendPhoneOtp(PhoneAuthParams params) async {
    final completer = Completer<PhoneOtpDispatch>();
    final phone = params.phoneNumber.trim();

    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        if (completer.isCompleted) return;
        try {
          final result = await _auth.signInWithCredential(credential);
          final user = result.user;
          if (user == null) {
            completer.completeError(
              FirebaseAuthException(
                code: 'null-user',
                message: 'Phone auto-verification returned no user.',
              ),
            );
            return;
          }
          if (params.name?.trim().isNotEmpty == true &&
              (user.displayName == null || user.displayName!.trim().isEmpty)) {
            try {
              await user.updateDisplayName(params.name!.trim());
            } on FirebaseAuthException {
              // Profile sync can still use fallback name.
            }
          }
          final mapped = await _mapUserWithRole(
            _auth.currentUser ?? user,
            fallbackName: params.name,
          );
          if (!completer.isCompleted) {
            completer.complete(PhoneOtpAutoVerified(mapped));
          }
        } catch (error) {
          if (!completer.isCompleted) completer.completeError(error);
        }
      },
      verificationFailed: (FirebaseAuthException error) {
        if (!completer.isCompleted) completer.completeError(error);
      },
      codeSent: (String verificationId, int? _) {
        if (!completer.isCompleted) {
          completer.complete(PhoneOtpSent(verificationId));
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        if (!completer.isCompleted) {
          completer.complete(PhoneOtpSent(verificationId));
        }
      },
    );

    return completer.future;
  }

  @override
  Future<AuthUser> verifyPhoneOtp(PhoneOtpParams params) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: params.verificationId,
      smsCode: params.smsCode.trim(),
    );
    final result = await _auth.signInWithCredential(credential);
    final user = result.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'null-user',
        message: 'Phone sign-in returned no user.',
      );
    }
    if (params.name?.trim().isNotEmpty == true &&
        (user.displayName == null || user.displayName!.trim().isEmpty)) {
      try {
        await user.updateDisplayName(params.name!.trim());
      } on FirebaseAuthException {
        // Profile sync can still use fallback name.
      }
    }
    return _mapUserWithRole(
      _auth.currentUser ?? user,
      fallbackName: params.name,
    );
  }

  @override
  Future<AuthUser?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _mapUserWithRole(user);
  }

  @override
  Future<void> logout() => _auth.signOut();

  @override
  Future<void> sendPasswordResetEmail(String email, {String? languageCode}) async {
    if (languageCode != null && languageCode.isNotEmpty) {
      await _auth.setLanguageCode(languageCode);
    }
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  @override
  Future<AuthUser> redeemInstructorCode(String code) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No user signed in to redeem code',
      );
    }

    final normalizedCode = code.trim().toUpperCase();
    final inviteRef = FirebaseFirestore.instance
        .collection('instructorInvites')
        .doc(normalizedCode);
    final inviteDoc = await inviteRef.get();

    if (inviteDoc.exists) {
      final data = inviteDoc.data() ?? {};
      final isUsed = data['used'] == true;
      if (isUsed) {
        throw FirebaseException(
          plugin: 'cloud_firestore',
          code: 'already-exists',
          message: 'Instructor invite code has already been redeemed',
        );
      }
      await inviteRef.update({
        'used': true,
        'usedBy': user.uid,
        'redeemedAt': FieldValue.serverTimestamp(),
      });
    }

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
      {
        'role': 'admin',
        'email': user.email ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    try {
      await user.getIdToken(true);
    } catch (_) {}

    return AuthUser(
      id: user.uid,
      email: user.email ?? '',
      name: user.displayName,
      phoneNumber: user.phoneNumber,
      role: 'admin',
    );
  }
}
