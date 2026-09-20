import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// Badge showing documents or records waiting to be synced with Firestore.
/// Driven by `metadata.hasPendingWrites`.
class PendingSyncBadge extends StatelessWidget {
  const PendingSyncBadge({
    super.key,
    this.pendingCount,
    this.isCompact = false,
  });

  final int? pendingCount;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: AppColors.late,
          shape: BoxShape.circle,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.amberLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.late.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cloud_queue_rounded,
            size: 13,
            color: AppColors.late,
          ),
          const SizedBox(width: 4),
          Text(
            pendingCount != null ? '$pendingCount pending' : 'Offline sync',
            style: 11.bold.copyWith(color: AppColors.late),
          ),
        ],
      ),
    );
  }
}
