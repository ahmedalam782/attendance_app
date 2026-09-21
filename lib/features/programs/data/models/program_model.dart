import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/program.dart';

class ProgramModel {
  const ProgramModel({
    required this.id,
    required this.title,
    required this.type,
    required this.ownerId,
    required this.inviteCode,
    this.description = '',
    this.location = '',
    this.startDate,
    this.endDate,
    this.adminIds = const [],
    this.studentCount = 0,
    this.sessionCount = 0,
    this.createdAt,
  });

  final String id;
  final String title;
  final String type;
  final String ownerId;
  final String inviteCode;
  final String description;
  final String location;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String> adminIds;
  final int studentCount;
  final int sessionCount;
  final DateTime? createdAt;

  factory ProgramModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? {};
    return ProgramModel(
      id: snapshot.id,
      title: data['title'] as String? ?? '',
      type: data['type'] as String? ?? 'course',
      ownerId: data['ownerId'] as String? ?? '',
      inviteCode: data['inviteCode'] as String? ?? '',
      description: data['description'] as String? ?? '',
      location: data['location'] as String? ?? '',
      startDate: (data['startDate'] as Timestamp?)?.toDate(),
      endDate: (data['endDate'] as Timestamp?)?.toDate(),
      adminIds: List<String>.from(data['adminIds'] as List? ?? []),
      studentCount: data['studentCount'] as int? ?? 0,
      sessionCount: data['sessionCount'] as int? ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title.trim(),
      'type': type,
      'ownerId': ownerId,
      'inviteCode': inviteCode.trim().toUpperCase(),
      'description': description.trim(),
      'location': location.trim(),
      if (startDate != null) 'startDate': Timestamp.fromDate(startDate!),
      if (endDate != null) 'endDate': Timestamp.fromDate(endDate!),
      'adminIds': adminIds,
      'studentCount': studentCount,
      'sessionCount': sessionCount,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Program toEntity() => Program(
        id: id,
        title: title,
        type: type,
        ownerId: ownerId,
        inviteCode: inviteCode,
        description: description,
        location: location,
        startDate: startDate,
        endDate: endDate,
        adminIds: adminIds,
        studentCount: studentCount,
        sessionCount: sessionCount,
        createdAt: createdAt,
      );
}
