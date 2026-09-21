import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../../core/dependency_injection/injected_bloc_provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../auth/presentation/view_model/cubit/auth_cubit.dart';
import '../widgets/student_settings_body.dart';

@RoutePage()
class StudentSettingsPage extends StatelessWidget implements AutoRouteWrapper {
  const StudentSettingsPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return InjectedBlocProvider<AuthCubit>(child: this);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: StudentSettingsBody(),
    );
  }
}
