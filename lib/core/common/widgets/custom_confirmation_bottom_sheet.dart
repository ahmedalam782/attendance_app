import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../languages/locale_keys.g.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import 'app_bottom_sheet.dart';
import 'custom_button.dart';

/// Clean bottom sheet modal for confirmations (e.g. sign-out, discard, delete).
class CustomConfirmationBottomSheet extends StatelessWidget {
  const CustomConfirmationBottomSheet({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel,
    this.cancelLabel,
    this.isDestructive = false,
    this.confirmColor,
  });

  final String title;
  final String message;
  final String? confirmLabel;
  final String? cancelLabel;
  final bool isDestructive;
  final Color? confirmColor;

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmLabel,
    String? cancelLabel,
    bool isDestructive = false,
    Color? confirmColor,
  }) {
    return showAppSheet<bool>(
      context,
      isDismissible: true,
      builder: (context) => CustomConfirmationBottomSheet(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
        confirmColor: confirmColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor = confirmColor ??
        (isDestructive ? AppColors.absent : AppColors.primerColor);
    final resolvedConfirm = confirmLabel ?? LocaleKeys.global_confirm.tr();
    final resolvedCancel = cancelLabel ?? LocaleKeys.global_cancel.tr();

    return AppSheetPadding(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: 17.bold.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: 13.regular.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  title: resolvedCancel,
                  isFilled: true,
                  isGradient: false,
                  backGroundColor: AppColors.slate100,
                  borderColor: AppColors.border,
                  titleStyle: 14.bold.copyWith(color: AppColors.slate800),
                  onTap: () => Navigator.of(context).pop(false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  title: resolvedConfirm,
                  isFilled: true,
                  isGradient: false,
                  backGroundColor: effectiveColor,
                  borderColor: effectiveColor,
                  titleStyle: 14.bold.copyWith(color: AppColors.originalWhite),
                  onTap: () => Navigator.of(context).pop(true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
