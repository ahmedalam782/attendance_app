/// Centralized Firestore paths and collections as defined in PROJECT.md.
abstract final class FirestorePaths {
  static const String users = 'users';
  static const String programs = 'programs';
  static const String students = 'students';
  static const String sessions = 'sessions';
  static const String attendance = 'attendance';
  static const String instructorInvites = 'instructorInvites';

  // Subcollection and document path builders
  static String user(String uid) => '$users/$uid';
  static String program(String programId) => '$programs/$programId';
  static String programStudents(String programId) =>
      '$programs/$programId/$students';
  static String programStudent(String programId, String studentId) =>
      '$programs/$programId/$students/$studentId';
  static String programSessions(String programId) =>
      '$programs/$programId/$sessions';
  static String programSession(String programId, String sessionId) =>
      '$programs/$programId/$sessions/$sessionId';
  static String sessionAttendance(String programId, String sessionId) =>
      '$programs/$programId/$sessions/$sessionId/$attendance';
  static String attendanceDoc(
    String programId,
    String sessionId,
    String attendanceId,
  ) =>
      '$programs/$programId/$sessions/$sessionId/$attendance/$attendanceId';

  /// Deterministic ID for attendance to ensure idempotent writes (first scan wins)
  static String deterministicAttendanceId(String sessionId, String studentId) =>
      '${sessionId}_$studentId';
}
