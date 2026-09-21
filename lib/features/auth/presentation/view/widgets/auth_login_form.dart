import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/common/widgets/custom_button.dart';
import '../../../../../core/common/widgets/custom_text_field.dart';
import '../../../../../core/common/widgets/pass_text_field.dart';
import '../../../../../core/config/validations.dart';
import '../../../../../core/languages/locale_keys.g.dart';
import '../../../../../core/routes/app_router.gr.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_typography.dart';
import '../pages/register_page.dart';
import 'forgot_password_sheet.dart';

class AuthLoginForm extends StatelessWidget {
  const AuthLoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.isBusy,
    required this.onEmailSubmit,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isBusy;
  final VoidCallback onEmailSubmit;

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: isBusy,
      child: Container(
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
              LocaleKeys.login_title.tr(),
              textAlign: TextAlign.center,
              style: 17.bold.copyWith(
                color: AppColors.slate900,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              LocaleKeys.login_subtitle.tr(),
              textAlign: TextAlign.center,
              style: 12.regular.copyWith(color: AppColors.slate400),
            ),
            const SizedBox(height: 16),
            CustomTextFormField(
              key: const ValueKey('email'),
              controller: emailController,
              hintText: LocaleKeys.login_email_hint.tr(),
              prefixSvg: AppIcons.iconsEmailOutline,
              textInputType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: Validations.validateEmail,
            ),
            const SizedBox(height: 12),
            PassTextFormField(
              key: const ValueKey('password'),
              controller: passwordController,
              hintText: LocaleKeys.login_password_hint.tr(),
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => onEmailSubmit(),
              validator: Validations.validateLoginPassword,
            ),
            const SizedBox(height: 6),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                key: const ValueKey('forgot_password_button'),
                onPressed: isBusy
                    ? null
                    : () => ForgotPasswordSheet.show(
                          context,
                          initialEmail: emailController.text,
                        ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  LocaleKeys.login_forgot_password.tr(),
                  style: 11.semiBold.copyWith(
                    color: AppColors.primerColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            CustomButton(
              title: LocaleKeys.login_login_button.tr(),
              onTap: isBusy ? null : onEmailSubmit,
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  LocaleKeys.login_dont_have_account.tr(),
                  style: 12.regular.copyWith(color: AppColors.slate400),
                ),
                const SizedBox(width: 5),
                GestureDetector(
                  key: const ValueKey('goto_register_button'),
                  onTap: isBusy
                      ? null
                      : () {
                          try {
                            context.router.push(const RegisterRoute());
                          } catch (_) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const RegisterPage(),
                              ),
                            );
                          }
                        },
                  child: Text(
                    LocaleKeys.login_create_account.tr(),
                    style: 12.bold.copyWith(color: AppColors.primerColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
