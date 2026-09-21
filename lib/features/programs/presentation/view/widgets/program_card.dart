import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toastification/toastification.dart';

import '../../../../../core/common/widgets/custom_toast.dart';
import '../../../../../core/languages/locale_keys.g.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../domain/entities/program.dart';
import 'program_qr_display_sheet.dart';

class ProgramCard extends StatelessWidget {
  const ProgramCard({
    super.key,
    required this.program,
    this.onTap,
    this.showInviteCode = true,
  });

  final Program program;
  final VoidCallback? onTap;
  final bool showInviteCode;

  Color get _typeColor {
    if (program.isBootcamp) return AppColors.late;
    if (program.isEvent) return AppColors.accent;
    return AppColors.primerColor;
  }

  IconData get _typeIcon {
    if (program.isBootcamp) return Icons.bolt_rounded;
    if (program.isEvent) return Icons.event_available_rounded;
    return Icons.school_rounded;
  }

  String get _typeLabel {
    if (program.isBootcamp) return LocaleKeys.programs_type_bootcamp.tr();
    if (program.isEvent) return LocaleKeys.programs_type_event.tr();
    return LocaleKeys.programs_type_course.tr();
  }

  void _copyInviteCode(BuildContext context) {
    Clipboard.setData(ClipboardData(text: program.inviteCode));
    CustomToast(
      context: context,
      header: LocaleKeys.programs_code_copied.tr(),
      type: ToastificationType.success,
    ).showToast();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.slate200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _typeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _typeColor.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_typeIcon, size: 13, color: _typeColor),
                      const SizedBox(width: 5),
                      Text(
                        _typeLabel,
                        style: 11.bold.copyWith(color: _typeColor),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (showInviteCode) ...[
                  GestureDetector(
                    onTap: () => _copyInviteCode(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.slate100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            program.inviteCode,
                            style: 12.bold.copyWith(
                              color: AppColors.slate700,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.copy_rounded,
                            size: 13,
                            color: AppColors.slate500,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: () => ProgramQrDisplaySheet.show(
                      context,
                      program: program,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.qr_code_2_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Text(
              program.title,
              style: 16.bold.copyWith(color: AppColors.slate900),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (program.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                program.description,
                style: 13.regular.copyWith(color: AppColors.slate500),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                if (program.location.isNotEmpty) ...[
                  const Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: AppColors.slate400,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      program.location,
                      style: 12.medium.copyWith(color: AppColors.slate500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                const Spacer(),
                Icon(
                  Icons.people_outline_rounded,
                  size: 14,
                  color: AppColors.slate400,
                ),
                const SizedBox(width: 4),
                Text(
                  LocaleKeys.programs_students_count.tr(
                    namedArgs: {'count': program.studentCount.toString()},
                  ),
                  style: 12.medium.copyWith(color: AppColors.slate500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
