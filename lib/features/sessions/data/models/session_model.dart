import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/session.dart';

class SessionModel {
  const SessionModel({
    required this.id,
    required this.programId,
    required this.title,
    required this.startAt,
    required this.endAt,
    this.status = 'scheduled',
    this.lateAfterMinutes = 15,
    this.attendanceCount = 0,
    this.createdAt,
  });

  final String id;
  final String programId;
  final String title;
  final DateTime startAt;
  final DateTime endAt;
  final String status;
  final int lateAfterMinutes;
  final int attendanceCount;
  final DateTime? createdAt;

  factory SessionModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    String programId,
  ) {
    final data = snapshot.data() ?? {};
    return SessionModel(
      id: snapshot.id,
      programId: programId,
      title: data['title'] as String? ?? '',
      startAt: (data['startAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endAt: (data['endAt'] as Timestamp?)?.toDate() ??
          DateTime.now().add(const Duration(hours: 2)),
      status: data['status'] as String? ?? 'scheduled',
      lateAfterMinutes: data['lateAfterMinutes'] as int? ?? 15,
      attendanceCount: data['attendanceCount'] as int? ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title.trim(),
      'startAt': Timestamp.fromDate(startAt),
      'endAt': Timestamp.fromDate(endAt),
      'status': status,
      'lateAfterMinutes': lateAfterMinutes,
      'attendanceCount': attendanceCount,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Session toEntity() => Session(
        id: id,
        programId: programId,
        title: title,
        startAt: startAt,
        endAt: endAt,
        status: status,
        lateAfterMinutes: lateAfterMinutes,
        attendanceCount: attendanceCount,
        createdAt: createdAt,
      );
}
