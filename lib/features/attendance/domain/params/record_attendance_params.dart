class RecordAttendanceParams {
  const RecordAttendanceParams({
    required this.programId,
    required this.sessionId,
    required this.studentId,
    required this.studentName,
    required this.scannedBy,
    required this.status,
    this.method = 'qr',
    this.scannedAt,
  });

  final String programId;
  final String sessionId;
  final String studentId;
  final String studentName;
  final String scannedBy;
  final String status;
  final String method;
  final DateTime? scannedAt;

  DateTime get actualScannedAt => scannedAt ?? DateTime.now();
}
