import 'package:easy_localization/easy_localization.dart';

import '../languages/locale_keys.g.dart';

/// Auth validations adapted from Al Faris (email instead of phone).
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
}
