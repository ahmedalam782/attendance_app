import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';

class AuthMetricCard extends StatelessWidget {
  const AuthMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.accentColor,
    required this.icon,
  });

  final String title;
  final String value;
  final Color accentColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.slate50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        children: [
          Icon(icon, color: accentColor, size: 20),
          const SizedBox(height: 4),
            Text(
              value,
              style: 15.bold.copyWith(color: AppColors.slate900),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: 10.medium.copyWith(color: AppColors.slate400),
            ),
        ],
      ),
    );
  }
}
