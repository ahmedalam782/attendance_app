import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/common/widgets/ambient_glow_background.dart';
import '../../../core/common/widgets/offline_status_pill.dart';
import '../../../core/dependency_injection/injectable_config.dart';
import '../../../core/languages/locale_keys.g.dart';
import '../../../core/routes/app_router.gr.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../auth/presentation/view_model/cubit/auth_cubit.dart';
import '../../home/data/app_bootstrap_impl.dart';
import '../../shared/widgets/app_logo.dart';

/// Premium animated splash screen with atmospheric background glows,
/// spring scale transitions, and localized branding copy.
@RoutePage()
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnimation = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.6, curve: Curves.easeIn),
      ),
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.65, 1.0, curve: Curves.easeInOutSine),
      ),
    );

    _controller.forward();
    _bootstrapAndNavigate();
  }

  Future<void> _bootstrapAndNavigate() async {
    try {
      final bootstrap = AppBootstrapImpl();
      await Future.wait([
        bootstrap.run(),
        Future<void>.delayed(const Duration(milliseconds: 1400)),
      ]);
      if (!mounted) return;
      final authCubit = getIt<AuthCubit>();
      final user = await authCubit.checkSession();
      if (!mounted) return;
      if (user == null) {
        context.router.replace(const AuthRoute());
      } else if (user.isStaff) {
        context.router.replace(const AdminLayoutRoute());
      } else {
        context.router.replace(const StudentLayoutRoute());
      }
    } catch (_) {
      if (!mounted) return;
      context.router.replace(const AuthRoute());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const AmbientGlowBackground(variant: AmbientGlowVariant.splash),
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) => Transform.scale(
                    scale: _controller.value > 0.65 ? _pulseAnimation.value : 1.0,
                    child: child,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const AppLogo(
                        height: 84,
                        isVertical: true,
                        heroTag: 'app_logo_hero',
                      ),
                      const SizedBox(height: 6),
                      Text(
                        context.tr(LocaleKeys.splash_subtitle),
                        textAlign: TextAlign.center,
                        style: 13.medium.copyWith(
                          color: AppColors.slate400,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom loading and status indicator
          Positioned(
            bottom: 48,
            left: 24,
            right: 24,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: SizedBox(
                      width: 140,
                      height: 3.5,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: const LinearProgressIndicator(
                          backgroundColor: AppColors.slate200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primerColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: OfflineStatusPill(
                      showSurface: false,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
