class PushRuntimeConfig {
  final bool enabled;

  const PushRuntimeConfig({required this.enabled});

  factory PushRuntimeConfig.fromEnvironment() {
    const raw = String.fromEnvironment(
      'PLANTCARE_FCM_ENABLED',
      defaultValue: 'false',
    );
    return PushRuntimeConfig(enabled: raw.toLowerCase() == 'true');
  }
}
