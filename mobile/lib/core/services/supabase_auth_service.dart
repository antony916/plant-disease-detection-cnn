import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_service.dart';
import 'cloud_auth_service.dart';

class SupabaseAuthService implements CloudAuthService {
  final SupabaseClient client;

  const SupabaseAuthService(this.client);

  @override
  Future<AppUser?> currentUser() async {
    final user = client.auth.currentUser;
    if (user == null) return null;
    return AppUser(
      id: user.id,
      email: user.email ?? '',
      displayName: user.userMetadata?['display_name'] as String?,
    );
  }

  @override
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final user = response.user;
    if (user == null) throw const AuthException('No user returned.');
    return AppUser(
      id: user.id,
      email: user.email ?? email,
      displayName: user.userMetadata?['display_name'] as String?,
    );
  }

  @override
  Future<void> signOut() => client.auth.signOut();
}
