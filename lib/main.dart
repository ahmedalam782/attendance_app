import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'core/languages/codegen_loader.g.dart';
import 'core/languages/lang.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [arabicLocale, englishLocale],
      fallbackLocale: arabicLocale,
      startLocale: arabicLocale,
      path: assetsLocalization,
      assetLoader: const CodegenLoader(),
      useFallbackTranslations: true,
      child: const AttendanceApp(),
    ),
  );
}
