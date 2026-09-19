import 'package:flutter/material.dart';

/// Color tokens aligned with Al Faris user.
abstract final class AppColors {
  static const Color primerColor = Color(0xffEA3433);
  static const Color primerColorDark = Color(0xffBC2624);

  /// Backward-compatible aliases used by existing attendance code.
  static const Color primary = primerColor;
  static const Color primaryDark = primerColorDark;
  static const Color text = black04;
  static const Color muted = grey99;
  static const Color surface = greyF5;
  static const Color error = redDA;
  static const Color white = originalWhite;

  static const LinearGradient primerGradient = LinearGradient(
    colors: [primerColor, primerColorDark],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const Color originalWhite = Color(0xffffffff);
  static const Color originalBlack = Color(0xff000000);
  static const Color black04 = Color(0xff040404);
  static const Color black1C = Color(0xff1C1C1C);
  static const Color black33 = Color(0xff333333);
  static const Color black1A = Color(0xff1A1A1A);
  static const Color black4B = Color(0xff4B4B4B);

  static const Color greyE0 = Color(0xffE0E0E0);
  static const Color greyB5 = Color(0xffB5B5B5);
  static const Color grey99 = Color(0xff999999);
  static const Color greyF5 = Color(0xffF5F6F7);
  static const Color grey8A = Color(0xff8A8A8A);
  static const Color greyA1 = Color(0xffA1A1A1);
  static const Color greyB9 = Color(0xffB9B9B9);

  static const Color blue30 = Color(0xff306FDA);
  static const Color blue15 = Color(0xff155BBD);
  static const Color redDA = Color(0xffDA251D);
  static const Color green34 = Color(0xff34C759);
  static const Color green27 = Color(0xff27AE60);
  static const Color orangeE6 = Color(0xffE67E22);
  static const Color transparent = Colors.transparent;
}
