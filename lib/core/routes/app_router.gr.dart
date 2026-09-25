// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:attendance_app/features/admin/presentation/view/pages/admin_layout_page.dart'
    as _i1;
import 'package:attendance_app/features/admin/presentation/view/pages/admin_programs_page.dart'
    as _i2;
import 'package:attendance_app/features/admin/presentation/view/pages/admin_reports_page.dart'
    as _i3;
import 'package:attendance_app/features/admin/presentation/view/pages/admin_scanner_page.dart'
    as _i4;
import 'package:attendance_app/features/admin/presentation/view/pages/admin_settings_page.dart'
    as _i5;
import 'package:attendance_app/features/admin/presentation/view/pages/instructor_invite_code_page.dart'
    as _i7;
import 'package:attendance_app/features/admin/presentation/view/pages/instructor_invites_history_page.dart'
    as _i8;
import 'package:attendance_app/features/auth/presentation/view/pages/auth_page.dart'
    as _i6;
import 'package:attendance_app/features/auth/presentation/view/pages/register_page.dart'
    as _i10;
import 'package:attendance_app/features/programs/domain/entities/program.dart'
    as _i19;
import 'package:attendance_app/features/programs/presentation/view/pages/program_details_page.dart'
    as _i9;
import 'package:attendance_app/features/splash/presentation/splash_page.dart'
    as _i11;
import 'package:attendance_app/features/student/presentation/view/pages/student_history_page.dart'
    as _i12;
import 'package:attendance_app/features/student/presentation/view/pages/student_layout_page.dart'
    as _i13;
import 'package:attendance_app/features/student/presentation/view/pages/student_programs_page.dart'
    as _i14;
import 'package:attendance_app/features/student/presentation/view/pages/student_qr_page.dart'
    as _i15;
import 'package:attendance_app/features/student/presentation/view/pages/student_settings_page.dart'
    as _i16;
import 'package:auto_route/auto_route.dart' as _i17;
import 'package:flutter/material.dart' as _i18;

/// generated route for
/// [_i1.AdminLayoutPage]
class AdminLayoutRoute extends _i17.PageRouteInfo<void> {
  const AdminLayoutRoute({List<_i17.PageRouteInfo>? children})
    : super(AdminLayoutRoute.name, initialChildren: children);

  static const String name = 'AdminLayoutRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      return const _i1.AdminLayoutPage();
    },
  );
}

/// generated route for
/// [_i2.AdminProgramsPage]
class AdminProgramsRoute extends _i17.PageRouteInfo<void> {
  const AdminProgramsRoute({List<_i17.PageRouteInfo>? children})
    : super(AdminProgramsRoute.name, initialChildren: children);

  static const String name = 'AdminProgramsRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      return _i17.WrappedRoute(child: const _i2.AdminProgramsPage());
    },
  );
}

/// generated route for
/// [_i3.AdminReportsPage]
class AdminReportsRoute extends _i17.PageRouteInfo<void> {
  const AdminReportsRoute({List<_i17.PageRouteInfo>? children})
    : super(AdminReportsRoute.name, initialChildren: children);

  static const String name = 'AdminReportsRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      return _i17.WrappedRoute(child: const _i3.AdminReportsPage());
    },
  );
}

/// generated route for
/// [_i4.AdminScannerPage]
class AdminScannerRoute extends _i17.PageRouteInfo<void> {
  const AdminScannerRoute({List<_i17.PageRouteInfo>? children})
    : super(AdminScannerRoute.name, initialChildren: children);

  static const String name = 'AdminScannerRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      return _i17.WrappedRoute(child: const _i4.AdminScannerPage());
    },
  );
}

/// generated route for
/// [_i5.AdminSettingsPage]
class AdminSettingsRoute extends _i17.PageRouteInfo<void> {
  const AdminSettingsRoute({List<_i17.PageRouteInfo>? children})
    : super(AdminSettingsRoute.name, initialChildren: children);

  static const String name = 'AdminSettingsRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      return _i17.WrappedRoute(child: const _i5.AdminSettingsPage());
    },
  );
}

/// generated route for
/// [_i6.AuthPage]
class AuthRoute extends _i17.PageRouteInfo<void> {
  const AuthRoute({List<_i17.PageRouteInfo>? children})
    : super(AuthRoute.name, initialChildren: children);

  static const String name = 'AuthRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      return _i17.WrappedRoute(child: const _i6.AuthPage());
    },
  );
}

/// generated route for
/// [_i7.InstructorInviteCodePage]
class InstructorInviteCodeRoute
    extends _i17.PageRouteInfo<InstructorInviteCodeRouteArgs> {
  InstructorInviteCodeRoute({
    _i18.Key? key,
    String? initialCode,
    List<_i17.PageRouteInfo>? children,
  }) : super(
         InstructorInviteCodeRoute.name,
         args: InstructorInviteCodeRouteArgs(
           key: key,
           initialCode: initialCode,
         ),
         initialChildren: children,
       );

  static const String name = 'InstructorInviteCodeRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<InstructorInviteCodeRouteArgs>(
        orElse: () => const InstructorInviteCodeRouteArgs(),
      );
      return _i7.InstructorInviteCodePage(
        key: args.key,
        initialCode: args.initialCode,
      );
    },
  );
}

class InstructorInviteCodeRouteArgs {
  const InstructorInviteCodeRouteArgs({this.key, this.initialCode});

  final _i18.Key? key;

  final String? initialCode;

  @override
  String toString() {
    return 'InstructorInviteCodeRouteArgs{key: $key, initialCode: $initialCode}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! InstructorInviteCodeRouteArgs) return false;
    return key == other.key && initialCode == other.initialCode;
  }

  @override
  int get hashCode => key.hashCode ^ initialCode.hashCode;
}

/// generated route for
/// [_i8.InstructorInvitesHistoryPage]
class InstructorInvitesHistoryRoute extends _i17.PageRouteInfo<void> {
  const InstructorInvitesHistoryRoute({List<_i17.PageRouteInfo>? children})
    : super(InstructorInvitesHistoryRoute.name, initialChildren: children);

  static const String name = 'InstructorInvitesHistoryRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      return const _i8.InstructorInvitesHistoryPage();
    },
  );
}

/// generated route for
/// [_i9.ProgramDetailsPage]
class ProgramDetailsRoute extends _i17.PageRouteInfo<ProgramDetailsRouteArgs> {
  ProgramDetailsRoute({
    _i18.Key? key,
    required _i19.Program program,
    bool isAdmin = false,
    List<_i17.PageRouteInfo>? children,
  }) : super(
         ProgramDetailsRoute.name,
         args: ProgramDetailsRouteArgs(
           key: key,
           program: program,
           isAdmin: isAdmin,
         ),
         initialChildren: children,
       );

  static const String name = 'ProgramDetailsRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ProgramDetailsRouteArgs>();
      return _i17.WrappedRoute(
        child: _i9.ProgramDetailsPage(
          key: args.key,
          program: args.program,
          isAdmin: args.isAdmin,
        ),
      );
    },
  );
}

class ProgramDetailsRouteArgs {
  const ProgramDetailsRouteArgs({
    this.key,
    required this.program,
    this.isAdmin = false,
  });

  final _i18.Key? key;

  final _i19.Program program;

  final bool isAdmin;

  @override
  String toString() {
    return 'ProgramDetailsRouteArgs{key: $key, program: $program, isAdmin: $isAdmin}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ProgramDetailsRouteArgs) return false;
    return key == other.key &&
        program == other.program &&
        isAdmin == other.isAdmin;
  }

  @override
  int get hashCode => key.hashCode ^ program.hashCode ^ isAdmin.hashCode;
}

/// generated route for
/// [_i10.RegisterPage]
class RegisterRoute extends _i17.PageRouteInfo<void> {
  const RegisterRoute({List<_i17.PageRouteInfo>? children})
    : super(RegisterRoute.name, initialChildren: children);

  static const String name = 'RegisterRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      return _i17.WrappedRoute(child: const _i10.RegisterPage());
    },
  );
}

/// generated route for
/// [_i11.SplashPage]
class SplashRoute extends _i17.PageRouteInfo<void> {
  const SplashRoute({List<_i17.PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      return const _i11.SplashPage();
    },
  );
}

/// generated route for
/// [_i12.StudentHistoryPage]
class StudentHistoryRoute extends _i17.PageRouteInfo<void> {
  const StudentHistoryRoute({List<_i17.PageRouteInfo>? children})
    : super(StudentHistoryRoute.name, initialChildren: children);

  static const String name = 'StudentHistoryRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      return _i17.WrappedRoute(child: const _i12.StudentHistoryPage());
    },
  );
}

/// generated route for
/// [_i13.StudentLayoutPage]
class StudentLayoutRoute extends _i17.PageRouteInfo<void> {
  const StudentLayoutRoute({List<_i17.PageRouteInfo>? children})
    : super(StudentLayoutRoute.name, initialChildren: children);

  static const String name = 'StudentLayoutRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      return const _i13.StudentLayoutPage();
    },
  );
}

/// generated route for
/// [_i14.StudentProgramsPage]
class StudentProgramsRoute extends _i17.PageRouteInfo<void> {
  const StudentProgramsRoute({List<_i17.PageRouteInfo>? children})
    : super(StudentProgramsRoute.name, initialChildren: children);

  static const String name = 'StudentProgramsRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      return _i17.WrappedRoute(child: const _i14.StudentProgramsPage());
    },
  );
}

/// generated route for
/// [_i15.StudentQrPage]
class StudentQrRoute extends _i17.PageRouteInfo<void> {
  const StudentQrRoute({List<_i17.PageRouteInfo>? children})
    : super(StudentQrRoute.name, initialChildren: children);

  static const String name = 'StudentQrRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      return const _i15.StudentQrPage();
    },
  );
}

/// generated route for
/// [_i16.StudentSettingsPage]
class StudentSettingsRoute extends _i17.PageRouteInfo<void> {
  const StudentSettingsRoute({List<_i17.PageRouteInfo>? children})
    : super(StudentSettingsRoute.name, initialChildren: children);

  static const String name = 'StudentSettingsRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      return _i17.WrappedRoute(child: const _i16.StudentSettingsPage());
    },
  );
}
