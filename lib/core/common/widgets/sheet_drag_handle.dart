import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Standard bottom-sheet drag handle.
class SheetDragHandle extends StatelessWidget {
  const SheetDragHandle({
    super.key,
    this.width = 40,
    this.height = 4,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.slate200,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
