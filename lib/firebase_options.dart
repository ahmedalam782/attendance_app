// Wired to Envied values from `.env` (Al Faris pattern).
// Reapply the Env references after running `flutterfire configure`.
// ignore_for_file: type=lint
import 'package:attendance_app/core/env/env.dart';
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static final FirebaseOptions web = FirebaseOptions(
    apiKey: Env.firebaseWebApiKey,
    appId: Env.firebaseWebAppId,
    messagingSenderId: Env.firebaseMessagingSenderId,
    projectId: Env.firebaseProjectId,
    authDomain: Env.firebaseWebAuthDomain,
    storageBucket: Env.firebaseStorageBucket,
    measurementId: Env.firebaseWebMeasurementId,
  );

  static final FirebaseOptions android = FirebaseOptions(
    apiKey: Env.firebaseAndroidApiKey,
    appId: Env.firebaseAndroidAppId,
    messagingSenderId: Env.firebaseMessagingSenderId,
    projectId: Env.firebaseProjectId,
    storageBucket: Env.firebaseStorageBucket,
  );

  static final FirebaseOptions ios = FirebaseOptions(
    apiKey: Env.firebaseIosApiKey,
    appId: Env.firebaseIosAppId,
    messagingSenderId: Env.firebaseMessagingSenderId,
    projectId: Env.firebaseProjectId,
    storageBucket: Env.firebaseStorageBucket,
    iosBundleId: Env.firebaseIosBundleId,
  );
}
