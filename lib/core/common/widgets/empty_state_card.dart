import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import 'custom_button.dart';

/// Empty / placeholder card used on feature tabs.
class EmptyStateCard extends StatelessWidget {
  const EmptyStateCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconColor,
    this.actionTitle,
    this.actionIcon,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color? iconColor;
  final String? actionTitle;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? AppColors.primerColor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate200),
        boxShadow: [
          BoxShadow(
            color: AppColors.slate900.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: color),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: 15.bold.copyWith(color: AppColors.slate900),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: 12.regular.copyWith(color: AppColors.slate400),
          ),
          if (actionTitle != null && onAction != null) ...[
            const SizedBox(height: 20),
            CustomButton(
              title: actionTitle!,
              prefixIcon: actionIcon == null
                  ? null
                  : Icon(
                      actionIcon,
                      color: AppColors.originalWhite,
                      size: 18,
                    ),
              onTap: onAction,
            ),
          ],
        ],
      ),
    );
  }
}
