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
import '../../../domain/params/create_program_params.dart';
import '../../view_model/cubit/programs_cubit.dart';
import '../../view_model/cubit/programs_state.dart';

class CreateProgramSheet extends StatefulWidget {
  const CreateProgramSheet({super.key, required this.ownerId});

  final String ownerId;

  static Future<bool?> show(BuildContext context, {required String ownerId}) {
    final cubit = context.read<ProgramsCubit>();
    return showAppSheet<bool>(
      context,
      maxHeightFactor: 0.70,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: CreateProgramSheet(ownerId: ownerId),
      ),
    );
  }

  @override
  State<CreateProgramSheet> createState() => _CreateProgramSheetState();
}

class _CreateProgramSheetState extends State<CreateProgramSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedType = 'course';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange({bool isStart = true}) async {
    final now = DateTime.now();
    DateTimeRange? initialRange;
    if (_startDate != null && _endDate != null) {
      initialRange = DateTimeRange(start: _startDate!, end: _endDate!);
    } else if (_startDate != null) {
      initialRange = DateTimeRange(start: _startDate!, end: _startDate!);
    } else if (_endDate != null) {
      initialRange = DateTimeRange(start: _endDate!, end: _endDate!);
    }

    final picked = await showAppDateRangePicker(
      context: context,
      initialDateRange: initialRange,
      firstDate: now.subtract(const Duration(days: 60)),
      lastDate: now.add(const Duration(days: 365 * 3)),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    final params = CreateProgramParams(
      title: _titleController.text.trim(),
      type: _selectedType,
      ownerId: widget.ownerId,
      inviteCode: '', // auto-generated
      location: _locationController.text.trim(),
      description: _descriptionController.text.trim(),
      startDate: _startDate,
      endDate: _endDate,
    );

    final success = await context.read<ProgramsCubit>().createProgram(params);
    if (success && mounted) {
      CustomToast(
        context: context,
        header: LocaleKeys.programs_created_success.tr(),
        type: ToastificationType.success,
      ).showToast();
      Navigator.of(context).pop(true);
    }
  }

  Widget _buildTypeChip({
    required String type,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.12) : AppColors.slate50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : AppColors.slate200,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? color : AppColors.slate400,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: (isSelected ? 11.bold : 11.medium).copyWith(
                  color: isSelected ? color : AppColors.slate600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProgramsCubit, ProgramsState>(
      builder: (context, state) {
        return AppSheetPadding(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppSheetHeader(
                    title: LocaleKeys.programs_create_title.tr(),
                    subtitle: LocaleKeys.programs_create_subtitle.tr(),
                  ),
                  const SizedBox(height: 14),

                  // Type Selector
                  Row(
                    children: [
                      _buildTypeChip(
                        type: 'course',
                        label: LocaleKeys.programs_type_course.tr(),
                        icon: Icons.school_rounded,
                        color: AppColors.primerColor,
                      ),
                      const SizedBox(width: 8),
                      _buildTypeChip(
                        type: 'bootcamp',
                        label: LocaleKeys.programs_type_bootcamp.tr(),
                        icon: Icons.bolt_rounded,
                        color: AppColors.late,
                      ),
                      const SizedBox(width: 8),
                      _buildTypeChip(
                        type: 'event',
                        label: LocaleKeys.programs_type_event.tr(),
                        icon: Icons.event_available_rounded,
                        color: AppColors.accent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Title Field
                  CustomTextFormField(
                    controller: _titleController,
                    hintText: LocaleKeys.programs_title_hint.tr(),
                    prefixIcon: Icons.title_rounded,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return LocaleKeys.programs_title_required.tr();
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),

                  // Location Field
                  CustomTextFormField(
                    controller: _locationController,
                    hintText: LocaleKeys.programs_location_hint.tr(),
                    prefixIcon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 10),

                  // Dates Row
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickDateRange(isStart: true),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            side: const BorderSide(color: AppColors.slate200),
                          ),
                          icon: const Icon(
                            Icons.calendar_today_rounded,
                            size: 15,
                            color: AppColors.slate500,
                          ),
                          label: Text(
                            _startDate != null
                                ? DateFormat('yyyy-MM-dd').format(_startDate!)
                                : LocaleKeys.programs_start_date.tr(),
                            style: 11.medium.copyWith(
                              color: _startDate != null
                                  ? AppColors.slate900
                                  : AppColors.slate400,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickDateRange(isStart: false),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            side: const BorderSide(color: AppColors.slate200),
                          ),
                          icon: const Icon(
                            Icons.event_rounded,
                            size: 15,
                            color: AppColors.slate500,
                          ),
                          label: Text(
                            _endDate != null
                                ? DateFormat('yyyy-MM-dd').format(_endDate!)
                                : LocaleKeys.programs_end_date.tr(),
                            style: 11.medium.copyWith(
                              color: _endDate != null
                                  ? AppColors.slate900
                                  : AppColors.slate400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Description Field
                  CustomTextFormField(
                    controller: _descriptionController,
                    hintText: LocaleKeys.programs_description_hint.tr(),
                    prefixIcon: Icons.notes_rounded,
                    textInputType: TextInputType.multiline,
                  ),
                  const SizedBox(height: 16),

                  // Submit Button
                  CustomButton(
                    title: LocaleKeys.programs_submit_create.tr(),
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
