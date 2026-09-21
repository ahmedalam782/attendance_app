class CreateSessionParams {
  const CreateSessionParams({
    required this.programId,
    required this.title,
    required this.startAt,
    required this.endAt,
    this.lateAfterMinutes = 15,
  });

  final String programId;
  final String title;
  final DateTime startAt;
  final DateTime endAt;
  final int lateAfterMinutes;
}
