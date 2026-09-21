import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/entities/attendance_stats.dart';
import 'reports_remote_data_source.dart';

@Injectable(as: ReportsRemoteDataSource)
class FirestoreReportsRemoteDataSource implements ReportsRemoteDataSource {
  FirestoreReportsRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  /// Loads attendance via nested program paths (avoids collectionGroup rule issues).
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _attendanceDocs({
    String? programId,
  }) async {
    final docs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];

    Future<void> loadProgram(String id) async {
      final sessionsSnap = await _firestore
          .collection('programs')
          .doc(id)
          .collection('sessions')
          .get();
      for (final session in sessionsSnap.docs) {
        final attSnap = await session.reference.collection('attendance').get();
        docs.addAll(attSnap.docs);
      }
    }

    if (programId != null && programId.isNotEmpty) {
      await loadProgram(programId);
      return docs;
    }

    final programsSnap = await _firestore.collection('programs').get();
    for (final program in programsSnap.docs) {
      await loadProgram(program.id);
    }
    return docs;
  }

  @override
  Future<AttendanceStats> getStats({String? programId}) async {
    final docs = await _attendanceDocs(programId: programId);

    var present = 0;
    var late = 0;
    for (final doc in docs) {
      final status = doc.data()['status'] as String? ?? 'present';
      if (status == 'present') {
        present++;
      } else if (status == 'late') {
        late++;
      }
    }

    var totalSessions = 0;
    var totalPrograms = 0;
    if (programId != null && programId.isNotEmpty) {
      totalPrograms = 1;
      final sessionsSnap = await _firestore
          .collection('programs')
          .doc(programId)
          .collection('sessions')
          .get();
      totalSessions = sessionsSnap.docs.length;
    } else {
      final programsSnap = await _firestore.collection('programs').get();
      totalPrograms = programsSnap.docs.length;
      for (final p in programsSnap.docs) {
        totalSessions += (p.data()['sessionCount'] as int? ?? 0);
      }
    }

    return AttendanceStats(
      totalPrograms: totalPrograms,
      totalSessions: totalSessions,
      totalCheckIns: docs.length,
      presentCount: present,
      lateCount: late,
    );
  }

  @override
  Future<List<SessionReportItem>> getSessionReports({String? programId}) async {
    final items = <SessionReportItem>[];

    if (programId == null || programId.isEmpty) return items;

    final sessionsSnap = await _firestore
        .collection('programs')
        .doc(programId)
        .collection('sessions')
        .orderBy('startAt', descending: true)
        .get();

    for (final sDoc in sessionsSnap.docs) {
      final sData = sDoc.data();
      final attSnap = await sDoc.reference.collection('attendance').get();
      var present = 0;
      var late = 0;
      for (final aDoc in attSnap.docs) {
        final st = aDoc.data()['status'] as String? ?? 'present';
        if (st == 'present') present++;
        if (st == 'late') late++;
      }

      items.add(
        SessionReportItem(
          sessionId: sDoc.id,
          sessionTitle: sData['title'] as String? ?? 'Session',
          programId: programId,
          startAt: (sData['startAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          totalScans: attSnap.docs.length,
          presentCount: present,
          lateCount: late,
        ),
      );
    }

    return items;
  }

  @override
  Future<String> exportCsv({
    String? programId,
    required String programTitle,
  }) async {
    final docs = await _attendanceDocs(programId: programId);

    final rows = <List<dynamic>>[
      [
        'Student ID',
        'Student Name',
        'Program ID',
        'Session ID',
        'Status',
        'Method',
        'Scanned At',
        'Scanned By',
      ],
    ];

    for (final doc in docs) {
      final data = doc.data();
      final scannedAt = (data['scannedAt'] as Timestamp?)?.toDate();
      rows.add([
        data['studentId'] ?? '',
        data['studentName'] ?? '',
        data['programId'] ?? '',
        data['sessionId'] ?? '',
        data['status'] ?? '',
        data['method'] ?? '',
        scannedAt != null ? scannedAt.toIso8601String() : '',
        data['scannedBy'] ?? '',
      ]);
    }

    final csvText = Csv().encode(rows);
    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/attendance_export_${DateTime.now().millisecondsSinceEpoch}.csv',
    );
    await file.writeAsString(csvText);
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], text: programTitle),
    );
    return file.path;
  }
}
