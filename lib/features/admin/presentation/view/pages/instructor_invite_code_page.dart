import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../widgets/instructor_invite_code_body.dart';

/// Thin RoutePage for displaying and sharing an instructor invite code.
/// Follows Al Faris presentation architecture (AutoRoute + public InstructorInviteCodeBody).
@RoutePage()
class InstructorInviteCodePage extends StatelessWidget {
  const InstructorInviteCodePage({super.key, this.initialCode});

  final String? initialCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: InstructorInviteCodeBody(initialCode: initialCode),
    );
  }
}
