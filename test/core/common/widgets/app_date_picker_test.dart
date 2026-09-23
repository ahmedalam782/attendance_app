import 'package:attendance_app/core/common/widgets/app_date_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ArabicDateRangeCalendarDelegate', () {
    const delegate = ArabicDateRangeCalendarDelegate();

    testWidgets('formats month/year with Eastern Arabic digits',
        (tester) async {
      final loc =
          await GlobalMaterialLocalizations.delegate.load(const Locale('ar'));
      final date = DateTime(2026, 9, 23);
      final formattedMonth = delegate.formatMonthYear(date, loc);
      expect(formattedMonth, equals('٢٠٢٦/٠٩'));
    });

    testWidgets('formats short date with Eastern Arabic digits',
        (tester) async {
      final loc =
          await GlobalMaterialLocalizations.delegate.load(const Locale('ar'));
      final date = DateTime(2026, 9, 23);
      final formattedDate = delegate.formatShortDate(date, loc);
      expect(formattedDate, equals('٢٠٢٦/٠٩/٢٣'));
    });
  });

  group('EnglishDateRangeCalendarDelegate', () {
    const delegate = EnglishDateRangeCalendarDelegate();

    testWidgets('formats month/year and date with standard digits',
        (tester) async {
      final loc =
          await GlobalMaterialLocalizations.delegate.load(const Locale('en'));
      final date = DateTime(2026, 9, 23);
      expect(delegate.formatMonthYear(date, loc), equals('2026/09'));
      expect(delegate.formatShortDate(date, loc), equals('2026/09/23'));
    });
  });

  group('showAppDateRangePicker Widget Test', () {
    testWidgets('opens Arabic styled date range picker modal', (tester) async {
      DateTimeRange? selectedRange;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar', 'EG'),
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          supportedLocales: const [Locale('ar', 'EG'), Locale('en', 'US')],
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  selectedRange = await showAppDateRangePicker(
                    context: context,
                    initialDateRange: DateTimeRange(
                      start: DateTime(2026, 9, 23),
                      end: DateTime(2026, 9, 23),
                    ),
                    firstDate: DateTime(2026, 1, 1),
                    lastDate: DateTime(2026, 12, 31),
                  );
                },
                child: const Text('Pick Range'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Pick Range'));
      await tester.pumpAndSettle();

      // Verify header texts matching user's design
      expect(find.text('اختيار النطاق'), findsOneWidget);
      expect(find.text('حفظ'), findsOneWidget);
      expect(find.text('٢٠٢٦/٠٩'), findsOneWidget);
      expect(find.text('٢٠٢٦/٠٩/٢٣'), findsNWidgets(2)); // start and end

      // Tap "حفظ" (Save)
      await tester.tap(find.text('حفظ'));
      await tester.pumpAndSettle();

      expect(selectedRange, isNotNull);
      expect(selectedRange!.start, equals(DateTime(2026, 9, 23)));
      expect(selectedRange!.end, equals(DateTime(2026, 9, 23)));
    });
  });

  group('showAppDatePicker Widget Test', () {
    testWidgets('opens single date picker modal', (tester) async {
      DateTime? selectedDate;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar', 'EG'),
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          supportedLocales: const [Locale('ar', 'EG'), Locale('en', 'US')],
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  selectedDate = await showAppDatePicker(
                    context: context,
                    initialDate: DateTime(2026, 9, 23),
                    firstDate: DateTime(2026, 1, 1),
                    lastDate: DateTime(2026, 12, 31),
                  );
                },
                child: const Text('Pick Date'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Pick Date'));
      await tester.pumpAndSettle();

      expect(find.text('حفظ'), findsOneWidget);
      await tester.tap(find.text('حفظ'));
      await tester.pumpAndSettle();

      expect(selectedDate, isNotNull);
      expect(selectedDate!.year, equals(2026));
      expect(selectedDate!.month, equals(9));
      expect(selectedDate!.day, equals(23));
    });
  });
}
