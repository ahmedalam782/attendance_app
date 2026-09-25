import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/languages/locale_keys.g.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../domain/entities/session.dart';

class SessionCard extends StatelessWidget {
  const SessionCard({
    super.key,
    required this.session,
    this.isAdmin = false,
    this.onTap,
    this.onStatusChanged,
    this.onEdit,
    this.onDelete,
    this.onShowQr,
    this.onScanBadges,
  });

  final Session session;
  final bool isAdmin;
  final VoidCallback? onTap;
  final ValueChanged<String>? onStatusChanged;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onShowQr;
  final VoidCallback? onScanBadges;

  Color get _statusColor {
    if (session.isOpen) return AppColors.present;
    if (session.isClosed) return AppColors.slate500;
    return AppColors.primary;
  }

  Color get _statusBgColor {
    if (session.isOpen) return AppColors.emeraldLight;
    if (session.isClosed) return AppColors.slate100;
    return AppColors.primaryLight;
  }

  String get _statusLabel {
    if (session.isOpen) return LocaleKeys.sessions_status_open.tr();
    if (session.isClosed) return LocaleKeys.sessions_status_closed.tr();
    return LocaleKeys.sessions_status_scheduled.tr();
  }

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('hh:mm a');
    final dateFormat = DateFormat('EEE, MMM d');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: session.isOpen
                ? AppColors.present.withValues(alpha: 0.3)
                : AppColors.slate200,
            width: session.isOpen ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: session.isOpen
                  ? AppColors.present.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    session.title,
                    style: 15.bold.copyWith(color: AppColors.slate900),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _statusBgColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _statusColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _statusColor,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _statusLabel,
                        style: 11.bold.copyWith(color: _statusColor),
                      ),
                    ],
                  ),
                ),
                if (isAdmin && (onEdit != null || onDelete != null || onShowQr != null)) ...[
                  const SizedBox(width: 4),
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_vert_rounded,
                      size: 20,
                      color: AppColors.slate400,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    style: IconButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    onSelected: (value) {
                      if (value == 'show_qr') onShowQr?.call();
                      if (value == 'edit') onEdit?.call();
                      if (value == 'delete') onDelete?.call();
                    },
                    itemBuilder: (context) => [
                      if (onShowQr != null && session.isOpen)
                        PopupMenuItem(
                          value: 'show_qr',
                          child: Row(
                            children: [
                              const Icon(
                                Icons.qr_code_2_rounded,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                LocaleKeys.dynamic_qr_display_qr.tr(),
                                style: 13.medium.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (onEdit != null)
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              const Icon(
                                Icons.edit_outlined,
                                size: 18,
                                color: AppColors.slate700,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                LocaleKeys.sessions_edit_session.tr(),
                                style: 13.medium.copyWith(
                                  color: AppColors.slate900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (onDelete != null)
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(
                                Icons.delete_outline_rounded,
                                size: 18,
                                color: AppColors.absent,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                LocaleKeys.sessions_delete_session.tr(),
                                style: 13.medium.copyWith(
                                  color: AppColors.absent,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 13,
                  color: AppColors.slate400,
                ),
                const SizedBox(width: 5),
                Text(
                  dateFormat.format(session.startAt),
                  style: 12.medium.copyWith(color: AppColors.slate600),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.access_time_rounded,
                  size: 13,
                  color: AppColors.slate400,
                ),
                const SizedBox(width: 5),
                Text(
                  '${timeFormat.format(session.startAt)} - ${timeFormat.format(session.endAt)}',
                  style: 12.medium.copyWith(color: AppColors.slate600),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.slate100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        size: 11,
                        color: AppColors.slate500,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '+${session.lateAfterMinutes}m grace',
                        style: 11.regular.copyWith(color: AppColors.slate600),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.how_to_reg_outlined,
                  size: 14,
                  color: AppColors.slate400,
                ),
                const SizedBox(width: 4),
                Text(
                  '${session.attendanceCount} attended',
                  style: 12.medium.copyWith(color: AppColors.slate600),
                ),
              ],
            ),
            if (isAdmin && !session.isClosed) ...[
              const SizedBox(height: 12),
              const Divider(height: 1, color: AppColors.slate100),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: session.isScheduled
                    ? ElevatedButton.icon(
                        onPressed: onStatusChanged != null
                            ? () => onStatusChanged!('open')
                            : null,
                        icon: const Icon(Icons.play_arrow_rounded, size: 16),
                        label: Text(
                          LocaleKeys.sessions_open_session.tr(),
                          style: 12.bold,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.present,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                      )
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.end,
                        children: [
                          if (onScanBadges != null)
                            ElevatedButton.icon(
                              onPressed: onScanBadges,
                              icon: const Icon(Icons.camera_alt_rounded, size: 16),
                              label: Text(
                                LocaleKeys.admin_scanner_open_camera.tr(),
                                style: 12.bold,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.present,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                            ),
                          if (onShowQr != null)
                            ElevatedButton.icon(
                              onPressed: onShowQr,
                              icon: const Icon(Icons.qr_code_2_rounded, size: 16),
                              label: Text(
                                LocaleKeys.dynamic_qr_display_qr.tr(),
                                style: 12.bold,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                            ),
                          OutlinedButton.icon(
                            onPressed: onStatusChanged != null
                                ? () => onStatusChanged!('closed')
                                : null,
                            icon: const Icon(Icons.stop_rounded, size: 16),
                            label: Text(
                              LocaleKeys.sessions_close_session.tr(),
                              style: 12.bold,
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.absent,
                              side: const BorderSide(color: AppColors.absent),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ],
        ),
      ),
    );

  }
}
