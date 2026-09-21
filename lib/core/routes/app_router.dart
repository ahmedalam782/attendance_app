import 'package:auto_route/auto_route.dart';
import 'package:injectable/injectable.dart';

import 'app_routes/admin_routes.dart';
import 'app_routes/global_routes.dart';
import 'app_routes/student_routes.dart';

@singleton
@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => const RouteType.material();

  @override
  List<AutoRoute> get routes => [
        ...GlobalRoutes.routes,
        ...AdminRoutes.routes,
        ...StudentRoutes.routes,
      ];
}
