import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

import '../../../../../core/common/widgets/custom_button.dart';
import '../../../../../core/common/widgets/custom_text_field.dart';
import '../../../../../core/common/widgets/custom_toast.dart';
import '../../../../../core/common/widgets/app_bottom_sheet.dart';
import '../../../../../core/languages/locale_keys.g.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../domain/params/join_program_params.dart';
import '../../view_model/cubit/programs_cubit.dart';
import '../../view_model/cubit/programs_state.dart';
import 'program_qr_scanner_sheet.dart';

class JoinProgramSheet extends StatefulWidget {
  const JoinProgramSheet({
    super.key,
    required this.studentId,
    required this.studentName,
  });

  final String studentId;
  final String studentName;

  static Future<bool?> show(
    BuildContext context, {
    required String studentId,
    required String studentName,
  }) {
    final cubit = context.read<ProgramsCubit>();
    return showAppSheet<bool>(context, builder: (_) => BlocProvider.value(
        value: cubit,
        child: JoinProgramSheet(
          studentId: studentId,
          studentName: studentName,
        ),
      ),
    );
  }

  @override
  State<JoinProgramSheet> createState() => _JoinProgramSheetState();
}

class _JoinProgramSheetState extends State<JoinProgramSheet> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _openQrScanner() async {
    final scannedCode = await ProgramQrScannerSheet.show(context);
    if (scannedCode != null && scannedCode.isNotEmpty && mounted) {
      _codeController.text = scannedCode;
      _submit();
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    final params = JoinProgramParams(
      inviteCode: _codeController.text.trim().toUpperCase(),
      studentId: widget.studentId,
      studentName: widget.studentName,
    );

    final success = await context.read<ProgramsCubit>().joinProgram(params);
    if (success && mounted) {
      CustomToast(
        context: context,
        header: LocaleKeys.programs_joined_success.tr(),
        type: ToastificationType.success,
      ).showToast();
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProgramsCubit, ProgramsState>(
      builder: (context, state) {
        return AppSheetPadding(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppSheetHeader(
                  title: LocaleKeys.programs_join_title.tr(),
                  subtitle: LocaleKeys.programs_join_subtitle.tr(),
                ),
                const SizedBox(height: 20),
                CustomTextFormField(
                  controller: _codeController,
                  hintText: LocaleKeys.programs_code_hint.tr(),
                  prefixIcon: Icons.vpn_key_rounded,
                  suffixWidget: IconButton(
                    tooltip: LocaleKeys.programs_scan_qr_to_join.tr(),
                    icon: const Icon(
                      Icons.qr_code_scanner_rounded,
                      color: AppColors.primary,
                    ),
                    onPressed: _openQrScanner,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                  ],
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return LocaleKeys.programs_code_required.tr();
                    }
                    if (val.trim().length < 4) {
                      return LocaleKeys.programs_code_invalid.tr();
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Expanded(child: Divider(color: AppColors.slate200)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'OR',
                        style: 11.bold.copyWith(color: AppColors.slate400),
                      ),
                    ),
                    const Expanded(child: Divider(color: AppColors.slate200)),
                  ],
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: state.isBusy ? null : _openQrScanner,
                  icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                  label: Text(
                    LocaleKeys.programs_or_scan_qr.tr(),
                    style: 13.bold,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                CustomButton(
                  title: LocaleKeys.programs_submit_join.tr(),
                  isLoading: state.isBusy,
                  onTap: state.isBusy ? null : _submit,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
