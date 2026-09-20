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

    final button = ElevatedButton(
      onPressed: disabled ? null : onTap,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
        splashFactory: NoSplash.splashFactory,
        disabledBackgroundColor: AppColors.greyE0,
        backgroundColor: isGradient || !isFilled
            ? Colors.transparent
            : backGroundColor,
        foregroundColor: AppColors.originalWhite,
        shadowColor: Colors.transparent,
        elevation: 0,
        side: BorderSide(
          color: isFilled
              ? (borderColor ?? AppColors.primerColor).withValues(alpha: 0.5)
              : Colors.transparent,
        ),
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
      ),
      child: isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.originalWhite,
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
                    style:
                        titleStyle ??
                        16.bold.copyWith(
                          color: disabled
                              ? AppColors.grey99
                              : isFilled
                              ? (borderColor ?? AppColors.primerColor)
                              : AppColors.originalWhite,
                        ),
                  ),
                ),
              ],
            ),
    );

    Widget result = button;
    if (isGradient && gradient != null) {
      result = Container(
        decoration: BoxDecoration(
          gradient: disabled ? null : gradient,
          color: disabled ? AppColors.greyE0 : null,
          borderRadius: borderRadius,
          boxShadow: disabled
              ? null
              : [
                  BoxShadow(
                    color: (borderColor ?? AppColors.primerColor)
                        .withValues(alpha: 0.28),
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
