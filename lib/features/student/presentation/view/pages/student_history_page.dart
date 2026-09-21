import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../../core/dependency_injection/injected_bloc_provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../attendance/presentation/view_model/cubit/attendance_cubit.dart';
import '../widgets/student_history_body.dart';

@RoutePage()
class StudentHistoryPage extends StatelessWidget implements AutoRouteWrapper {
  const StudentHistoryPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return InjectedBlocProvider<AttendanceCubit>(child: this);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: StudentHistoryBody(),
    );
  }
}
