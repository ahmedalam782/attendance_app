/// Runtime environment flags that must not live in [main.dart].
///
/// Local builds: set [runLocal] to `true` when you add local-only endpoints.
/// Live builds: set [runLocal] to `false` for production.
class AppEnvironment {
  const AppEnvironment._();

  /// Set to `true` for local development, `false` for production.
  static const bool runLocal = false;
}
