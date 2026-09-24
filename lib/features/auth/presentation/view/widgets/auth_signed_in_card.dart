import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/common/widgets/custom_button.dart';
import '../../../../../core/common/widgets/status_chip.dart';
import '../../../../../core/languages/locale_keys.g.dart';
import '../../../../../core/routes/app_router.gr.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../domain/models/auth_user.dart';
import '../utils/auth_user_utils.dart';
import 'auth_metric_card.dart';
import 'qr_pass_sheet.dart';

class AuthSignedInCard extends StatelessWidget {
  const AuthSignedInCard({
    super.key,
    required this.user,
    required this.isBusy,
    required this.onLogout,
  });

  final AuthUser user;
  final bool isBusy;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final initials = AuthUserUtils.initials(user);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
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
              gradient: AppColors.modernPrimaryGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.32),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Text(
                initials,
                style: 22.bold.copyWith(color: AppColors.originalWhite),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            LocaleKeys.login_signed_in.tr(),
            textAlign: TextAlign.center,
            style: 17.bold.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 3),
          Text(
            user.email,
            textAlign: TextAlign.center,
            style: 13.medium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          StatusChip(
            status: AttendanceStatus.present,
            customLabel: user.isAdmin
                ? LocaleKeys.home_verified_admin.tr()
                : (user.isInstructor
                    ? LocaleKeys.home_verified_instructor.tr()
                    : LocaleKeys.home_verified_attendee.tr()),
          ),
          if (!user.isStaff) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: AuthMetricCard(
                    title: LocaleKeys.home_attendance.tr(),
                    value: '98%',
                    accentColor: AppColors.present,
                    icon: Icons.check_circle_outline,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AuthMetricCard(
                    title: LocaleKeys.home_sessions.tr(),
                    value: '14/15',
                    accentColor: AppColors.accent,
                    icon: Icons.school_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => QrPassSheet.show(context, user),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.slate50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.cyanLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.qr_code_rounded,
                        color: AppColors.accent,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            LocaleKeys.home_qr_pass_title.tr(),
                            style: 13.bold.copyWith(color: AppColors.textPrimary),
                          ),
                          Text(
                            LocaleKeys.home_qr_pass_subtitle.tr(),
                            style: 11.regular
                                .copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.slate400,
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          CustomButton(
            title: user.isStaff
                ? (user.isAdmin
                    ? LocaleKeys.admin_enter_dashboard.tr()
                    : LocaleKeys.settings_extra_instructor_enter_portal.tr())
                : LocaleKeys.student_enter_portal.tr(),
            prefixIcon: Icon(
              user.isAdmin
                  ? Icons.admin_panel_settings_rounded
                  : (user.isInstructor
                      ? Icons.school_rounded
                      : Icons.school_rounded),
              color: AppColors.originalWhite,
              size: 18,
            ),
            onTap: () {
              if (user.isStaff) {
                context.router.replaceAll([const AdminLayoutRoute()]);
              } else {
                context.router.replaceAll([const StudentLayoutRoute()]);
              }
            },
          ),
          const SizedBox(height: 10),
          CustomButton(
            title: LocaleKeys.login_logout.tr(),
            isFilled: true,
            backGroundColor: AppColors.cardSurface,
            borderColor: AppColors.absent.withValues(alpha: 0.3),
            titleStyle: 14.bold.copyWith(color: AppColors.absent),
            prefixIcon: const Icon(
              Icons.logout_rounded,
              color: AppColors.absent,
              size: 18,
            ),
            onTap: isBusy ? null : onLogout,
          ),
        ],
      ),
    );
  }
}
