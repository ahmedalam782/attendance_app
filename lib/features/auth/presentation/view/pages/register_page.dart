import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/dependency_injection/injected_bloc_provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../view_model/cubit/auth_cubit.dart';
import '../widgets/register_body.dart';

/// Dedicated registration screen with back navigation.
/// Follows Al Faris thin-page architecture: AutoRouteWrapper + public RegisterBody.
@RoutePage()
class RegisterPage extends StatelessWidget implements AutoRouteWrapper {
  const RegisterPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return InjectedBlocProvider<AuthCubit>(child: this);
  }

  @override
  Widget build(BuildContext context) {
    return const AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AppColors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: RegisterBody(),
      ),
    );
  }
}
