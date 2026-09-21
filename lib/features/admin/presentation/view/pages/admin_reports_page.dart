import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../../core/dependency_injection/injected_bloc_provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../programs/presentation/view_model/cubit/programs_cubit.dart';
import '../../../../reports/presentation/view_model/cubit/reports_cubit.dart';
import '../widgets/admin_reports_body.dart';

@RoutePage()
class AdminReportsPage extends StatelessWidget implements AutoRouteWrapper {
  const AdminReportsPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return InjectedBlocProvider<ProgramsCubit>(
      child: InjectedBlocProvider<ReportsCubit>(child: this),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: AdminReportsBody(),
    );
  }
}
