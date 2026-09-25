import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_runtime_config.dart';

enum BackendMode { demo, supabase }

class BackendRuntime {
  final SupabaseRuntimeConfig config;
  BackendMode mode = BackendMode.demo;
  SupabaseClient? client;

  BackendRuntime(this.config);

  Future<void> initialize() async {
    if (!config.isConfigured) return;

    await Supabase.initialize(
      url: config.url,
      anonKey: config.publishableKey,
    );

    client = Supabase.instance.client;
    mode = BackendMode.supabase;
  }

  bool get isCloudEnabled => mode == BackendMode.supabase;
}
