import 'package:attendance_app/features/enrollment/data/utils/csv_roster_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const parser = CsvRosterParser();

  group('CsvRosterParser', () {
    test('parses standard CSV with header correctly', () {
      const csv = '''name,id
Ahmed Hassan,STU-101
Sara Mahmoud,STU-102
Omar Khaled,STU-103''';

      final entries = parser.parse(csv);

      expect(entries.length, 3);
      expect(entries[0].name, 'Ahmed Hassan');
      expect(entries[0].id, 'STU-101');
      expect(entries[0].isValid, isTrue);

      expect(entries[1].name, 'Sara Mahmoud');
      expect(entries[1].id, 'STU-102');
      expect(entries[1].isValid, isTrue);

      expect(entries[2].name, 'Omar Khaled');
      expect(entries[2].id, 'STU-103');
      expect(entries[2].isValid, isTrue);
    });

    test('parses CSV with alternative header casing and Windows line endings', () {
      const csv = "Student_Name,Email\r\nJohn Doe,john@test.com\r\nJane Smith,jane@test.com\r\n";

      final entries = parser.parse(csv);

      expect(entries.length, 2);
      expect(entries[0].name, 'John Doe');
      expect(entries[0].id, 'john@test.com');
      expect(entries[0].isValid, isTrue);
    });

    test('flags entries with missing name or missing id as invalid', () {
      const csv = '''name,id
,STU-201
Khaled Aly,
Valid Student,STU-203''';

      final entries = parser.parse(csv);

      expect(entries.length, 3);
      expect(entries[0].isValid, isFalse);
      expect(entries[0].error, 'missing_name');

      expect(entries[1].isValid, isFalse);
      expect(entries[1].error, 'missing_id');

      expect(entries[2].isValid, isTrue);
    });

    test('handles empty and whitespace-only CSV safely', () {
      expect(parser.parse(''), isEmpty);
      expect(parser.parse('   \n  \n  '), isEmpty);
    });
  });
}
