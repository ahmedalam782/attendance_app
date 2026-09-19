import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTypography {
  static const fontFamily = 'SomarSans';

  static String locale = 'ar';
  static Brightness brightness = Brightness.light;

  static Color get textColor => brightness == Brightness.dark
      ? AppColors.originalWhite
      : AppColors.black04;
}

extension TextStyleExtension on num {
  TextStyle get bold => TextStyle(
    fontSize: toDouble(),
    fontWeight: FontWeight.w700,
    fontFamily: AppTypography.fontFamily,
  );

  TextStyle get semiBold => TextStyle(
    fontSize: toDouble(),
    fontWeight: FontWeight.w600,
    fontFamily: AppTypography.fontFamily,
  );

  TextStyle get medium => TextStyle(
    fontSize: toDouble(),
    fontWeight: FontWeight.w500,
    fontFamily: AppTypography.fontFamily,
  );

  TextStyle get regular => TextStyle(
    fontSize: toDouble(),
    fontWeight: FontWeight.w400,
    fontFamily: AppTypography.fontFamily,
  );

  TextStyle get light => TextStyle(
    fontSize: toDouble(),
    fontWeight: FontWeight.w300,
    fontFamily: AppTypography.fontFamily,
  );
}
