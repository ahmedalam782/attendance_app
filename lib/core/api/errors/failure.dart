import 'package:firebase_auth/firebase_auth.dart';

abstract class Failure implements Exception {
  const Failure({required this.errorMessage});

  final String errorMessage;

  @override
  String toString() => errorMessage;
}

/// Firebase Auth failure — mirrors [ServerFailure] for Dio in Al Faris.
class AuthFailure extends Failure {
  const AuthFailure({required this.code, required super.errorMessage});

  final String code;

  factory AuthFailure.fromFirebaseException(FirebaseAuthException exception) {
    return AuthFailure(
      code: exception.code,
      errorMessage: exception.message?.trim().isNotEmpty == true
          ? exception.message!
          : exception.code,
    );
  }
}
