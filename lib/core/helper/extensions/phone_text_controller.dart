import 'package:flutter/material.dart';

import '../phone_helper/phone_length_helper.dart';

extension PhoneTextEditingControllerExtension on TextEditingController {
  static final Map<TextEditingController, String> _countryCodes = {};

  String get selectedCountryCode => _countryCodes[this] ?? '964';

  void updateSelectedCountryCode(String countryCode) {
    _countryCodes[this] = countryCode;
  }

  String get fullPhoneNumber => '+$selectedCountryCode$text';

  String get phoneNumberOnly => text;

  void setPhoneWithCountryCode(String phoneWithCode) {
    if (phoneWithCode.startsWith('+')) {
      final match = RegExp(r'^\+(\d{1,4})(.*)$').firstMatch(phoneWithCode);
      if (match != null) {
        updateSelectedCountryCode(match.group(1)!);
        text = match.group(2)!;
      }
    } else {
      text = phoneWithCode;
    }
  }

  void clearCountryCode() {
    _countryCodes.remove(this);
  }

  void initValue(String phoneWithCode) {
    final code = PhoneHelper.getCountryCode(phoneWithCode);
    setPhoneWithCountryCode(code ?? '');
    text = phoneWithCode.replaceRange(
      0,
      code?.length ?? 0,
      '',
    );
  }

  bool get hasCountryCode => _countryCodes.containsKey(this);

  void initializeCountryCode(String countryCode) {
    if (!hasCountryCode) {
      updateSelectedCountryCode(countryCode);
    }
  }
}
