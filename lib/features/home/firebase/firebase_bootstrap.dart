import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../firebase_options.dart';

/// Firebase-specific startup (replaces an `api/` layer for this feature).
class FirebaseBootstrap {
  Future<void> initialize() async {
    final options = DefaultFirebaseOptions.currentPlatform;
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: options);
    } else {
      final app = Firebase.app();
      if (app.options.projectId != options.projectId ||
          app.options.appId != options.appId) {
        throw StateError('An unexpected Firebase project is configured.');
      }
    }

    // Bind Firestore to the default app early so first Auth→profile writes
    // do not hit a cold pigeon channel after hot restart.
    final firestore = FirebaseFirestore.instanceFor(app: Firebase.app());
    firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }
}
