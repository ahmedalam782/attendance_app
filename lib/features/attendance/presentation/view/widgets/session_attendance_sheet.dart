import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

import '../../../../../core/common/widgets/app_bottom_sheet.dart';
import '../../../../../core/common/widgets/custom_confirmation_bottom_sheet.dart';
import '../../../../../core/common/widgets/custom_toast.dart';
import '../../../../../core/common/widgets/empty_state_card.dart';
import '../../../../../core/common/widgets/status_chip.dart';
import '../../../../../core/languages/locale_keys.g.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
import 'admin_session_scanner_sheet.dart';

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

    return showAppSheet(
      context,
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
    if (widget.isAdmin) {
      context.read<AttendanceCubit>().setActiveSession(widget.session);
    }
  }

  void _onStudentTap(EnrolledStudent student, AttendanceRecord? existingRecord) {
    if (!widget.isAdmin) return;

    showAppSheet<void>(
      context,
      builder: (bottomSheetContext) {
        return AppSheetPadding(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                bottomSheetContext,
                title: LocaleKeys.session_attendance_status_present.tr(),
                status: 'present',
                color: AppColors.present,
                icon: Icons.check_circle_outline_rounded,
                student: student,
              ),
              const SizedBox(height: 8),
              _buildStatusOption(
                bottomSheetContext,
                title: LocaleKeys.session_attendance_status_late.tr(),
                status: 'late',
                color: AppColors.late,
                icon: Icons.access_time_rounded,
                student: student,
              ),
              const SizedBox(height: 8),
              _buildStatusOption(
                bottomSheetContext,
                title: LocaleKeys.session_attendance_status_excused.tr(),
                status: 'excused',
                color: AppColors.excused,
                icon: Icons.info_outline_rounded,
                student: student,
              ),
              const SizedBox(height: 8),
              _buildStatusOption(
                bottomSheetContext,
                title: LocaleKeys.session_attendance_status_absent.tr(),
                status: 'absent',
                color: AppColors.absent,
                icon: Icons.cancel_outlined,
                student: student,
              ),
              if (existingRecord != null) ...[
                const SizedBox(height: 12),
                const Divider(color: AppColors.slate200, height: 1),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () {
                    Navigator.of(bottomSheetContext).pop();
                    _confirmDeleteAttendance(student);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.absent.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.absent.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.delete_outline_rounded, color: AppColors.absent, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          LocaleKeys.attendance_delete_record.tr(),
                          style: 14.bold.copyWith(color: AppColors.absent),
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.absent),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDeleteAttendance(EnrolledStudent student) async {
    final confirmed = await CustomConfirmationBottomSheet.show(
      context,
      title: LocaleKeys.attendance_delete_record_confirm_title.tr(),
      message: LocaleKeys.attendance_delete_record_confirm_desc.tr(
        namedArgs: {'name': student.name},
      ),
      confirmLabel: LocaleKeys.attendance_delete_record.tr(),
      cancelLabel: LocaleKeys.global_cancel.tr(),
      isDestructive: true,
      icon: Icons.delete_outline_rounded,
    );
    if (confirmed != true || !mounted) return;

    final success = await context.read<AttendanceCubit>().deleteAttendance(
          programId: widget.program.id,
          sessionId: widget.session.id,
          studentId: student.id,
        );
    if (success && mounted) {
      CustomToast(
        context: context,
        header: LocaleKeys.attendance_record_deleted.tr(),
        type: ToastificationType.success,
      ).showToast();
    }
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
    final scannedBy = FirebaseAuth.instance.currentUser?.uid ?? 'admin';

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

  Future<void> _confirmMarkAllAbsent(
      List<EnrolledStudent> unmarkedStudents) async {
    if (unmarkedStudents.isEmpty) return;

    final confirmed = await CustomConfirmationBottomSheet.show(
      context,
      title: LocaleKeys.auto_absent_confirm_title.tr(),
      message: LocaleKeys.auto_absent_confirm_desc.tr(
        namedArgs: {'count': unmarkedStudents.length.toString()},
      ),
      confirmLabel: LocaleKeys.auto_absent_mark_all_unmarked.tr(),
      cancelLabel: LocaleKeys.global_cancel.tr(),
      isDestructive: true,
      icon: Icons.person_off_rounded,
    );
    if (confirmed != true || !mounted) return;

    final scannedBy = FirebaseAuth.instance.currentUser?.uid ?? 'admin';
    final names = {for (final s in unmarkedStudents) s.id: s.name};
    final count = await context.read<AttendanceCubit>().markUnmarkedStudentsAbsent(
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
  }

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('h:mm a');

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.only(top: 48),
      child: Column(
        children: [

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
                        maxLines: 2,
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
                    onPressed: () => AdminSessionScannerSheet.show(
                      context,
                      session: widget.session,
                      program: widget.program,
                    ),
                    icon: const Icon(
                      Icons.camera_alt_rounded,
                      color: AppColors.present,
                      size: 22,
                    ),
                    tooltip: LocaleKeys.admin_scanner_open_camera.tr(),
                  ),
                  const SizedBox(width: 4),
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
                        if (attendanceState.pendingSyncCount > 0)
                          Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 4,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.late.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.late.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.sync_rounded,
                                  size: 15,
                                  color: AppColors.late,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    LocaleKeys.attendance_pending_sync.tr(
                                      namedArgs: {
                                        'count':
                                            '${attendanceState.pendingSyncCount}',
                                      },
                                    ),
                                    style: 11.semiBold.copyWith(
                                      color: AppColors.late,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (widget.isAdmin && unmarked.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 4,
                            ),
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    '${students.length} students • ${unmarked.length} unmarked',
                                    style: 12.medium.copyWith(
                                      color: AppColors.slate500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
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
                                          Flexible(
                                            child: Text(
                                              student.id,
                                              style: 11.medium.copyWith(
                                                color: AppColors.slate500,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (record != null) ...[
                                            const SizedBox(width: 6),
                                            Flexible(
                                              child: Text(
                                                '• ${DateFormat('h:mm a').format(record.scannedAt)}',
                                                style: 11.regular.copyWith(
                                                  color: AppColors.slate400,
                                                ),
                                                overflow: TextOverflow.ellipsis,
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
                                if (record != null) ...[
                                  if (record.isPendingSync) ...[
                                    Tooltip(
                                      message: LocaleKeys.attendance_pending_sync
                                          .tr(namedArgs: {'count': '1'}),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.late
                                              .withValues(alpha: 0.12),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.sync_rounded,
                                              size: 11,
                                              color: AppColors.late,
                                            ),
                                            const SizedBox(width: 3),
                                            Text(
                                              'Sync',
                                              style: 9.bold.copyWith(
                                                color: AppColors.late,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                  ],
                                  StatusChip.fromString(record.status),
                                ] else
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
