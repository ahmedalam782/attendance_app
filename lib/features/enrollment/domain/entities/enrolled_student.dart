import 'package:equatable/equatable.dart';

class EnrolledStudent extends Equatable {
  const EnrolledStudent({
    required this.id,
    required this.name,
    required this.joinedAt,
    this.status = 'active',
  });

  final String id;
  final String name;
  final DateTime joinedAt;
  final String status;

  bool get isActive => status.toLowerCase() == 'active';

  @override
  List<Object?> get props => [id, name, joinedAt, status];
}
