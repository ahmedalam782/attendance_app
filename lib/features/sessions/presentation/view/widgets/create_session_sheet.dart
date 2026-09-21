import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

import '../../../../../core/common/widgets/custom_button.dart';
import '../../../../../core/common/widgets/custom_text_field.dart';
import '../../../../../core/common/widgets/custom_toast.dart';
import '../../../../../core/common/widgets/sheet_drag_handle.dart';
import '../../../../../core/languages/locale_keys.g.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../domain/params/create_session_params.dart';
import '../../view_model/cubit/sessions_cubit.dart';
import '../../view_model/cubit/sessions_state.dart';

class CreateSessionSheet extends StatefulWidget {
  const CreateSessionSheet({super.key, required this.programId});

  final String programId;

  static Future<bool?> show(BuildContext context, {required String programId}) {
    final cubit = context.read<SessionsCubit>();
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: CreateSessionSheet(programId: programId),
      ),
    );
  }

  @override
  State<CreateSessionSheet> createState() => _CreateSessionSheetState();
}

class _CreateSessionSheetState extends State<CreateSessionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();

  late DateTime _sessionDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  int _lateAfterMinutes = 15;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _sessionDate = DateTime(now.year, now.month, now.day);
    _startTime = TimeOfDay(hour: now.hour, minute: 0);
    _endTime = TimeOfDay(hour: (now.hour + 2) % 24, minute: 0);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _sessionDate,
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
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
        _endTime = TimeOfDay(hour: (picked.hour + 2) % 24, minute: picked.minute);
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

    final params = CreateSessionParams(
      programId: widget.programId,
      title: _titleController.text.trim(),
      startAt: startAt,
      endAt: endAt,
      lateAfterMinutes: _lateAfterMinutes,
    );

    final success = await context.read<SessionsCubit>().createSession(params);
    if (success && mounted) {
      CustomToast(
        context: context,
        header: LocaleKeys.sessions_created_success.tr(),
        type: ToastificationType.success,
      ).showToast();
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionsCubit, SessionsState>(
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SheetDragHandle(),
                  const SizedBox(height: 16),
                  Text(
                    LocaleKeys.sessions_create_title.tr(),
                    style: 20.bold.copyWith(color: AppColors.slate900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    LocaleKeys.sessions_create_subtitle.tr(),
                    style: 13.regular.copyWith(color: AppColors.slate400),
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
                    title: LocaleKeys.sessions_submit_create.tr(),
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
