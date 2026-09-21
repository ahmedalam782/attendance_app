import 'package:auto_route/auto_route.dart';

import '../app_router.gr.dart';
import '../routes.dart';

abstract class GlobalRoutes {
  static final List<AutoRoute> routes = [
    CustomRoute(
      page: SplashRoute.page,
      path: AppRoutes.splash,
      initial: true,
      transitionsBuilder: TransitionsBuilders.fadeIn,
      duration: const Duration(milliseconds: 400),
    ),
    CustomRoute(
      page: AuthRoute.page,
      path: AppRoutes.auth,
      transitionsBuilder: TransitionsBuilders.slideLeftWithFade,
      duration: const Duration(milliseconds: 450),
    ),
    CustomRoute(
      page: RegisterRoute.page,
      path: AppRoutes.register,
      transitionsBuilder: TransitionsBuilders.slideLeftWithFade,
      duration: const Duration(milliseconds: 450),
    ),
    CustomRoute(
      page: ProgramDetailsRoute.page,
      path: AppRoutes.programDetails,
      transitionsBuilder: TransitionsBuilders.slideLeftWithFade,
      duration: const Duration(milliseconds: 350),
    ),
  ];
}
