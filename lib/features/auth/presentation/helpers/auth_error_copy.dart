import 'package:easy_localization/easy_localization.dart';

import '../../../../core/languages/locale_keys.g.dart';

/// Maps Firebase Auth error codes to localized UI copy.
abstract final class AuthErrorCopy {
  static String message(String code) => switch (code) {
    'invalid-email' => LocaleKeys.validations_email_invalid.tr(),
    'email-already-in-use' => LocaleKeys.auth_errors_email_already_in_use.tr(),
    'weak-password' => LocaleKeys.auth_errors_weak_password.tr(),
    'invalid-credential' ||
    'wrong-password' ||
    'user-not-found' => LocaleKeys.auth_errors_invalid_credential.tr(),
    'network-request-failed' =>
      LocaleKeys.auth_errors_network_request_failed.tr(),
    'too-many-requests' => LocaleKeys.auth_errors_too_many_requests.tr(),
    'operation-not-allowed' =>
      LocaleKeys.auth_errors_operation_not_allowed.tr(),
    'user-disabled' => LocaleKeys.auth_errors_user_disabled.tr(),
    _ => LocaleKeys.auth_errors_unknown.tr(),
  };
}
