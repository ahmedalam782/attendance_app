import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toastification/toastification.dart';

import '../../../../../core/common/widgets/custom_button.dart';
import '../../../../../core/common/widgets/custom_toast.dart';
import '../../../../../core/common/widgets/qr_card.dart';
import '../../../../../core/common/widgets/sheet_drag_handle.dart';
import '../../../../../core/languages/locale_keys.g.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../domain/entities/program.dart';

class ProgramQrDisplaySheet extends StatelessWidget {
  const ProgramQrDisplaySheet({
    super.key,
    required this.program,
  });

  final Program program;

  static Future<void> show(BuildContext context, {required Program program}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => ProgramQrDisplaySheet(program: program),
    );
  }

  void _copyInviteCode(BuildContext context) {
    Clipboard.setData(ClipboardData(text: program.inviteCode));
    HapticFeedback.selectionClick();
    CustomToast(
      context: context,
      header: LocaleKeys.programs_code_copied.tr(),
      type: ToastificationType.success,
    ).showToast();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 16, 24, 16 + bottomInset),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SheetDragHandle(),
              const SizedBox(height: 16),
              Text(
                program.title,
                style: 20.bold.copyWith(color: AppColors.slate900),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                LocaleKeys.programs_qr_display_subtitle.tr(),
                style: 13.regular.copyWith(color: AppColors.slate400),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              QrCard(
                title: program.title,
                token: 'attendance:program:${program.inviteCode}',
                size: 210,
                footerText:
                    '${LocaleKeys.programs_invite_code_label.tr()}: ${program.inviteCode}',
              ),
              const SizedBox(height: 20),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.slate100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.slate200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.vpn_key_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        program.inviteCode,
                        style: 18.bold.copyWith(
                          color: AppColors.primary,
                          letterSpacing: 3.0,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: () => _copyInviteCode(context),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.copy_rounded,
                              size: 16,
                              color: AppColors.slate600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              LocaleKeys.programs_copy_code.tr(),
                              style: 12.medium
                                  .copyWith(color: AppColors.slate600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
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
      ),
    );
  }
}
