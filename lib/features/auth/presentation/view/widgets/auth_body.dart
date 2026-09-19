import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

import '../../../../../core/common/widgets/app_loading_dialog.dart';
import '../../../../../core/common/widgets/custom_button.dart';
import '../../../../../core/common/widgets/custom_text_field.dart';
import '../../../../../core/common/widgets/custom_toast.dart';
import '../../../../../core/common/widgets/pass_text_field.dart';
import '../../../../../core/common/widgets/version_info.dart';
import '../../../../../core/config/validations.dart';
import '../../../../../core/languages/locale_keys.g.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/models/auth_user.dart';
import '../../../domain/params/login_params.dart';
import '../../../domain/params/register_params.dart';
import '../../helpers/auth_error_copy.dart';
import '../../view_model/cubit/auth_cubit.dart';
import '../../view_model/cubit/auth_states.dart';

class AuthBody extends StatefulWidget {
  const AuthBody({super.key, required this.repository});

  final AuthRepository repository;

  @override
  State<AuthBody> createState() => _AuthBodyState();
}

class _AuthBodyState extends State<AuthBody> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  late final Stream<AuthUser?> _users = widget.repository.users;
  bool _register = false;

  @override
  void dispose() {
    for (final controller in [_name, _email, _password, _confirmation]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    final cubit = context.read<AuthCubit>();
    if (_register) {
      await cubit.register(
        RegisterParams(
          name: _name.text,
          email: _email.text,
          password: _password.text,
        ),
      );
    } else {
      await cubit.login(
        LoginParams(email: _email.text, password: _password.text),
      );
    }
    if (mounted && cubit.state.error == null) {
      _password.clear();
      _confirmation.clear();
    }
  }

  void _switchMode() {
    _form.currentState?.reset();
    _name.clear();
    _password.clear();
    _confirmation.clear();
    context.read<AuthCubit>().clearError();
    setState(() => _register = !_register);
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LocaleKeys.login_logout_title.tr()),
        content: Text(LocaleKeys.login_logout_confirm.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(LocaleKeys.login_logout_cancel.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(LocaleKeys.login_logout_button.tr()),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<AuthCubit>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthStates>(
      listener: (context, state) {
        if (state.busy) {
          AppLoadingDialog.show(context);
        } else {
          AppLoadingDialog.hide(context);
        }
        if (state.loggedOut) {
          CustomToast(
            context: context,
            header: LocaleKeys.login_logout_success.tr(),
            type: ToastificationType.success,
          ).showToast();
        }
        if (state.error case final error?) {
          CustomToast(
            context: context,
            header: AuthErrorCopy.message(error),
            type: ToastificationType.error,
          ).showToast();
        }
      },
      builder: (context, state) => StreamBuilder<AuthUser?>(
        stream: _users,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return Form(
            key: _form,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  const AppLogo(),
                  const SizedBox(height: 30),
                  if (snapshot.data case final user?)
                    _signedIn(context, user, state)
                  else
                    _authForm(context, state),
                  const SizedBox(height: 20),
                  VersionInfo(
                    textStyle: 12.medium.copyWith(color: AppColors.grey99),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _signedIn(
    BuildContext context,
    AuthUser user,
    AuthStates state,
  ) => Column(
    children: [
      Text(
        LocaleKeys.login_signed_in.tr(),
        textAlign: TextAlign.center,
        style: 24.semiBold.copyWith(color: AppColors.black04),
      ),
      const SizedBox(height: 8),
      Text(
        user.email,
        textAlign: TextAlign.center,
        style: 16.medium.copyWith(color: AppColors.grey99),
      ),
      const SizedBox(height: 32),
      CustomButton(
        title: LocaleKeys.login_logout.tr(),
        isLoading: state.busy,
        onTap: state.busy ? null : _confirmLogout,
      ),
    ],
  );

  Widget _authForm(BuildContext context, AuthStates state) => AbsorbPointer(
    absorbing: state.busy,
    child: Column(
      children: [
        Text(
          _register
              ? LocaleKeys.register_title.tr()
              : LocaleKeys.login_title.tr(),
          textAlign: TextAlign.center,
          style: 24.semiBold.copyWith(color: AppColors.black04),
        ),
        const SizedBox(height: 8),
        Text(
          _register
              ? LocaleKeys.register_subtitle.tr()
              : LocaleKeys.login_subtitle.tr(),
          textAlign: TextAlign.center,
          style: 16.medium.copyWith(color: AppColors.grey99),
        ),
        const SizedBox(height: 24),
        if (_register) ...[
          CustomTextFormField(
            key: const ValueKey('name'),
            controller: _name,
            hintText: LocaleKeys.register_name_hint.tr(),
            prefixSvg: AppIcons.iconsPerson,
            textInputAction: TextInputAction.next,
            validator: Validations.validateName,
          ),
          const SizedBox(height: 16),
        ],
        CustomTextFormField(
          key: const ValueKey('email'),
          controller: _email,
          hintText: _register
              ? LocaleKeys.register_email_hint.tr()
              : LocaleKeys.login_email_hint.tr(),
          prefixSvg: AppIcons.iconsEmailOutline,
          textInputType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          validator: Validations.validateEmail,
        ),
        const SizedBox(height: 16),
        PassTextFormField(
          key: const ValueKey('password'),
          controller: _password,
          hintText: _register
              ? LocaleKeys.register_password_hint.tr()
              : LocaleKeys.login_password_hint.tr(),
          textInputAction: _register
              ? TextInputAction.next
              : TextInputAction.done,
          onFieldSubmitted: (_) {
            if (!_register) _submit();
          },
          validator: _register
              ? Validations.validatePassword
              : Validations.validateLoginPassword,
        ),
        if (_register) ...[
          const SizedBox(height: 16),
          PassTextFormField(
            key: const ValueKey('confirmation'),
            controller: _confirmation,
            hintText: LocaleKeys.register_confirm_password_hint.tr(),
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            validator: (value) => Validations.validatePasswordVerification(
              value,
              _password.text,
            ),
          ),
        ],
        const SizedBox(height: 32),
        CustomButton(
          title: _register
              ? LocaleKeys.register_create_button.tr()
              : LocaleKeys.login_login_button.tr(),
          isLoading: state.busy,
          onTap: state.busy ? null : _submit,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _register
                  ? LocaleKeys.register_already_have_account.tr()
                  : LocaleKeys.login_dont_have_account.tr(),
              style: 14.regular.copyWith(color: AppColors.grey99),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: state.busy ? null : _switchMode,
              child: Text(
                _register
                    ? LocaleKeys.register_login.tr()
                    : LocaleKeys.login_create_account.tr(),
                style: 14.medium.copyWith(color: AppColors.black04),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
