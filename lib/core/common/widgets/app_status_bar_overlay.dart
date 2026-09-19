import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';

final RouteObserver<ModalRoute<void>> appStatusBarRouteObserver =
    RouteObserver<ModalRoute<void>>();

class AppStatusBarOverlay extends StatelessWidget {
  const AppStatusBarOverlay({super.key, this.opacity = 1.0});

  final double opacity;

  static const SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
    statusBarColor: AppColors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemStatusBarContrastEnforced: false,
  );

  static int _suppressCount = 0;
  static bool _notifyScheduled = false;
  static final ValueNotifier<bool> isSuppressed = ValueNotifier(false);

  static void suppress() {
    _suppressCount++;
    _scheduleNotify();
  }

  static void unsuppress() {
    if (_suppressCount <= 0) return;
    _suppressCount--;
    _scheduleNotify();
  }

  static void _scheduleNotify() {
    if (_notifyScheduled) return;
    _notifyScheduled = true;

    final binding = WidgetsBinding.instance;
    void apply() {
      _notifyScheduled = false;
      final next = _suppressCount > 0;
      if (isSuppressed.value != next) {
        isSuppressed.value = next;
      }
    }

    switch (binding.schedulerPhase) {
      case SchedulerPhase.idle:
      case SchedulerPhase.postFrameCallbacks:
        apply();
      case SchedulerPhase.transientCallbacks:
      case SchedulerPhase.midFrameMicrotasks:
      case SchedulerPhase.persistentCallbacks:
        binding.addPostFrameCallback((_) => apply());
    }
  }

  static Widget tint({double opacity = 1.0}) {
    return Builder(
      builder: (context) {
        final height = MediaQuery.viewPaddingOf(context).top;
        if (height <= 0) return const SizedBox.shrink();
        return IgnorePointer(
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: ColoredBox(
              color: AppColors.primerColor.withValues(alpha: opacity),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.viewPaddingOf(context).top;
    if (height <= 0) return const SizedBox.shrink();

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: height,
      child: IgnorePointer(
        child: ColoredBox(
          color: AppColors.primerColor.withValues(alpha: opacity),
        ),
      ),
    );
  }
}
