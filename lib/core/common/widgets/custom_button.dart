import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// Al Faris-style primary button (gradient by default). No Lottie/SVG deps.
class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    this.onTap,
    this.title,
    this.isLoading = false,
    this.isFilled = false,
    this.isGradient = true,
    this.isExpanded = true,
    this.width,
    this.height,
    this.radius,
    this.titleStyle,
    this.prefixIcon,
    this.backGroundColor = AppColors.originalWhite,
    this.borderColor = AppColors.primerColor,
    this.gradient = AppColors.primerGradient,
  });

  final VoidCallback? onTap;
  final String? title;
  final bool isLoading;
  final bool isFilled;
  final bool isGradient;
  final bool isExpanded;
  final double? width;
  final double? height;
  final double? radius;
  final TextStyle? titleStyle;
  final Widget? prefixIcon;
  final Color? backGroundColor;
  final Color? borderColor;
  final LinearGradient? gradient;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius ?? 16);
    final disabled = onTap == null || isLoading;
    final useGradient = isGradient && !isFilled && gradient != null;
    final effectiveBorder = borderColor ?? AppColors.primerColor;
    final solidBackground = backGroundColor ?? AppColors.cardSurface;
    final labelColor = titleStyle?.color ??
        (disabled
            ? AppColors.grey99
            : useGradient || !isFilled
                ? AppColors.originalWhite
                : AppColors.slate800);

    final button = ElevatedButton(
      onPressed: disabled ? null : onTap,
      style: ButtonStyle(
        elevation: const WidgetStatePropertyAll(0),
        shadowColor: const WidgetStatePropertyAll(Colors.transparent),
        splashFactory: NoSplash.splashFactory,
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(vertical: 15, horizontal: 16),
        ),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.greyE0;
          }
          return useGradient ? Colors.transparent : solidBackground;
        }),
        foregroundColor: WidgetStatePropertyAll(labelColor),
        side: WidgetStatePropertyAll(
          BorderSide(
            color: isFilled
                ? effectiveBorder.withValues(alpha: 0.55)
                : Colors.transparent,
          ),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: borderRadius),
        ),
      ),
      child: isLoading
          ? SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: labelColor,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (prefixIcon != null) ...[
                  prefixIcon!,
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    title ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: (titleStyle ?? 14.bold).copyWith(color: labelColor),
                  ),
                ),
              ],
            ),
    );

    Widget result = button;
    if (useGradient) {
      result = Container(
        decoration: BoxDecoration(
          gradient: disabled ? null : gradient,
          color: disabled ? AppColors.greyE0 : null,
          borderRadius: borderRadius,
          boxShadow: disabled
              ? null
              : [
                  BoxShadow(
                    color: AppColors.primerColor.withValues(alpha: 0.28),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: borderRadius,
          child: button,
        ),
      );
    }

    return Center(
      child: SizedBox(
        width: isExpanded ? (width ?? double.infinity) : width,
        height: height,
        child: result,
      ),
    );
  }
}
