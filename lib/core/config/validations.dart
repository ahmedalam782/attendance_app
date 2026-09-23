import 'package:easy_localization/easy_localization.dart';

import '../languages/locale_keys.g.dart';

/// Auth validations adapted from Al Faris.
abstract final class Validations {
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return LocaleKeys.validations_name_required.tr();
    }
    return null;
  }

  static String? validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return LocaleKeys.validations_email_required.tr();
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      return LocaleKeys.validations_email_invalid.tr();
    }
    return null;
  }

  static String? validateLoginPassword(String? value) {
    if (value == null || value.isEmpty) {
      return LocaleKeys.validations_password_required.tr();
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return LocaleKeys.validations_password_required.tr();
    }
    if (value.length < 6) return LocaleKeys.validations_password_short.tr();
    return null;
  }

  static String? validatePasswordVerification(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return LocaleKeys.validations_confirm_password_required.tr();
    }
    if (value != password) {
      return LocaleKeys.validations_confirm_password_mismatch.tr();
    }
    return null;
  }

  /// Simple E.164 phone validator for registration.
  static String? validateSimplePhone(String? value) {
    final phone = value?.trim() ?? '';
    if (phone.isEmpty) return LocaleKeys.validations_phone_required.tr();
    if (!phone.startsWith('+') || phone.length < 7) {
      return LocaleKeys.validations_phone_invalid.tr();
    }
    return null;
  }

  /// Al Faris phone local-number validation (country code separate).
  static String? validatePhoneNumber(
    String? value,
    int? phoneLength,
    String countryCode,
  ) {
    if (value == null || value.trim().isEmpty) {
      return LocaleKeys.validations_phone_required.tr();
    }

    final cleanValue = value.trim();

    if (cleanValue.startsWith('0')) {
      return LocaleKeys.validations_phone_invalid_start.tr();
    }

    if (countryCode == '964' && !cleanValue.startsWith('7')) {
      return LocaleKeys.validations_phone_invalid_start_7.tr();
    }

    if (phoneLength != null && cleanValue.length != phoneLength) {
      return LocaleKeys.validations_phone_length_error.tr(
        args: [phoneLength.toString()],
      );
    }

    return null;
  }

  static String? validateOtp(String? value) {
    final code = value?.trim() ?? '';
    if (code.isEmpty) return LocaleKeys.validations_otp_required.tr();
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      return LocaleKeys.validations_otp_invalid.tr();
    }
    return null;
  }
}
