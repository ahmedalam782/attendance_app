import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

import '../../../../../core/common/widgets/custom_button.dart';
import '../../../../../core/common/widgets/custom_text_field.dart';
import '../../../../../core/common/widgets/custom_toast.dart';
import '../../../../../core/common/widgets/app_bottom_sheet.dart';
import '../../../../../core/config/validations.dart';
import '../../../../../core/languages/locale_keys.g.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/utils/form_utils.dart';
import '../utils/auth_error_copy.dart';
import '../../view_model/cubit/auth_cubit.dart';
import '../../view_model/cubit/auth_states.dart';

/// Clean bottom sheet modal for sending password reset emails.
class ForgotPasswordSheet extends StatefulWidget {
  const ForgotPasswordSheet({super.key, this.initialEmail});

  final String? initialEmail;

  static Future<void> show(BuildContext context, {String? initialEmail}) {
    final cubit = context.read<AuthCubit>();
    cubit.resetForgotPasswordState();

    return showAppSheet<void>(context, builder: (_) => BlocProvider.value(
        value: cubit,
        child: ForgotPasswordSheet(initialEmail: initialEmail),
      ),
    );
  }

  @override
  State<ForgotPasswordSheet> createState() => _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends State<ForgotPasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!FormUtils.validateAndUnfocus(_formKey, context)) return;
    await context.read<AuthCubit>().sendPasswordResetEmail(
          _emailController.text.trim(),
          languageCode: context.locale.languageCode,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthStates>(
      listener: (context, state) {
        if (state.passwordResetSent) {
          CustomToast(
            context: context,
            header: LocaleKeys.login_forgot_password_success.tr(),
            type: ToastificationType.success,
          ).showToast();
        } else if (state.error case final error?) {
          CustomToast(
            context: context,
            header: AuthErrorCopy.message(error),
            type: ToastificationType.error,
          ).showToast();
        }
      },
      builder: (context, state) {
        final isSuccess = state.passwordResetSent;

        return AppSheetPadding(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            child: isSuccess
                ? const ForgotPasswordSuccessView()
                : ForgotPasswordFormView(
                    formKey: _formKey,
                    emailController: _emailController,
                    isBusy: state.busy,
                    onSubmit: _submit,
                  ),
          ),
        );
      },
    );
  }
}

class ForgotPasswordFormView extends StatelessWidget {
  const ForgotPasswordFormView({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.isBusy,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final bool isBusy;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.primerColor.withValues(alpha: 0.18),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.lock_reset_rounded,
                color: AppColors.primerColor,
                size: 30,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            LocaleKeys.login_forgot_password_title.tr(),
            textAlign: TextAlign.center,
            style: 17.bold.copyWith(
              color: AppColors.slate900,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            LocaleKeys.login_forgot_password_subtitle.tr(),
            textAlign: TextAlign.center,
            style: 12.regular.copyWith(
              color: AppColors.slate400,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 22),
          CustomTextFormField(
            controller: emailController,
            hintText: LocaleKeys.login_email_hint.tr(),
            prefixSvg: AppIcons.iconsEmailOutline,
            textInputType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => onSubmit(),
            validator: Validations.validateEmail,
          ),
          const SizedBox(height: 20),
          CustomButton(
            title: LocaleKeys.login_forgot_password_button.tr(),
            isLoading: isBusy,
            onTap: isBusy ? null : onSubmit,
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              LocaleKeys.login_forgot_password_back.tr(),
              style: 13.semiBold.copyWith(color: AppColors.slate400),
            ),
          ),
        ],
      ),
    );
  }
}

class ForgotPasswordSuccessView extends StatelessWidget {
  const ForgotPasswordSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.present.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mark_email_read_rounded,
              color: AppColors.present,
              size: 34,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          LocaleKeys.login_forgot_password_title.tr(),
          textAlign: TextAlign.center,
          style: 17.bold.copyWith(color: AppColors.slate900),
        ),
        const SizedBox(height: 8),
        Text(
          LocaleKeys.login_forgot_password_success.tr(),
          textAlign: TextAlign.center,
          style: 13.regular.copyWith(
            color: AppColors.slate600,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        CustomButton(
          title: LocaleKeys.login_forgot_password_back.tr(),
          titleStyle: 14.bold,
          onTap: () => Navigator.of(context).pop(),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
