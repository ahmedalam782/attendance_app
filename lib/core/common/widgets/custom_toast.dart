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
  });

  final BuildContext context;
  final String? header;
  final String? description;
  final Color? primaryColor;
  ToastificationType? type;
  final bool isWeb;

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
      showProgressBar: true,
      showIcon: false,
      context: context,
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: primaryColor ?? _colorByType(),
        width: 0.5,
      ),
      title: Text(
        header ?? '',
        style: 14.semiBold.copyWith(color: AppColors.black04),
      ),
      description: description != null
          ? Text(
              description!,
              style: 14.regular.copyWith(color: AppColors.grey99),
            )
          : null,
      autoCloseDuration: const Duration(seconds: 5),
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
