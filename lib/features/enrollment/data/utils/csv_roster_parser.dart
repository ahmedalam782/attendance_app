import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart';

import '../../domain/entities/csv_student_entry.dart';

class CsvRosterParser {
  const CsvRosterParser();

  List<CsvStudentEntry> parse(String csvContent) {
    if (csvContent.trim().isEmpty) return const [];

    // Normalize line endings
    final normalized = csvContent.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final rows = Csv().decode(normalized);
    if (rows.isEmpty) return const [];

    // Identify header row if present
    int nameCol = -1;
    int idCol = -1;
    int startRow = 0;

    final firstRow = rows.first;
    for (var i = 0; i < firstRow.length; i++) {
      final val = firstRow[i].toString().trim().toLowerCase();
      if (val.contains('name') || val == 'student') {
        nameCol = i;
      } else if (val.contains('id') || val == 'code' || val == 'email') {
        idCol = i;
      }
    }

    if (nameCol != -1 && idCol != -1) {
      startRow = 1; // Skip header
    } else {
      // Fallback: column 0 = Name, column 1 = ID
      nameCol = 0;
      idCol = 1;
      startRow = 0;
    }

    final entries = <CsvStudentEntry>[];

    for (var i = startRow; i < rows.length; i++) {
      final row = rows[i];
      if (row.isEmpty || row.every((c) => c.toString().trim().isEmpty)) {
        continue;
      }

      final name = nameCol < row.length ? row[nameCol].toString().trim() : '';
      final id = idCol < row.length ? row[idCol].toString().trim() : '';

      if (name.isEmpty) {
        entries.add(
          CsvStudentEntry(
            id: id,
            name: name,
            isValid: false,
            error: 'missing_name',
          ),
        );
      } else if (id.isEmpty) {
        entries.add(
          CsvStudentEntry(
            id: id,
            name: name,
            isValid: false,
            error: 'missing_id',
          ),
        );
      } else {
        entries.add(
          CsvStudentEntry(
            id: id,
            name: name,
            isValid: true,
          ),
        );
      }
    }

    return entries;
  }

  List<CsvStudentEntry> parseBytes(Uint8List bytes) {
    try {
      final content = utf8.decode(bytes);
      return parse(content);
    } catch (_) {
      // Fallback latin1
      final content = latin1.decode(bytes);
      return parse(content);
    }
  }
}
