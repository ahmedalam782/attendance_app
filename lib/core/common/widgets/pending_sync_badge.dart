import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../languages/locale_keys.g.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class PendingSyncBadge extends StatelessWidget {
  const PendingSyncBadge({
    super.key,
    required this.pendingCount,
  });

  final int pendingCount;

  @override
  Widget build(BuildContext context) {
    final hasPending = pendingCount > 0;
    final color = hasPending ? AppColors.late : AppColors.present;
    final bgColor = hasPending ? AppColors.amberLight : AppColors.emeraldLight;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasPending
                ? Icons.cloud_upload_outlined
                : Icons.cloud_done_rounded,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              hasPending
                  ? LocaleKeys.attendance_pending_sync.tr(
                      namedArgs: {'count': pendingCount.toString()},
                    )
                  : LocaleKeys.attendance_all_synced.tr(),
              style: 11.bold.copyWith(color: color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
