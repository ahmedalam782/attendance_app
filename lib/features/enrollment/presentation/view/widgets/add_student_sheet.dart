import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

import '../../../../../core/common/widgets/app_bottom_sheet.dart';
import '../../../../../core/common/widgets/custom_button.dart';
import '../../../../../core/common/widgets/custom_text_field.dart';
import '../../../../../core/common/widgets/custom_toast.dart';
import '../../../../../core/languages/locale_keys.g.dart';
import '../../view_model/cubit/enrollment_cubit.dart';
import '../../view_model/cubit/enrollment_state.dart';

class AddStudentSheet extends StatefulWidget {
  const AddStudentSheet({
    super.key,
    required this.programId,
  });

  final String programId;

  static Future<void> show(BuildContext context, {required String programId}) {
    final cubit = context.read<EnrollmentCubit>();
    return showAppSheet(
      context,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: AddStudentSheet(programId: programId),
      ),
    );
  }

  @override
  State<AddStudentSheet> createState() => _AddStudentSheetState();
}

class _AddStudentSheetState extends State<AddStudentSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _idController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await context.read<EnrollmentCubit>().addStudent(
          programId: widget.programId,
          studentId: _idController.text.trim(),
          name: _nameController.text.trim(),
        );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
      CustomToast(
        context: context,
        header: LocaleKeys.roster_student_added.tr(),
        type: ToastificationType.success,
      ).showToast();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppSheetPadding(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSheetHeader(
              title: LocaleKeys.roster_add_student.tr(),
            ),
            const SizedBox(height: 16),
            CustomTextFormField(
              controller: _nameController,
              hintText: LocaleKeys.roster_student_name.tr(),
              prefixIcon: Icons.person_outline_rounded,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? LocaleKeys.validations_name_required.tr() : null,
            ),
            const SizedBox(height: 12),
            CustomTextFormField(
              controller: _idController,
              hintText: LocaleKeys.roster_student_id.tr(),
              prefixIcon: Icons.badge_outlined,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? LocaleKeys.validations_name_required.tr() : null,
            ),
            const SizedBox(height: 20),
            BlocBuilder<EnrollmentCubit, EnrollmentState>(
              builder: (context, state) {
                return CustomButton(
                  title: LocaleKeys.roster_add_student.tr(),
                  isLoading: state.isActionLoading,
                  onTap: _submit,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
