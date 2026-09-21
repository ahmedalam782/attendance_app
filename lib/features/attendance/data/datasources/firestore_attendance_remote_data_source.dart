import 'package:cloud_firestore/cloud_firestore.dart';
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
    final existingDoc = await docRef.get();

    if (existingDoc.exists) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'already-exists',
        message: 'Student already checked in for this session',
      );
    }

    final scannedAt = params.actualScannedAt;

    final model = AttendanceModel(
      id: deterministicId,
      programId: params.programId,
      sessionId: params.sessionId,
      studentId: params.studentId,
      studentName: params.studentName,
      scannedAt: scannedAt,
      scannedBy: params.scannedBy,
      method: params.method,
      status: params.status,
      isPendingSync: true,
    );

    final sessionRef = _firestore.doc(
      FirestorePaths.programSession(params.programId, params.sessionId),
    );

    final batch = _firestore.batch();
    batch.set(docRef, model.toFirestore());
    batch.update(sessionRef, {
      'attendanceCount': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
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
}
