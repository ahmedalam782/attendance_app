import '../../../core/dependency_injection/injectable_config.dart';
import '../domain/app_bootstrap.dart';
import '../firebase/firebase_bootstrap.dart';

class AppBootstrapImpl implements AppBootstrap {
  AppBootstrapImpl({FirebaseBootstrap? firebase})
    : _firebase = firebase ?? FirebaseBootstrap();

  final FirebaseBootstrap _firebase;

  @override
  Future<void> run() async {
    await _firebase.initialize();
    await getIt.reset();
    await configureDependencies();
  }
}
