import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

import '../../../../../core/common/widgets/custom_button.dart';
import '../../../../../core/common/widgets/custom_text_field.dart';
import '../../../../../core/common/widgets/custom_toast.dart';
import '../../../../../core/languages/locale_keys.g.dart';
import '../../../../../core/routes/app_router.gr.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../programs/presentation/view/widgets/program_qr_scanner_sheet.dart';
import '../../view_model/cubit/auth_cubit.dart';
import '../../view_model/cubit/auth_states.dart';

class RedeemInstructorCodeSheet extends StatefulWidget {
  const RedeemInstructorCodeSheet({super.key});

  static Future<void> show(BuildContext context) {
    final cubit = context.read<AuthCubit>();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: const RedeemInstructorCodeSheet(),
      ),
    );
  }

  @override
  State<RedeemInstructorCodeSheet> createState() =>
      _RedeemInstructorCodeSheetState();
}

class _RedeemInstructorCodeSheetState extends State<RedeemInstructorCodeSheet> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _openQrScanner() async {
    final scannedCode = await ProgramQrScannerSheet.show(
      context,
      instruction: LocaleKeys.settings_extra_qr_scan_instruction.tr(),
    );
    if (scannedCode != null && scannedCode.isNotEmpty && mounted) {
      _codeController.text = scannedCode;
      await _submit();
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final code = _codeController.text.trim();
    final success = await context.read<AuthCubit>().redeemInstructorCode(code);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
      CustomToast(
        context: context,
        header: LocaleKeys.settings_extra_redeem_success.tr(),
        type: ToastificationType.success,
      ).showToast();

      AutoRouter.of(context).replaceAll([const AdminLayoutRoute()]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthStates>(
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            top: 20,
            left: 20,
            right: 20,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  LocaleKeys.settings_extra_instructor_code_sheet_title.tr(),
                  style: 18.bold.copyWith(color: AppColors.slate900),
                ),
                const SizedBox(height: 6),
                Text(
                  LocaleKeys.settings_extra_instructor_code_sheet_desc.tr(),
                  style: 13.regular.copyWith(
                    color: AppColors.slate500,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                CustomTextFormField(
                  controller: _codeController,
                  hintText: LocaleKeys.settings_extra_code_hint.tr(),
                  prefixIcon: Icons.vpn_key_outlined,
                  suffixWidget: IconButton(
                    tooltip: LocaleKeys.settings_extra_scan_qr_to_redeem.tr(),
                    icon: const Icon(
                      Icons.qr_code_scanner_rounded,
                      color: AppColors.primary,
                    ),
                    onPressed: state.busy ? null : _openQrScanner,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\-]')),
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      return newValue.copyWith(
                        text: newValue.text.toUpperCase(),
                      );
                    }),
                  ],
                  validator: (v) => v == null || v.trim().isEmpty
                      ? LocaleKeys.programs_code_required.tr()
                      : null,
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
                  onPressed: state.busy ? null : _openQrScanner,
                  icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                  label: Text(
                    LocaleKeys.settings_extra_or_scan_qr.tr(),
                    style: 13.bold,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                CustomButton(
                  title: LocaleKeys.settings_extra_redeem_submit.tr(),
                  isLoading: state.busy,
                  onTap: _submit,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
