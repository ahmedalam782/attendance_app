import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

import '../../../../../core/common/widgets/app_bottom_sheet.dart';
import '../../../../../core/common/widgets/app_date_picker.dart';
import '../../../../../core/common/widgets/custom_button.dart';
import '../../../../../core/common/widgets/custom_text_field.dart';
import '../../../../../core/common/widgets/custom_toast.dart';
import '../../../../../core/languages/locale_keys.g.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../domain/entities/session.dart';
import '../../../domain/params/update_session_params.dart';
import '../../view_model/cubit/sessions_cubit.dart';
import '../../view_model/cubit/sessions_state.dart';

class EditSessionSheet extends StatefulWidget {
  const EditSessionSheet({
    super.key,
    required this.programId,
    required this.session,
  });

  final String programId;
  final Session session;

  static Future<bool?> show(
    BuildContext context, {
    required String programId,
    required Session session,
  }) {
    final cubit = context.read<SessionsCubit>();
    return showAppSheet<bool>(
      context,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: EditSessionSheet(programId: programId, session: session),
      ),
    );
  }

  @override
  State<EditSessionSheet> createState() => _EditSessionSheetState();
}

class _EditSessionSheetState extends State<EditSessionSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;

  late DateTime _sessionDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late int _lateAfterMinutes;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.session.title);
    _sessionDate = widget.session.startAt;
    _startTime = TimeOfDay.fromDateTime(widget.session.startAt);
    _endTime = TimeOfDay.fromDateTime(widget.session.endAt);
    _lateAfterMinutes = widget.session.lateAfterMinutes;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showAppDatePicker(
      context: context,
      initialDate: _sessionDate,
      firstDate: DateTime.now().subtract(const Duration(days: 90)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _sessionDate = picked);
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null) {
      setState(() => _endTime = picked);
    }
  }

  DateTime _combine(DateTime date, TimeOfDay time) =>
      DateTime(date.year, date.month, date.day, time.hour, time.minute);

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    final startAt = _combine(_sessionDate, _startTime);
    var endAt = _combine(_sessionDate, _endTime);
    if (endAt.isBefore(startAt)) {
      endAt = endAt.add(const Duration(days: 1));
    }

    final params = UpdateSessionParams(
      programId: widget.programId,
      sessionId: widget.session.id,
      title: _titleController.text.trim(),
      startAt: startAt,
      endAt: endAt,
      lateAfterMinutes: _lateAfterMinutes,
    );

    final success = await context.read<SessionsCubit>().updateSession(params);
    if (success && mounted) {
      CustomToast(
        context: context,
        header: LocaleKeys.sessions_updated_success.tr(),
        type: ToastificationType.success,
      ).showToast();
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionsCubit, SessionsState>(
      builder: (context, state) {
        return AppSheetPadding(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppSheetHeader(
                    title: LocaleKeys.sessions_edit_session.tr(),
                    subtitle: LocaleKeys.sessions_edit_session_subtitle.tr(),
                  ),
                  const SizedBox(height: 20),

                  // Title Field
                  CustomTextFormField(
                    controller: _titleController,
                    hintText: LocaleKeys.sessions_title_hint.tr(),
                    prefixIcon: Icons.event_note_rounded,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return LocaleKeys.sessions_title_required.tr();
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Session Date
                  OutlinedButton.icon(
                    onPressed: _pickDate,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      side: const BorderSide(color: AppColors.slate200),
                    ),
                    icon: const Icon(
                      Icons.calendar_today_rounded,
                      size: 16,
                      color: AppColors.slate500,
                    ),
                    label: Text(
                      DateFormat('EEEE, MMM d, yyyy').format(_sessionDate),
                      style: 13.medium.copyWith(color: AppColors.slate900),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Times Row
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickStartTime,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            side: const BorderSide(color: AppColors.slate200),
                          ),
                          icon: const Icon(
                            Icons.access_time_rounded,
                            size: 16,
                            color: AppColors.slate500,
                          ),
                          label: Text(
                            'Start: ${_startTime.format(context)}',
                            style: 12.medium.copyWith(color: AppColors.slate900),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickEndTime,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            side: const BorderSide(color: AppColors.slate200),
                          ),
                          icon: const Icon(
                            Icons.schedule_rounded,
                            size: 16,
                            color: AppColors.slate500,
                          ),
                          label: Text(
                            'End: ${_endTime.format(context)}',
                            style: 12.medium.copyWith(color: AppColors.slate900),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Late grace minutes
                  Row(
                    children: [
                      Text(
                        '${LocaleKeys.sessions_late_after.tr()}:',
                        style: 13.medium.copyWith(color: AppColors.slate600),
                      ),
                      const Spacer(),
                      for (final mins in [10, 15, 30]) ...[
                        GestureDetector(
                          onTap: () => setState(() => _lateAfterMinutes = mins),
                          child: Container(
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: _lateAfterMinutes == mins
                                  ? AppColors.primary
                                  : AppColors.slate100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '+${mins}m',
                              style: (
                                _lateAfterMinutes == mins
                                    ? 12.bold
                                    : 12.medium
                              ).copyWith(
                                color: _lateAfterMinutes == mins
                                    ? Colors.white
                                    : AppColors.slate600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 22),

                  // Submit Button
                  CustomButton(
                    title: LocaleKeys.sessions_submit_update.tr(),
                    isLoading: state.isBusy,
                    onTap: state.isBusy ? null : _submit,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
