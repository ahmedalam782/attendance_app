import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Soft indigo/cyan radial glows used behind auth and splash screens.
class AmbientGlowBackground extends StatelessWidget {
  const AmbientGlowBackground({
    super.key,
    this.variant = AmbientGlowVariant.auth,
  });

  final AmbientGlowVariant variant;

  @override
  Widget build(BuildContext context) {
    final glows = switch (variant) {
      AmbientGlowVariant.auth => const [
          Positioned(
            top: -60,
            right: -60,
            child: _GlowOrb(
              size: 200,
              color: AppColors.primary,
              opacity: 0.12,
            ),
          ),
          Positioned(
            top: 120,
            left: -60,
            child: _GlowOrb(
              size: 180,
              color: AppColors.accent,
              opacity: 0.10,
            ),
          ),
        ],
      AmbientGlowVariant.register => const [
          Positioned(
            top: -60,
            right: -60,
            child: _GlowOrb(
              size: 220,
              color: AppColors.primary,
              opacity: 0.12,
            ),
          ),
          Positioned(
            bottom: -40,
            left: -40,
            child: _GlowOrb(
              size: 180,
              color: AppColors.accent,
              opacity: 0.10,
            ),
          ),
        ],
      AmbientGlowVariant.splash => const [
          Positioned(
            top: -80,
            right: -80,
            child: _GlowOrb(
              size: 280,
              color: AppColors.primary,
              opacity: 0.16,
            ),
          ),
          Positioned(
            bottom: -60,
            left: -60,
            child: _GlowOrb(
              size: 260,
              color: AppColors.accent,
              opacity: 0.14,
            ),
          ),
        ],
    };

    return IgnorePointer(
      child: ColoredBox(
        color: AppColors.background,
        child: SizedBox.expand(
          child: Stack(children: glows),
        ),
      ),
    );
  }
}

enum AmbientGlowVariant { auth, register, splash }

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.size,
    required this.color,
    required this.opacity,
  });

  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: opacity),
            color.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}
