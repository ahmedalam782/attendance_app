import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'base_response/result.dart';
import 'errors/failure.dart';

/// Firebase equivalent of Al Faris [executeApi] for Dio.
Future<Result<T>> executeFirebase<T>(Future<T> Function() call) async {
  try {
    final result = await call();
    return Success<T>(data: result);
  } on FirebaseAuthException catch (ex, stackTrace) {
    if (kDebugMode) {
      log('FirebaseAuthException caught: $ex', stackTrace: stackTrace);
    }
    return Error<T>(
      exception: AuthFailure.fromFirebaseException(ex),
    );
  } on FirebaseException catch (ex, stackTrace) {
    if (kDebugMode) {
      log('FirebaseException caught: $ex', stackTrace: stackTrace);
    }
    return Error<T>(
      exception: AuthFailure(
        code: ex.code,
        errorMessage: ex.message?.trim().isNotEmpty == true
            ? ex.message!
            : ex.code,
      ),
    );
  } on Exception catch (ex, stackTrace) {
    if (kDebugMode) {
      log('Unexpected Firebase error: $ex', stackTrace: stackTrace);
    }
    return Error<T>(exception: ex);
  }
}
