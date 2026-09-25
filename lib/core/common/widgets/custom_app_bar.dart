import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// Clean AppBar with standard back affordance (no custom floating buttons).
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
    this.showBottomBorder = true,
  });

  final String? title;
  final Widget? titleWidget;
  final Widget? leading;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final bool showBackButton;
  final bool centerTitle;
  final Color? backgroundColor;
  final bool showBottomBorder;

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
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        onPressed: () => Navigator.of(context).maybePop(),
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 18,
          color: AppColors.textPrimary,
        ),
      );
    }

    return AppBar(
      title: titleWidget ??
          (title != null
              ? Text(
                  title!,
                  style: 16.bold.copyWith(color: AppColors.textPrimary),
                )
              : null),
      centerTitle: centerTitle,
      automaticallyImplyLeading: false,
      leading: effectiveLeading,
      actions: actions,
      bottom: bottom,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: backgroundColor ?? AppColors.cardSurface,
      foregroundColor: AppColors.textPrimary,
      surfaceTintColor: AppColors.transparent,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: AppColors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      shape: showBottomBorder
          ? const Border(
              bottom: BorderSide(color: AppColors.border, width: 0.8),
            )
          : null,
    );
  }
}
