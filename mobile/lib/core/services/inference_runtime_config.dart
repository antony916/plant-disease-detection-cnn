class InferenceRuntimeConfig {
  final String endpoint;

  const InferenceRuntimeConfig({required this.endpoint});

  bool get isConfigured => endpoint.trim().isNotEmpty;

  factory InferenceRuntimeConfig.fromEnvironment() {
    const endpoint = String.fromEnvironment('PLANTCARE_INFERENCE_URL');
    return const InferenceRuntimeConfig(endpoint: endpoint);
  }
}
