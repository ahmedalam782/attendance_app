// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../features/attendance/data/datasources/attendance_remote_data_source.dart'
    as _i680;
import '../../features/attendance/data/datasources/firestore_attendance_remote_data_source.dart'
    as _i501;
import '../../features/attendance/data/repositories/attendance_repository_impl.dart'
    as _i719;
import '../../features/attendance/domain/repositories/attendance_repository.dart'
    as _i477;
import '../../features/attendance/domain/use_cases/record_attendance_use_case.dart'
    as _i716;
import '../../features/attendance/domain/use_cases/watch_session_attendance_use_case.dart'
    as _i17;
import '../../features/attendance/domain/use_cases/watch_student_attendance_history_use_case.dart'
    as _i614;
import '../../features/attendance/presentation/view_model/cubit/attendance_cubit.dart'
    as _i659;
import '../../features/auth/data/datasources/auth_remote_data_source.dart'
    as _i107;
import '../../features/auth/data/datasources/user_profile_remote_data_source.dart'
    as _i1041;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/domain/use_cases/forgot_password_use_case.dart'
    as _i897;
import '../../features/auth/domain/use_cases/get_current_user_use_case.dart'
    as _i129;
import '../../features/auth/domain/use_cases/login_use_case.dart' as _i1038;
import '../../features/auth/domain/use_cases/redeem_instructor_code_use_case.dart'
    as _i418;
import '../../features/auth/domain/use_cases/register_use_case.dart' as _i1010;
import '../../features/auth/firebase/datasources/firebase_auth_remote_data_source.dart'
    as _i613;
import '../../features/auth/firebase/datasources/firestore_user_profile_remote_data_source.dart'
    as _i205;
import '../../features/auth/presentation/view_model/cubit/auth_cubit.dart'
    as _i796;
import '../../features/enrollment/data/datasources/enrollment_remote_data_source.dart'
    as _i231;
import '../../features/enrollment/data/datasources/firestore_enrollment_remote_data_source.dart'
    as _i97;
import '../../features/enrollment/data/repositories/enrollment_repository_impl.dart'
    as _i752;
import '../../features/enrollment/domain/repositories/enrollment_repository.dart'
    as _i149;
import '../../features/enrollment/domain/use_cases/add_student_to_program_use_case.dart'
    as _i308;
import '../../features/enrollment/domain/use_cases/import_students_csv_use_case.dart'
    as _i147;
import '../../features/enrollment/domain/use_cases/remove_student_from_program_use_case.dart'
    as _i301;
import '../../features/enrollment/domain/use_cases/watch_program_students_use_case.dart'
    as _i446;
import '../../features/enrollment/presentation/view_model/cubit/enrollment_cubit.dart'
    as _i564;
import '../../features/programs/data/datasources/firestore_programs_remote_data_source.dart'
    as _i88;
import '../../features/programs/data/datasources/programs_remote_data_source.dart'
    as _i972;
import '../../features/programs/data/repositories/programs_repository_impl.dart'
    as _i934;
import '../../features/programs/domain/repositories/programs_repository.dart'
    as _i1036;
import '../../features/programs/domain/use_cases/create_program_use_case.dart'
    as _i74;
import '../../features/programs/domain/use_cases/get_admin_programs_use_case.dart'
    as _i743;
import '../../features/programs/domain/use_cases/get_program_by_id_use_case.dart'
    as _i476;
import '../../features/programs/domain/use_cases/get_student_programs_use_case.dart'
    as _i223;
import '../../features/programs/domain/use_cases/join_program_by_code_use_case.dart'
    as _i681;
import '../../features/programs/presentation/view_model/cubit/programs_cubit.dart'
    as _i804;
import '../../features/reports/data/datasources/firestore_reports_remote_data_source.dart'
    as _i54;
import '../../features/reports/data/datasources/reports_remote_data_source.dart'
    as _i673;
import '../../features/reports/data/repositories/reports_repository_impl.dart'
    as _i227;
import '../../features/reports/domain/repositories/reports_repository.dart'
    as _i808;
import '../../features/reports/domain/use_cases/export_attendance_csv_use_case.dart'
    as _i848;
import '../../features/reports/domain/use_cases/get_program_report_use_case.dart'
    as _i853;
import '../../features/reports/presentation/view_model/cubit/reports_cubit.dart'
    as _i96;
import '../../features/sessions/data/datasources/firestore_sessions_remote_data_source.dart'
    as _i643;
import '../../features/sessions/data/datasources/sessions_remote_data_source.dart'
    as _i931;
import '../../features/sessions/data/repositories/sessions_repository_impl.dart'
    as _i809;
import '../../features/sessions/domain/repositories/sessions_repository.dart'
    as _i374;
import '../../features/sessions/domain/use_cases/create_session_use_case.dart'
    as _i686;
import '../../features/sessions/domain/use_cases/delete_session_use_case.dart'
    as _i439;
import '../../features/sessions/domain/use_cases/get_sessions_use_case.dart'
    as _i383;
import '../../features/sessions/domain/use_cases/update_session_status_use_case.dart'
    as _i403;
import '../../features/sessions/domain/use_cases/update_session_use_case.dart'
    as _i133;
import '../../features/sessions/presentation/view_model/cubit/sessions_cubit.dart'
    as _i510;
import '../crypto/qr_token_service.dart' as _i922;
import '../helper/logout_session.dart' as _i932;
import '../routes/app_router.dart' as _i629;
import '../services/notification_service.dart' as _i941;
import 'register_module.dart' as _i291;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => registerModule.prefs,
      preResolve: true,
    );
    gh.singleton<_i629.AppRouter>(() => _i629.AppRouter());
    gh.lazySingleton<_i922.QrTokenService>(() => _i922.QrTokenService());
    gh.lazySingleton<_i59.FirebaseAuth>(() => registerModule.firebaseAuth);
    gh.lazySingleton<_i974.FirebaseFirestore>(
      () => registerModule.firebaseFirestore,
    );
    gh.lazySingleton<_i941.NotificationService>(
      () => _i941.NotificationService(),
    );
    gh.factory<_i107.AuthRemoteDataSource>(
      () => _i613.FirebaseAuthRemoteDataSource(gh<_i59.FirebaseAuth>()),
    );
    gh.factory<_i231.EnrollmentRemoteDataSource>(
      () => _i97.FirestoreEnrollmentRemoteDataSource(
        gh<_i974.FirebaseFirestore>(),
      ),
    );
    gh.factory<_i680.AttendanceRemoteDataSource>(
      () => _i501.FirestoreAttendanceRemoteDataSource(
        gh<_i974.FirebaseFirestore>(),
      ),
    );
    gh.factory<_i1041.UserProfileRemoteDataSource>(
      () => _i205.FirestoreUserProfileRemoteDataSource(
        gh<_i974.FirebaseFirestore>(),
      ),
    );
    gh.factory<_i673.ReportsRemoteDataSource>(
      () =>
          _i54.FirestoreReportsRemoteDataSource(gh<_i974.FirebaseFirestore>()),
    );
    gh.factory<_i972.ProgramsRemoteDataSource>(
      () =>
          _i88.FirestoreProgramsRemoteDataSource(gh<_i974.FirebaseFirestore>()),
    );
    gh.factory<_i931.SessionsRemoteDataSource>(
      () => _i643.FirestoreSessionsRemoteDataSource(
        gh<_i974.FirebaseFirestore>(),
      ),
    );
    gh.factory<_i808.ReportsRepository>(
      () => _i227.ReportsRepositoryImpl(gh<_i673.ReportsRemoteDataSource>()),
    );
    gh.factory<_i787.AuthRepository>(
      () => _i153.AuthRepositoryImpl(
        gh<_i107.AuthRemoteDataSource>(),
        gh<_i1041.UserProfileRemoteDataSource>(),
      ),
    );
    gh.factory<_i1036.ProgramsRepository>(
      () => _i934.ProgramsRepositoryImpl(gh<_i972.ProgramsRemoteDataSource>()),
    );
    gh.factory<_i149.EnrollmentRepository>(
      () => _i752.EnrollmentRepositoryImpl(
        gh<_i231.EnrollmentRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i932.LogoutSession>(
      () => _i932.LogoutSession(
        gh<_i460.SharedPreferences>(),
        gh<_i787.AuthRepository>(),
      ),
    );
    gh.factory<_i477.AttendanceRepository>(
      () => _i719.AttendanceRepositoryImpl(
        gh<_i680.AttendanceRemoteDataSource>(),
      ),
    );
    gh.factory<_i308.AddStudentToProgramUseCase>(
      () => _i308.AddStudentToProgramUseCase(gh<_i149.EnrollmentRepository>()),
    );
    gh.factory<_i147.ImportStudentsCsvUseCase>(
      () => _i147.ImportStudentsCsvUseCase(gh<_i149.EnrollmentRepository>()),
    );
    gh.factory<_i301.RemoveStudentFromProgramUseCase>(
      () => _i301.RemoveStudentFromProgramUseCase(
        gh<_i149.EnrollmentRepository>(),
      ),
    );
    gh.factory<_i446.WatchProgramStudentsUseCase>(
      () => _i446.WatchProgramStudentsUseCase(gh<_i149.EnrollmentRepository>()),
    );
    gh.factory<_i374.SessionsRepository>(
      () => _i809.SessionsRepositoryImpl(gh<_i931.SessionsRemoteDataSource>()),
    );
    gh.factory<_i716.RecordAttendanceUseCase>(
      () => _i716.RecordAttendanceUseCase(gh<_i477.AttendanceRepository>()),
    );
    gh.factory<_i17.WatchSessionAttendanceUseCase>(
      () =>
          _i17.WatchSessionAttendanceUseCase(gh<_i477.AttendanceRepository>()),
    );
    gh.factory<_i614.WatchStudentAttendanceHistoryUseCase>(
      () => _i614.WatchStudentAttendanceHistoryUseCase(
        gh<_i477.AttendanceRepository>(),
      ),
    );
    gh.factory<_i564.EnrollmentCubit>(
      () => _i564.EnrollmentCubit(
        gh<_i446.WatchProgramStudentsUseCase>(),
        gh<_i308.AddStudentToProgramUseCase>(),
        gh<_i301.RemoveStudentFromProgramUseCase>(),
        gh<_i147.ImportStudentsCsvUseCase>(),
      ),
    );
    gh.factory<_i848.ExportAttendanceCsvUseCase>(
      () => _i848.ExportAttendanceCsvUseCase(gh<_i808.ReportsRepository>()),
    );
    gh.factory<_i853.GetProgramReportUseCase>(
      () => _i853.GetProgramReportUseCase(gh<_i808.ReportsRepository>()),
    );
    gh.factory<_i659.AttendanceCubit>(
      () => _i659.AttendanceCubit(
        gh<_i716.RecordAttendanceUseCase>(),
        gh<_i17.WatchSessionAttendanceUseCase>(),
        gh<_i614.WatchStudentAttendanceHistoryUseCase>(),
        gh<_i922.QrTokenService>(),
      ),
    );
    gh.factory<_i897.ForgotPasswordUseCase>(
      () => _i897.ForgotPasswordUseCase(gh<_i787.AuthRepository>()),
    );
    gh.factory<_i129.GetCurrentUserUseCase>(
      () => _i129.GetCurrentUserUseCase(gh<_i787.AuthRepository>()),
    );
    gh.factory<_i1038.LoginUseCase>(
      () => _i1038.LoginUseCase(gh<_i787.AuthRepository>()),
    );
    gh.factory<_i418.RedeemInstructorCodeUseCase>(
      () => _i418.RedeemInstructorCodeUseCase(gh<_i787.AuthRepository>()),
    );
    gh.factory<_i1010.RegisterUseCase>(
      () => _i1010.RegisterUseCase(gh<_i787.AuthRepository>()),
    );
    gh.factory<_i686.CreateSessionUseCase>(
      () => _i686.CreateSessionUseCase(gh<_i374.SessionsRepository>()),
    );
    gh.factory<_i439.DeleteSessionUseCase>(
      () => _i439.DeleteSessionUseCase(gh<_i374.SessionsRepository>()),
    );
    gh.factory<_i383.GetSessionsUseCase>(
      () => _i383.GetSessionsUseCase(gh<_i374.SessionsRepository>()),
    );
    gh.factory<_i403.UpdateSessionStatusUseCase>(
      () => _i403.UpdateSessionStatusUseCase(gh<_i374.SessionsRepository>()),
    );
    gh.factory<_i133.UpdateSessionUseCase>(
      () => _i133.UpdateSessionUseCase(gh<_i374.SessionsRepository>()),
    );
    gh.factory<_i74.CreateProgramUseCase>(
      () => _i74.CreateProgramUseCase(gh<_i1036.ProgramsRepository>()),
    );
    gh.factory<_i743.GetAdminProgramsUseCase>(
      () => _i743.GetAdminProgramsUseCase(gh<_i1036.ProgramsRepository>()),
    );
    gh.factory<_i476.GetProgramByIdUseCase>(
      () => _i476.GetProgramByIdUseCase(gh<_i1036.ProgramsRepository>()),
    );
    gh.factory<_i223.GetStudentProgramsUseCase>(
      () => _i223.GetStudentProgramsUseCase(gh<_i1036.ProgramsRepository>()),
    );
    gh.factory<_i681.JoinProgramByCodeUseCase>(
      () => _i681.JoinProgramByCodeUseCase(gh<_i1036.ProgramsRepository>()),
    );
    gh.factory<_i804.ProgramsCubit>(
      () => _i804.ProgramsCubit(
        gh<_i743.GetAdminProgramsUseCase>(),
        gh<_i223.GetStudentProgramsUseCase>(),
        gh<_i74.CreateProgramUseCase>(),
        gh<_i681.JoinProgramByCodeUseCase>(),
      ),
    );
    gh.factory<_i96.ReportsCubit>(
      () => _i96.ReportsCubit(
        gh<_i853.GetProgramReportUseCase>(),
        gh<_i848.ExportAttendanceCsvUseCase>(),
      ),
    );
    gh.factory<_i510.SessionsCubit>(
      () => _i510.SessionsCubit(
        gh<_i383.GetSessionsUseCase>(),
        gh<_i686.CreateSessionUseCase>(),
        gh<_i403.UpdateSessionStatusUseCase>(),
        gh<_i439.DeleteSessionUseCase>(),
        gh<_i133.UpdateSessionUseCase>(),
      ),
    );
    gh.factory<_i796.AuthCubit>(
      () => _i796.AuthCubit(
        gh<_i1038.LoginUseCase>(),
        gh<_i1010.RegisterUseCase>(),
        gh<_i932.LogoutSession>(),
        gh<_i897.ForgotPasswordUseCase>(),
        gh<_i129.GetCurrentUserUseCase>(),
        gh<_i418.RedeemInstructorCodeUseCase>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}
