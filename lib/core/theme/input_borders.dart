import 'package:flutter/material.dart';

import 'app_colors.dart';

OutlineInputBorder customOutLineBorders({
  double? borderRadius,
  Color? borderColor,
  double? borderWidth,
}) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(borderRadius ?? 14),
    borderSide: BorderSide(
      color: borderColor ?? AppColors.slate200,
      width: borderWidth ?? 1.0,
    ),
  );
}
