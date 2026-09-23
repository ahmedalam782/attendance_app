import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

import '../../languages/locale_keys.g.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class QrCard extends StatelessWidget {
  const QrCard({
    super.key,
    this.token,
    this.studentName,
    this.studentId,
    this.title,
    this.subtitle,
    this.footerText,
    this.qrContent,
    this.size = 220,
    this.actions,
    this.headerWidget,
  });

  final String? token;
  final String? studentName;
  final String? studentId;
  final String? title;
  final String? subtitle;
  final String? footerText;
  final Widget? qrContent;
  final double size;
  final List<Widget>? actions;
  final Widget? headerWidget;

  String get _displayTitle => title ?? studentName ?? 'Student Pass';
  String? get _displaySubtitle =>
      subtitle ?? (studentId != null ? 'ID: ${studentId!.length > 12 ? studentId!.substring(0, 12) : studentId}' : null);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.slate200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header info
          if (headerWidget != null) ...[
            headerWidget!,
          ] else if (actions != null && actions!.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _displayTitle,
                        style: 18.bold.copyWith(color: AppColors.slate900),
                        textAlign: TextAlign.center,
                      ),
                      if (_displaySubtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          _displaySubtitle!,
                          style: 12.medium.copyWith(color: AppColors.slate500),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: actions!,
                ),
              ],
            ),
          ] else ...[
            Text(
              _displayTitle,
              style: 18.bold.copyWith(color: AppColors.slate900),
              textAlign: TextAlign.center,
            ),
            if (_displaySubtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                _displaySubtitle!,
                style: 12.medium.copyWith(color: AppColors.slate500),
              ),
            ],
          ],
          const SizedBox(height: 18),

          // High-contrast QR Container (Always black on white)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.qrBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.slate200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: qrContent ??
                (token != null
                    ? SizedBox(
                        width: size,
                        height: size,
                        child: PrettyQrView.data(
                          data: token!,
                          decoration: const PrettyQrDecoration(
                            shape: PrettyQrSmoothSymbol(
                              color: AppColors.qrForeground,
                            ),
                          ),
                        ),
                      )
                    : SizedBox(
                        width: size,
                        height: size,
                        child: const Center(
                          child: Icon(
                            Icons.qr_code_2_rounded,
                            size: 140,
                            color: AppColors.qrForeground,
                          ),
                        ),
                      )),
          ),
          const SizedBox(height: 18),

          // Footer / Offline indicator badge
          if (footerText != null)
            Text(
              footerText!,
              style: 11.medium.copyWith(color: AppColors.slate500),
              textAlign: TextAlign.center,
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.emeraldLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.present.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.verified_user_rounded,
                    size: 14,
                    color: AppColors.present,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    LocaleKeys.attendance_pass_offline_ready.tr(),
                    style: 11.bold.copyWith(color: AppColors.present),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
