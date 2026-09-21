import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../../core/dependency_injection/injected_bloc_provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../programs/presentation/view_model/cubit/programs_cubit.dart';
import '../widgets/admin_programs_body.dart';

@RoutePage()
class AdminProgramsPage extends StatelessWidget implements AutoRouteWrapper {
  const AdminProgramsPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return InjectedBlocProvider<ProgramsCubit>(child: this);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: AdminProgramsBody(),
    );
  }
}
