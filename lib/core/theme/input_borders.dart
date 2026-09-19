import 'package:flutter/material.dart';

import 'app_colors.dart';

OutlineInputBorder customOutLineBorders({
  double? borderRadius,
  Color? borderColor,
  double? borderWidth,
}) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(borderRadius ?? 12),
    borderSide: BorderSide(
      color: borderColor ?? AppColors.greyE0,
      width: borderWidth ?? 0.7,
    ),
  );
}
