import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../languages/locale_keys.g.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// Compact online/offline readiness indicator.
class OfflineStatusPill extends StatelessWidget {
  const OfflineStatusPill({
    super.key,
    this.showSurface = true,
    this.fontSize = 10,
  });

  final bool showSurface;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(
            color: AppColors.present,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          LocaleKeys.splash_offline_ready.tr(),
          style: fontSize.semiBold.copyWith(color: AppColors.textSecondary),
          maxLines: 1,
          softWrap: false,
        ),
      ],
    );

    if (!showSurface) return content;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: content,
    );
  }
}
