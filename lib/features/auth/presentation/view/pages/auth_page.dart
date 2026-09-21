import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/dependency_injection/injected_bloc_provider.dart';
import '../../../../../core/dependency_injection/injectable_config.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../view_model/cubit/auth_cubit.dart';
import '../widgets/auth_body.dart';

@RoutePage()
class AuthPage extends StatelessWidget implements AutoRouteWrapper {
  const AuthPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return InjectedBlocProvider<AuthCubit>(child: this);
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AuthBody(repository: getIt<AuthRepository>()),
      ),
    );

    try {
      context.read<AuthCubit>();
    } catch (_) {
      content = InjectedBlocProvider<AuthCubit>(child: content);
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: content,
    );
  }
}
