import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

import '../../../../../core/common/widgets/app_loading_dialog.dart';
import '../pages/register_page.dart';
import '../../../../../core/common/widgets/custom_button.dart';
import '../../../../../core/common/widgets/custom_text_field.dart';
import '../../../../../core/common/widgets/custom_toast.dart';
import '../../../../../core/common/widgets/pass_text_field.dart';
import '../../../../../core/common/widgets/qr_card.dart';
import '../../../../../core/common/widgets/status_chip.dart';
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
import '../../helpers/auth_error_copy.dart';
import 'forgot_password_sheet.dart';
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
  final _email = TextEditingController();
  final _password = TextEditingController();
  late final Stream<AuthUser?> _users = widget.repository.users;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    final cubit = context.read<AuthCubit>();
    await cubit.login(
      LoginParams(email: _email.text, password: _password.text),
    );
    if (mounted && cubit.state.error == null) {
      _password.clear();
    }
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          LocaleKeys.login_logout_title.tr(),
          style: 20.bold.copyWith(color: AppColors.slate900),
        ),
        content: Text(
          LocaleKeys.login_logout_confirm.tr(),
          style: 15.regular.copyWith(color: AppColors.slate600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              LocaleKeys.login_logout_cancel.tr(),
              style: 15.semiBold.copyWith(color: AppColors.slate400),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              LocaleKeys.login_logout_button.tr(),
              style: 15.bold.copyWith(color: AppColors.primerColor),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<AuthCubit>().logout();
    }
  }

  void _showQrPassSheet(AuthUser user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.slate200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const StatusChip(
              status: AttendanceStatus.present,
              customLabel: '✓ Verified Offline Pass',
            ),
            const SizedBox(height: 16),
            QrCard(
              title: user.name ?? user.email.split('@').first,
              subtitle: user.email,
              footerText:
                  'Show this QR code to the instructor at the door to check in.',
              size: 180,
              qrContent: const CustomPaint(
                size: Size(160, 160),
                painter: _MockQrPainter(accentColor: AppColors.qrForeground),
              ),
            ),
            const SizedBox(height: 20),
            CustomButton(
              title: 'Done',
              isFilled: true,
              backGroundColor: AppColors.slate100,
              borderColor: AppColors.border,
              titleStyle: 15.bold.copyWith(color: AppColors.textPrimary),
              onTap: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 8),
          ],
        ),
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
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primerColor),
            );
          }

          final currentUser = snapshot.data;

          return Stack(
            children: [
              // Ambient soft background glow shapes (Indigo & Cyan)
              Positioned(
                top: -60,
                right: -60,
                child: Container(
                  width: 200,
                  height: 200,
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
                top: 120,
                left: -60,
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
              LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 16,
                        ),
                        child: Form(
                          key: _form,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 8),
                              // Prominently centered logo and status badge
                              Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const AppLogo(
                                      height: 56,
                                      isVertical: true,
                                      heroTag: 'app_logo_hero',
                                    ),
                                    const SizedBox(height: 10),
                                    _statusPill(),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 18),
                              if (currentUser != null)
                                _signedIn(context, currentUser, state)
                              else
                                _authForm(context, state),
                              const SizedBox(height: 16),
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
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _statusPill() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: AppColors.present,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              context.tr(LocaleKeys.splash_offline_ready),
              style: 11.semiBold.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );

  Widget _signedIn(
    BuildContext context,
    AuthUser user,
    AuthStates state,
  ) {
    final initials = (user.name?.isNotEmpty ?? false)
        ? user.name![0].toUpperCase()
        : (user.email.isNotEmpty ? user.email[0].toUpperCase() : 'U');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Avatar with Ring
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.modernPrimaryGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.32),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Text(
                initials,
                style: 26.bold.copyWith(color: AppColors.originalWhite),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            LocaleKeys.login_signed_in.tr(),
            textAlign: TextAlign.center,
            style: 20.bold.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 3),
          Text(
            user.email,
            textAlign: TextAlign.center,
            style: 14.medium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          // Verified Badge
          StatusChip(
            status: AttendanceStatus.present,
            customLabel:
                user.isAdmin ? '✓ Verified Admin' : '✓ Verified Attendee',
          ),
          const SizedBox(height: 20),
          // Attendance metrics preview
          Row(
            children: [
              Expanded(
                child: _metricCard(
                  title: 'Attendance',
                  value: '98%',
                  accentColor: AppColors.present,
                  icon: Icons.check_circle_outline,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _metricCard(
                  title: 'Sessions',
                  value: '14/15',
                  accentColor: AppColors.accent,
                  icon: Icons.school_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Quick Action: Show QR Pass
          InkWell(
            onTap: () => _showQrPassSheet(user),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.slate50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.cyanLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.qr_code_rounded,
                      color: AppColors.accent,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Attendance QR Pass',
                          style: 14.bold.copyWith(color: AppColors.textPrimary),
                        ),
                        Text(
                          'Tap to show code for check-in',
                          style: 12.regular.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.slate400,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          CustomButton(
            title: LocaleKeys.login_logout.tr(),
            isLoading: state.busy,
            isFilled: true,
            backGroundColor: AppColors.cardSurface,
            borderColor: AppColors.slate200,
            titleStyle: 15.bold.copyWith(color: AppColors.slate800),
            prefixIcon: const Icon(
              Icons.logout_rounded,
              color: AppColors.slate800,
              size: 18,
            ),
            onTap: state.busy ? null : _confirmLogout,
          ),
        ],
      ),
    );
  }

  Widget _metricCard({
    required String title,
    required String value,
    required Color accentColor,
    required IconData icon,
  }) => Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.slate50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.slate200),
        ),
        child: Column(
          children: [
            Icon(icon, color: accentColor, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: 17.bold.copyWith(color: AppColors.slate900),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: 11.medium.copyWith(color: AppColors.slate400),
            ),
          ],
        ),
      );

  Widget _authForm(BuildContext context, AuthStates state) => AbsorbPointer(
        absorbing: state.busy,
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
                style: 20.bold.copyWith(
                  color: AppColors.slate900,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                LocaleKeys.login_subtitle.tr(),
                textAlign: TextAlign.center,
                style: 13.regular.copyWith(color: AppColors.slate400),
              ),
              const SizedBox(height: 20),
              CustomTextFormField(
                key: const ValueKey('email'),
                controller: _email,
                hintText: LocaleKeys.login_email_hint.tr(),
                prefixSvg: AppIcons.iconsEmailOutline,
                textInputType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: Validations.validateEmail,
              ),
              const SizedBox(height: 12),
              PassTextFormField(
                key: const ValueKey('password'),
                controller: _password,
                hintText: LocaleKeys.login_password_hint.tr(),
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                validator: Validations.validateLoginPassword,
              ),
              const SizedBox(height: 6),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  key: const ValueKey('forgot_password_button'),
                  onPressed: state.busy
                      ? null
                      : () => ForgotPasswordSheet.show(
                            context,
                            initialEmail: _email.text,
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
                    style: 12.semiBold.copyWith(
                      color: AppColors.primerColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              CustomButton(
                title: LocaleKeys.login_login_button.tr(),
                isLoading: state.busy,
                onTap: state.busy ? null : _submit,
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    LocaleKeys.login_dont_have_account.tr(),
                    style: 13.regular.copyWith(color: AppColors.slate400),
                  ),
                  const SizedBox(width: 5),
                  GestureDetector(
                    key: const ValueKey('goto_register_button'),
                    onTap: state.busy
                        ? null
                        : () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: context.read<AuthCubit>(),
                                  child: const RegisterPage(),
                                ),
                              ),
                            );
                          },
                    child: Text(
                      LocaleKeys.login_create_account.tr(),
                      style: 13.bold.copyWith(color: AppColors.primerColor),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}

/// Custom painter for scannable-looking QR pattern
class _MockQrPainter extends CustomPainter {
  const _MockQrPainter({required this.accentColor});

  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;

    final step = size.width / 15;

    // Corner Finder Patterns (top-left, top-right, bottom-left)
    _drawFinderPattern(canvas, 0, 0, step, paint);
    _drawFinderPattern(canvas, size.width - step * 5, 0, step, paint);
    _drawFinderPattern(canvas, 0, size.height - step * 5, step, paint);

    // Decorative QR data modules
    final activeModules = [
      const Offset(6, 1),
      const Offset(7, 1),
      const Offset(8, 1),
      const Offset(6, 2),
      const Offset(8, 3),
      const Offset(6, 4),
      const Offset(7, 5),
      const Offset(8, 5),
      const Offset(1, 6),
      const Offset(3, 6),
      const Offset(5, 6),
      const Offset(7, 6),
      const Offset(9, 6),
      const Offset(11, 6),
      const Offset(13, 6),
      const Offset(2, 7),
      const Offset(4, 7),
      const Offset(6, 7),
      const Offset(10, 7),
      const Offset(12, 7),
      const Offset(6, 8),
      const Offset(7, 8),
      const Offset(8, 8),
      const Offset(9, 8),
      const Offset(11, 8),
      const Offset(6, 9),
      const Offset(8, 9),
      const Offset(10, 9),
      const Offset(12, 9),
      const Offset(6, 10),
      const Offset(7, 11),
      const Offset(9, 11),
      const Offset(11, 11),
      const Offset(6, 12),
      const Offset(8, 12),
      const Offset(10, 12),
      const Offset(12, 12),
      const Offset(7, 13),
      const Offset(9, 13),
      const Offset(11, 13),
      const Offset(13, 13),
    ];

    for (final module in activeModules) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            module.dx * step,
            module.dy * step,
            step * 0.9,
            step * 0.9,
          ),
          const Radius.circular(2),
        ),
        paint,
      );
    }
  }

  void _drawFinderPattern(
    Canvas canvas,
    double x,
    double y,
    double step,
    Paint paint,
  ) {
    // Outer square
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, step * 5, step * 5),
        const Radius.circular(6),
      ),
      paint,
    );
    // Inner cutout
    final clearPaint = Paint()..color = AppColors.originalWhite;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x + step, y + step, step * 3, step * 3),
        const Radius.circular(4),
      ),
      clearPaint,
    );
    // Center core
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x + step * 1.6, y + step * 1.6, step * 1.8, step * 1.8),
        const Radius.circular(3),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
