/// Boots Firebase + DI before the first feature screen is shown.
abstract class AppBootstrap {
  Future<void> run();
}
