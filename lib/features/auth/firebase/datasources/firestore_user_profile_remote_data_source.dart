import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../data/datasources/user_profile_remote_data_source.dart';
import '../../domain/models/auth_user.dart';

@Injectable(as: UserProfileRemoteDataSource)
class FirestoreUserProfileRemoteDataSource
    implements UserProfileRemoteDataSource {
  FirestoreUserProfileRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  String _displayName(AuthUser user) {
    if (user.name?.trim().isNotEmpty == true) return user.name!.trim();
    final email = user.email.trim();
    final at = email.indexOf('@');
    return at > 0 ? email.substring(0, at) : email;
  }

  Future<void> _ensureAuthToken({bool forceRefresh = false}) async {
    await FirebaseAuth.instance.currentUser?.getIdToken(forceRefresh);
  }

  Map<String, dynamic> _createPayload(AuthUser user) {
    final now = FieldValue.serverTimestamp();
    return {
      'uid': user.id,
      'email': user.email.trim(),
      'name': _displayName(user),
      'createdAt': now,
      'updatedAt': now,
    };
  }

  Future<void> _withRetry(Future<void> Function() action) async {
    try {
      await action();
    } catch (error) {
      final message = error.toString();
      final isChannelError = message.contains('channel-error') ||
          message.contains('Unable to establish connection on channel');
      if (!isChannelError) rethrow;

      if (kDebugMode) {
        log('Firestore channel error, retrying once: $error');
      }
      await Future<void>.delayed(const Duration(milliseconds: 400));
      await _ensureAuthToken(forceRefresh: true);
      await action();
    }
  }

  @override
  Future<void> createProfile(AuthUser user) async {
    await _ensureAuthToken(forceRefresh: true);
    await _withRetry(() => _users.doc(user.id).set(_createPayload(user)));
  }

  @override
  Future<void> syncProfile(AuthUser user) async {
    await _ensureAuthToken();
    final doc = _users.doc(user.id);
    final name = _displayName(user);

    await _withRetry(() async {
      try {
        await doc.update({
          'name': name,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } on FirebaseException catch (error) {
        if (error.code == 'not-found') {
          await doc.set(_createPayload(user));
          return;
        }
        rethrow;
      }
    });
  }
}
