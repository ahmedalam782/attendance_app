class Program {
  const Program({
    required this.id,
    required this.title,
    required this.type,
    required this.ownerId,
    required this.inviteCode,
    this.description = '',
    this.location = '',
    this.startDate,
    this.endDate,
    this.adminIds = const [],
    this.studentCount = 0,
    this.sessionCount = 0,
    this.createdAt,
  });

  final String id;
  final String title;
  final String type; // 'course' | 'event' | 'bootcamp'
  final String ownerId;
  final String inviteCode;
  final String description;
  final String location;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String> adminIds;
  final int studentCount;
  final int sessionCount;
  final DateTime? createdAt;

  bool get isCourse => type == 'course';
  bool get isBootcamp => type == 'bootcamp';
  bool get isEvent => type == 'event';
}
