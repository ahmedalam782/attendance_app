import 'dart:io';
import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:toastification/toastification.dart';

import '../../../../../core/common/widgets/custom_toast.dart';
import '../../../../../core/languages/locale_keys.g.dart';

/// Presentation utilities for the Programs feature adhering to Al Faris architecture.
abstract final class ProgramViewUtils {
  static void copyInviteCode(BuildContext context, String code) {
    Clipboard.setData(ClipboardData(text: code));
    HapticFeedback.selectionClick();
    CustomToast(
      context: context,
      header: LocaleKeys.programs_code_copied.tr(),
      type: ToastificationType.success,
    ).showToast();
  }

  static Future<void> shareProgramInvite(
    BuildContext context, {
    required String title,
    required String code,
    GlobalKey? qrKey,
  }) async {
    final isArabic = context.locale.languageCode == 'ar';
    final message = isArabic
        ? 'انضم إلى برنامج "$title" في تطبيق الحضور الذكي:\n'
            'رمز الدعوة: $code\n\n'
            'قم بفتح التطبيق ومسح رمز الـ QR أو إدخال رمز الدعوة للانضمام فوراً.'
        : 'Join "$title" on Smart Attendance App:\n'
            'Invite Code: $code\n\n'
            'Scan this QR code or enter the invite code in the app to join instantly.';

    try {
      if (qrKey != null) {
        final boundary =
            qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
        if (boundary != null) {
          final image = await boundary.toImage(pixelRatio: 3.0);
          final byteData =
              await image.toByteData(format: ui.ImageByteFormat.png);
          if (byteData != null) {
            final pngBytes = byteData.buffer.asUint8List();
            final dir = await getTemporaryDirectory();
            final file = File('${dir.path}/program_${code}_qr.png');
            await file.writeAsBytes(pngBytes, flush: true);

            await SharePlus.instance.share(
              ShareParams(
                files: [XFile(file.path)],
                text: message,
              ),
            );
            return;
          }
        }
      }
    } catch (_) {
      // Fallback to text sharing
    }

    await SharePlus.instance.share(ShareParams(text: message));
  }
}
