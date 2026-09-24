import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/common/widgets/custom_confirmation_bottom_sheet.dart';
import '../../../../../core/languages/locale_keys.g.dart';

/// Auth-related dialogs and confirmation sheets.
abstract final class AuthDialogs {
  static Future<bool> confirmLogout(BuildContext context) async {
    final confirmed = await CustomConfirmationBottomSheet.show(
      context,
      title: LocaleKeys.login_logout_title.tr(),
      message: LocaleKeys.login_logout_confirm.tr(),
      confirmLabel: LocaleKeys.login_logout_button.tr(),
      cancelLabel: LocaleKeys.login_logout_cancel.tr(),
      isDestructive: true,
    );
    return confirmed == true;
  }
}
