import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/languages/locale_keys.g.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_typography.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.height = 48,
    this.showTitle = true,
    this.subtitle,
    this.isVertical = false,
    this.heroTag,
  });

  final double height;
  final bool showTitle;
  final String? subtitle;
  final bool isVertical;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final markSize = height;

    Widget logoBadge = Container(
      width: markSize,
      height: markSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(markSize * 0.28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: markSize * 0.35,
            offset: Offset(0, markSize * 0.12),
          ),
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.15),
            blurRadius: markSize * 0.2,
            offset: Offset(0, markSize * 0.05),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(markSize * 0.28),
        child: SvgPicture.asset(
          AppIcons.iconsAppLogo,
          width: markSize,
          height: markSize,
          fit: BoxFit.contain,
        ),
      ),
    );

    if (heroTag != null) {
      logoBadge = Hero(
        tag: heroTag!,
        child: logoBadge,
      );
    }

    if (!showTitle) {
      return logoBadge;
    }

    final titleColumn = Column(
      crossAxisAlignment:
          isVertical ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          context.tr(LocaleKeys.global_app_name),
          style: (isVertical ? 28 : 22).bold.copyWith(
            color: AppColors.slate900,
            letterSpacing: -0.5,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 3),
          Text(
            subtitle!,
            style: (isVertical ? 14 : 12).medium.copyWith(
                  color: AppColors.slate400,
                  letterSpacing: -0.2,
                ),
          ),
        ],
      ],
    );

    if (isVertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          logoBadge,
          const SizedBox(height: 16),
          titleColumn,
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        logoBadge,
        const SizedBox(width: 12),
        titleColumn,
      ],
    );
  }
}
