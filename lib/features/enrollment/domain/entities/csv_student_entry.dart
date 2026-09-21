import 'package:equatable/equatable.dart';

import 'enrolled_student.dart';

class CsvStudentEntry extends Equatable {
  const CsvStudentEntry({
    required this.id,
    required this.name,
    this.isValid = true,
    this.error,
  });

  final String id;
  final String name;
  final bool isValid;
  final String? error;

  EnrolledStudent toEnrolledStudent() {
    return EnrolledStudent(
      id: id,
      name: name,
      joinedAt: DateTime.now(),
      status: 'active',
    );
  }

  @override
  List<Object?> get props => [id, name, isValid, error];
}
