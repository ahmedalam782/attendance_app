import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

import '../../../../../core/common/widgets/custom_toast.dart';
import '../../../../../core/common/widgets/empty_state_card.dart';
import '../../../../../core/common/widgets/status_chip.dart';
import '../../../../../core/languages/locale_keys.g.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../auth/presentation/view_model/cubit/auth_cubit.dart';
import '../../../../enrollment/domain/entities/enrolled_student.dart';
import '../../../../enrollment/presentation/view_model/cubit/enrollment_cubit.dart';
import '../../../../enrollment/presentation/view_model/cubit/enrollment_state.dart';
import '../../../../programs/domain/entities/program.dart';
import '../../../../sessions/domain/entities/session.dart';
import '../../../../sessions/presentation/view/widgets/dynamic_session_qr_sheet.dart';
import '../../../domain/entities/attendance_record.dart';
import '../../../domain/params/record_attendance_params.dart';
import '../../view_model/cubit/attendance_cubit.dart';
import '../../view_model/cubit/attendance_state.dart';

class SessionAttendanceSheet extends StatefulWidget {
  const SessionAttendanceSheet({
    super.key,
    required this.program,
    required this.session,
    this.isAdmin = false,
  });

  final Program program;
  final Session session;
  final bool isAdmin;

  static Future<void> show(
    BuildContext context, {
    required Program program,
    required Session session,
    bool isAdmin = false,
  }) {
    final enrollmentCubit = context.read<EnrollmentCubit>();
    final attendanceCubit = context.read<AttendanceCubit>();

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: enrollmentCubit),
          BlocProvider.value(value: attendanceCubit),
        ],
        child: SessionAttendanceSheet(
          program: program,
          session: session,
          isAdmin: isAdmin,
        ),
      ),
    );
  }

  @override
  State<SessionAttendanceSheet> createState() => _SessionAttendanceSheetState();
}

class _SessionAttendanceSheetState extends State<SessionAttendanceSheet> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<EnrollmentCubit>().watchProgramStudents(widget.program.id);
    context
        .read<AttendanceCubit>()
        .watchSessionAttendance(widget.program.id, widget.session.id);
  }

  void _onStudentTap(EnrolledStudent student, AttendanceRecord? existingRecord) {
    if (!widget.isAdmin) return;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.slate300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                student.name,
                style: 16.bold.copyWith(color: AppColors.slate900),
              ),
              Text(
                LocaleKeys.session_attendance_mark_status.tr(),
                style: 13.medium.copyWith(color: AppColors.slate500),
              ),
              const SizedBox(height: 18),
              _buildStatusOption(
                context,
                title: LocaleKeys.session_attendance_status_present.tr(),
                status: 'present',
                color: AppColors.present,
                icon: Icons.check_circle_outline_rounded,
                student: student,
              ),
              const SizedBox(height: 8),
              _buildStatusOption(
                context,
                title: LocaleKeys.session_attendance_status_late.tr(),
                status: 'late',
                color: AppColors.late,
                icon: Icons.access_time_rounded,
                student: student,
              ),
              const SizedBox(height: 8),
              _buildStatusOption(
                context,
                title: LocaleKeys.session_attendance_status_excused.tr(),
                status: 'excused',
                color: AppColors.excused,
                icon: Icons.info_outline_rounded,
                student: student,
              ),
              const SizedBox(height: 8),
              _buildStatusOption(
                context,
                title: LocaleKeys.session_attendance_status_absent.tr(),
                status: 'absent',
                color: AppColors.absent,
                icon: Icons.cancel_outlined,
                student: student,
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusOption(
    BuildContext ctx, {
    required String title,
    required String status,
    required Color color,
    required IconData icon,
    required EnrolledStudent student,
  }) {
    return InkWell(
      onTap: () {
        Navigator.of(ctx).pop();
        _markStatus(student, status);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(
              title,
              style: 14.bold.copyWith(color: color),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: color),
          ],
        ),
      ),
    );
  }

  void _markStatus(EnrolledStudent student, String newStatus) {
    final adminUser = context.read<AuthCubit>().state.authState.data;
    final scannedBy = adminUser?.id ?? 'admin';

    context.read<AttendanceCubit>().recordManualAttendance(
          RecordAttendanceParams(
            programId: widget.program.id,
            sessionId: widget.session.id,
            studentId: student.id,
            studentName: student.name,
            scannedBy: scannedBy,
            status: newStatus,
            method: 'manual',
          ),
        );

    CustomToast(
      context: context,
      header: LocaleKeys.session_attendance_marked_success.tr(
        namedArgs: {'name': student.name},
      ),
      type: ToastificationType.success,
    ).showToast();
  }

  void _confirmMarkAllAbsent(List<EnrolledStudent> unmarkedStudents) {
    if (unmarkedStudents.isEmpty) return;

    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(LocaleKeys.auto_absent_confirm_title.tr(), style: 16.bold),
        content: Text(
          LocaleKeys.auto_absent_confirm_desc.tr(
            namedArgs: {'count': unmarkedStudents.length.toString()},
          ),
          style: 13.regular,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(LocaleKeys.global_cancel.tr(), style: 13.medium),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              final adminUser = context.read<AuthCubit>().state.authState.data;
              final scannedBy = adminUser?.id ?? 'admin';
              final names = {for (final s in unmarkedStudents) s.id: s.name};
              final count = await context
                  .read<AttendanceCubit>()
                  .markUnmarkedStudentsAbsent(
                    programId: widget.program.id,
                    sessionId: widget.session.id,
                    studentIds: unmarkedStudents.map((s) => s.id).toList(),
                    studentNames: names,
                    scannedBy: scannedBy,
                  );

              if (mounted && count > 0) {
                CustomToast(
                  context: context,
                  header: LocaleKeys.auto_absent_success.tr(
                    namedArgs: {'count': count.toString()},
                  ),
                  type: ToastificationType.success,
                ).showToast();
              }
            },
            child: Text(
              LocaleKeys.auto_absent_mark_all_unmarked.tr(),
              style: 13.bold.copyWith(color: AppColors.absent),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('h:mm a');

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.only(top: 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.slate300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header: Session info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.session.title,
                        style: 18.bold.copyWith(color: AppColors.slate900),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${DateFormat('EEE, MMM d').format(widget.session.startAt)} • ${timeFormat.format(widget.session.startAt)}',
                        style: 12.medium.copyWith(color: AppColors.slate500),
                      ),
                    ],
                  ),
                ),
                if (widget.isAdmin && widget.session.isOpen) ...[
                  IconButton(
                    onPressed: () => DynamicSessionQrSheet.show(
                      context,
                      session: widget.session,
                      programTitle: widget.program.title,
                    ),
                    icon: const Icon(
                      Icons.qr_code_2_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                    tooltip: LocaleKeys.dynamic_qr_display_qr.tr(),
                  ),
                  const SizedBox(width: 4),
                ],
                StatusChip.fromString(widget.session.status),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Search input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
              decoration: InputDecoration(
                hintText: LocaleKeys.session_attendance_search_hint.tr(),
                hintStyle: 13.regular.copyWith(color: AppColors.slate400),
                prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.slate400),
                filled: true,
                fillColor: AppColors.slate100,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // List of Enrolled Students with Attendance Status
          Expanded(
            child: BlocBuilder<EnrollmentCubit, EnrollmentState>(
              builder: (context, enrollmentState) {
                return BlocBuilder<AttendanceCubit, AttendanceState>(
                  builder: (context, attendanceState) {
                    final students = enrollmentState.students.where((s) {
                      if (_searchQuery.isEmpty) return true;
                      final q = _searchQuery.toLowerCase();
                      return s.name.toLowerCase().contains(q) ||
                          s.id.toLowerCase().contains(q);
                    }).toList();

                    if (students.isEmpty) {
                      return EmptyStateCard(
                        icon: Icons.people_outline_rounded,
                        title: LocaleKeys.roster_empty_roster.tr(),
                        subtitle: LocaleKeys.roster_empty_roster_desc.tr(),
                      );
                    }

                    // Map attendance by studentId
                    final attendanceMap = <String, AttendanceRecord>{};
                    for (final rec in attendanceState.records) {
                      attendanceMap[rec.studentId] = rec;
                    }

                    final unmarked =
                        students.where((s) => !attendanceMap.containsKey(s.id)).toList();

                    return Column(
                      children: [
                        if (widget.isAdmin && unmarked.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 4,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '${students.length} students • ${unmarked.length} unmarked',
                                  style: 12.medium.copyWith(
                                    color: AppColors.slate500,
                                  ),
                                ),
                                const Spacer(),
                                TextButton.icon(
                                  onPressed: () =>
                                      _confirmMarkAllAbsent(unmarked),
                                  icon: const Icon(
                                    Icons.person_off_outlined,
                                    size: 14,
                                    color: AppColors.absent,
                                  ),
                                  label: Text(
                                    LocaleKeys.auto_absent_mark_all_unmarked
                                        .tr(),
                                    style: 11.bold.copyWith(
                                      color: AppColors.absent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            itemCount: students.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final student = students[index];
                              final record = attendanceMap[student.id];

                        return InkWell(
                          onTap: widget.isAdmin
                              ? () => _onStudentTap(student, record)
                              : null,
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.cardSurface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: record != null
                                    ? AppColors.primary.withValues(alpha: 0.2)
                                    : AppColors.slate200,
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: record != null
                                      ? AppColors.present.withValues(alpha: 0.1)
                                      : AppColors.slate200,
                                  child: Icon(
                                    record != null
                                        ? Icons.check_rounded
                                        : Icons.person_outline_rounded,
                                    size: 18,
                                    color: record != null
                                        ? AppColors.present
                                        : AppColors.slate500,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        student.name,
                                        style: 14.bold.copyWith(
                                          color: AppColors.slate900,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Text(
                                            student.id,
                                            style: 11.medium.copyWith(
                                              color: AppColors.slate500,
                                            ),
                                          ),
                                          if (record != null) ...[
                                            const SizedBox(width: 6),
                                            Text(
                                              '• ${DateFormat('h:mm a').format(record.scannedAt)}',
                                              style: 11.regular.copyWith(
                                                color: AppColors.slate400,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Icon(
                                              record.isManual
                                                  ? Icons.touch_app_rounded
                                                  : Icons.qr_code_2_rounded,
                                              size: 12,
                                              color: AppColors.slate400,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                if (record != null)
                                  StatusChip.fromString(record.status)
                                else
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.slate100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      LocaleKeys.session_attendance_status_not_marked.tr(),
                                      style: 10.bold.copyWith(
                                        color: AppColors.slate500,
                                      ),
                                    ),
                                  ),
                                if (widget.isAdmin) ...[
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.edit_note_rounded,
                                    size: 18,
                                    color: AppColors.slate400,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    ),
        ],
      ),
    );
  }
}
