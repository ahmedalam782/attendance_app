import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/common/widgets/ambient_glow_background.dart';
import '../../../../../core/common/widgets/empty_state_card.dart';
import '../../../../../core/common/widgets/feature_page_header.dart';
import '../../../../../core/languages/locale_keys.g.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../attendance/presentation/view_model/cubit/attendance_cubit.dart';
import '../../../../attendance/presentation/view_model/cubit/attendance_state.dart';

class StudentHistoryBody extends StatefulWidget {
  const StudentHistoryBody({super.key});

  @override
  State<StudentHistoryBody> createState() => _StudentHistoryBodyState();
}

class _StudentHistoryBodyState extends State<StudentHistoryBody> {
  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    if (_uid.isNotEmpty) {
      context.read<AttendanceCubit>().watchStudentHistory(_uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEE, MMM d, yyyy • hh:mm a');

    return Stack(
      children: [
        const AmbientGlowBackground(variant: AmbientGlowVariant.auth),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FeaturePageHeader(
                  title: LocaleKeys.student_history_title.tr(),
                  subtitle: LocaleKeys.student_history_subtitle.tr(),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: BlocBuilder<AttendanceCubit, AttendanceState>(
                    builder: (context, state) {
                      if (state.history.isEmpty) {
                        return EmptyStateCard(
                          icon: Icons.history_toggle_off_rounded,
                          title: LocaleKeys.student_history_empty_title.tr(),
                          subtitle: LocaleKeys.student_history_empty_subtitle.tr(),
                          iconColor: AppColors.accent,
                        );
                      }

                      return ListView.builder(
                        itemCount: state.history.length,
                        itemBuilder: (context, index) {
                          final record = state.history[index];
                          final isPresent = record.isPresent;
                          final statusColor =
                              isPresent ? AppColors.present : AppColors.late;
                          final statusBg = isPresent
                              ? AppColors.emeraldLight
                              : AppColors.amberLight;
                          final statusText = isPresent
                              ? LocaleKeys.sessions_status_open.tr() // Present/Open
                              : 'Late';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.cardSurface,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppColors.slate200),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: statusBg,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: statusColor.withValues(alpha: 0.25),
                                    ),
                                  ),
                                  child: Icon(
                                    isPresent
                                        ? Icons.check_circle_rounded
                                        : Icons.access_time_filled_rounded,
                                    color: statusColor,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        record.sessionId,
                                        style: 14.bold.copyWith(
                                          color: AppColors.slate900,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        dateFormat.format(record.scannedAt),
                                        style: 11.regular.copyWith(
                                          color: AppColors.slate500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (record.isPendingSync) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.late
                                          .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: AppColors.late
                                            .withValues(alpha: 0.35),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.sync_rounded,
                                          size: 12,
                                          color: AppColors.late,
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          'Queued',
                                          style: 10.semiBold.copyWith(
                                            color: AppColors.late,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusBg,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: statusColor.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Text(
                                    statusText,
                                    style: 11.bold.copyWith(color: statusColor),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
