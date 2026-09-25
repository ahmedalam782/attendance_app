import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/common/widgets/app_bottom_sheet.dart';
import '../../../../../core/common/widgets/custom_button.dart';
import '../../../../../core/common/widgets/qr_card.dart';
import '../../../../../core/languages/locale_keys.g.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../domain/entities/program.dart';
import '../utils/program_view_utils.dart';

class ProgramQrDisplaySheet extends StatefulWidget {
  const ProgramQrDisplaySheet({
    super.key,
    required this.program,
  });

  final Program program;

  static Future<void> show(BuildContext context, {required Program program}) {
    return showAppSheet<void>(
      context,
      builder: (_) => ProgramQrDisplaySheet(program: program),
    );
  }

  @override
  State<ProgramQrDisplaySheet> createState() => _ProgramQrDisplaySheetState();
}

class _ProgramQrDisplaySheetState extends State<ProgramQrDisplaySheet> {
  final _qrKey = GlobalKey();
  bool _isSharing = false;

  Future<void> _shareQr() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);
    try {
      await ProgramViewUtils.shareProgramInvite(
        context,
        title: widget.program.title,
        code: widget.program.inviteCode,
        qrKey: _qrKey,
      );
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppSheetPadding(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.program.title,
              style: 20.bold.copyWith(color: AppColors.slate900),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              LocaleKeys.programs_qr_display_subtitle.tr(),
              style: 13.regular.copyWith(color: AppColors.slate400),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),

            // Captured QR Card
            RepaintBoundary(
              key: _qrKey,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: QrCard(
                  title: widget.program.title,
                  token: 'attendance:program:${widget.program.inviteCode}',
                  size: 210,
                  footerText:
                      '${LocaleKeys.programs_invite_code_label.tr()}: ${widget.program.inviteCode}',
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Invite Code Display Container with Quick Copy & Share actions
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.slate100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.slate200),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.vpn_key_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.program.inviteCode,
                          style: 18.bold.copyWith(
                            color: AppColors.primary,
                            letterSpacing: 2.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          LocaleKeys.programs_invite_code_label.tr(),
                          style: 11.medium.copyWith(color: AppColors.slate500),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: LocaleKeys.programs_copy_code.tr(),
                    icon: const Icon(
                      Icons.copy_rounded,
                      size: 20,
                      color: AppColors.slate700,
                    ),
                    onPressed: () => ProgramViewUtils.copyInviteCode(
                      context,
                      widget.program.inviteCode,
                    ),
                  ),
                  IconButton(
                    tooltip: LocaleKeys.programs_share_qr.tr(),
                    icon: const Icon(
                      Icons.share_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    onPressed: _shareQr,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Primary Share Button
            CustomButton(
              title: LocaleKeys.programs_share_qr.tr(),
              isLoading: _isSharing,
              prefixIcon: const Icon(
                Icons.share_rounded,
                color: Colors.white,
                size: 18,
              ),
              onTap: _shareQr,
            ),
            const SizedBox(height: 10),

            // Secondary Cancel / Close Button
            CustomButton(
              title: LocaleKeys.global_cancel.tr(),
              isGradient: false,
              isFilled: false,
              borderColor: AppColors.slate300,
              titleStyle: 14.medium.copyWith(color: AppColors.slate700),
              onTap: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
