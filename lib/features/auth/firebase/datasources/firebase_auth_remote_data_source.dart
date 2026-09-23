import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

import '../../data/datasources/auth_remote_data_source.dart';
import '../../domain/models/auth_user.dart';
import '../../domain/params/login_params.dart';
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
    String? fallbackPhone,
  }) async {
    final role = await _resolveRole(user);
    final phone = (user.phoneNumber?.trim().isNotEmpty == true)
        ? user.phoneNumber
        : (fallbackPhone?.trim().isNotEmpty == true ? fallbackPhone!.trim() : null);
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
    return _mapUserWithRole(
      user,
      fallbackName: params.name,
      fallbackPhone: params.phone.trim().isNotEmpty ? params.phone.trim() : null,
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
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final currentRole = userDoc.data()?['role'] as String?;
    if (currentRole == 'instructor') {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'already-instructor',
        message: 'Your account is already activated as an instructor',
      );
    }

    final inviteDoc = await inviteRef.get();
    if (!inviteDoc.exists) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'invalid-invite-code',
        message: 'Invalid or non-existent instructor invite code',
      );
    }

    final data = inviteDoc.data() ?? {};
    final isUsed = data['used'] == true;
    if (isUsed) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'code-already-used',
        message: 'Instructor invite code has already been redeemed',
      );
    }

    String displayName = user.displayName ?? '';
    if (displayName.trim().isEmpty) {
      try {
        final uDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        displayName = (uDoc.data()?['name'] ?? uDoc.data()?['displayName'] ?? '') as String;
      } catch (_) {}
    }

    await inviteRef.update({
      'used': true,
      'usedBy': user.uid,
      'usedByName': displayName,
      'usedByEmail': user.email ?? '',
      'redeemedAt': FieldValue.serverTimestamp(),
    });

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
      {
        'role': 'instructor',
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
      role: 'instructor',
    );
  }
}
