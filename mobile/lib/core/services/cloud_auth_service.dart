import 'auth_service.dart';

abstract interface class CloudAuthService {
  Future<AppUser?> currentUser();
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  });
  Future<void> signOut();
}
