import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

import '../../../../../core/common/widgets/custom_app_bar.dart';
import '../../../../../core/common/widgets/custom_confirmation_bottom_sheet.dart';
import '../../../../../core/common/widgets/custom_toast.dart';
import '../../../../../core/dependency_injection/injected_bloc_provider.dart';
import '../../../../../core/languages/locale_keys.g.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../domain/entities/program.dart';
import '../../../../attendance/presentation/view_model/cubit/attendance_cubit.dart';
import '../../../../enrollment/presentation/view_model/cubit/enrollment_cubit.dart';
import '../../../../programs/presentation/view_model/cubit/programs_cubit.dart';
import '../../../../sessions/presentation/view_model/cubit/sessions_cubit.dart';
import '../utils/program_view_utils.dart';
import '../widgets/edit_program_sheet.dart';
import '../widgets/program_details_body.dart';
import '../widgets/program_qr_display_sheet.dart';

/// Thin RoutePage for Program Details adhering to Al Faris presentation architecture.
@RoutePage()
class ProgramDetailsPage extends StatefulWidget implements AutoRouteWrapper {
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
  State<ProgramDetailsPage> createState() => _ProgramDetailsPageState();
}

class _ProgramDetailsPageState extends State<ProgramDetailsPage> {
  late Program _program;

  @override
  void initState() {
    super.initState();
    _program = widget.program;
  }

  Future<void> _onEditProgram() async {
    final updated = await EditProgramSheet.show(context, program: _program);
    if (updated == true && mounted) {
      final cubit = context.read<ProgramsCubit>();
      final found = cubit.state.programs.where((p) => p.id == _program.id);
      if (found.isNotEmpty) {
        setState(() => _program = found.first);
      }
    }
  }

  Future<void> _onDeleteProgram() async {
    final confirmed = await CustomConfirmationBottomSheet.show(
      context,
      title: LocaleKeys.programs_delete_confirm_title.tr(),
      message: LocaleKeys.programs_delete_confirm_desc.tr(
        namedArgs: {'title': _program.title},
      ),
      confirmLabel: LocaleKeys.programs_delete_program.tr(),
      cancelLabel: LocaleKeys.global_cancel.tr(),
      isDestructive: true,
      icon: Icons.delete_outline_rounded,
    );
    if (confirmed != true || !mounted) return;

    final success = await context.read<ProgramsCubit>().deleteProgram(_program.id);
    if (success && mounted) {
      CustomToast(
        context: context,
        header: LocaleKeys.programs_deleted_success.tr(),
        type: ToastificationType.success,
      ).showToast();
      context.router.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: _program.title,
        backgroundColor: AppColors.background,
        centerTitle: false,
        actions: widget.isAdmin
            ? [
                IconButton(
                  tooltip: LocaleKeys.programs_copy_code.tr(),
                  onPressed: () => ProgramViewUtils.copyInviteCode(
                    context,
                    _program.inviteCode,
                  ),
                  icon: const Icon(Icons.copy_rounded, size: 20),
                  color: AppColors.textPrimary,
                ),
                IconButton(
                  tooltip: LocaleKeys.programs_show_qr.tr(),
                  onPressed: () => ProgramQrDisplaySheet.show(
                    context,
                    program: _program,
                  ),
                  icon: const Icon(Icons.qr_code_2_rounded, size: 22),
                  color: AppColors.primary,
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, size: 22, color: AppColors.textPrimary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  onSelected: (value) {
                    if (value == 'edit') _onEditProgram();
                    if (value == 'delete') _onDeleteProgram();
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(Icons.edit_outlined, size: 18, color: AppColors.slate700),
                          const SizedBox(width: 10),
                          Text(
                            LocaleKeys.programs_edit_program.tr(),
                            style: 13.medium.copyWith(color: AppColors.slate900),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.absent),
                          const SizedBox(width: 10),
                          Text(
                            LocaleKeys.programs_delete_program.tr(),
                            style: 13.medium.copyWith(color: AppColors.absent),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ]
            : null,
      ),
      body: ProgramDetailsBody(
        key: ValueKey(_program),
        program: _program,
        isAdmin: widget.isAdmin,
      ),
    );
  }
}
