import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../routes/app_router.gr.dart';
import '../../features/auth/presentation/utils/auth_dialogs.dart';
import '../../features/auth/presentation/view_model/cubit/auth_cubit.dart';

/// Shared logout + navigate-to-auth flow for settings screens.
abstract final class SessionUtils {
  static Future<void> confirmLogoutAndLeave(BuildContext context) async {
    final confirmed = await AuthDialogs.confirmLogout(context);
    if (!confirmed || !context.mounted) return;

    await context.read<AuthCubit>().logout();
    if (!context.mounted) return;
    context.router.replaceAll([const AuthRoute()]);
  }
}
