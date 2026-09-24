import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'view/widgets/splash_body.dart';

/// Thin RoutePage for Splash screen adhering to Al Faris presentation architecture.
@RoutePage()
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: SplashBody(),
    );
  }
}
