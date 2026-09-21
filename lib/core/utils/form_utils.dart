import 'package:flutter/material.dart';

/// Shared form helpers used by auth and other feature screens.
abstract final class FormUtils {
  /// Validates [formKey] and unfocuses the keyboard when valid.
  /// Returns `true` only when the form is valid.
  static bool validateAndUnfocus(
    GlobalKey<FormState> formKey,
    BuildContext context,
  ) {
    if (!(formKey.currentState?.validate() ?? false)) return false;
    FocusScope.of(context).unfocus();
    return true;
  }
}
