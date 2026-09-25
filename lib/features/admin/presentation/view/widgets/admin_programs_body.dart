import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:toastification/toastification.dart';

import '../../../../../core/common/widgets/ambient_glow_background.dart';
import '../../../../../core/common/widgets/custom_confirmation_bottom_sheet.dart';
import '../../../../../core/common/widgets/custom_toast.dart';
import '../../../../../core/common/widgets/empty_state_card.dart';
import '../../../../../core/common/widgets/feature_page_header.dart';
import '../../../../../core/common/widgets/role_badge.dart';
import '../../../../../core/languages/locale_keys.g.dart';
import '../../../../../core/routes/app_router.gr.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../programs/domain/entities/program.dart';
import '../../../../programs/presentation/view/widgets/create_program_sheet.dart';
import '../../../../programs/presentation/view/widgets/edit_program_sheet.dart';
import '../../../../programs/presentation/view/widgets/program_card.dart';
import '../../../../programs/presentation/view_model/cubit/programs_cubit.dart';
import '../../../../programs/presentation/view_model/cubit/programs_state.dart';

class AdminProgramsBody extends StatefulWidget {
  const AdminProgramsBody({super.key});

  @override
  State<AdminProgramsBody> createState() => _AdminProgramsBodyState();
}

class _AdminProgramsBodyState extends State<AdminProgramsBody> {
  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    if (_uid.isNotEmpty) {
      context.read<ProgramsCubit>().watchAdminPrograms(_uid);
    }
  }

  void _openCreateProgram() {
    if (_uid.isEmpty) return;
    CreateProgramSheet.show(context, ownerId: _uid);
  }

  Future<void> _confirmDeleteProgram(Program program) async {
    final confirmed = await CustomConfirmationBottomSheet.show(
      context,
      title: LocaleKeys.programs_delete_confirm_title.tr(),
      message: LocaleKeys.programs_delete_confirm_desc.tr(
        namedArgs: {'title': program.title},
      ),
      confirmLabel: LocaleKeys.programs_delete_program.tr(),
      cancelLabel: LocaleKeys.global_cancel.tr(),
      isDestructive: true,
      icon: Icons.delete_outline_rounded,
    );
    if (confirmed != true || !mounted) return;

    final success = await context.read<ProgramsCubit>().deleteProgram(program.id);
    if (success && mounted) {
      CustomToast(
        context: context,
        header: LocaleKeys.programs_deleted_success.tr(),
        type: ToastificationType.success,
      ).showToast();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const AmbientGlowBackground(variant: AmbientGlowVariant.auth),
        SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: FeaturePageHeader(
                    title: LocaleKeys.admin_programs_title.tr(),
                    subtitle: LocaleKeys.admin_programs_subtitle.tr(),
                    showOfflinePill: true,
                    leading: RoleBadge(
                      label: LocaleKeys.home_verified_admin.tr(),
                      icon: Icons.shield_rounded,
                      color: AppColors.primerColor,
                    ),
                  ),
                ),
              ),
              BlocBuilder<ProgramsCubit, ProgramsState>(
                builder: (context, state) {
                  if (state.programs.isEmpty) {
                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: EmptyStateCard(
                          icon: Icons.school_rounded,
                          title: LocaleKeys.admin_programs_empty_title.tr(),
                          subtitle: LocaleKeys.admin_programs_empty_subtitle.tr(),
                          actionTitle: LocaleKeys.admin_programs_add.tr(),
                          actionIcon: Icons.add_rounded,
                          onAction: _openCreateProgram,
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  Text(
                                    '${state.programs.length} ${state.programs.length == 1 ? 'Program' : 'Programs'}',
                                    style: 13.bold.copyWith(
                                      color: AppColors.slate600,
                                    ),
                                  ),
                                  const Spacer(),
                                  ElevatedButton.icon(
                                    onPressed: _openCreateProgram,
                                    icon: const Icon(Icons.add_rounded, size: 16),
                                    label: Text(
                                      LocaleKeys.admin_programs_add.tr(),
                                      style: 12.bold,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      elevation: 0,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          final program = state.programs[index - 1];
                          return ProgramCard(
                            program: program,
                            showInviteCode: true,
                            isAdmin: true,
                            onEdit: () => EditProgramSheet.show(context, program: program),
                            onDelete: () => _confirmDeleteProgram(program),
                            onTap: () {
                              context.router.push(
                                ProgramDetailsRoute(
                                  program: program,
                                  isAdmin: true,
                                ),
                              );
                            },
                          );
                        },
                        childCount: state.programs.length + 1,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
