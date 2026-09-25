import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../languages/locale_keys.g.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import 'custom_button.dart';
import 'custom_confirmation_bottom_sheet.dart';

/// Supported permission types for confirmation modals.
enum PermissionType {
  camera,
  file,
  notification,
}

/// A premium, beautiful confirmation dialog shown before requesting system permissions.
/// Satisfies user intent and store transparency requirements across the entire app.
class PermissionConfirmationDialog extends StatelessWidget {
  const PermissionConfirmationDialog({
    super.key,
    required this.type,
    required this.title,
    required this.message,
    this.featurePoints = const [],
    this.confirmLabel,
    this.cancelLabel,
  });

  final PermissionType type;
  final String title;
  final String message;
  final List<String> featurePoints;
  final String? confirmLabel;
  final String? cancelLabel;

  /// Shows the dialog and returns `true` if the user confirmed/granted permission intent.
  static Future<bool> show(
    BuildContext context, {
    required PermissionType type,
    String? title,
    String? message,
    List<String>? featurePoints,
    String? confirmLabel,
    String? cancelLabel,
  }) async {
    final result = await CustomConfirmationBottomSheet.show(
      context,
      title: title ?? _defaultTitle(type),
      message: message ?? _defaultMessage(type),
      featurePoints: featurePoints ?? _defaultFeaturePoints(type),
      icon: _iconForType(type),
      confirmColor: AppColors.primary,
      confirmLabel: confirmLabel ?? LocaleKeys.permissions_allow.tr(),
      cancelLabel: cancelLabel ?? LocaleKeys.permissions_deny.tr(),
    );
    return result ?? false;
  }

  static IconData _iconForType(PermissionType type) {
    switch (type) {
      case PermissionType.camera:
        return Icons.camera_alt_rounded;
      case PermissionType.file:
        return Icons.folder_open_rounded;
      case PermissionType.notification:
        return Icons.notifications_active_rounded;
    }
  }

  /// Convenience helper for camera permissions (QR scanners).
  static Future<bool> showCameraPermission(
    BuildContext context, {
    String? customMessage,
  }) {
    return show(
      context,
      type: PermissionType.camera,
      message: customMessage,
    );
  }

  /// Convenience helper for storage/file permissions (CSV import).
  static Future<bool> showFilePermission(
    BuildContext context, {
    String? customMessage,
  }) {
    return show(
      context,
      type: PermissionType.file,
      message: customMessage,
    );
  }

  /// Convenience helper for notification permissions.
  static Future<bool> showNotificationPermission(
    BuildContext context, {
    String? customMessage,
  }) {
    return show(
      context,
      type: PermissionType.notification,
      message: customMessage,
    );
  }

  static String _defaultTitle(PermissionType type) {
    switch (type) {
      case PermissionType.camera:
        return LocaleKeys.permissions_camera_title.tr();
      case PermissionType.file:
        return LocaleKeys.permissions_file_title.tr();
      case PermissionType.notification:
        return LocaleKeys.permissions_notifications_title.tr();
    }
  }

  static String _defaultMessage(PermissionType type) {
    switch (type) {
      case PermissionType.camera:
        return LocaleKeys.permissions_camera_message.tr();
      case PermissionType.file:
        return LocaleKeys.permissions_file_message.tr();
      case PermissionType.notification:
        return LocaleKeys.permissions_notifications_message.tr();
    }
  }

  static List<String> _defaultFeaturePoints(PermissionType type) {
    switch (type) {
      case PermissionType.camera:
        return [
          LocaleKeys.permissions_camera_feature_1.tr(),
          LocaleKeys.permissions_camera_feature_2.tr(),
        ];
      case PermissionType.file:
        return [
          LocaleKeys.permissions_file_feature_1.tr(),
          LocaleKeys.permissions_file_feature_2.tr(),
        ];
      case PermissionType.notification:
        return [
          LocaleKeys.permissions_notifications_feature_1.tr(),
          LocaleKeys.permissions_notifications_feature_2.tr(),
        ];
    }
  }

  IconData get _icon {
    switch (type) {
      case PermissionType.camera:
        return Icons.camera_alt_rounded;
      case PermissionType.file:
        return Icons.folder_open_rounded;
      case PermissionType.notification:
        return Icons.notifications_active_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final resolvedConfirm = confirmLabel ?? LocaleKeys.permissions_allow.tr();
    final resolvedCancel = cancelLabel ?? LocaleKeys.permissions_deny.tr();

    return Dialog(
      backgroundColor: AppColors.cardSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 28, 22, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Icon Badge
            Center(
              child: Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: Icon(
                  _icon,
                  size: 32,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: 17.bold.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 10),

            // Message Rationale
            Text(
              message,
              textAlign: TextAlign.center,
              style: 13.regular.copyWith(
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),

            // Highlights
            if (featurePoints.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.slate50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.slate200),
                ),
                child: Column(
                  children: featurePoints.map((point) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 16,
                            color: AppColors.present,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              point,
                              style: 12.medium.copyWith(
                                color: AppColors.slate700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    title: resolvedCancel,
                    isFilled: true,
                    isGradient: false,
                    backGroundColor: AppColors.slate100,
                    borderColor: AppColors.border,
                    titleStyle: 13.bold.copyWith(color: AppColors.slate700),
                    onTap: () => Navigator.of(context).pop(false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    title: resolvedConfirm,
                    isFilled: true,
                    isGradient: false,
                    backGroundColor: AppColors.primary,
                    borderColor: AppColors.primary,
                    titleStyle:
                        13.bold.copyWith(color: AppColors.originalWhite),
                    onTap: () => Navigator.of(context).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
