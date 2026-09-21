import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        fontFamily: AppTypography.fontFamily,
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.primary,
        canvasColor: AppColors.background,
        splashColor: AppColors.transparent,
        highlightColor: AppColors.transparent,
        dividerColor: AppColors.border,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          onPrimary: AppColors.onPrimary,
          secondary: AppColors.accent,
          onSecondary: AppColors.onPrimary,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
          error: AppColors.absent,
          onError: AppColors.onPrimary,
          outline: AppColors.border,
        ),
        cardTheme: CardThemeData(
          color: AppColors.cardSurface,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          surfaceTintColor: AppColors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: AppColors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.cardSurface,
          surfaceTintColor: AppColors.transparent,
          modalBackgroundColor: AppColors.cardSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          showDragHandle: false,
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.cardSurface,
          surfaceTintColor: AppColors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.border,
          thickness: 1,
          space: 1,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          hintStyle: TextStyle(color: AppColors.slate400, fontSize: 14),
          border: customThemeOutline(),
          enabledBorder: customThemeOutline(),
          focusedBorder: customThemeOutline(
            color: AppColors.primary,
            width: 1.5,
          ),
          errorBorder: customThemeOutline(color: AppColors.absent),
          focusedErrorBorder: customThemeOutline(
            color: AppColors.absent,
            width: 1.5,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            disabledBackgroundColor: AppColors.border,
            disabledForegroundColor: AppColors.slate400,
            elevation: 0,
            minimumSize: const Size(0, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary, width: 1.5),
            minimumSize: const Size(0, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 2,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.slate100,
          selectedColor: AppColors.primaryLight,
          disabledColor: AppColors.slate100,
          labelStyle: const TextStyle(color: AppColors.textPrimary),
          secondaryLabelStyle: const TextStyle(color: AppColors.primary),
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.cardSurface,
          indicatorColor: AppColors.primary.withValues(alpha: 0.12),
          surfaceTintColor: AppColors.transparent,
          elevation: 0,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              );
            }
            return const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.slate400,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: AppColors.primary, size: 20);
            }
            return const IconThemeData(color: AppColors.slate400, size: 20);
          }),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.primary,
          linearTrackColor: AppColors.slate200,
        ),
        textTheme: TextTheme(
          bodyLarge: 14.medium.copyWith(color: AppColors.textPrimary),
          bodyMedium: 13.medium.copyWith(color: AppColors.textPrimary),
          bodySmall: 11.medium.copyWith(color: AppColors.textSecondary),
          titleLarge: 20.bold.copyWith(color: AppColors.textPrimary),
          titleMedium: 16.bold.copyWith(color: AppColors.textPrimary),
          titleSmall: 14.bold.copyWith(color: AppColors.textPrimary),
          labelLarge: 14.bold.copyWith(color: AppColors.textPrimary),
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: AppTypography.fontFamily,
        scaffoldBackgroundColor: AppColors.darkBackground,
        primaryColor: AppColors.darkPrimary,
        canvasColor: AppColors.darkBackground,
        splashColor: AppColors.transparent,
        highlightColor: AppColors.transparent,
        dividerColor: AppColors.darkBorder,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.darkPrimary,
          onPrimary: AppColors.darkBackground,
          secondary: AppColors.accent,
          onSecondary: AppColors.darkBackground,
          surface: AppColors.darkSurface,
          onSurface: AppColors.darkTextPrimary,
          error: AppColors.absent,
          onError: AppColors.onPrimary,
          outline: AppColors.darkBorder,
        ),
        cardTheme: CardThemeData(
          color: AppColors.darkSurface,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.darkBorder, width: 1),
          ),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: AppColors.darkSurface,
          foregroundColor: AppColors.darkTextPrimary,
          surfaceTintColor: AppColors.transparent,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: AppColors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.darkSurface,
          surfaceTintColor: AppColors.transparent,
          modalBackgroundColor: AppColors.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.darkSurface,
          border: customThemeOutline(color: AppColors.slate700),
          enabledBorder: customThemeOutline(color: AppColors.slate700),
          focusedBorder: customThemeOutline(
            color: AppColors.darkPrimary,
            width: 1.5,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            elevation: 0,
            minimumSize: const Size(0, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        textTheme: TextTheme(
          bodyLarge: 14.medium.copyWith(color: AppColors.darkTextPrimary),
          bodyMedium: 13.medium.copyWith(color: AppColors.darkTextPrimary),
          bodySmall: 11.medium.copyWith(color: AppColors.darkTextSecondary),
        ),
      );

  static OutlineInputBorder customThemeOutline({
    Color color = AppColors.border,
    double width = 1.0,
  }) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: width),
      );
}
