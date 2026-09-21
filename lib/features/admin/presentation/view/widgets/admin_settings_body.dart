import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/common/widgets/ambient_glow_background.dart';
import '../../../../../core/common/widgets/custom_button.dart';
import '../../../../../core/common/widgets/feature_page_header.dart';
import '../../../../../core/common/widgets/language_selector_tile.dart';
import '../../../../../core/common/widgets/settings_profile_card.dart';
import '../../../../../core/languages/locale_keys.g.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/utils/session_utils.dart';
import '../../../../auth/presentation/utils/auth_feedback.dart';
import '../../../../auth/presentation/view_model/cubit/auth_cubit.dart';
import '../../../../auth/presentation/view_model/cubit/auth_states.dart';

class AdminSettingsBody extends StatelessWidget {
  const AdminSettingsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthStates>(
      listener: AuthFeedback.handle,
      child: Stack(
        children: [
          const AmbientGlowBackground(variant: AmbientGlowVariant.auth),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FeaturePageHeader(
                    title: LocaleKeys.admin_settings_title.tr(),
                    subtitle: LocaleKeys.admin_settings_subtitle.tr(),
                  ),
                  const SizedBox(height: 24),
                  SettingsProfileCard(
                    title: LocaleKeys.admin_account_title.tr(),
                    subtitle: LocaleKeys.home_verified_admin.tr(),
                    icon: Icons.admin_panel_settings_rounded,
                    accentColor: AppColors.primerColor,
                  ),
                  const SizedBox(height: 18),
                  const LanguageSelectorTile(),
                  const Spacer(),
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
      ),
    );
  }
}
