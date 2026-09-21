import '../../domain/models/auth_user.dart';

/// Small helpers for [AuthUser] display values.
abstract final class AuthUserUtils {
  static String initials(AuthUser user) {
    if (user.name?.isNotEmpty ?? false) {
      return user.name![0].toUpperCase();
    }
    if (user.email.isNotEmpty) {
      return user.email[0].toUpperCase();
    }
    return 'U';
  }

  static String displayName(AuthUser user) {
    if (user.name?.isNotEmpty ?? false) return user.name!;
    return user.email.split('@').first;
  }
}
