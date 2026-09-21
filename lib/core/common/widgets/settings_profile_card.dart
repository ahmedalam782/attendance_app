import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// Settings profile summary row.
class SettingsProfileCard extends StatelessWidget {
  const SettingsProfileCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: accentColor.withValues(alpha: 0.1),
            child: Icon(icon, size: 28, color: accentColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: 14.bold.copyWith(color: AppColors.slate900),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: 12.medium.copyWith(color: accentColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
