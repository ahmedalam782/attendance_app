import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../languages/locale_keys.g.dart';
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
    this.fontSize = 11,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  });

  final AttendanceStatus status;
  final String? customLabel;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  factory StatusChip.fromString(
    String statusStr, {
    Key? key,
    String? customLabel,
    double fontSize = 11,
    EdgeInsetsGeometry padding =
        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  }) {
    final normalized = statusStr.trim().toLowerCase();
    final status = switch (normalized) {
      'present' => AttendanceStatus.present,
      'late' => AttendanceStatus.late,
      'absent' => AttendanceStatus.absent,
      'excused' => AttendanceStatus.excused,
      'pendingsync' || 'pending' => AttendanceStatus.pendingSync,
      _ => AttendanceStatus.present,
    };
    return StatusChip(
      key: key,
      status: status,
      customLabel: customLabel,
      fontSize: fontSize,
      padding: padding,
    );
  }

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

  String get _defaultLabelKey => switch (status) {
        AttendanceStatus.present => LocaleKeys.status_present,
        AttendanceStatus.late => LocaleKeys.status_late,
        AttendanceStatus.absent => LocaleKeys.status_absent,
        AttendanceStatus.excused => LocaleKeys.status_excused,
        AttendanceStatus.pendingSync => LocaleKeys.status_pending,
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
            customLabel ?? _defaultLabelKey.tr(),
            style: fontSize.bold.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
