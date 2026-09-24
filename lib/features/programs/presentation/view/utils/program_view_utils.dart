import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toastification/toastification.dart';

import '../../../../../core/common/widgets/custom_toast.dart';
import '../../../../../core/languages/locale_keys.g.dart';

/// Presentation utilities for the Programs feature adhering to Al Faris architecture.
abstract final class ProgramViewUtils {
  static void copyInviteCode(BuildContext context, String code) {
    Clipboard.setData(ClipboardData(text: code));
    HapticFeedback.selectionClick();
    CustomToast(
      context: context,
      header: LocaleKeys.programs_code_copied.tr(),
      type: ToastificationType.success,
    ).showToast();
  }
}
