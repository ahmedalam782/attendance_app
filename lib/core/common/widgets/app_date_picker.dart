import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

String _toEasternArabicDigits(String input) {
  const western = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const eastern = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  var result = input;
  for (int i = 0; i < 10; i++) {
    result = result.replaceAll(western[i], eastern[i]);
  }
  return result;
}

/// Calendar delegate for Arabic date formatting matching the exact visual style:
/// Month title: "٢٠٢٦/٠٩"
/// Range date: "٢٠٢٦/٠٩/٢٣"
class ArabicDateRangeCalendarDelegate extends GregorianCalendarDelegate {
  const ArabicDateRangeCalendarDelegate();

  @override
  String formatMonthYear(DateTime date, MaterialLocalizations localizations) {
    final year = _toEasternArabicDigits(date.year.toString());
    final month = _toEasternArabicDigits(date.month.toString().padLeft(2, '0'));
    return '$year/$month';
  }

  @override
  String formatShortMonthDay(DateTime date, MaterialLocalizations localizations) {
    final year = _toEasternArabicDigits(date.year.toString());
    final month = _toEasternArabicDigits(date.month.toString().padLeft(2, '0'));
    final day = _toEasternArabicDigits(date.day.toString().padLeft(2, '0'));
    return '$year/$month/$day';
  }

  @override
  String formatShortDate(DateTime date, MaterialLocalizations localizations) {
    final year = _toEasternArabicDigits(date.year.toString());
    final month = _toEasternArabicDigits(date.month.toString().padLeft(2, '0'));
    final day = _toEasternArabicDigits(date.day.toString().padLeft(2, '0'));
    return '$year/$month/$day';
  }

  @override
  String formatMediumDate(DateTime date, MaterialLocalizations localizations) {
    final year = _toEasternArabicDigits(date.year.toString());
    final month = _toEasternArabicDigits(date.month.toString().padLeft(2, '0'));
    final day = _toEasternArabicDigits(date.day.toString().padLeft(2, '0'));
    return '$year/$month/$day';
  }

  @override
  String formatFullDate(DateTime date, MaterialLocalizations localizations) {
    final year = _toEasternArabicDigits(date.year.toString());
    final month = _toEasternArabicDigits(date.month.toString().padLeft(2, '0'));
    final day = _toEasternArabicDigits(date.day.toString().padLeft(2, '0'));
    return '$year/$month/$day';
  }

  @override
  String formatCompactDate(DateTime date, MaterialLocalizations localizations) {
    final year = _toEasternArabicDigits(date.year.toString());
    final month = _toEasternArabicDigits(date.month.toString().padLeft(2, '0'));
    final day = _toEasternArabicDigits(date.day.toString().padLeft(2, '0'));
    return '$year/$month/$day';
  }
}

/// Calendar delegate for English date range picker formatting with YYYY/MM/DD.
class EnglishDateRangeCalendarDelegate extends GregorianCalendarDelegate {
  const EnglishDateRangeCalendarDelegate();

  @override
  String formatMonthYear(DateTime date, MaterialLocalizations localizations) {
    final month = date.month.toString().padLeft(2, '0');
    return '${date.year}/$month';
  }

  @override
  String formatShortMonthDay(DateTime date, MaterialLocalizations localizations) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}/$month/$day';
  }

  @override
  String formatShortDate(DateTime date, MaterialLocalizations localizations) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}/$month/$day';
  }
}

/// Displays a custom date range picker modal styled identically to the design:
/// - Deep purple header with 'حفظ' (Save) on top-left and 'X' close icon on top-right.
/// - Centered title 'اختيار النطاق' and date range formatted 'YYYY/MM/DD – YYYY/MM/DD'.
/// - White container with rounded corners (r: 24) and soft shadow.
/// - Weekday names row starting with Saturday (س) in Arabic.
/// - Selected dates highlighted with filled purple circle.
Future<DateTimeRange?> showAppDateRangePicker({
  required BuildContext context,
  DateTimeRange? initialDateRange,
  DateTime? firstDate,
  DateTime? lastDate,
  DateTime? currentDate,
  String? helpText,
  String? saveText,
}) async {
  final isArabic = Localizations.localeOf(context).languageCode == 'ar';
  final now = DateTime.now();

  final effectiveFirstDate = firstDate ?? now.subtract(const Duration(days: 365));
  final effectiveLastDate = lastDate ?? now.add(const Duration(days: 365 * 3));

  return showDateRangePicker(
    context: context,
    initialDateRange: initialDateRange,
    firstDate: effectiveFirstDate,
    lastDate: effectiveLastDate,
    currentDate: currentDate ?? now,
    initialEntryMode: DatePickerEntryMode.calendarOnly,
    helpText: helpText ?? (isArabic ? 'اختيار النطاق' : 'Select range'),
    saveText: saveText ?? (isArabic ? 'حفظ' : 'Save'),
    calendarDelegate: isArabic
        ? const ArabicDateRangeCalendarDelegate()
        : const EnglishDateRangeCalendarDelegate(),
    builder: (BuildContext dialogContext, Widget? child) {
      if (child == null) return const SizedBox.shrink();

      final mediaQuery = MediaQuery.of(dialogContext);
      final screenWidth = mediaQuery.size.width;
      final screenHeight = mediaQuery.size.height;

      final targetWidth = math.min(390.0, screenWidth - 32.0);
      final targetHeight = math.min(560.0, screenHeight - 64.0);

      final theme = Theme.of(dialogContext);
      final pickerTheme = DatePickerThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        rangePickerBackgroundColor: Colors.white,
        rangePickerSurfaceTintColor: Colors.transparent,
        rangePickerHeaderBackgroundColor: AppColors.primary,
        rangePickerHeaderForegroundColor: Colors.white,
        rangePickerHeaderHeadlineStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          height: 1.3,
        ),
        rangePickerHeaderHelpStyle: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.bold,
          height: 1.3,
        ),
        rangePickerShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return null;
        }),
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          if (states.contains(WidgetState.disabled)) {
            return AppColors.slate300;
          }
          return AppColors.textPrimary;
        }),
        todayForegroundColor: WidgetStateProperty.all(AppColors.primary),
        todayBorder: const BorderSide(color: AppColors.primary, width: 1.5),
        rangeSelectionBackgroundColor: AppColors.primaryLight,
        rangeSelectionOverlayColor: WidgetStateProperty.all(
          AppColors.primaryLight.withValues(alpha: 0.5),
        ),
      );

      return Center(
        child: Container(
          width: targetWidth,
          height: targetHeight,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: MediaQuery(
            data: mediaQuery.copyWith(
              size: Size(targetWidth, targetHeight),
            ),
            child: Theme(
              data: theme.copyWith(
                colorScheme: theme.colorScheme.copyWith(
                  primary: AppColors.primary,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: AppColors.textPrimary,
                ),
                datePickerTheme: pickerTheme,
              ),
              child: child,
            ),
          ),
        ),
      );
    },
  );
}

/// Displays a single date picker styled with matching purple theme and rounded dialog.
Future<DateTime?> showAppDatePicker({
  required BuildContext context,
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
  DateTime? currentDate,
  String? helpText,
  String? confirmText,
  String? cancelText,
}) async {
  final now = DateTime.now();
  final isArabic = Localizations.localeOf(context).languageCode == 'ar';

  return showDatePicker(
    context: context,
    initialDate: initialDate ?? now,
    firstDate: firstDate ?? now.subtract(const Duration(days: 365)),
    lastDate: lastDate ?? now.add(const Duration(days: 365 * 3)),
    currentDate: currentDate ?? now,
    helpText: helpText ?? (isArabic ? 'تحديد التاريخ' : 'Select date'),
    confirmText: confirmText ?? (isArabic ? 'حفظ' : 'Save'),
    cancelText: cancelText ?? (isArabic ? 'إلغاء' : 'Cancel'),
    builder: (BuildContext dialogContext, Widget? child) {
      if (child == null) return const SizedBox.shrink();
      final theme = Theme.of(dialogContext);

      return Theme(
        data: theme.copyWith(
          colorScheme: theme.colorScheme.copyWith(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: AppColors.textPrimary,
          ),
          dialogTheme: DialogThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
        child: child,
      );
    },
  );
}
