import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import 'offline_status_pill.dart';

/// Shared page header used across admin/student tabs.
class FeaturePageHeader extends StatelessWidget {
  const FeaturePageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.leading,
    this.trailing,
    this.showOfflinePill = false,
  });

  final String title;
  final String subtitle;
  final Widget? leading;
  final Widget? trailing;
  final bool showOfflinePill;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (leading != null) ...[
          Row(
            children: [
              leading!,
              if (trailing != null) ...[
                const Spacer(),
                trailing!,
              ],
            ],
          ),
          const SizedBox(height: 14),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                title,
                style: 20.bold.copyWith(color: AppColors.slate900),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (trailing != null && leading == null) ...[
              const SizedBox(width: 10),
              Flexible(child: trailing!),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: 12.regular.copyWith(color: AppColors.slate400),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (showOfflinePill) ...[
          const SizedBox(height: 10),
          const OfflineStatusPill(showSurface: true),
        ],
      ],
    );
  }
}
