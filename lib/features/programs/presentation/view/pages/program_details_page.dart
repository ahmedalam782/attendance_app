import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toastification/toastification.dart';

import '../../../../../core/common/widgets/custom_app_bar.dart';
import '../../../../../core/common/widgets/custom_toast.dart';
import '../../../../../core/dependency_injection/injected_bloc_provider.dart';
import '../../../../../core/languages/locale_keys.g.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/program.dart';
import '../../../../attendance/presentation/view_model/cubit/attendance_cubit.dart';
import '../../../../enrollment/presentation/view_model/cubit/enrollment_cubit.dart';
import '../../../../sessions/presentation/view_model/cubit/sessions_cubit.dart';
import '../widgets/program_details_body.dart';
import '../widgets/program_qr_display_sheet.dart';

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
        child: InjectedBlocProvider<AttendanceCubit>(child: this),
      ),
    );
  }

  void _copyInviteCode(BuildContext context) {
    Clipboard.setData(ClipboardData(text: program.inviteCode));
    CustomToast(
      context: context,
      header: LocaleKeys.programs_code_copied.tr(),
      type: ToastificationType.success,
    ).showToast();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: program.title,
        backgroundColor: AppColors.background,
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: LocaleKeys.programs_copy_code.tr(),
            onPressed: () => _copyInviteCode(context),
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
        ],
      ),
      body: ProgramDetailsBody(
        program: program,
        isAdmin: isAdmin,
      ),
    );
  }
}
