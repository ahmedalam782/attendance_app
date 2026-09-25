import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

import '../../../../../core/common/widgets/ambient_glow_background.dart';
import '../../../../../core/common/widgets/custom_confirmation_bottom_sheet.dart';
import '../../../../../core/common/widgets/custom_toast.dart';
import '../../../../../core/common/widgets/empty_state_card.dart';
import '../../../../../core/languages/locale_keys.g.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../attendance/presentation/view/widgets/session_attendance_sheet.dart';
import '../../../../enrollment/presentation/view/widgets/add_student_sheet.dart';
import '../../../../enrollment/presentation/view/widgets/csv_import_sheet.dart';
import '../../../../enrollment/presentation/view/widgets/student_roster_tile.dart';
import '../../../../enrollment/presentation/view_model/cubit/enrollment_cubit.dart';
import '../../../../enrollment/presentation/view_model/cubit/enrollment_state.dart';
import '../../../domain/entities/program.dart';
import '../../../../sessions/domain/entities/session.dart';
import '../../../../sessions/domain/params/delete_session_params.dart';
import '../../../../sessions/domain/params/update_session_status_params.dart';
import '../../../../sessions/presentation/view/widgets/create_session_sheet.dart';
import '../../../../sessions/presentation/view/widgets/dynamic_session_qr_sheet.dart';
import '../../../../sessions/presentation/view/widgets/edit_session_sheet.dart';
import '../../../../sessions/presentation/view/widgets/session_card.dart';
import '../../../../sessions/presentation/view_model/cubit/sessions_cubit.dart';
import '../../../../sessions/presentation/view_model/cubit/sessions_state.dart';
import '../../../../student/presentation/view/widgets/student_scanner_sheet.dart';

class ProgramDetailsBody extends StatefulWidget {
  const ProgramDetailsBody({
    super.key,
    required this.program,
    this.isAdmin = false,
  });

  final Program program;
  final bool isAdmin;

  @override
  State<ProgramDetailsBody> createState() => _ProgramDetailsBodyState();
}

class _ProgramDetailsBodyState extends State<ProgramDetailsBody> {
  int _selectedTabIndex = 0; // 0: Sessions, 1: Students (Roster)
  final _rosterSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<SessionsCubit>().watchSessions(widget.program.id);
    if (widget.isAdmin) {
      context.read<EnrollmentCubit>().watchProgramStudents(widget.program.id);
    }
  }

  @override
  void dispose() {
    _rosterSearchController.dispose();
    super.dispose();
  }

  void _copyInviteCode() {
    Clipboard.setData(ClipboardData(text: widget.program.inviteCode));
    CustomToast(
      context: context,
      header: LocaleKeys.programs_code_copied.tr(),
      type: ToastificationType.success,
    ).showToast();
  }

  void _openCreateSessionSheet() {
    CreateSessionSheet.show(context, programId: widget.program.id);
  }

  void _openAddStudentSheet() {
    AddStudentSheet.show(context, programId: widget.program.id);
  }

  void _openCsvImportSheet() {
    CsvImportSheet.show(context, programId: widget.program.id);
  }

  void _openSessionAttendance(Session session) {
    SessionAttendanceSheet.show(
      context,
      program: widget.program,
      session: session,
      isAdmin: widget.isAdmin,
    );
  }

  void _openDynamicSessionQr(Session session) {
    DynamicSessionQrSheet.show(
      context,
      session: session,
      programTitle: widget.program.title,
    );
  }

  Future<void> _onStatusChange(String sessionId, String newStatus) async {
    if (newStatus == 'closed') {
      final confirmed = await CustomConfirmationBottomSheet.show(
        context,
        title: LocaleKeys.sessions_close_confirm_title.tr(),
        message: LocaleKeys.sessions_close_confirm_desc.tr(),
        confirmLabel: LocaleKeys.sessions_close_session.tr(),
        cancelLabel: LocaleKeys.global_cancel.tr(),
        isDestructive: true,
        icon: Icons.stop_circle_outlined,
      );
      if (confirmed != true || !mounted) return;
    }

    if (!mounted) return;
    final success = await context.read<SessionsCubit>().updateStatus(
          UpdateSessionStatusParams(
            programId: widget.program.id,
            sessionId: sessionId,
            status: newStatus,
          ),
        );

    if (success && newStatus == 'open' && mounted) {
      final session = context
          .read<SessionsCubit>()
          .state
          .sessions
          .where((s) => s.id == sessionId)
          .firstOrNull;
      if (session != null && mounted) {
        _openDynamicSessionQr(session.copyWith(status: 'open'));
      }
    }
  }

  Future<void> _openEditSession(Session session) async {
    await EditSessionSheet.show(
      context,
      programId: widget.program.id,
      session: session,
    );
  }

  Future<void> _confirmDeleteSession(Session session) async {
    final confirmed = await CustomConfirmationBottomSheet.show(
      context,
      title: LocaleKeys.sessions_delete_confirm_title.tr(),
      message: LocaleKeys.sessions_delete_confirm_desc.tr(
        namedArgs: {'title': session.title},
      ),
      confirmLabel: LocaleKeys.sessions_delete_session.tr(),
      cancelLabel: LocaleKeys.global_cancel.tr(),
      isDestructive: true,
      icon: Icons.delete_outline_rounded,
    );
    if (confirmed != true || !mounted) return;

    final success = await context.read<SessionsCubit>().deleteSession(
          DeleteSessionParams(
            programId: widget.program.id,
            sessionId: session.id,
          ),
        );
    if (success && mounted) {
      CustomToast(
        context: context,
        header: LocaleKeys.sessions_deleted_success.tr(),
        type: ToastificationType.success,
      ).showToast();
    }
  }

  Color get _typeColor {
    if (widget.program.isBootcamp) return AppColors.late;
    if (widget.program.isEvent) return AppColors.accent;
    return AppColors.primerColor;
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');

    return Stack(
      children: [
        const AmbientGlowBackground(variant: AmbientGlowVariant.auth),
        Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Program Overview Card
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.cardSurface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.slate200),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _typeColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    widget.program.type.toUpperCase(),
                                    style: 11.bold.copyWith(color: _typeColor),
                                  ),
                                ),
                                const Spacer(),
                                BlocBuilder<EnrollmentCubit, EnrollmentState>(
                                  builder: (context, enrollState) {
                                    final count = enrollState.students.isNotEmpty
                                        ? enrollState.students.length
                                        : widget.program.studentCount;
                                    return Row(
                                      children: [
                                        const Icon(
                                          Icons.people_outline_rounded,
                                          size: 15,
                                          color: AppColors.slate400,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '$count enrolled',
                                          style: 12.medium.copyWith(
                                            color: AppColors.slate600,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                            if (widget.program.description.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Text(
                                widget.program.description,
                                style: 13.regular.copyWith(
                                  color: AppColors.slate600,
                                  height: 1.4,
                                ),
                              ),
                            ],
                            if (widget.program.location.isNotEmpty ||
                                widget.program.startDate != null) ...[
                              const SizedBox(height: 14),
                              const Divider(height: 1, color: AppColors.slate100),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  if (widget.program.location.isNotEmpty) ...[
                                    const Icon(
                                      Icons.location_on_outlined,
                                      size: 14,
                                      color: AppColors.slate400,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        widget.program.location,
                                        style: 12.medium.copyWith(
                                          color: AppColors.slate500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                  if (widget.program.startDate != null) ...[
                                    const Icon(
                                      Icons.calendar_today_outlined,
                                      size: 13,
                                      color: AppColors.slate400,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      dateFormat.format(widget.program.startDate!),
                                      style: 12.medium.copyWith(
                                        color: AppColors.slate500,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Segmented Tab Switcher (Sessions vs Students) - Admin only
                      if (widget.isAdmin) ...[
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.slate100,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.slate200),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildSegmentButton(
                                  index: 0,
                                  title: LocaleKeys.programs_tab_sessions.tr(),
                                  icon: Icons.event_note_rounded,
                                ),
                              ),
                              Expanded(
                                child: _buildSegmentButton(
                                  index: 1,
                                  title: LocaleKeys.programs_tab_students.tr(),
                                  icon: Icons.people_alt_rounded,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                      ],

                      // Active Tab Content
                      if (!widget.isAdmin || _selectedTabIndex == 0)
                        _buildSessionsSection()
                      else
                        _buildStudentsSection(),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildSegmentButton({
    required int index,
    required String title,
    required IconData icon,
  }) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.primary : AppColors.slate500,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: isSelected
                  ? 13.bold.copyWith(color: AppColors.primary)
                  : 13.medium.copyWith(color: AppColors.slate600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              LocaleKeys.programs_tab_sessions.tr(),
              style: 16.bold.copyWith(color: AppColors.slate900),
            ),
            const Spacer(),
            if (widget.isAdmin)
              ElevatedButton.icon(
                onPressed: _openCreateSessionSheet,
                icon: const Icon(Icons.add_rounded, size: 16),
                label: Text(
                  LocaleKeys.sessions_create_title.tr(),
                  style: 12.bold,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
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
        const SizedBox(height: 12),
        BlocBuilder<SessionsCubit, SessionsState>(
          builder: (context, state) {
            if (state.sessions.isEmpty) {
              return EmptyStateCard(
                icon: Icons.event_note_outlined,
                title: LocaleKeys.sessions_empty_sessions.tr(),
                subtitle: LocaleKeys.sessions_empty_sessions_desc.tr(),
                actionTitle: widget.isAdmin
                    ? LocaleKeys.sessions_create_title.tr()
                    : null,
                actionIcon: Icons.add_rounded,
                onAction: widget.isAdmin ? _openCreateSessionSheet : null,
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.sessions.length,
              itemBuilder: (context, index) {
                final session = state.sessions[index];
                return SessionCard(
                  session: session,
                  isAdmin: widget.isAdmin,
                  onTap: widget.isAdmin
                      ? () => _openSessionAttendance(session)
                      : (session.isOpen
                          ? () => StudentScannerSheet.show(context)
                          : null),
                  onStatusChanged: widget.isAdmin
                      ? (newStatus) => _onStatusChange(session.id, newStatus)
                      : null,
                  onShowQr: widget.isAdmin ? () => _openDynamicSessionQr(session) : null,
                  onEdit: widget.isAdmin ? () => _openEditSession(session) : null,
                  onDelete: widget.isAdmin ? () => _confirmDeleteSession(session) : null,
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildStudentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              LocaleKeys.roster_title.tr(),
              style: 16.bold.copyWith(color: AppColors.slate900),
            ),
            const Spacer(),
            if (widget.isAdmin) ...[
              OutlinedButton.icon(
                onPressed: _openCsvImportSheet,
                icon: const Icon(Icons.file_upload_outlined, size: 15),
                label: Text(
                  'CSV',
                  style: 12.bold,
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primaryLight, width: 1.5),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _openAddStudentSheet,
                icon: const Icon(Icons.person_add_rounded, size: 16),
                label: Text(
                  LocaleKeys.roster_add_student.tr(),
                  style: 12.bold,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
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
          ],
        ),
        const SizedBox(height: 12),

        // Search text field
        TextField(
          controller: _rosterSearchController,
          onChanged: (val) {
            context.read<EnrollmentCubit>().updateSearchQuery(val);
          },
          decoration: InputDecoration(
            hintText: LocaleKeys.session_attendance_search_hint.tr(),
            hintStyle: 13.regular.copyWith(color: AppColors.slate400),
            prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.slate400),
            suffixIcon: _rosterSearchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 18),
                    onPressed: () {
                      _rosterSearchController.clear();
                      context.read<EnrollmentCubit>().updateSearchQuery('');
                      setState(() {});
                    },
                  )
                : null,
            filled: true,
            fillColor: AppColors.slate100,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Enrolled Students List
        BlocBuilder<EnrollmentCubit, EnrollmentState>(
          builder: (context, state) {
            final students = state.filteredStudents;

            if (students.isEmpty) {
              return EmptyStateCard(
                icon: Icons.people_outline_rounded,
                title: LocaleKeys.roster_empty_roster.tr(),
                subtitle: LocaleKeys.roster_empty_roster_desc.tr(),
                actionTitle: LocaleKeys.roster_share_code.tr(),
                actionIcon: Icons.share_rounded,
                onAction: _copyInviteCode,
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                return StudentRosterTile(
                  student: student,
                  isAdmin: widget.isAdmin,
                  onRemove: () {
                    context.read<EnrollmentCubit>().removeStudent(
                          programId: widget.program.id,
                          studentId: student.id,
                        );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}
