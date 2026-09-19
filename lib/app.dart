import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toastification/toastification.dart';

import 'core/common/widgets/app_status_bar_overlay.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_typography.dart';
import 'core/utils/constants/app_strings.dart';
import 'features/home/presentation/home_page.dart';

/// Root widget — theme + MaterialApp shell only (Al Faris style).
class AttendanceApp extends StatelessWidget {
  const AttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    AppTypography.locale = context.locale.languageCode;
    AppTypography.brightness = Brightness.light;

    return ToastificationWrapper(
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: MaterialApp(
          title: AppStrings.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          themeMode: ThemeMode.light,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          navigatorObservers: [appStatusBarRouteObserver],
          home: const HomePage(),
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
