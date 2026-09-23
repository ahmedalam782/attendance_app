import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/common/widgets/custom_button.dart';
import '../../../../../core/common/widgets/qr_card.dart';
import '../../../../../core/common/widgets/app_bottom_sheet.dart';
import '../../../../../core/common/widgets/status_chip.dart';
import '../../../../../core/languages/locale_keys.g.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../domain/models/auth_user.dart';
import '../../utils/auth_user_utils.dart';

class QrPassSheet extends StatelessWidget {
  const QrPassSheet({super.key, required this.user});

  final AuthUser user;

  static Future<void> show(BuildContext context, AuthUser user) {
    return showAppSheet<void>(context, builder: (_) => QrPassSheet(user: user),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppSheetPadding(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          StatusChip(
            status: AttendanceStatus.present,
            customLabel: LocaleKeys.home_verified_offline_pass.tr(),
          ),
          const SizedBox(height: 16),
          QrCard(
            title: AuthUserUtils.displayName(user),
            subtitle: user.email,
            footerText: LocaleKeys.home_qr_pass_footer.tr(),
            size: 180,
            qrContent: const CustomPaint(
              size: Size(160, 160),
              painter: MockQrPainter(accentColor: AppColors.qrForeground),
            ),
          ),
          const SizedBox(height: 20),
          CustomButton(
            title: LocaleKeys.global_done.tr(),
            isFilled: true,
            backGroundColor: AppColors.cardSurface,
            borderColor: AppColors.absent.withValues(alpha: 0.3),
            titleStyle: 15.bold.copyWith(color: AppColors.absent),
            onTap: () => Navigator.of(context).pop(),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Custom painter for a scannable-looking QR pattern.
class MockQrPainter extends CustomPainter {
  const MockQrPainter({required this.accentColor});

  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;

    final step = size.width / 15;

    _drawFinderPattern(canvas, 0, 0, step, paint);
    _drawFinderPattern(canvas, size.width - step * 5, 0, step, paint);
    _drawFinderPattern(canvas, 0, size.height - step * 5, step, paint);

    const activeModules = [
      Offset(6, 1),
      Offset(7, 1),
      Offset(8, 1),
      Offset(6, 2),
      Offset(8, 3),
      Offset(6, 4),
      Offset(7, 5),
      Offset(8, 5),
      Offset(1, 6),
      Offset(3, 6),
      Offset(5, 6),
      Offset(7, 6),
      Offset(9, 6),
      Offset(11, 6),
      Offset(13, 6),
      Offset(2, 7),
      Offset(4, 7),
      Offset(6, 7),
      Offset(10, 7),
      Offset(12, 7),
      Offset(6, 8),
      Offset(7, 8),
      Offset(8, 8),
      Offset(9, 8),
      Offset(11, 8),
      Offset(6, 9),
      Offset(8, 9),
      Offset(10, 9),
      Offset(12, 9),
      Offset(6, 10),
      Offset(7, 11),
      Offset(9, 11),
      Offset(11, 11),
      Offset(6, 12),
      Offset(8, 12),
      Offset(10, 12),
      Offset(12, 12),
      Offset(7, 13),
      Offset(9, 13),
      Offset(11, 13),
      Offset(13, 13),
    ];

    for (final module in activeModules) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            module.dx * step,
            module.dy * step,
            step * 0.9,
            step * 0.9,
          ),
          const Radius.circular(2),
        ),
        paint,
      );
    }
  }

  void _drawFinderPattern(
    Canvas canvas,
    double x,
    double y,
    double step,
    Paint paint,
  ) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, step * 5, step * 5),
        const Radius.circular(6),
      ),
      paint,
    );
    final clearPaint = Paint()..color = AppColors.originalWhite;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x + step, y + step, step * 3, step * 3),
        const Radius.circular(4),
      ),
      clearPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x + step * 1.6, y + step * 1.6, step * 1.8, step * 1.8),
        const Radius.circular(3),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
