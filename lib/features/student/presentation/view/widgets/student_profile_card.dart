import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/common/widgets/profile_info_tile.dart';
import '../../../../../core/common/widgets/role_badge.dart';
import '../../../../../core/languages/locale_keys.g.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../auth/domain/models/auth_user.dart';
import '../../../../auth/presentation/utils/auth_user_utils.dart';

/// Student profile summary + detail tiles.
class StudentProfileCard extends StatelessWidget {
  const StudentProfileCard({super.key, required this.user});

  final AuthUser user;

  @override
  Widget build(BuildContext context) {
    final displayName = AuthUserUtils.displayName(user);
    final initials = AuthUserUtils.initials(user);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate200),
        boxShadow: [
          BoxShadow(
            color: AppColors.slate900.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.accentGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.28),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Text(
                initials,
                style: 24.bold.copyWith(color: AppColors.originalWhite),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            displayName,
            textAlign: TextAlign.center,
            style: 16.bold.copyWith(color: AppColors.slate900),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            textAlign: TextAlign.center,
            style: 12.medium.copyWith(color: AppColors.slate400),
          ),
          const SizedBox(height: 10),
          RoleBadge(
            label: LocaleKeys.home_verified_attendee.tr(),
            icon: Icons.verified_user_rounded,
            color: AppColors.accent,
          ),
          const SizedBox(height: 18),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              LocaleKeys.student_profile_section.tr(),
              style: 12.semiBold.copyWith(color: AppColors.slate600),
            ),
          ),
          const SizedBox(height: 4),
          ProfileInfoTile(
            icon: Icons.person_outline_rounded,
            label: LocaleKeys.student_profile_name.tr(),
            value: displayName,
          ),
          ProfileInfoTile(
            icon: Icons.email_outlined,
            label: LocaleKeys.student_profile_email.tr(),
            value: user.email,
          ),
          ProfileInfoTile(
            icon: Icons.badge_outlined,
            label: LocaleKeys.student_profile_role.tr(),
            value: LocaleKeys.student_role_student.tr(),
            showDivider: false,
          ),
        ],
      ),
    );
  }
}

class StudentProfileLoadingCard extends StatelessWidget {
  const StudentProfileLoadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 18),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            LocaleKeys.student_profile_loading.tr(),
            style: 12.medium.copyWith(color: AppColors.slate400),
          ),
        ],
      ),
    );
  }
}

class StudentProfileUnavailableCard extends StatelessWidget {
  const StudentProfileUnavailableCard({super.key, this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.person_off_outlined,
            size: 36,
            color: AppColors.slate400,
          ),
          const SizedBox(height: 10),
          Text(
            LocaleKeys.student_profile_unavailable.tr(),
            textAlign: TextAlign.center,
            style: 13.semiBold.copyWith(color: AppColors.slate900),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: onRetry,
              child: Text(LocaleKeys.global_retry.tr()),
            ),
          ],
        ],
      ),
    );
  }
}
