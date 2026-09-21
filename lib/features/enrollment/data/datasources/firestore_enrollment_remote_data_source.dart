import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/csv_student_entry.dart';
import '../models/enrolled_student_model.dart';
import 'enrollment_remote_data_source.dart';

@Injectable(as: EnrollmentRemoteDataSource)
class FirestoreEnrollmentRemoteDataSource implements EnrollmentRemoteDataSource {
  FirestoreEnrollmentRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _programs =>
      _firestore.collection('programs');

  @override
  Stream<List<EnrolledStudentModel>> watchProgramStudents(String programId) {
    return _programs
        .doc(programId)
        .collection('students')
        .orderBy('name')
        .snapshots(includeMetadataChanges: true)
        .map(
          (snap) => snap.docs
              .map(
                (doc) => EnrolledStudentModel.fromFirestore(
                  doc as DocumentSnapshot<Map<String, dynamic>>,
                ),
              )
              .toList(),
        );
  }

  @override
  Future<EnrolledStudentModel> addStudent({
    required String programId,
    required String studentId,
    required String name,
  }) async {
    final programRef = _programs.doc(programId);
    final studentRef = programRef.collection('students').doc(studentId);

    final now = DateTime.now();
    final batch = _firestore.batch();
    batch.set(studentRef, {
      'name': name.trim(),
      'joinedAt': FieldValue.serverTimestamp(),
      'status': 'active',
    });
    batch.update(programRef, {
      'studentIds': FieldValue.arrayUnion([studentId]),
      'studentCount': FieldValue.increment(1),
    });

    await batch.commit();

    return EnrolledStudentModel(
      id: studentId,
      name: name.trim(),
      joinedAt: now,
      status: 'active',
    );
  }

  @override
  Future<void> removeStudent({
    required String programId,
    required String studentId,
  }) async {
    final programRef = _programs.doc(programId);
    final studentRef = programRef.collection('students').doc(studentId);

    final batch = _firestore.batch();
    batch.delete(studentRef);
    batch.update(programRef, {
      'studentIds': FieldValue.arrayRemove([studentId]),
      'studentCount': FieldValue.increment(-1),
    });

    await batch.commit();
  }

  @override
  Future<int> batchEnrollStudents({
    required String programId,
    required List<CsvStudentEntry> students,
  }) async {
    final validStudents = students.where((s) => s.isValid).toList();
    if (validStudents.isEmpty) return 0;

    final programRef = _programs.doc(programId);
    final enrolledIds = <String>[];

    const chunkSize = 200;
    for (var i = 0; i < validStudents.length; i += chunkSize) {
      final chunk = validStudents.sublist(
        i,
        (i + chunkSize > validStudents.length)
            ? validStudents.length
            : i + chunkSize,
      );

      final batch = _firestore.batch();
      for (final student in chunk) {
        final docRef = programRef.collection('students').doc(student.id);
        batch.set(docRef, {
          'name': student.name.trim(),
          'joinedAt': FieldValue.serverTimestamp(),
          'status': 'active',
        });
        enrolledIds.add(student.id);
      }
      await batch.commit();
    }

    await programRef.update({
      'studentIds': FieldValue.arrayUnion(enrolledIds),
      'studentCount': FieldValue.increment(enrolledIds.length),
    });

    return enrolledIds.length;
  }
}
