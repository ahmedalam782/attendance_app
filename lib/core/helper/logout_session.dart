import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/base_response/result.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';

/// Clears local session caches after Firebase sign-out (Al Faris–style).
@lazySingleton
class LogoutSession {
  LogoutSession(this._prefs, this._authRepository);

  final SharedPreferences _prefs;
  final AuthRepository _authRepository;

  Future<Result<void>> logout() async {
    final result = await _authRepository.logout();
    if (result is Success<void>) {
      await _prefs.clear();
    }
    return result;
  }
}
