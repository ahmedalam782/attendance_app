import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/enrolled_student.dart';

class EnrolledStudentModel extends EnrolledStudent {
  const EnrolledStudentModel({
    required super.id,
    required super.name,
    required super.joinedAt,
    super.status,
  });

  factory EnrolledStudentModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final joinedAtRaw = data['joinedAt'];
    DateTime joinedAt;
    if (joinedAtRaw is Timestamp) {
      joinedAt = joinedAtRaw.toDate();
    } else if (joinedAtRaw is String) {
      joinedAt = DateTime.tryParse(joinedAtRaw) ?? DateTime.now();
    } else {
      joinedAt = DateTime.now();
    }

    return EnrolledStudentModel(
      id: doc.id,
      name: (data['name'] as String?) ?? '',
      joinedAt: joinedAt,
      status: (data['status'] as String?) ?? 'active',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'status': status,
    };
  }
}
