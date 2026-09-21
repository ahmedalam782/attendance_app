import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/attendance_record.dart';

class AttendanceModel {
  const AttendanceModel({
    required this.id,
    required this.programId,
    required this.sessionId,
    required this.studentId,
    required this.studentName,
    required this.scannedAt,
    required this.scannedBy,
    required this.method,
    required this.status,
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

  factory AttendanceModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot, {
    String? programId,
    String? sessionId,
  }) {
    final data = snapshot.data() ?? {};
    return AttendanceModel(
      id: snapshot.id,
      programId: programId ?? (data['programId'] as String? ?? ''),
      sessionId: sessionId ?? (data['sessionId'] as String? ?? ''),
      studentId: data['studentId'] as String? ?? '',
      studentName: data['studentName'] as String? ?? '',
      scannedAt: (data['scannedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      scannedBy: data['scannedBy'] as String? ?? '',
      method: data['method'] as String? ?? 'qr',
      status: data['status'] as String? ?? 'present',
      isPendingSync: snapshot.metadata.hasPendingWrites,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'programId': programId,
      'sessionId': sessionId,
      'scannedAt': Timestamp.fromDate(scannedAt),
      'scannedBy': scannedBy,
      'method': method,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  AttendanceRecord toEntity() => AttendanceRecord(
        id: id,
        programId: programId,
        sessionId: sessionId,
        studentId: studentId,
        studentName: studentName,
        scannedAt: scannedAt,
        scannedBy: scannedBy,
        method: method,
        status: status,
        isPendingSync: isPendingSync,
      );
}
