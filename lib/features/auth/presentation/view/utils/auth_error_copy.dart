import 'package:easy_localization/easy_localization.dart';

import '../../../../../core/languages/locale_keys.g.dart';

/// Maps Firebase Auth error codes to localized UI copy.
abstract final class AuthErrorCopy {
  static String message(String code) => switch (code) {
    'invalid-email' => LocaleKeys.validations_email_invalid.tr(),
    'email-already-in-use' => LocaleKeys.auth_errors_email_already_in_use.tr(),
    'weak-password' => LocaleKeys.auth_errors_weak_password.tr(),
    'invalid-credential' ||
    'wrong-password' => LocaleKeys.auth_errors_invalid_credential.tr(),
    'user-not-found' => LocaleKeys.auth_errors_user_not_found.tr(),
    'network-request-failed' =>
      LocaleKeys.auth_errors_network_request_failed.tr(),
    'too-many-requests' => LocaleKeys.auth_errors_too_many_requests.tr(),
    'operation-not-allowed' =>
      LocaleKeys.auth_errors_operation_not_allowed.tr(),
    'user-disabled' => LocaleKeys.auth_errors_user_disabled.tr(),
    'invalid-phone-number' => LocaleKeys.auth_errors_invalid_phone_number.tr(),
    'invalid-verification-code' =>
      LocaleKeys.auth_errors_invalid_verification_code.tr(),
    'invalid-verification-id' =>
      LocaleKeys.auth_errors_invalid_verification_id.tr(),
    'session-expired' => LocaleKeys.auth_errors_session_expired.tr(),
    'quota-exceeded' => LocaleKeys.auth_errors_quota_exceeded.tr(),
    'missing_client_identifier' =>
      LocaleKeys.auth_errors_missing_client_identifier.tr(),
    'code-already-used' ||
    'already-exists' =>
      LocaleKeys.auth_errors_code_already_used.tr(),
    'invalid-invite-code' ||
    'not-found' =>
      LocaleKeys.auth_errors_invalid_invite_code.tr(),
    'already-instructor' =>
      LocaleKeys.auth_errors_already_instructor.tr(),
    _ => LocaleKeys.auth_errors_unknown.tr(),
  };
}
