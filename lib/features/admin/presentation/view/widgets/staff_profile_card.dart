import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/common/widgets/profile_info_tile.dart';
import '../../../../../core/common/widgets/role_badge.dart';
import '../../../../../core/languages/locale_keys.g.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../auth/domain/models/auth_user.dart';
import '../../../../auth/presentation/utils/auth_user_utils.dart';

/// Staff profile card displaying instructor / admin credentials and data.
class StaffProfileCard extends StatelessWidget {
  const StaffProfileCard({super.key, required this.user});

  final AuthUser user;

  @override
  Widget build(BuildContext context) {
    final displayName = AuthUserUtils.displayName(user);
    final initials = AuthUserUtils.initials(user);
    final isSuperAdmin = user.isAdmin;

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
              gradient: AppColors.primerGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primerColor.withValues(alpha: 0.28),
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
            label: isSuperAdmin
                ? LocaleKeys.home_verified_admin.tr()
                : LocaleKeys.home_verified_instructor.tr(),
            icon: isSuperAdmin
                ? Icons.admin_panel_settings_rounded
                : Icons.school_rounded,
            color: AppColors.primerColor,
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
          if (user.phoneNumber != null && user.phoneNumber!.trim().isNotEmpty)
            ProfileInfoTile(
              icon: Icons.phone_outlined,
              label: LocaleKeys.student_profile_phone.tr(),
              value: user.phoneNumber!,
            ),
          ProfileInfoTile(
            icon: Icons.badge_outlined,
            label: LocaleKeys.student_profile_role.tr(),
            value: isSuperAdmin
                ? LocaleKeys.settings_extra_role_admin.tr()
                : LocaleKeys.settings_extra_role_instructor.tr(),
            showDivider: false,
          ),
        ],
      ),
    );
  }
}

class StaffProfileLoadingCard extends StatelessWidget {
  const StaffProfileLoadingCard({super.key});

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
              color: AppColors.primerColor,
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

class StaffProfileUnavailableCard extends StatelessWidget {
  const StaffProfileUnavailableCard({super.key, this.onRetry});

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
