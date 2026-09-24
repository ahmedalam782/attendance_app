import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../widgets/instructor_invites_history_body.dart';

/// Thin RoutePage for Instructor Invites History adhering to Al Faris presentation architecture.
@RoutePage()
class InstructorInvitesHistoryPage extends StatelessWidget {
  const InstructorInvitesHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: InstructorInvitesHistoryBody(),
    );
  }
}
