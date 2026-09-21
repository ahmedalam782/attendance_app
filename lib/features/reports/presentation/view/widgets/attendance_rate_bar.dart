import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/languages/locale_keys.g.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../domain/entities/attendance_stats.dart';

class AttendanceRateBar extends StatelessWidget {
  const AttendanceRateBar({
    super.key,
    required this.stats,
  });

  final AttendanceStats stats;

  @override
  Widget build(BuildContext context) {
    final total = stats.totalCheckIns;
    final onTimeFlex = total > 0 ? (stats.presentCount * 100 ~/ total) : 100;
    final lateFlex = total > 0 ? 100 - onTimeFlex : 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                LocaleKeys.reports_attendance_breakdown.tr(),
                style: 14.bold.copyWith(color: AppColors.slate900),
              ),
              const Spacer(),
              Text(
                '${stats.onTimePercentage}% On-Time',
                style: 13.bold.copyWith(color: AppColors.present),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Segmented Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 12,
              child: total > 0
                  ? Row(
                      children: [
                        if (onTimeFlex > 0)
                          Expanded(
                            flex: onTimeFlex,
                            child: Container(color: AppColors.present),
                          ),
                        if (lateFlex > 0)
                          Expanded(
                            flex: lateFlex,
                            child: Container(color: AppColors.late),
                          ),
                      ],
                    )
                  : Container(color: AppColors.slate200),
            ),
          ),
          const SizedBox(height: 14),

          // Legends Row
          Row(
            children: [
              _buildLegend(
                color: AppColors.present,
                label: LocaleKeys.reports_present_count.tr(
                  namedArgs: {'count': stats.presentCount.toString()},
                ),
              ),
              const Spacer(),
              _buildLegend(
                color: AppColors.late,
                label: LocaleKeys.reports_late_count.tr(
                  namedArgs: {'count': stats.lateCount.toString()},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: 12.medium.copyWith(color: AppColors.slate600),
        ),
      ],
    );
  }
}
