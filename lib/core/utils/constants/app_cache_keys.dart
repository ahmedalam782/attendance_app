/// Local storage and cache keys as defined in PROJECT.md.
abstract final class AppCacheKeys {
  static const String userRole = 'cached_user_role';
  static const String userEmail = 'cached_user_email';
  static const String userId = 'cached_user_id';
  static const String qrPublicKey = 'cached_qr_public_key';
  static const String studentQrToken = 'cached_student_qr_token';
  static const String lastSyncTimestamp = 'cached_last_sync_timestamp';
  static const String offlinePendingWrites = 'cached_offline_pending_writes';
}
