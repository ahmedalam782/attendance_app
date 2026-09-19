import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/languages/locale_keys.g.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_typography.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.height = 65, this.showTitle = true});

  final double height;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final markSize = height * 0.72;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          AppIcons.iconsAppLogo,
          height: markSize,
          width: markSize,
        ),
        if (showTitle) ...[
          const SizedBox(width: 12),
          Text(
            context.tr(LocaleKeys.global_app_name),
            style: 24.semiBold.copyWith(color: AppColors.black04),
          ),
        ],
      ],
    );
  }
}
