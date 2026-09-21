import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import '../../../../core/common/widgets/app_loading_dialog.dart';
import '../../../../core/common/widgets/custom_toast.dart';
import '../../../../core/languages/locale_keys.g.dart';
import '../helpers/auth_error_copy.dart';
import '../view_model/cubit/auth_states.dart';

/// Shared loading / toast reactions for [AuthStates] changes.
abstract final class AuthFeedback {
  static void handle(
    BuildContext context,
    AuthStates state, {
    bool showLoggedOutToast = false,
  }) {
    if (state.busy) {
      AppLoadingDialog.show(context);
    } else {
      AppLoadingDialog.hide(context);
    }

    if (showLoggedOutToast && state.loggedOut) {
      CustomToast(
        context: context,
        header: LocaleKeys.login_logout_success.tr(),
        type: ToastificationType.success,
      ).showToast();
    }

    if (state.error case final error?) {
      CustomToast(
        context: context,
        header: AuthErrorCopy.message(error),
        type: ToastificationType.error,
      ).showToast();
    }
  }
}
