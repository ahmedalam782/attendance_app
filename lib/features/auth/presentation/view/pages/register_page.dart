import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

import '../../../../../core/api/base_state/base_state.dart';
import '../../../../../core/common/widgets/app_loading_dialog.dart';
import '../../../../../core/common/widgets/custom_button.dart';
import '../../../../../core/common/widgets/custom_text_field.dart';
import '../../../../../core/common/widgets/custom_toast.dart';
import '../../../../../core/common/widgets/pass_text_field.dart';
import '../../../../../core/common/widgets/version_info.dart';
import '../../../../../core/config/validations.dart';
import '../../../../../core/dependency_injection/injectable_config.dart';
import '../../../../../core/languages/locale_keys.g.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../../../domain/params/register_params.dart';
import '../../helpers/auth_error_copy.dart';
import '../../view_model/cubit/auth_cubit.dart';
import '../../view_model/cubit/auth_states.dart';

/// Dedicated registration screen with back navigation.
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    Widget content = const _RegisterBody();

    // Ensure AuthCubit is available even if pushed directly without an ancestor provider
    try {
      context.read<AuthCubit>();
    } catch (_) {
      content = BlocProvider<AuthCubit>(
        create: (_) => getIt<AuthCubit>(),
        child: content,
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.slate200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.slate800,
                size: 20,
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(child: content),
      ),
    );
  }
}

class _RegisterBody extends StatefulWidget {
  const _RegisterBody();

  @override
  State<_RegisterBody> createState() => _RegisterBodyState();
}

class _RegisterBodyState extends State<_RegisterBody> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    await context.read<AuthCubit>().register(
          RegisterParams(
            name: _name.text,
            email: _email.text,
            password: _password.text,
          ),
        );
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
        if (state.error case final error?) {
          CustomToast(
            context: context,
            header: AuthErrorCopy.message(error),
            type: ToastificationType.error,
          ).showToast();
        }
        if (state.authState.state == StatusState.success) {
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        return Stack(
          children: [
            // Ambient glowing background
            Positioned(
              top: -60,
              right: -60,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.12),
                      AppColors.primary.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -40,
              left: -40,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accent.withValues(alpha: 0.10),
                      AppColors.accent.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

            // Centered scroll view
            LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 4),
                            // Centered logo
                            const Center(
                              child: AppLogo(
                                height: 50,
                                isVertical: true,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Registration card
                            _registerCard(context, state),
                            const SizedBox(height: 14),

                            // Version
                            Center(
                              child: VersionInfo(
                                textStyle: 12.medium
                                    .copyWith(color: AppColors.slate400),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _registerCard(BuildContext context, AuthStates state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.slate200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            LocaleKeys.register_title.tr(),
            textAlign: TextAlign.center,
            style: 20.bold.copyWith(
              color: AppColors.slate900,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            LocaleKeys.register_subtitle.tr(),
            textAlign: TextAlign.center,
            style: 13.regular.copyWith(color: AppColors.slate400),
          ),
          const SizedBox(height: 20),

          // Name
          CustomTextFormField(
            key: const ValueKey('name'),
            controller: _name,
            hintText: LocaleKeys.register_name_hint.tr(),
            prefixSvg: AppIcons.iconsPerson,
            textInputAction: TextInputAction.next,
            validator: Validations.validateName,
          ),
          const SizedBox(height: 12),

          // Email
          CustomTextFormField(
            key: const ValueKey('email'),
            controller: _email,
            hintText: LocaleKeys.register_email_hint.tr(),
            prefixSvg: AppIcons.iconsEmailOutline,
            textInputType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: Validations.validateEmail,
          ),
          const SizedBox(height: 12),

          // Password
          PassTextFormField(
            key: const ValueKey('password'),
            controller: _password,
            hintText: LocaleKeys.register_password_hint.tr(),
            textInputAction: TextInputAction.next,
            validator: Validations.validatePassword,
          ),
          const SizedBox(height: 12),

          // Confirm Password
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
          const SizedBox(height: 20),

          // Submit Button
          CustomButton(
            title: LocaleKeys.register_create_button.tr(),
            isLoading: state.busy,
            onTap: state.busy ? null : _submit,
          ),
          const SizedBox(height: 14),

          // Bottom link back to login
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                LocaleKeys.register_already_have_account.tr(),
                style: 13.regular.copyWith(color: AppColors.slate400),
              ),
              const SizedBox(width: 5),
              GestureDetector(
                onTap: state.busy ? null : () => Navigator.of(context).pop(),
                child: Text(
                  LocaleKeys.register_login.tr(),
                  style: 13.bold.copyWith(color: AppColors.primerColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
