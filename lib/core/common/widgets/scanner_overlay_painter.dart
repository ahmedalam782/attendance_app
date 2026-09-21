import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Overlay that dims the camera preview and punches a transparent viewfinder.
/// Uses even-odd fill (more reliable than Path.combine on some Android GPUs).
class ScannerOverlayPainter extends CustomPainter {
  const ScannerOverlayPainter({
    required this.scanWindowSize,
    required this.borderRadius,
    this.overlayColor = AppColors.scannerOverlay,
    this.borderColor = AppColors.scannerFrame,
    this.borderWidth = 0,
  });

  final double scanWindowSize;
  final double borderRadius;
  final Color overlayColor;
  final Color borderColor;
  final double borderWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final cutoutRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: scanWindowSize,
        height: scanWindowSize,
      ),
      Radius.circular(borderRadius),
    );

    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(cutoutRect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(
      overlayPath,
      Paint()
        ..color = overlayColor
        ..style = PaintingStyle.fill,
    );

    if (borderWidth > 0) {
      canvas.drawRRect(
        cutoutRect,
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ScannerOverlayPainter oldDelegate) =>
      oldDelegate.scanWindowSize != scanWindowSize ||
      oldDelegate.borderRadius != borderRadius ||
      oldDelegate.overlayColor != overlayColor ||
      oldDelegate.borderColor != borderColor ||
      oldDelegate.borderWidth != borderWidth;
}
