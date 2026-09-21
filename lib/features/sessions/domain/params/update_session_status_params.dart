class UpdateSessionStatusParams {
  const UpdateSessionStatusParams({
    required this.programId,
    required this.sessionId,
    required this.status, // 'scheduled' | 'open' | 'closed'
  });

  final String programId;
  final String sessionId;
  final String status;
}
