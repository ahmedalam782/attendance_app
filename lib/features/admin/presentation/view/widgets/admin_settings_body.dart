import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/routes/app_router.gr.dart';
import '../../../../../core/common/widgets/ambient_glow_background.dart';
import '../../../../../core/common/widgets/centered_scroll_body.dart';
import '../../../../../core/common/widgets/custom_button.dart';
import '../../../../../core/common/widgets/feature_page_header.dart';
import '../../../../../core/common/widgets/language_selector_tile.dart';
import '../../../../../core/languages/locale_keys.g.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/utils/session_utils.dart';
import '../../../../auth/presentation/utils/auth_feedback.dart';
import '../../../../auth/presentation/view_model/cubit/auth_cubit.dart';
import '../../../../auth/presentation/view_model/cubit/auth_states.dart';
import 'staff_profile_card.dart';

class AdminSettingsBody extends StatefulWidget {
  const AdminSettingsBody({super.key});

  @override
  State<AdminSettingsBody> createState() => _AdminSettingsBodyState();
}

class _AdminSettingsBodyState extends State<AdminSettingsBody> {
  var _loadingProfile = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
  }

  Future<void> _loadProfile() async {
    setState(() => _loadingProfile = true);
    await context.read<AuthCubit>().checkSession();
    if (!mounted) return;
    setState(() => _loadingProfile = false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthStates>(
      listener: AuthFeedback.handle,
      builder: (context, state) {
        final user = state.authState.data;
        final isSuperAdmin = user?.isAdmin ?? false;

        return Stack(
          children: [
            const AmbientGlowBackground(variant: AmbientGlowVariant.auth),
            SafeArea(
              child: CenteredScrollBody(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FeaturePageHeader(
                      title: isSuperAdmin
                          ? LocaleKeys.admin_settings_title.tr()
                          : LocaleKeys.settings_extra_instructor_settings_title.tr(),
                      subtitle: isSuperAdmin
                          ? LocaleKeys.admin_settings_subtitle.tr()
                          : LocaleKeys.settings_extra_instructor_settings_subtitle.tr(),
                    ),
                    const SizedBox(height: 20),
                    if (_loadingProfile && user == null)
                      const StaffProfileLoadingCard()
                    else if (user != null)
                      StaffProfileCard(user: user)
                    else
                      StaffProfileUnavailableCard(onRetry: _loadProfile),
                    const SizedBox(height: 18),

                    // Language Selector
                    const LanguageSelectorTile(),

                    // Invite New Instructor & History Cards (Only for Super Admin)
                    if (isSuperAdmin) ...[
                      const SizedBox(height: 14),
                      // Card 1: Instructor Invite Code & QR
                      InkWell(
                        onTap: () => context.router.push(InstructorInviteCodeRoute()),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.cardSurface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.slate200),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.primerColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.qr_code_2_rounded,
                                  color: AppColors.primerColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      LocaleKeys.settings_extra_admin_invite_instructor_title.tr(),
                                      style: 14.bold.copyWith(color: AppColors.slate900),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      LocaleKeys.settings_extra_admin_invite_instructor_subtitle.tr(),
                                      style: 12.medium.copyWith(color: AppColors.slate500),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 14,
                                color: AppColors.slate400,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Card 2: Instructor Invites History
                      InkWell(
                        onTap: () => context.router.push(const InstructorInvitesHistoryRoute()),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.cardSurface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.slate200),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.slate100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.history_rounded,
                                  color: AppColors.slate700,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      LocaleKeys.settings_extra_invite_history_title.tr(),
                                      style: 14.bold.copyWith(color: AppColors.slate900),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      context.locale.languageCode == 'ar'
                                          ? 'متابعة جميع الأكواد السابقة وحالة استخدامها'
                                          : 'Track all issued codes and their status',
                                      style: 12.medium.copyWith(color: AppColors.slate500),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 14,
                                color: AppColors.slate400,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),

                    CustomButton(
                      title: LocaleKeys.login_logout_button.tr(),
                      isFilled: true,
                      backGroundColor: AppColors.cardSurface,
                      borderColor: AppColors.absent.withValues(alpha: 0.3),
                      titleStyle: 14.bold.copyWith(color: AppColors.absent),
                      prefixIcon: const Icon(
                        Icons.logout_rounded,
                        color: AppColors.absent,
                        size: 18,
                      ),
                      onTap: () => SessionUtils.confirmLogoutAndLeave(context),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
