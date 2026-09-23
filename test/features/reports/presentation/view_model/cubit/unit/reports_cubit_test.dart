import 'package:attendance_app/core/api/base_response/result.dart';
import 'package:attendance_app/core/api/base_state/base_state.dart';
import 'package:attendance_app/features/reports/domain/entities/attendance_stats.dart';
import 'package:attendance_app/features/reports/domain/repositories/reports_repository.dart';
import 'package:attendance_app/features/reports/domain/use_cases/export_attendance_csv_use_case.dart';
import 'package:attendance_app/features/reports/domain/use_cases/get_program_report_use_case.dart';
import 'package:attendance_app/features/reports/presentation/view_model/cubit/reports_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeReportsRepository implements ReportsRepository {
  AttendanceStats mockStats = const AttendanceStats(
    totalPrograms: 2,
    totalSessions: 5,
    totalCheckIns: 100,
    presentCount: 85,
    lateCount: 15,
  );

  List<SessionReportItem> mockSessions = [
    SessionReportItem(
      sessionId: 's1',
      sessionTitle: 'Lecture 1',
      programId: 'p1',
      startAt: DateTime(2026, 9, 20, 10, 0),
      totalScans: 50,
      presentCount: 45,
      lateCount: 5,
    ),
  ];

  @override
  Future<Result<AttendanceStats>> getStats({String? programId}) async {
    return Success(data: mockStats);
  }

  @override
  Future<Result<List<SessionReportItem>>> getSessionReports({
    String? programId,
  }) async {
    return Success(data: mockSessions);
  }

  @override
  Future<Result<String>> exportCsv({
    String? programId,
    required String programTitle,
  }) async {
    return const Success(data: '/tmp/attendance_export.csv');
  }
}

void main() {
  late FakeReportsRepository repository;
  late ReportsCubit cubit;

  setUp(() {
    repository = FakeReportsRepository();
    cubit = ReportsCubit(
      GetProgramReportUseCase(repository),
      ExportAttendanceCsvUseCase(repository),
    );
  });

  tearDown(() async {
    await cubit.close();
  });

  group('AttendanceStats entity calculations', () {
    test('calculates correct percentages for present and late', () {
      const stats = AttendanceStats(
        totalCheckIns: 50,
        presentCount: 40,
        lateCount: 10,
      );

      expect(stats.onTimeRate, 0.8);
      expect(stats.lateRate, 0.2);
      expect(stats.onTimePercentage, 80);
      expect(stats.latePercentage, 20);
    });

    test('handles zero check-ins safely without division by zero', () {
      const stats = AttendanceStats();

      expect(stats.onTimeRate, 0.0);
      expect(stats.lateRate, 0.0);
      expect(stats.onTimePercentage, 0);
      expect(stats.latePercentage, 0);
    });
  });

  group('ReportsCubit', () {
    test('loadReports updates stats and session reports', () async {
      await cubit.loadReports(programId: 'p1', programTitle: 'Course 101');

      expect(cubit.state.selectedProgramId, 'p1');
      expect(cubit.state.selectedProgramTitle, 'Course 101');
      expect(cubit.state.stats.totalCheckIns, 100);
      expect(cubit.state.stats.onTimePercentage, 85);
      expect(cubit.state.sessionReports.length, 1);
      expect(cubit.state.loadState.state, StatusState.success);
    });

    test('exportCsv triggers export and sets success file path', () async {
      final success = await cubit.exportCsv();

      expect(success, isTrue);
      expect(cubit.state.exportState.state, StatusState.success);
      expect(cubit.state.exportState.data, '/tmp/attendance_export.csv');
    });
  });
}
