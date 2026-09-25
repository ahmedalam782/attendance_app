class UpdateSessionParams {
  const UpdateSessionParams({
    required this.programId,
    required this.sessionId,
    required this.title,
    required this.startAt,
    required this.endAt,
    required this.lateAfterMinutes,
  });

  final String programId;
  final String sessionId;
  final String title;
  final DateTime startAt;
  final DateTime endAt;
  final int lateAfterMinutes;
}
