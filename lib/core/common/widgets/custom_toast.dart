import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class CustomToast {
  CustomToast({
    required this.context,
    this.header,
    this.description,
    this.type = ToastificationType.success,
    this.isWeb = kIsWeb,
    this.primaryColor,
    this.showProgressBar = true,
  });

  final BuildContext context;
  final String? header;
  final String? description;
  final Color? primaryColor;
  ToastificationType? type;
  final bool isWeb;
  final bool showProgressBar;

  static ToastificationItem? _currentToast;

  void showToast() {
    if (_currentToast != null) {
      toastification.dismiss(_currentToast!);
    }
    toastification.dismissAll(delayForAnimation: false);

    _currentToast = toastification.show(
      primaryColor: primaryColor ?? _colorByType(),
      style: ToastificationStyle.flatColored,
      alignment: isWeb ? AlignmentDirectional.topEnd : Alignment.topCenter,
      progressBarTheme: ProgressIndicatorThemeData(
        color: primaryColor ?? _colorByType(),
        linearMinHeight: 2,
        linearTrackColor: (primaryColor ?? _colorByType()).withValues(
          alpha: 0.2,
        ),
      ),
      type: type,
      closeOnClick: true,
      dragToClose: true,
      showProgressBar: showProgressBar,
      showIcon: false,
      sizeConstraints: const BoxConstraints(minHeight: 0),
      closeButton: ToastCloseButton(
        showType: CloseButtonShowType.always,
        buttonBuilder: (context, onClose) => Center(
          child: GestureDetector(
            onTap: onClose,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(start: 6, end: 2),
              child: Icon(
                Icons.close_rounded,
                size: 16,
                color: AppColors.black04.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      context: context,
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        color: primaryColor ?? _colorByType(),
        width: 0.5,
      ),
      title: Text(
        header ?? '',
        style: 11.medium.copyWith(
          color: AppColors.black04,
          height: 1.2,
        ),
      ),
      description: description != null
          ? Text(
              description!,
              style: 10.regular.copyWith(color: AppColors.grey99),
            )
          : null,
      autoCloseDuration: const Duration(seconds: 4),
    );
  }

  Color _colorByType() => switch (type) {
    ToastificationType.success => AppColors.green27,
    ToastificationType.error => AppColors.redDA,
    ToastificationType.info => AppColors.blue15,
    ToastificationType.warning => AppColors.orangeE6,
    _ => AppColors.greyB5,
  };
}
