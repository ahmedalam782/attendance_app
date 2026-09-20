import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// Card widget that displays student or session QR check-in code.
/// Adheres strictly to the PROJECT.md rule:
/// Always renders black on white, even in dark mode, for maximum optical scanner reliability.
class QrCard extends StatelessWidget {
  const QrCard({
    super.key,
    required this.qrContent,
    this.title,
    this.subtitle,
    this.footerText = 'Show this QR code at the door for check-in.',
    this.size = 200,
  });

  final Widget qrContent;
  final String? title;
  final String? subtitle;
  final String footerText;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.qrBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Text(
              title!,
              textAlign: TextAlign.center,
              style: 18.bold.copyWith(color: AppColors.textPrimary),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: 13.regular.copyWith(color: AppColors.textSecondary),
              ),
            ],
            const SizedBox(height: 20),
          ],
          // Optical QR Display Container (enforces pure white and black contrast)
          Container(
            width: size,
            height: size,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.qrBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Center(child: qrContent),
          ),
          const SizedBox(height: 18),
          Text(
            footerText,
            textAlign: TextAlign.center,
            style: 12.medium.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
