import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/common/widgets/app_bottom_nav_bar.dart';
import '../../../../../core/languages/locale_keys.g.dart';
import '../../../../../core/routes/app_router.gr.dart';
import '../../../../../core/theme/app_colors.dart';

@RoutePage()
class AdminLayoutPage extends StatelessWidget {
  const AdminLayoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsScaffold(
      backgroundColor: AppColors.background,
      routes: const [
        AdminProgramsRoute(),
        AdminScannerRoute(),
        AdminReportsRoute(),
        AdminSettingsRoute(),
      ],
      bottomNavigationBuilder: (_, tabsRouter) {
        return AppBottomNavBar(
          selectedIndex: tabsRouter.activeIndex,
          onDestinationSelected: tabsRouter.setActiveIndex,
          destinations: [
            AppBottomNavDestination(
              icon: Icons.layers_outlined,
              selectedIcon: Icons.layers_rounded,
              label: LocaleKeys.nav_programs.tr(),
            ),
            AppBottomNavDestination(
              icon: Icons.qr_code_scanner_outlined,
              selectedIcon: Icons.qr_code_scanner_rounded,
              label: LocaleKeys.nav_scanner.tr(),
            ),
            AppBottomNavDestination(
              icon: Icons.bar_chart_outlined,
              selectedIcon: Icons.bar_chart_rounded,
              label: LocaleKeys.nav_reports.tr(),
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
