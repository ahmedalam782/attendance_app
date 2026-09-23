import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// Shows a bottom-sheet with a floating circular X close button
/// that sits above the sheet edge.
///
/// Usage:
/// `dart
/// showAppSheet(context, builder: (_) => MySheetContent());
/// `
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool isScrollControlled = true,
  bool isDismissible = true,
  double? maxHeightFactor,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    isDismissible: isDismissible,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (ctx) => _AppSheetScaffold(
      maxHeightFactor: maxHeightFactor,
      child: builder(ctx),
    ),
  );
}

/// Internal scaffold — clips the sheet top edge with a circular notch
/// and floats a circular close button in that notch.
class _AppSheetScaffold extends StatelessWidget {
  const _AppSheetScaffold({
    required this.child,
    this.maxHeightFactor,
  });

  final Widget child;
  final double? maxHeightFactor;

  static const double buttonRadius = 20.0;
  static const double buttonDiameter = 40.0;
  static const double notchRadius = 27.0;
  static const double buttonCenterY = 0.0;
  static const double buttonCenterXFromRight = 56.0;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final keyboardHeight = mediaQuery.viewInsets.bottom;
    final factor = maxHeightFactor ?? 0.72;
    final screenH = mediaQuery.size.height;
    final availableHeight = screenH - keyboardHeight;
    final maxH = keyboardHeight > 0
        ? (availableHeight * 0.88)
        : (screenH * factor);

    return AnimatedPadding(
      padding: EdgeInsets.only(bottom: keyboardHeight),
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxH),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Sheet body with circular cutout notch
            ClipPath(
              clipper: const _NotchedSheetClipper(
                buttonCenterXFromRight: buttonCenterXFromRight,
                buttonCenterY: buttonCenterY,
                notchRadius: notchRadius,
                cornerRadius: 28.0,
              ),
              child: Container(
                color: AppColors.cardSurface,
                child: MediaQuery.removeViewInsets(
                  removeBottom: true,
                  context: context,
                  child: child,
                ),
              ),
            ),

            // Floating circular close button inside the notch
            Positioned(
              top: buttonCenterY - buttonRadius,
              right: buttonCenterXFromRight - buttonRadius,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: buttonDiameter,
                  height: buttonDiameter,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9), // light off-white
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.slate200,
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: AppColors.slate700,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cuts a circular notch into the top edge of a rounded-top rectangle.
class _NotchedSheetClipper extends CustomClipper<Path> {
  const _NotchedSheetClipper({
    required this.buttonCenterXFromRight,
    required this.buttonCenterY,
    required this.notchRadius,
    this.cornerRadius = 28.0,
  });

  final double buttonCenterXFromRight;
  final double buttonCenterY;
  final double notchRadius;
  final double cornerRadius;

  @override
  Path getClip(Size size) {
    final hostPath = Path()
      ..addRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(0, 0, size.width, size.height),
          topLeft: Radius.circular(cornerRadius),
          topRight: Radius.circular(cornerRadius),
        ),
      );

    final guestPath = Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(size.width - buttonCenterXFromRight, buttonCenterY),
          radius: notchRadius,
        ),
      );

    return Path.combine(PathOperation.difference, hostPath, guestPath);
  }

  @override
  bool shouldReclip(_NotchedSheetClipper oldClipper) {
    return oldClipper.buttonCenterXFromRight != buttonCenterXFromRight ||
        oldClipper.buttonCenterY != buttonCenterY ||
        oldClipper.notchRadius != notchRadius ||
        oldClipper.cornerRadius != cornerRadius;
  }
}

/// Standard inner padding for sheet content.
/// Accounts for keyboard insets and bottom safe area.
class AppSheetPadding extends StatelessWidget {
  const AppSheetPadding({
    super.key,
    required this.child,
    this.horizontal = 20.0,
    this.topExtra = 34.0,
  });

  final Widget child;
  final double horizontal;
  final double topExtra;

  @override
  Widget build(BuildContext context) {
    final bottom =
        MediaQuery.of(context).viewInsets.bottom +
        MediaQuery.of(context).viewPadding.bottom +
        20;
    return Padding(
      padding: EdgeInsets.fromLTRB(horizontal, topExtra, horizontal, bottom),
      child: child,
    );
  }
}

/// Sheet section header — title + optional subtitle.
class AppSheetHeader extends StatelessWidget {
  const AppSheetHeader({
    super.key,
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: 18.bold.copyWith(color: AppColors.slate900),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 3),
          Text(
            subtitle!,
            style: 12.regular.copyWith(color: AppColors.slate400),
          ),
        ],
      ],
    );
  }
}
