class UpdateProgramParams {
  const UpdateProgramParams({
    required this.id,
    required this.title,
    required this.type,
    this.description = '',
    this.location = '',
    this.startDate,
    this.endDate,
  });

  final String id;
  final String title;
  final String type; // 'course' | 'event' | 'bootcamp'
  final String description;
  final String location;
  final DateTime? startDate;
  final DateTime? endDate;
}
