import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/dependency_injection/injected_bloc_provider.dart';
import '../../../../../core/dependency_injection/injectable_config.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../view_model/cubit/auth_cubit.dart';
import '../widgets/auth_body.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: const SystemUiOverlayStyle(
      statusBarColor: AppColors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
    child: Scaffold(
      body: SafeArea(
        child: InjectedBlocProvider<AuthCubit>(
          child: AuthBody(repository: getIt<AuthRepository>()),
        ),
      ),
    ),
  );
}
