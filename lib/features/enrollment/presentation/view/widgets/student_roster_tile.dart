import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/common/widgets/custom_confirmation_bottom_sheet.dart';
import '../../../../../core/common/widgets/status_chip.dart';
import '../../../../../core/languages/locale_keys.g.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../domain/entities/enrolled_student.dart';

class StudentRosterTile extends StatelessWidget {
  const StudentRosterTile({
    super.key,
    required this.student,
    this.isAdmin = false,
    this.onRemove,
  });

  final EnrolledStudent student;
  final bool isAdmin;
  final VoidCallback? onRemove;

  String get _initials {
    final parts = student.name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'S';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Initials Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text(
              _initials,
              style: 14.bold.copyWith(color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 14),

          // Name and ID / Join date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: 14.bold.copyWith(color: AppColors.slate900),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        student.id,
                        style: 11.medium.copyWith(color: AppColors.slate500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 3,
                      height: 3,
                      decoration: const BoxDecoration(
                        color: AppColors.slate300,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dateFormat.format(student.joinedAt),
                      style: 11.regular.copyWith(color: AppColors.slate400),
                      maxLines: 1,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Status & optional Admin remove button
          StatusChip.fromString(student.status),
          if (isAdmin && onRemove != null) ...[
            const SizedBox(width: 6),
            IconButton(
              onPressed: () => _confirmRemove(context),
              icon: const Icon(Icons.person_remove_outlined, size: 18),
              color: AppColors.absent,
              tooltip: LocaleKeys.roster_remove_student.tr(),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmRemove(BuildContext context) async {
    final confirmed = await CustomConfirmationBottomSheet.show(
      context,
      title: LocaleKeys.roster_remove_student.tr(),
      message: LocaleKeys.roster_remove_student_confirm.tr(
        namedArgs: {'name': student.name},
      ),
      confirmLabel: LocaleKeys.roster_remove_student.tr(),
      cancelLabel: LocaleKeys.global_cancel.tr(),
      isDestructive: true,
      icon: Icons.person_remove_rounded,
    );
    if (confirmed == true) {
      onRemove?.call();
    }
  }
}
