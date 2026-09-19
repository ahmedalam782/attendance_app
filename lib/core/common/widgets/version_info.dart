import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../languages/locale_keys.g.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../utils/constants/app_strings.dart';

class VersionInfo extends StatelessWidget {
  const VersionInfo({super.key, this.textStyle});

  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Text(
      '${context.tr(LocaleKeys.global_app_name)} ${AppStrings.appVersion}',
      style: textStyle ?? 12.medium.copyWith(color: AppColors.grey99),
    );
  }
}
