import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

import '../../data/datasources/auth_remote_data_source.dart';
import '../../domain/models/auth_user.dart';
import '../../domain/params/login_params.dart';
import '../../domain/params/register_params.dart';

@Injectable(as: AuthRemoteDataSource)
class FirebaseAuthRemoteDataSource implements AuthRemoteDataSource {
  FirebaseAuthRemoteDataSource(this._auth);

  final FirebaseAuth _auth;

  AuthUser _mapUser(User user) => AuthUser(
    id: user.uid,
    email: user.email ?? '',
    name: user.displayName,
  );

  @override
  Stream<AuthUser?> get users => _auth.userChanges().map(
    (user) => user == null ? null : _mapUser(user),
  );

  @override
  Future<AuthUser> login(LoginParams params) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: params.email.trim(),
      password: params.password,
    );
    return _mapUser(credential.user!);
  }

  @override
  Future<AuthUser> register(RegisterParams params) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: params.email.trim(),
      password: params.password,
    );
    try {
      await credential.user!.updateDisplayName(params.name.trim());
    } on FirebaseAuthException {
      // Account is usable even if display name update fails.
    }
    final user = _auth.currentUser ?? credential.user!;
    return _mapUser(user);
  }

  @override
  Future<void> logout() => _auth.signOut();

  @override
  Future<void> sendPasswordResetEmail(String email, {String? languageCode}) async {
    if (languageCode != null && languageCode.isNotEmpty) {
      await _auth.setLanguageCode(languageCode);
    }
    await _auth.sendPasswordResetEmail(email: email.trim());
  }
}
