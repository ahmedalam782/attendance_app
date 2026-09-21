import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toastification/toastification.dart';

import 'core/common/widgets/app_status_bar_overlay.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_typography.dart';
import 'core/utils/constants/app_strings.dart';

/// Root widget — theme + MaterialApp.router with AutoRoute (Al Faris style).
class AttendanceApp extends StatefulWidget {
  const AttendanceApp({super.key, this.router});

  final AppRouter? router;

  @override
  State<AttendanceApp> createState() => _AttendanceAppState();
}

class _AttendanceAppState extends State<AttendanceApp> {
  late final AppRouter _appRouter = widget.router ?? AppRouter();

  @override
  Widget build(BuildContext context) {
    AppTypography.locale = context.locale.languageCode;
    AppTypography.brightness = Brightness.light;

    return ToastificationWrapper(
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: MaterialApp.router(
          title: AppStrings.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          themeMode: ThemeMode.light,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          routerConfig: _appRouter.config(
            navigatorObservers: () => [appStatusBarRouteObserver],
          ),
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.noScaling),
              child: AnnotatedRegion<SystemUiOverlayStyle>(
                value: const SystemUiOverlayStyle(
                  statusBarColor: AppColors.transparent,
                  statusBarIconBrightness: Brightness.dark,
                  statusBarBrightness: Brightness.light,
                ),
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
        ),
      ),
    );
  }
}
