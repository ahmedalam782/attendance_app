import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/app_animation_curves.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_icons.dart';

class AppLoadingDialog {
  static bool _isDialogShown = false;

  static void show(BuildContext context) {
    if (_isDialogShown) return;
    _isDialogShown = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: AppColors.originalBlack.withValues(alpha: 0.5),
      builder: (context) => const PopScope(
        canPop: false,
        child: Center(child: _AnimatedAppLogo()),
      ),
    ).then((_) {
      _isDialogShown = false;
    });
  }

  static void hide(BuildContext context) {
    if (_isDialogShown) {
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      _isDialogShown = false;
    }
  }
}

class _AnimatedAppLogo extends StatefulWidget {
  const _AnimatedAppLogo();

  @override
  State<_AnimatedAppLogo> createState() => _AnimatedAppLogoState();
}

class _AnimatedAppLogoState extends State<_AnimatedAppLogo>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _spinController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: AppAnimationCurves.easeInOutSine,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: AppAnimationCurves.easeInOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _spinController,
          builder: (context, child) {
            return SizedBox(
              width: 150,
              height: 150,
              child: CustomPaint(
                painter: _OrbitalPainter(
                  progress: _spinController.value,
                  color: AppColors.primerColor,
                ),
              ),
            );
          },
        ),
        FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: SizedBox(
              width: 60,
              height: 60,
              child: FittedBox(
                child: SvgPicture.asset(AppIcons.iconsAppLogoHeader),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OrbitalPainter extends CustomPainter {
  _OrbitalPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final gradientShader = AppColors.primerGradient.createShader(
      Rect.fromCircle(center: center, radius: radius),
    );

    void drawRing({
      required double ringRadius,
      required double startAngle,
      required double sweepAngle,
      required double strokeWidth,
      required double dotAngle,
      required double dotSize,
    }) {
      final paint = Paint()
        ..shader = gradientShader
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: ringRadius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      final dotOffset = Offset(
        center.dx + ringRadius * cos(dotAngle),
        center.dy + ringRadius * sin(dotAngle),
      );

      canvas.drawCircle(
        dotOffset,
        dotSize * 1.5,
        Paint()
          ..color = color.withValues(alpha: 0.6)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      canvas.drawCircle(
        dotOffset,
        dotSize,
        Paint()
          ..shader = gradientShader
          ..style = PaintingStyle.fill,
      );
    }

    drawRing(
      ringRadius: radius * 0.95,
      startAngle: progress * 2 * pi,
      sweepAngle: pi * 1.5,
      strokeWidth: 0.8,
      dotAngle: progress * 2 * pi + pi,
      dotSize: 2.5,
    );
    drawRing(
      ringRadius: radius * 0.75,
      startAngle: -progress * 2 * pi + (pi / 4),
      sweepAngle: pi * 1.2,
      strokeWidth: 1.2,
      dotAngle: -progress * 2 * pi + pi,
      dotSize: 3.5,
    );
    drawRing(
      ringRadius: radius * 0.55,
      startAngle: progress * 3 * pi,
      sweepAngle: pi * 0.8,
      strokeWidth: 0.6,
      dotAngle: progress * 3 * pi + (pi / 2),
      dotSize: 2,
    );
  }

  @override
  bool shouldRepaint(covariant _OrbitalPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
