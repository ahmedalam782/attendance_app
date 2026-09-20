import 'package:attendance_app/core/api/base_response/result.dart';
import 'package:attendance_app/core/dependency_injection/injectable_config.dart';
import 'package:attendance_app/core/helper/logout_session.dart';
import 'package:attendance_app/core/languages/lang.dart';
import 'package:attendance_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:attendance_app/features/auth/domain/models/auth_user.dart';
import 'package:attendance_app/features/auth/domain/params/login_params.dart';
import 'package:attendance_app/features/auth/domain/params/register_params.dart';
import 'package:attendance_app/features/auth/domain/use_cases/login_use_case.dart';
import 'package:attendance_app/features/auth/domain/use_cases/register_use_case.dart';
import 'package:attendance_app/features/auth/presentation/view/pages/auth_page.dart';
import 'package:attendance_app/features/auth/presentation/view_model/cubit/auth_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeRepository implements AuthRepository {
  @override
  Stream<AuthUser?> get users => Stream.value(null);

  @override
  Future<Result<AuthUser>> login(LoginParams params) async =>
      Success(data: AuthUser(id: '1', email: params.email));

  @override
  Future<Result<AuthUser>> register(RegisterParams params) async =>
      Success(
        data: AuthUser(id: '1', email: params.email, name: params.name),
      );

  @override
  Future<Result<void>> logout() async => const Success();

  @override
  Future<Result<void>> sendPasswordResetEmail(String email, {String? languageCode}) async =>
      const Success();
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  setUp(() async {
    await getIt.reset();
    final prefs = await SharedPreferences.getInstance();
    final repository = FakeRepository();
    getIt.registerSingleton<SharedPreferences>(prefs);
    getIt.registerSingleton<AuthRepository>(repository);
    getIt.registerSingleton<LoginUseCase>(LoginUseCase(repository));
    getIt.registerSingleton<RegisterUseCase>(RegisterUseCase(repository));
    getIt.registerSingleton<LogoutSession>(LogoutSession(prefs, repository));
    getIt.registerFactory<AuthCubit>(
      () => AuthCubit(getIt(), getIt(), getIt()),
    );
  });

  tearDown(() async => getIt.reset());

  testWidgets('auth page renders with Firebase project wired', (tester) async {
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [englishLocale, arabicLocale],
        fallbackLocale: englishLocale,
        startLocale: englishLocale,
        path: assetsLocalization,
        child: Builder(
          builder: (context) => MaterialApp(
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            home: const AuthPage(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Sign in'), findsOneWidget);
  });
}
