abstract interface class CloudBackend {
  Future<bool> isConfigured();
  Future<void> initialize();
}

/// Placeholder until Supabase credentials are supplied through secure
/// runtime configuration. Credentials must never be committed to Git.
class SupabaseBackend implements CloudBackend {
  final String? url;
  final String? anonKey;

  const SupabaseBackend({this.url, this.anonKey});

  @override
  Future<bool> isConfigured() async =>
      url != null && url!.isNotEmpty && anonKey != null && anonKey!.isNotEmpty;

  @override
  Future<void> initialize() async {
    if (!await isConfigured()) return;
    // Supabase client initialization will be enabled when runtime
    // configuration is connected.
  }
}
