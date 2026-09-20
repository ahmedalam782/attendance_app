import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// Supported attendance states adhering to PROJECT.md
enum AttendanceStatus {
  present,
  late,
  absent,
  excused,
  pendingSync,
}

/// Shared chip widget for displaying attendance status.
/// Never relies on color alone: pairs color with icon and text label.
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.status,
    this.customLabel,
    this.fontSize = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  });

  final AttendanceStatus status;
  final String? customLabel;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  Color get _color => switch (status) {
        AttendanceStatus.present => AppColors.present,
        AttendanceStatus.late => AppColors.late,
        AttendanceStatus.absent => AppColors.absent,
        AttendanceStatus.excused => AppColors.excused,
        AttendanceStatus.pendingSync => AppColors.pendingSync,
      };

  Color get _backgroundColor => switch (status) {
        AttendanceStatus.present => AppColors.emeraldLight,
        AttendanceStatus.late => AppColors.amberLight,
        AttendanceStatus.absent => AppColors.redLight,
        AttendanceStatus.excused => AppColors.blueLight,
        AttendanceStatus.pendingSync => AppColors.slate100,
      };

  IconData get _icon => switch (status) {
        AttendanceStatus.present => Icons.check_circle_rounded,
        AttendanceStatus.late => Icons.access_time_rounded,
        AttendanceStatus.absent => Icons.cancel_rounded,
        AttendanceStatus.excused => Icons.info_rounded,
        AttendanceStatus.pendingSync => Icons.sync_rounded,
      };

  String get _defaultLabel => switch (status) {
        AttendanceStatus.present => '✓ Present',
        AttendanceStatus.late => '⏱ Late',
        AttendanceStatus.absent => '✕ Absent',
        AttendanceStatus.excused => 'ℹ Excused',
        AttendanceStatus.pendingSync => '⟳ Pending',
      };

  @override
  Widget build(BuildContext context) {
    final color = _color;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, color: color, size: fontSize + 2),
          const SizedBox(width: 5),
          Text(
            customLabel ?? _defaultLabel,
            style: fontSize.bold.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
