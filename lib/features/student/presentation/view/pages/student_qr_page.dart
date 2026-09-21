import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../widgets/student_qr_body.dart';

@RoutePage()
class StudentQrPage extends StatelessWidget {
  const StudentQrPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: StudentQrBody(),
    );
  }
}
