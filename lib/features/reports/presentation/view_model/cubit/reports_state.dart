import '../../../../../core/api/base_state/base_state.dart';
import '../../../domain/entities/attendance_stats.dart';

class ReportsState {
  const ReportsState({
    this.selectedProgramId,
    this.selectedProgramTitle = 'All Programs',
    this.stats = const AttendanceStats(),
    this.sessionReports = const [],
    this.loadState = const BaseState<AttendanceStats>(state: StatusState.initial),
    this.exportState = const BaseState<String>(state: StatusState.initial),
  });

  final String? selectedProgramId;
  final String selectedProgramTitle;
  final AttendanceStats stats;
  final List<SessionReportItem> sessionReports;
  final BaseState<AttendanceStats> loadState;
  final BaseState<String> exportState;

  bool get isLoading => loadState.state == StatusState.loading;
  bool get isExporting => exportState.state == StatusState.loading;

  ReportsState copyWith({
    String? Function()? selectedProgramId,
    String? selectedProgramTitle,
    AttendanceStats? stats,
    List<SessionReportItem>? sessionReports,
    BaseState<AttendanceStats>? loadState,
    BaseState<String>? exportState,
  }) =>
      ReportsState(
        selectedProgramId: selectedProgramId != null
            ? selectedProgramId()
            : this.selectedProgramId,
        selectedProgramTitle:
            selectedProgramTitle ?? this.selectedProgramTitle,
        stats: stats ?? this.stats,
        sessionReports: sessionReports ?? this.sessionReports,
        loadState: loadState ?? this.loadState,
        exportState: exportState ?? this.exportState,
      );
}
