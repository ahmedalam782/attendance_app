import 'package:equatable/equatable.dart';

class AttendanceRecord extends Equatable {
  const AttendanceRecord({
    required this.id,
    required this.programId,
    required this.sessionId,
    required this.studentId,
    required this.studentName,
    required this.scannedAt,
    required this.scannedBy,
    required this.method, // 'qr' | 'manual' | 'self'
    required this.status, // 'present' | 'late' | 'absent' | 'excused'
    this.isPendingSync = false,
  });

  final String id;
  final String programId;
  final String sessionId;
  final String studentId;
  final String studentName;
  final DateTime scannedAt;
  final String scannedBy;
  final String method;
  final String status;
  final bool isPendingSync;

  bool get isPresent => status == 'present';
  bool get isLate => status == 'late';
  bool get isManual => method == 'manual';

  @override
  List<Object?> get props => [
        id,
        programId,
        sessionId,
        studentId,
        studentName,
        scannedAt,
        scannedBy,
        method,
        status,
        isPendingSync,
      ];
}
