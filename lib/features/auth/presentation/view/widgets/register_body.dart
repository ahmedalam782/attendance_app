import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/api/base_state/base_state.dart';
import '../../../../../core/common/widgets/ambient_glow_background.dart';
import '../../../../../core/common/widgets/centered_scroll_body.dart';
import '../../../../../core/common/widgets/custom_button.dart';
import '../../../../../core/common/widgets/custom_phone_field.dart';
import '../../../../../core/common/widgets/custom_text_field.dart';
import '../../../../../core/common/widgets/pass_text_field.dart';
import '../../../../../core/common/widgets/version_info.dart';
import '../../../../../core/config/validations.dart';
import '../../../../../core/helper/extensions/phone_text_controller.dart';
import '../../../../../core/languages/locale_keys.g.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/utils/form_utils.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../../../domain/params/register_params.dart';
import '../utils/auth_feedback.dart';
import '../../view_model/cubit/auth_cubit.dart';
import '../../view_model/cubit/auth_states.dart';

/// Public registration body widget following Al Faris presentation architecture.
class RegisterBody extends StatefulWidget {
  const RegisterBody({super.key});

  @override
  State<RegisterBody> createState() => _RegisterBodyState();
}

class _RegisterBodyState extends State<RegisterBody> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!FormUtils.validateAndUnfocus(_formKey, context)) return;
    await context.read<AuthCubit>().register(
          RegisterParams(
            name: _name.text,
            phone: _phone.fullPhoneNumber,
            email: _email.text,
            password: _password.text,
          ),
        );
  }


  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthStates>(
      listener: (context, state) {
        AuthFeedback.handle(context, state);
        if (state.authState.state == StatusState.success) {
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        return Stack(
          children: [
            const AmbientGlowBackground(variant: AmbientGlowVariant.register),
            SafeArea(
              child: CenteredScrollBody(
                padding: const EdgeInsets.fromLTRB(18, 56, 18, 12),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 4),
                      const Center(child: AppLogo(height: 50, isVertical: true)),
                      const SizedBox(height: 16),
                      RegisterFormCard(
                        nameController: _name,
                        phoneController: _phone,
                        emailController: _email,
                        passwordController: _password,
                        confirmationController: _confirmation,
                        isBusy: state.busy,
                        onSubmit: _submit,
                      ),
                      const SizedBox(height: 14),
                      Center(
                        child: VersionInfo(
                          textStyle: 12.medium.copyWith(
                            color: AppColors.slate400,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
            PositionedDirectional(
              top: 0,
              start: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(start: 16, top: 8),
                  child: Material(
                    color: AppColors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.of(context).maybePop(),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.cardSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.slate200),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadow,
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: AppColors.slate800,
                          size: 20,
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
}

class RegisterFormCard extends StatelessWidget {
  const RegisterFormCard({
    super.key,
    required this.nameController,
    required this.phoneController,
    required this.emailController,
    required this.passwordController,
    required this.confirmationController,
    required this.isBusy,
    required this.onSubmit,
  });

  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmationController;
  final bool isBusy;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.slate200, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
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
            style: 17.bold.copyWith(
              color: AppColors.slate900,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            LocaleKeys.register_subtitle.tr(),
            textAlign: TextAlign.center,
            style: 12.regular.copyWith(color: AppColors.slate400),
          ),
          const SizedBox(height: 16),
          CustomTextFormField(
            key: const ValueKey('name'),
            controller: nameController,
            hintText: LocaleKeys.register_name_hint.tr(),
            prefixSvg: AppIcons.iconsPerson,
            textInputAction: TextInputAction.next,
            validator: Validations.validateName,
          ),
          const SizedBox(height: 12),
          CustomPhoneField(
            key: const ValueKey('phone'),
            controller: phoneController,
          ),
          const SizedBox(height: 12),
          CustomTextFormField(
            key: const ValueKey('email'),
            controller: emailController,
            hintText: LocaleKeys.register_email_hint.tr(),
            prefixSvg: AppIcons.iconsEmailOutline,
            textInputType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: Validations.validateEmail,
          ),
          const SizedBox(height: 12),
          PassTextFormField(
            key: const ValueKey('password'),
            controller: passwordController,
            hintText: LocaleKeys.register_password_hint.tr(),
            textInputAction: TextInputAction.next,
            validator: Validations.validatePassword,
          ),
          const SizedBox(height: 12),
          PassTextFormField(
            key: const ValueKey('confirmation'),
            controller: confirmationController,
            hintText: LocaleKeys.register_confirm_password_hint.tr(),
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => onSubmit(),
            validator: (value) => Validations.validatePasswordVerification(
              value,
              passwordController.text,
            ),
          ),
          const SizedBox(height: 20),
          CustomButton(
            title: LocaleKeys.register_create_button.tr(),
            onTap: isBusy ? null : onSubmit,
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                LocaleKeys.register_already_have_account.tr(),
                style: 12.regular.copyWith(color: AppColors.slate400),
              ),
              const SizedBox(width: 5),
              GestureDetector(
                onTap: isBusy ? null : () => Navigator.of(context).pop(),
                child: Text(
                  LocaleKeys.register_login.tr(),
                  style: 12.bold.copyWith(color: AppColors.primerColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
