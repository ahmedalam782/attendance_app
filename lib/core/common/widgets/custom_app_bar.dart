import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// Clean custom AppBar supporting light & dark themes as defined in PROJECT.md.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.actions,
    this.bottom,
    this.showBackButton = true,
    this.centerTitle = true,
    this.backgroundColor,
  });

  final String? title;
  final Widget? titleWidget;
  final Widget? leading;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final bool showBackButton;
  final bool centerTitle;
  final Color? backgroundColor;

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
      );

  @override
  Widget build(BuildContext context) {
    Widget? effectiveLeading = leading;
    if (effectiveLeading == null &&
        showBackButton &&
        Navigator.of(context).canPop()) {
      effectiveLeading = IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        color: AppColors.textPrimary,
        onPressed: () => Navigator.of(context).pop(),
      );
    }

    return AppBar(
      title: titleWidget ??
          (title != null
              ? Text(
                  title!,
                  style: 18.bold.copyWith(color: AppColors.textPrimary),
                )
              : null),
      centerTitle: centerTitle,
      leading: effectiveLeading,
      actions: actions,
      bottom: bottom,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: backgroundColor ?? AppColors.cardSurface,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: AppColors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      shape: const Border(
        bottom: BorderSide(color: AppColors.border, width: 0.8),
      ),
    );
  }
}
