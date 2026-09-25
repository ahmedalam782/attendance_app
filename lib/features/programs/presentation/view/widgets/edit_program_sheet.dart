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
import '../../../domain/entities/program.dart';
import '../../../domain/params/update_program_params.dart';
import '../../view_model/cubit/programs_cubit.dart';

class EditProgramSheet extends StatefulWidget {
  const EditProgramSheet({super.key, required this.program});

  final Program program;

  static Future<bool?> show(BuildContext context, {required Program program}) {
    final cubit = context.read<ProgramsCubit>();
    return showAppSheet<bool>(
      context,
      maxHeightFactor: 0.75,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: EditProgramSheet(program: program),
      ),
    );
  }

  @override
  State<EditProgramSheet> createState() => _EditProgramSheetState();
}

class _EditProgramSheetState extends State<EditProgramSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _locationController;
  late final TextEditingController _descriptionController;

  late String _selectedType;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.program.title);
    _locationController = TextEditingController(text: widget.program.location);
    _descriptionController = TextEditingController(text: widget.program.description);
    _selectedType = widget.program.type;
    _startDate = widget.program.startDate;
    _endDate = widget.program.endDate;
  }

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
      initialRange = DateTimeRange(
        start: _startDate!,
        end: _startDate!.add(const Duration(days: 30)),
      );
    }

    final picked = await showAppDateRangePicker(
      context: context,
      initialDateRange: initialRange,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 730)),
    );

    if (picked != null && mounted) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  Future<void> _onSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);
    final params = UpdateProgramParams(
      id: widget.program.id,
      title: _titleController.text.trim(),
      type: _selectedType,
      description: _descriptionController.text.trim(),
      location: _locationController.text.trim(),
      startDate: _startDate,
      endDate: _endDate,
    );

    final success = await context.read<ProgramsCubit>().updateProgram(params);
    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      CustomToast(
        context: context,
        header: LocaleKeys.programs_updated_success.tr(),
        type: ToastificationType.success,
      ).showToast();
      Navigator.of(context).pop(true);
    } else {
      CustomToast(
        context: context,
        header: LocaleKeys.global_retry.tr(),
        type: ToastificationType.error,
      ).showToast();
    }
  }

  @override
  Widget build(BuildContext context) {
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
                title: LocaleKeys.programs_edit_program.tr(),
                subtitle: LocaleKeys.programs_edit_program_subtitle.tr(),
              ),
              const SizedBox(height: 14),

              // Program Type Selector
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

              // Title
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

              // Location
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

              // Description
              CustomTextFormField(
                controller: _descriptionController,
                hintText: LocaleKeys.programs_description_hint.tr(),
                prefixIcon: Icons.notes_rounded,
                textInputType: TextInputType.multiline,
              ),
              const SizedBox(height: 16),

              // Submit Button
              CustomButton(
                title: LocaleKeys.sessions_submit_update.tr(),
                isLoading: _isSaving,
                onTap: _isSaving ? null : _onSubmit,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
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
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.12) : AppColors.slate100,
            borderRadius: BorderRadius.circular(14),
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
                size: 20,
                color: isSelected ? color : AppColors.slate500,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: 11.bold.copyWith(
                  color: isSelected ? color : AppColors.slate700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
