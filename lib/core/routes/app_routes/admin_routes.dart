import 'package:auto_route/auto_route.dart';

import '../app_router.gr.dart';
import '../routes.dart';

abstract class AdminRoutes {
  static final List<AutoRoute> routes = [
    AutoRoute(
      page: AdminLayoutRoute.page,
      path: AppRoutes.admin,
      children: [
        AutoRoute(
          page: AdminProgramsRoute.page,
          path: AppRoutes.adminPrograms,
          initial: true,
        ),
        AutoRoute(
          page: AdminScannerRoute.page,
          path: AppRoutes.adminScanner,
        ),
        AutoRoute(
          page: AdminReportsRoute.page,
          path: AppRoutes.adminReports,
        ),
        AutoRoute(
          page: AdminSettingsRoute.page,
          path: AppRoutes.adminSettings,
        ),
      ],
    ),
  ];
}
