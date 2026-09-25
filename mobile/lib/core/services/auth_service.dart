class AppUser {
  final String id;
  final String email;
  final String? displayName;

  const AppUser({
    required this.id,
    required this.email,
    this.displayName,
  });
}

abstract interface class AuthService {
  Future<AppUser?> currentUser();
  Future<AppUser> signInWithGoogle();
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  });
  Future<void> signOut();
}
