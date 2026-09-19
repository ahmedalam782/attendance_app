import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/app_animation_curves.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_typography.dart';
import 'custom_button.dart';

class CustomSuccessDialog extends StatelessWidget {
  const CustomSuccessDialog({
    super.key,
    required this.title,
    required this.subTitle,
    required this.buttonName,
    required this.onTap,
    this.showButton = true,
    this.popOnTap = true,
  });

  final String title;
  final String subTitle;
  final String buttonName;
  final VoidCallback onTap;
  final bool showButton;
  final bool popOnTap;

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required String subTitle,
    required String buttonName,
    required VoidCallback onTap,
    bool showButton = true,
    bool popOnTap = true,
    bool barrierDismissible = false,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => CustomSuccessDialog(
        title: title,
        subTitle: subTitle,
        buttonName: buttonName,
        onTap: onTap,
        showButton: showButton,
        popOnTap: popOnTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.originalWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.6, end: 1),
              duration: const Duration(milliseconds: 450),
              curve: AppAnimationCurves.easeOutBack,
              builder: (context, value, child) =>
                  Transform.scale(scale: value, child: child),
              child: SvgPicture.asset(
                AppIcons.iconsCheckSuccess,
                width: 72,
                height: 72,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: 20.semiBold.copyWith(color: AppColors.black04),
            ),
            const SizedBox(height: 8),
            Text(
              subTitle,
              textAlign: TextAlign.center,
              style: 14.regular.copyWith(color: AppColors.grey99),
            ),
            if (showButton) ...[
              const SizedBox(height: 24),
              CustomButton(
                title: buttonName,
                onTap: () {
                  if (popOnTap) Navigator.of(context).pop();
                  onTap();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
