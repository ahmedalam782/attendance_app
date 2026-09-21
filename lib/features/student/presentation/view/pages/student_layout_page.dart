import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/common/widgets/app_bottom_nav_bar.dart';
import '../../../../../core/languages/locale_keys.g.dart';
import '../../../../../core/routes/app_router.gr.dart';
import '../../../../../core/theme/app_colors.dart';

@RoutePage()
class StudentLayoutPage extends StatelessWidget {
  const StudentLayoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsScaffold(
      backgroundColor: AppColors.background,
      routes: const [
        StudentProgramsRoute(),
        StudentQrRoute(),
        StudentHistoryRoute(),
        StudentSettingsRoute(),
      ],
      bottomNavigationBuilder: (_, tabsRouter) {
        return AppBottomNavBar(
          selectedIndex: tabsRouter.activeIndex,
          onDestinationSelected: tabsRouter.setActiveIndex,
          destinations: [
            AppBottomNavDestination(
              icon: Icons.school_outlined,
              selectedIcon: Icons.school_rounded,
              label: LocaleKeys.nav_my_programs.tr(),
            ),
            AppBottomNavDestination(
              icon: Icons.qr_code_2_outlined,
              selectedIcon: Icons.qr_code_2_rounded,
              label: LocaleKeys.nav_my_qr.tr(),
            ),
            AppBottomNavDestination(
              icon: Icons.history_outlined,
              selectedIcon: Icons.history_rounded,
              label: LocaleKeys.nav_history.tr(),
            ),
            AppBottomNavDestination(
              icon: Icons.settings_outlined,
              selectedIcon: Icons.settings_rounded,
              label: LocaleKeys.nav_settings.tr(),
            ),
          ],
        );
      },
    );
  }
}
