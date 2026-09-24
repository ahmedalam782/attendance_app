import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/common/widgets/ambient_glow_background.dart';
import '../../../../../core/common/widgets/centered_scroll_body.dart';
import '../../../../../core/common/widgets/offline_status_pill.dart';
import '../../../../../core/common/widgets/version_info.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/utils/form_utils.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../../../domain/models/auth_user.dart';
import '../../../domain/params/login_params.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../utils/auth_dialogs.dart';
import '../utils/auth_feedback.dart';
import '../../view_model/cubit/auth_cubit.dart';
import '../../view_model/cubit/auth_states.dart';
import 'auth_login_form.dart';
import 'auth_signed_in_card.dart';

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
    if (!FormUtils.validateAndUnfocus(_form, context)) return;
    final cubit = context.read<AuthCubit>();
    await cubit.login(
      LoginParams(email: _email.text, password: _password.text),
    );
    if (mounted && cubit.state.error == null) {
      _password.clear();
    }
  }

  Future<void> _confirmLogout() async {
    final confirmed = await AuthDialogs.confirmLogout(context);
    if (confirmed && mounted) {
      await context.read<AuthCubit>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthStates>(
      listener: (context, state) => AuthFeedback.handle(
        context,
        state,
        showLoggedOutToast: true,
      ),
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
              const AmbientGlowBackground(),
              CenteredScrollBody(
                child: Form(
                  key: _form,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 8),
                      const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppLogo(
                              height: 56,
                              isVertical: true,
                              heroTag: 'app_logo_hero',
                            ),
                            SizedBox(height: 10),
                            OfflineStatusPill(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      if (currentUser != null)
                        AuthSignedInCard(
                          user: currentUser,
                          isBusy: state.busy,
                          onLogout: _confirmLogout,
                        )
                      else
                        AuthLoginForm(
                          emailController: _email,
                          passwordController: _password,
                          isBusy: state.busy,
                          onEmailSubmit: _submit,
                        ),
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
            ],
          );
        },
      ),
    );
  }
}
