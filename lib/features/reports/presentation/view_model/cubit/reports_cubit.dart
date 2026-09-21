import 'package:injectable/injectable.dart';

import '../../../../../core/api/base_response/result.dart';
import '../../../../../core/api/base_state/base_cubit.dart';
import '../../../../../core/api/base_state/base_state.dart';
import '../../../domain/entities/attendance_stats.dart';
import '../../../domain/use_cases/export_attendance_csv_use_case.dart';
import '../../../domain/use_cases/get_program_report_use_case.dart';
import 'reports_state.dart';

@injectable
class ReportsCubit extends BaseCubit<ReportsState> {
  ReportsCubit(
    this._getReport,
    this._exportCsv,
  ) : super(const ReportsState());

  final GetProgramReportUseCase _getReport;
  final ExportAttendanceCsvUseCase _exportCsv;

  Future<void> loadReports({
    String? programId,
    String? programTitle,
  }) async {
    emit(state.copyWith(
      selectedProgramId: () => programId,
      selectedProgramTitle: programTitle ?? 'All Programs',
      loadState: const BaseState<AttendanceStats>(state: StatusState.loading),
    ));

    final statsResult = await _getReport.getStats(programId: programId);
    final sessionsResult =
        await _getReport.getSessionReports(programId: programId);

    final stats = switch (statsResult) {
      Success<AttendanceStats>(data: final data) =>
        data ?? const AttendanceStats(),
      _ => const AttendanceStats(),
    };

    final sessions = switch (sessionsResult) {
      Success<List<SessionReportItem>>(data: final data) =>
        data ?? <SessionReportItem>[],
      _ => <SessionReportItem>[],
    };

    emit(state.copyWith(
      stats: stats,
      sessionReports: sessions,
      loadState: BaseState<AttendanceStats>(
        state: StatusState.success,
        data: stats,
      ),
    ));
  }

  Future<bool> exportCsv() async {
    if (state.isExporting) return false;

    emit(state.copyWith(
      exportState: const BaseState<String>(state: StatusState.loading),
    ));

    final result = await _exportCsv(
      programId: state.selectedProgramId,
      programTitle: state.selectedProgramTitle,
    );

    return switch (result) {
      Success<String>(data: final path) => () {
          emit(state.copyWith(
            exportState: BaseState<String>(
              state: StatusState.success,
              data: path,
            ),
          ));
          return true;
        }(),
      Error<String>(exception: final exc) => () {
          emit(state.copyWith(
            exportState: BaseState<String>(
              state: StatusState.failure,
              exception: exc,
            ),
          ));
          return false;
        }(),
      Cancelled<String>() => () {
          emit(state.copyWith(
            exportState: const BaseState<String>(state: StatusState.initial),
          ));
          return false;
        }(),
    };
  }
}
