import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/common/widgets/ambient_glow_background.dart';
import '../../../../../core/common/widgets/centered_scroll_body.dart';
import '../../../../../core/common/widgets/custom_button.dart';
import '../../../../../core/common/widgets/feature_page_header.dart';
import '../../../../../core/languages/locale_keys.g.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/utils/session_utils.dart';
import '../../../../../core/common/widgets/language_selector_tile.dart';
import '../../../../auth/presentation/view/utils/auth_feedback.dart';
import '../../../../auth/presentation/view/widgets/redeem_instructor_code_sheet.dart';
import '../../../../auth/presentation/view_model/cubit/auth_cubit.dart';
import '../../../../auth/presentation/view_model/cubit/auth_states.dart';
import 'student_profile_card.dart';

class StudentSettingsBody extends StatefulWidget {
  const StudentSettingsBody({super.key});

  @override
  State<StudentSettingsBody> createState() => _StudentSettingsBodyState();
}

class _StudentSettingsBodyState extends State<StudentSettingsBody> {
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
                      title: LocaleKeys.student_settings_title.tr(),
                      subtitle: LocaleKeys.student_settings_subtitle.tr(),
                    ),
                    const SizedBox(height: 20),
                    if (_loadingProfile)
                      const StudentProfileLoadingCard()
                    else if (user != null)
                      StudentProfileCard(user: user)
                    else
                      StudentProfileUnavailableCard(onRetry: _loadProfile),
                    const SizedBox(height: 20),

                    // Language Selector
                    const LanguageSelectorTile(),
                    const SizedBox(height: 14),

                    // Become an Instructor card
                    InkWell(
                      onTap: () => RedeemInstructorCodeSheet.show(context),
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
                                Icons.admin_panel_settings_rounded,
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
                                    LocaleKeys.settings_extra_instructor_code_title.tr(),
                                    style: 14.bold.copyWith(color: AppColors.slate900),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    LocaleKeys.settings_extra_instructor_code_subtitle.tr(),
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
