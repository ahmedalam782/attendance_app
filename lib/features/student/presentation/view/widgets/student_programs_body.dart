import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/common/widgets/ambient_glow_background.dart';
import '../../../../../core/common/widgets/empty_state_card.dart';
import '../../../../../core/common/widgets/feature_page_header.dart';
import '../../../../../core/common/widgets/role_badge.dart';
import '../../../../../core/languages/locale_keys.g.dart';
import '../../../../../core/routes/app_router.gr.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../programs/presentation/view/widgets/join_program_sheet.dart';
import '../../../../programs/presentation/view/widgets/program_card.dart';
import '../../../../programs/presentation/view_model/cubit/programs_cubit.dart';
import '../../../../programs/presentation/view_model/cubit/programs_state.dart';
import 'student_scanner_sheet.dart';

class StudentProgramsBody extends StatefulWidget {
  const StudentProgramsBody({super.key});

  @override
  State<StudentProgramsBody> createState() => _StudentProgramsBodyState();
}

class _StudentProgramsBodyState extends State<StudentProgramsBody> {
  User? get _user => FirebaseAuth.instance.currentUser;
  String get _uid => _user?.uid ?? '';
  String get _displayName =>
      _user?.displayName ?? _user?.email?.split('@').first ?? 'Student';

  @override
  void initState() {
    super.initState();
    if (_uid.isNotEmpty) {
      context.read<ProgramsCubit>().watchStudentPrograms(_uid);
    }
  }

  void _openJoinProgram() {
    if (_uid.isEmpty) return;
    JoinProgramSheet.show(
      context,
      studentId: _uid,
      studentName: _displayName,
    );
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
                    title: LocaleKeys.student_programs_title.tr(),
                    subtitle: LocaleKeys.student_programs_subtitle.tr(),
                    showOfflinePill: true,
                    leading: RoleBadge(
                      label: LocaleKeys.home_verified_attendee.tr(),
                      icon: Icons.verified_user_rounded,
                      color: AppColors.accent,
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
                          icon: Icons.school_outlined,
                          title: LocaleKeys.student_programs_empty_title.tr(),
                          subtitle: LocaleKeys.student_programs_empty_subtitle.tr(),
                          iconColor: AppColors.accent,
                          actionTitle: LocaleKeys.student_join_with_code.tr(),
                          actionIcon: Icons.vpn_key_rounded,
                          onAction: _openJoinProgram,
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${state.programs.length} Enrolled',
                                    style: 13.bold.copyWith(
                                      color: AppColors.slate600,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () =>
                                            StudentScannerSheet.show(context),
                                        icon: const Icon(
                                          Icons.qr_code_scanner_rounded,
                                          size: 15,
                                        ),
                                        label: Text(
                                          LocaleKeys
                                              .self_check_in_scan_to_check_in
                                              .tr(),
                                          style: 12.bold,
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: AppColors.onPrimary,
                                          minimumSize: Size.zero,
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 10,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          elevation: 0,
                                        ),
                                      ),
                                      OutlinedButton.icon(
                                        onPressed: _openJoinProgram,
                                        icon: const Icon(
                                          Icons.vpn_key_rounded,
                                          size: 15,
                                        ),
                                        label: Text(
                                          LocaleKeys.student_join_with_code
                                              .tr(),
                                          style: 12.bold,
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppColors.accent,
                                          side: const BorderSide(
                                            color: AppColors.accent,
                                          ),
                                          minimumSize: Size.zero,
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 10,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }

                          final program = state.programs[index - 1];
                          return ProgramCard(
                            program: program,
                            showInviteCode: false,
                            onTap: () {
                              context.router.push(
                                ProgramDetailsRoute(
                                  program: program,
                                  isAdmin: false,
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
