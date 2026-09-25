class SupabaseRuntimeConfig {
  final String url;
  final String publishableKey;

  const SupabaseRuntimeConfig({
    required this.url,
    required this.publishableKey,
  });

  bool get isConfigured =>
      url.isNotEmpty && publishableKey.isNotEmpty;

  factory SupabaseRuntimeConfig.fromEnvironment() {
    const url = String.fromEnvironment('SUPABASE_URL');
    const key = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
    return const SupabaseRuntimeConfig(
      url: url,
      publishableKey: key,
    );
  }
}
