import 'package:flutter/material.dart';

/// Clean & trustworthy brand & education color system for Attendance App.
abstract final class AppColors {
  // Brand colors
  static const Color primary = Color(0xff4F46E5); // Indigo
  static const Color primaryDark = Color(0xff3730A3);
  static const Color primaryLight = Color(0xffE0E7FF);
  static const Color accent = Color(0xff06B6D4); // Cyan

  // Backward-compatible aliases
  static const Color primerColor = primary;
  static const Color primerColorDark = primaryDark;
  static const Color primaryAccent = accent;

  // Gradients
  static const LinearGradient primerGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient modernPrimaryGradient = LinearGradient(
    colors: [Color(0xff4F46E5), Color(0xff3730A3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xff06B6D4), Color(0xff0891B2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Light theme tokens
  static const Color background = Color(0xffF8FAFC);
  static const Color backgroundLight = background;
  static const Color surface = Color(0xffFFFFFF);
  static const Color cardSurface = surface;
  static const Color textPrimary = Color(0xff0F172A);
  static const Color textSecondary = Color(0xff64748B);
  static const Color border = Color(0xffE2E8F0);
  static const Color slate200 = border;
  static const Color slate50 = Color(0xffF8FAFC);
  static const Color slate100 = Color(0xffF1F5F9);
  static const Color slate400 = Color(0xff94A3B8);
  static const Color slate600 = Color(0xff64748B);
  static const Color slate800 = Color(0xff1E293B);
  static const Color slate900 = Color(0xff0F172A);

  // Dark theme tokens
  static const Color darkBackground = Color(0xff0B1020);
  static const Color darkSurface = Color(0xff151B2E);
  static const Color darkTextPrimary = Color(0xffE5E7EB);
  static const Color darkTextSecondary = Color(0xff94A3B8);
  static const Color darkPrimary = Color(0xff818CF8);

  // Attendance status colors
  static const Color present = Color(0xff16A34A); // Green
  static const Color late = Color(0xffF59E0B); // Amber
  static const Color lateStatus = late;
  static const Color absent = Color(0xffDC2626); // Red
  static const Color excused = Color(0xff0284C7); // Blue
  static const Color pendingSync = Color(0xff64748B); // Slate / offline
  static const Color pending = pendingSync;

  // QR always black on white, even in dark mode
  static const Color qrForeground = Color(0xff000000);
  static const Color qrBackground = Color(0xffffffff);

  // Semantic status accents
  static const Color emerald = present;
  static const Color emeraldLight = Color(0xffECFDF5);
  static const Color amber = lateStatus;
  static const Color amberLight = Color(0xffFFFBEB);
  static const Color cyanLight = Color(0xffECFEFF);
  static const Color redLight = Color(0xffFEF2F2);
  static const Color blueLight = Color(0xffF0F9FF);

  // Backward-compatible UI tokens
  static const Color text = black04;
  static const Color muted = grey99;
  static const Color error = absent;
  static const Color white = originalWhite;

  static const Color originalWhite = Color(0xffffffff);
  static const Color originalBlack = Color(0xff000000);
  static const Color black04 = textPrimary;
  static const Color black1C = Color(0xff1C1C1C);
  static const Color black33 = Color(0xff333333);
  static const Color black1A = Color(0xff1A1A1A);
  static const Color black4B = Color(0xff4B4B4B);

  static const Color greyE0 = border;
  static const Color greyB5 = slate400;
  static const Color grey99 = textSecondary;
  static const Color greyF5 = background;
  static const Color grey8A = Color(0xff8A8A8A);
  static const Color greyA1 = Color(0xffA1A1A1);
  static const Color greyB9 = Color(0xffB9B9B9);

  static const Color blue30 = Color(0xff306FDA);
  static const Color blue15 = Color(0xff155BBD);
  static const Color redDA = absent;
  static const Color green34 = present;
  static const Color green27 = present;
  static const Color orangeE6 = lateStatus;
  static const Color transparent = Colors.transparent;
}
