import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env', requireEnvFile: true)
abstract class Env {
  @EnviedField(varName: 'FIREBASE_PROJECT_ID')
  static const String firebaseProjectId = _Env.firebaseProjectId;

  @EnviedField(varName: 'FIREBASE_MESSAGING_SENDER_ID')
  static const String firebaseMessagingSenderId =
      _Env.firebaseMessagingSenderId;

  @EnviedField(varName: 'FIREBASE_STORAGE_BUCKET')
  static const String firebaseStorageBucket = _Env.firebaseStorageBucket;

  @EnviedField(varName: 'FIREBASE_ANDROID_API_KEY', obfuscate: true)
  static final String firebaseAndroidApiKey = _Env.firebaseAndroidApiKey;

  @EnviedField(varName: 'FIREBASE_ANDROID_APP_ID', obfuscate: true)
  static final String firebaseAndroidAppId = _Env.firebaseAndroidAppId;

  @EnviedField(varName: 'FIREBASE_IOS_API_KEY', obfuscate: true)
  static final String firebaseIosApiKey = _Env.firebaseIosApiKey;

  @EnviedField(varName: 'FIREBASE_IOS_APP_ID', obfuscate: true)
  static final String firebaseIosAppId = _Env.firebaseIosAppId;

  @EnviedField(varName: 'FIREBASE_IOS_BUNDLE_ID')
  static const String firebaseIosBundleId = _Env.firebaseIosBundleId;

  @EnviedField(varName: 'FIREBASE_WEB_API_KEY', obfuscate: true)
  static final String firebaseWebApiKey = _Env.firebaseWebApiKey;

  @EnviedField(varName: 'FIREBASE_WEB_APP_ID', obfuscate: true)
  static final String firebaseWebAppId = _Env.firebaseWebAppId;

  @EnviedField(varName: 'FIREBASE_WEB_AUTH_DOMAIN')
  static const String firebaseWebAuthDomain = _Env.firebaseWebAuthDomain;

  @EnviedField(varName: 'FIREBASE_WEB_MEASUREMENT_ID')
  static const String firebaseWebMeasurementId = _Env.firebaseWebMeasurementId;
}
