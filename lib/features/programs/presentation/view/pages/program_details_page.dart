import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/common/widgets/custom_app_bar.dart';
import '../../../../../core/dependency_injection/injected_bloc_provider.dart';
import '../../../../../core/languages/locale_keys.g.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/program.dart';
import '../../../../attendance/presentation/view_model/cubit/attendance_cubit.dart';
import '../../../../enrollment/presentation/view_model/cubit/enrollment_cubit.dart';
import '../../../../programs/presentation/view_model/cubit/programs_cubit.dart';
import '../../../../sessions/presentation/view_model/cubit/sessions_cubit.dart';
import '../utils/program_view_utils.dart';
import '../widgets/program_details_body.dart';
import '../widgets/program_qr_display_sheet.dart';

/// Thin RoutePage for Program Details adhering to Al Faris presentation architecture.
@RoutePage()
class ProgramDetailsPage extends StatelessWidget implements AutoRouteWrapper {
  const ProgramDetailsPage({
    super.key,
    required this.program,
    this.isAdmin = false,
  });

  final Program program;
  final bool isAdmin;

  @override
  Widget wrappedRoute(BuildContext context) {
    return InjectedBlocProvider<SessionsCubit>(
      child: InjectedBlocProvider<EnrollmentCubit>(
        child: InjectedBlocProvider<AttendanceCubit>(
          child: InjectedBlocProvider<ProgramsCubit>(child: this),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: program.title,
        backgroundColor: AppColors.background,
        centerTitle: false,
        actions: isAdmin
            ? [
                IconButton(
                  tooltip: LocaleKeys.programs_copy_code.tr(),
                  onPressed: () => ProgramViewUtils.copyInviteCode(
                    context,
                    program.inviteCode,
                  ),
                  icon: const Icon(Icons.copy_rounded, size: 20),
                  color: AppColors.textPrimary,
                ),
                IconButton(
                  tooltip: LocaleKeys.programs_show_qr.tr(),
                  onPressed: () => ProgramQrDisplaySheet.show(
                    context,
                    program: program,
                  ),
                  icon: const Icon(Icons.qr_code_2_rounded, size: 22),
                  color: AppColors.primary,
                ),
              ]
            : null,
      ),
      body: ProgramDetailsBody(
        program: program,
        isAdmin: isAdmin,
      ),
    );
  }
}
