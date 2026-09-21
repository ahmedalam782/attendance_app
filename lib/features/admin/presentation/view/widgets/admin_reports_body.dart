import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

import '../../../../../core/common/widgets/ambient_glow_background.dart';
import '../../../../../core/common/widgets/custom_button.dart';
import '../../../../../core/common/widgets/custom_toast.dart';
import '../../../../../core/common/widgets/feature_page_header.dart';
import '../../../../../core/languages/locale_keys.g.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../programs/presentation/view_model/cubit/programs_cubit.dart';
import '../../../../programs/presentation/view_model/cubit/programs_state.dart';
import '../../../../reports/presentation/view/widgets/attendance_rate_bar.dart';
import '../../../../reports/presentation/view/widgets/attendance_stat_card.dart';
import '../../../../reports/presentation/view_model/cubit/reports_cubit.dart';
import '../../../../reports/presentation/view_model/cubit/reports_state.dart';

class AdminReportsBody extends StatefulWidget {
  const AdminReportsBody({super.key});

  @override
  State<AdminReportsBody> createState() => _AdminReportsBodyState();
}

class _AdminReportsBodyState extends State<AdminReportsBody> {
  String get _adminUid => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    if (_adminUid.isNotEmpty) {
      context.read<ProgramsCubit>().watchAdminPrograms(_adminUid);
    }
    context.read<ReportsCubit>().loadReports();
  }

  Future<void> _exportCsv() async {
    final success = await context.read<ReportsCubit>().exportCsv();
    if (success && mounted) {
      CustomToast(
        context: context,
        header: LocaleKeys.reports_export_success.tr(),
        type: ToastificationType.success,
      ).showToast();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d • hh:mm a');

    return Stack(
      children: [
        const AmbientGlowBackground(variant: AmbientGlowVariant.auth),
        SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FeaturePageHeader(
                        title: LocaleKeys.admin_reports_title.tr(),
                        subtitle: LocaleKeys.admin_reports_subtitle.tr(),
                        showOfflinePill: true,
                      ),
                      const SizedBox(height: 18),

                      // Program Filter Chips
                      BlocBuilder<ProgramsCubit, ProgramsState>(
                        builder: (context, progState) {
                          return BlocBuilder<ReportsCubit, ReportsState>(
                            builder: (context, repState) {
                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    _buildFilterChip(
                                      title: LocaleKeys.reports_filter_all.tr(),
                                      isSelected:
                                          repState.selectedProgramId == null,
                                      onTap: () => context
                                          .read<ReportsCubit>()
                                          .loadReports(),
                                    ),
                                    for (final p in progState.programs) ...[
                                      const SizedBox(width: 8),
                                      _buildFilterChip(
                                        title: p.title,
                                        isSelected:
                                            repState.selectedProgramId == p.id,
                                        onTap: () => context
                                            .read<ReportsCubit>()
                                            .loadReports(
                                              programId: p.id,
                                              programTitle: p.title,
                                            ),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      // KPI Stats & Visual Breakdown
                      BlocBuilder<ReportsCubit, ReportsState>(
                        builder: (context, state) {
                          final stats = state.stats;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 2x2 Grid
                              Row(
                                children: [
                                  Expanded(
                                    child: AttendanceStatCard(
                                      title: LocaleKeys.reports_total_checkins
                                          .tr(),
                                      value: stats.totalCheckIns.toString(),
                                      icon: Icons.how_to_reg_rounded,
                                      accentColor: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: AttendanceStatCard(
                                      title: LocaleKeys.reports_presence_rate
                                          .tr(),
                                      value: '${stats.onTimePercentage}%',
                                      icon: Icons.verified_rounded,
                                      accentColor: AppColors.present,
                                      badge: 'On-Time',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: AttendanceStatCard(
                                      title: LocaleKeys.reports_late_rate.tr(),
                                      value: '${stats.latePercentage}%',
                                      icon: Icons.schedule_rounded,
                                      accentColor: AppColors.late,
                                      badge: 'Late',
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: AttendanceStatCard(
                                      title: LocaleKeys.reports_active_sessions
                                          .tr(),
                                      value: stats.totalSessions.toString(),
                                      icon: Icons.calendar_month_rounded,
                                      accentColor: AppColors.accent,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Visual segmented breakdown
                              AttendanceRateBar(stats: stats),
                              const SizedBox(height: 24),

                              // Session list section
                              if (state.sessionReports.isNotEmpty) ...[
                                Text(
                                  LocaleKeys.reports_sessions_breakdown.tr(),
                                  style: 15.bold.copyWith(
                                    color: AppColors.slate900,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                for (final s in state.sessionReports)
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: AppColors.cardSurface,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: AppColors.slate200,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                s.sessionTitle,
                                                style: 14.bold.copyWith(
                                                  color: AppColors.slate900,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                dateFormat.format(s.startAt),
                                                style: 11.medium.copyWith(
                                                  color: AppColors.slate500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.slate100,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            '${s.totalScans} scans',
                                            style: 12.bold.copyWith(
                                              color: AppColors.slate700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Export CSV Action Footer
              BlocBuilder<ReportsCubit, ReportsState>(
                builder: (context, state) {
                  return Container(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      border: const Border(
                        top: BorderSide(color: AppColors.slate200),
                      ),
                    ),
                    child: CustomButton(
                      title: LocaleKeys.reports_export_csv.tr(),
                      prefixIcon: const Icon(
                        Icons.file_download_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                      isLoading: state.isExporting,
                      onTap: state.isExporting ? null : _exportCsv,
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

  Widget _buildFilterChip({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.cardSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.slate200,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          style: (isSelected ? 12.bold : 12.medium).copyWith(
            color: isSelected ? Colors.white : AppColors.slate600,
          ),
        ),
      ),
    );
  }
}
