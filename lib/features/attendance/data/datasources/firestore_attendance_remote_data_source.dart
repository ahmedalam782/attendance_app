import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/utils/constants/firestore_paths.dart';
import '../../domain/params/record_attendance_params.dart';
import '../models/attendance_model.dart';
import 'attendance_remote_data_source.dart';

@Injectable(as: AttendanceRemoteDataSource)
class FirestoreAttendanceRemoteDataSource implements AttendanceRemoteDataSource {
  FirestoreAttendanceRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<AttendanceModel> recordAttendance(RecordAttendanceParams params) async {
    final deterministicId = FirestorePaths.deterministicAttendanceId(
      params.sessionId,
      params.studentId,
    );

    final docPath = FirestorePaths.attendanceDoc(
      params.programId,
      params.sessionId,
      deterministicId,
    );

    final docRef = _firestore.doc(docPath);

    // 1. Check local cache first (instant SQLite offline read)
    DocumentSnapshot<Map<String, dynamic>>? existingDoc;
    try {
      existingDoc = await docRef
          .get(const GetOptions(source: Source.cache))
          .timeout(const Duration(milliseconds: 500));
    } catch (_) {}

    // 2. If not found in cache, check server with short timeout
    if (existingDoc == null || !existingDoc.exists) {
      try {
        existingDoc = await docRef
            .get()
            .timeout(const Duration(milliseconds: 1500));
      } catch (_) {}
    }

    final scannedAt = params.actualScannedAt;
    final effectiveScannedBy = params.scannedBy.trim().isNotEmpty
        ? params.scannedBy.trim()
        : (FirebaseAuth.instance.currentUser?.uid ?? params.studentId);

    final model = AttendanceModel(
      id: deterministicId,
      programId: params.programId,
      sessionId: params.sessionId,
      studentId: params.studentId,
      studentName: params.studentName,
      scannedAt: scannedAt,
      scannedBy: effectiveScannedBy,
      method: params.method,
      status: params.status,
      isPendingSync: true,
    );

    final sessionRef = _firestore.doc(
      FirestorePaths.programSession(params.programId, params.sessionId),
    );

    if (existingDoc != null && existingDoc.exists) {
      if (params.method == 'manual') {
        final oldData = existingDoc.data() ?? {};
        final oldStatus = oldData['status'] as String? ?? '';
        final wasAttended = oldStatus == 'present' || oldStatus == 'late';
        final isAttended = params.status == 'present' || params.status == 'late';

        await docRef.set({
          ...model.toFirestore(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        if (!wasAttended && isAttended) {
          try {
            await sessionRef.update({
              'attendanceCount': FieldValue.increment(1),
              'updatedAt': FieldValue.serverTimestamp(),
            });
          } catch (_) {}
        } else if (wasAttended && !isAttended) {
          try {
            await sessionRef.update({
              'attendanceCount': FieldValue.increment(-1),
              'updatedAt': FieldValue.serverTimestamp(),
            });
          } catch (_) {}
        }

        return model;
      }

      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'already-exists',
        message: 'Student already checked in for this session',
      );
    }

    await docRef.set(model.toFirestore());

    try {
      await sessionRef.update({
        'attendanceCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}

    return model;
  }

  @override
  Stream<List<AttendanceModel>> watchSessionAttendance(
    String programId,
    String sessionId,
  ) {
    final path = FirestorePaths.sessionAttendance(programId, sessionId);
    return _firestore
        .collection(path)
        .orderBy('scannedAt', descending: true)
        .snapshots(includeMetadataChanges: true)
        .map(
          (snap) => snap.docs
              .map(
                (d) => AttendanceModel.fromFirestore(
                  d,
                  programId: programId,
                  sessionId: sessionId,
                ),
              )
              .toList(),
        );
  }

  @override
  Stream<List<AttendanceModel>> watchStudentAttendanceHistory(
    String studentId,
  ) {
    return _firestore
        .collectionGroup(FirestorePaths.attendance)
        .where('studentId', isEqualTo: studentId)
        .snapshots(includeMetadataChanges: true)
        .map(
          (snap) => snap.docs
              .map(
                (d) => AttendanceModel.fromFirestore(
                  d,
                  programId: d.data()['programId'] as String?,
                  sessionId: d.data()['sessionId'] as String?,
                ),
              )
              .toList()
            ..sort((a, b) => b.scannedAt.compareTo(a.scannedAt)),
        );
  }

  @override
  Future<void> deleteAttendance({
    required String programId,
    required String sessionId,
    required String studentId,
  }) async {
    final deterministicId = FirestorePaths.deterministicAttendanceId(
      sessionId,
      studentId,
    );

    final docPath = FirestorePaths.attendanceDoc(
      programId,
      sessionId,
      deterministicId,
    );

    final docRef = _firestore.doc(docPath);
    final snap = await docRef.get();
    if (!snap.exists) return;

    final data = snap.data() ?? {};
    final status = data['status'] as String? ?? '';
    final wasAttended = status == 'present' || status == 'late';

    await docRef.delete();

    if (wasAttended) {
      try {
        final sessionRef = _firestore.doc(
          FirestorePaths.programSession(programId, sessionId),
        );
        await sessionRef.update({
          'attendanceCount': FieldValue.increment(-1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } catch (_) {}
    }
  }
}
