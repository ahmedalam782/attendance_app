import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../domain/params/create_session_params.dart';
import '../../domain/params/update_session_status_params.dart';
import '../models/session_model.dart';
import 'sessions_remote_data_source.dart';

@Injectable(as: SessionsRemoteDataSource)
class FirestoreSessionsRemoteDataSource implements SessionsRemoteDataSource {
  FirestoreSessionsRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _sessionsRef(String programId) =>
      _firestore.collection('programs').doc(programId).collection('sessions');

  @override
  Stream<List<SessionModel>> watchSessions(String programId) {
    return _sessionsRef(programId)
        .orderBy('startAt', descending: true)
        .snapshots(includeMetadataChanges: true)
        .map(
          (snap) => snap.docs
              .map((doc) => SessionModel.fromFirestore(doc, programId))
              .toList(),
        );
  }

  @override
  Future<SessionModel> createSession(CreateSessionParams params) async {
    final programDoc = _firestore.collection('programs').doc(params.programId);
    final docRef = programDoc.collection('sessions').doc();

    final model = SessionModel(
      id: docRef.id,
      programId: params.programId,
      title: params.title,
      startAt: params.startAt,
      endAt: params.endAt,
      status: 'scheduled',
      lateAfterMinutes: params.lateAfterMinutes,
      attendanceCount: 0,
      createdAt: DateTime.now(),
    );

    final batch = _firestore.batch();
    batch.set(docRef, model.toFirestore());
    batch.update(programDoc, {
      'sessionCount': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
    return model;
  }

  @override
  Future<void> updateSessionStatus(UpdateSessionStatusParams params) async {
    final docRef = _sessionsRef(params.programId).doc(params.sessionId);
    await docRef.update({
      'status': params.status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
