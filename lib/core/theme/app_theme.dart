import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: AppTypography.fontFamily,
    scaffoldBackgroundColor: AppColors.originalWhite,
    primaryColor: AppColors.primerColor,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primerColor,
      primary: AppColors.primerColor,
      surface: AppColors.originalWhite,
      error: AppColors.redDA,
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: AppColors.primerColor,
      foregroundColor: AppColors.originalWhite,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: AppColors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.originalWhite,
      border: customThemeOutline(),
      enabledBorder: customThemeOutline(),
      focusedBorder: customThemeOutline(
        color: AppColors.primerColor,
        width: 1.5,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primerColor,
        foregroundColor: AppColors.originalWhite,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    textTheme: TextTheme(
      bodyLarge: 16.medium.copyWith(color: AppColors.originalBlack),
      bodyMedium: 14.medium.copyWith(color: AppColors.originalBlack),
      bodySmall: 12.medium.copyWith(color: AppColors.originalBlack),
    ),
  );

  static OutlineInputBorder customThemeOutline({
    Color color = AppColors.greyE0,
    double width = 0.7,
  }) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: color, width: width),
  );
}
