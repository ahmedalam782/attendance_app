import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../domain/params/create_program_params.dart';
import '../../domain/params/join_program_params.dart';
import '../models/program_model.dart';
import 'programs_remote_data_source.dart';

@Injectable(as: ProgramsRemoteDataSource)
class FirestoreProgramsRemoteDataSource implements ProgramsRemoteDataSource {
  FirestoreProgramsRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _programs =>
      _firestore.collection('programs');

  String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // no O/0/I/1 for clarity
    final rnd = Random();
    return List.generate(6, (_) => chars[rnd.nextInt(chars.length)]).join();
  }

  @override
  Stream<List<ProgramModel>> watchAdminPrograms(String adminUid) {
    return _programs
        .where('adminIds', arrayContains: adminUid)
        .snapshots(includeMetadataChanges: true)
        .map((snap) => snap.docs.map(ProgramModel.fromFirestore).toList());
  }

  @override
  Stream<List<ProgramModel>> watchStudentPrograms(String studentUid) {
    return _programs
        .where('studentIds', arrayContains: studentUid)
        .snapshots(includeMetadataChanges: true)
        .map((snap) => snap.docs.map(ProgramModel.fromFirestore).toList());
  }

  @override
  Future<ProgramModel> createProgram(CreateProgramParams params) async {
    final docRef = _programs.doc();
    final inviteCode = params.inviteCode.isNotEmpty
        ? params.inviteCode.toUpperCase()
        : _generateInviteCode();

    final adminIds = {...params.adminIds, params.ownerId}.toList();

    final model = ProgramModel(
      id: docRef.id,
      title: params.title,
      type: params.type,
      ownerId: params.ownerId,
      inviteCode: inviteCode,
      description: params.description,
      location: params.location,
      startDate: params.startDate,
      endDate: params.endDate,
      adminIds: adminIds,
      studentCount: 0,
      sessionCount: 0,
      createdAt: DateTime.now(),
    );

    final data = model.toFirestore();
    data['studentIds'] = <String>[];

    await docRef.set(data);
    return model;
  }

  @override
  Future<ProgramModel> joinProgramByCode(JoinProgramParams params) async {
    final normalizedCode = params.inviteCode.trim().toUpperCase();
    final query = await _programs
        .where('inviteCode', isEqualTo: normalizedCode)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'not-found',
        message: 'No program matches invite code $normalizedCode',
      );
    }

    final programDoc = query.docs.first;
    final programId = programDoc.id;

    final studentDocRef = _programs
        .doc(programId)
        .collection('students')
        .doc(params.studentId);

    final studentSnapshot = await studentDocRef.get();
    if (studentSnapshot.exists) {
      return ProgramModel.fromFirestore(programDoc);
    }

    // Add student subdocument and update program student list
    final batch = _firestore.batch();
    batch.set(studentDocRef, {
      'name': params.studentName.trim(),
      'joinedAt': FieldValue.serverTimestamp(),
      'status': 'active',
    });
    batch.update(programDoc.reference, {
      'studentIds': FieldValue.arrayUnion([params.studentId]),
      'studentCount': FieldValue.increment(1),
    });

    await batch.commit();
    final updatedDoc = await programDoc.reference.get();
    return ProgramModel.fromFirestore(updatedDoc);
  }

  @override
  Future<ProgramModel> getProgramById(String programId) async {
    final doc = await _programs.doc(programId).get();
    if (!doc.exists) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'not-found',
        message: 'Program $programId not found',
      );
    }
    return ProgramModel.fromFirestore(doc);
  }
}
