import '../../domain/models/auth_user.dart';

abstract class UserProfileRemoteDataSource {
  /// Creates `users/{uid}` after registration.
  Future<void> createProfile(AuthUser user);

  /// Updates name on login; creates the doc if it is missing.
  Future<void> syncProfile(AuthUser user);
}
