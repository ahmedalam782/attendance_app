import 'package:auto_route/auto_route.dart';

import '../app_router.gr.dart';
import '../routes.dart';

abstract class StudentRoutes {
  static final List<AutoRoute> routes = [
    AutoRoute(
      page: StudentLayoutRoute.page,
      path: AppRoutes.student,
      children: [
        AutoRoute(
          page: StudentProgramsRoute.page,
          path: AppRoutes.studentPrograms,
          initial: true,
        ),
        AutoRoute(
          page: StudentQrRoute.page,
          path: AppRoutes.studentQr,
        ),
        AutoRoute(
          page: StudentHistoryRoute.page,
          path: AppRoutes.studentHistory,
        ),
        AutoRoute(
          page: StudentSettingsRoute.page,
          path: AppRoutes.studentSettings,
        ),
      ],
    ),
  ];
}
