import 'package:equatable/equatable.dart';

class AttendanceStats extends Equatable {
  const AttendanceStats({
    this.totalPrograms = 0,
    this.totalSessions = 0,
    this.totalCheckIns = 0,
    this.presentCount = 0,
    this.lateCount = 0,
  });

  final int totalPrograms;
  final int totalSessions;
  final int totalCheckIns;
  final int presentCount;
  final int lateCount;

  double get onTimeRate =>
      totalCheckIns > 0 ? (presentCount / totalCheckIns) : 0.0;

  double get lateRate =>
      totalCheckIns > 0 ? (lateCount / totalCheckIns) : 0.0;

  int get onTimePercentage => (onTimeRate * 100).round();
  int get latePercentage => (lateRate * 100).round();

  @override
  List<Object?> get props => [
        totalPrograms,
        totalSessions,
        totalCheckIns,
        presentCount,
        lateCount,
      ];
}

class SessionReportItem extends Equatable {
  const SessionReportItem({
    required this.sessionId,
    required this.sessionTitle,
    required this.programId,
    required this.startAt,
    required this.totalScans,
    required this.presentCount,
    required this.lateCount,
  });

  final String sessionId;
  final String sessionTitle;
  final String programId;
  final DateTime startAt;
  final int totalScans;
  final int presentCount;
  final int lateCount;

  @override
  List<Object?> get props => [
        sessionId,
        sessionTitle,
        programId,
        startAt,
        totalScans,
        presentCount,
        lateCount,
      ];
}
