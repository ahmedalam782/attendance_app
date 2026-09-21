import 'package:equatable/equatable.dart';

import '../../../../../core/api/base_state/base_state.dart';
import '../../../domain/entities/enrolled_student.dart';

class EnrollmentState extends Equatable {
  const EnrollmentState({
    this.status = StatusState.initial,
    this.students = const [],
    this.searchQuery = '',
    this.isActionLoading = false,
    this.actionError,
    this.actionSuccessMessage,
  });

  final StatusState status;
  final List<EnrolledStudent> students;
  final String searchQuery;
  final bool isActionLoading;
  final String? actionError;
  final String? actionSuccessMessage;

  List<EnrolledStudent> get filteredStudents {
    if (searchQuery.trim().isEmpty) return students;
    final q = searchQuery.toLowerCase().trim();
    return students.where((s) {
      return s.name.toLowerCase().contains(q) || s.id.toLowerCase().contains(q);
    }).toList();
  }

  EnrollmentState copyWith({
    StatusState? status,
    List<EnrolledStudent>? students,
    String? searchQuery,
    bool? isActionLoading,
    String? actionError,
    String? actionSuccessMessage,
    bool clearActionMessages = false,
  }) {
    return EnrollmentState(
      status: status ?? this.status,
      students: students ?? this.students,
      searchQuery: searchQuery ?? this.searchQuery,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      actionError: clearActionMessages ? null : (actionError ?? this.actionError),
      actionSuccessMessage: clearActionMessages
          ? null
          : (actionSuccessMessage ?? this.actionSuccessMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        students,
        searchQuery,
        isActionLoading,
        actionError,
        actionSuccessMessage,
      ];
}
