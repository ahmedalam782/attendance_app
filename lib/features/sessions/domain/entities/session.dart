class Session {
  const Session({
    required this.id,
    required this.programId,
    required this.title,
    required this.startAt,
    required this.endAt,
    this.status = 'scheduled', // 'scheduled' | 'open' | 'closed'
    this.lateAfterMinutes = 15,
    this.attendanceCount = 0,
    this.createdAt,
  });

  final String id;
  final String programId;
  final String title;
  final DateTime startAt;
  final DateTime endAt;
  final String status;
  final int lateAfterMinutes;
  final int attendanceCount;
  final DateTime? createdAt;

  bool get isScheduled => status == 'scheduled';
  bool get isOpen => status == 'open';
  bool get isClosed => status == 'closed';

  Session copyWith({
    String? id,
    String? programId,
    String? title,
    DateTime? startAt,
    DateTime? endAt,
    String? status,
    int? lateAfterMinutes,
    int? attendanceCount,
    DateTime? createdAt,
  }) {
    return Session(
      id: id ?? this.id,
      programId: programId ?? this.programId,
      title: title ?? this.title,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      status: status ?? this.status,
      lateAfterMinutes: lateAfterMinutes ?? this.lateAfterMinutes,
      attendanceCount: attendanceCount ?? this.attendanceCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
