class CreateProgramParams {
  const CreateProgramParams({
    required this.title,
    required this.type,
    required this.ownerId,
    required this.inviteCode,
    this.description = '',
    this.location = '',
    this.startDate,
    this.endDate,
    this.adminIds = const [],
  });

  final String title;
  final String type; // 'course' | 'event' | 'bootcamp'
  final String ownerId;
  final String inviteCode;
  final String description;
  final String location;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String> adminIds;
}
