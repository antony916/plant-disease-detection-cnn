# PlantCare AI Mobile

Production mobile foundation for the PlantCare AI platform.

## Product direction

PlantCare AI is designed for terrace and home gardeners. The production client is planned for Android and iPhone and will eventually connect:

- account authentication
- persistent garden data
- plant photos and diagnosis history
- AI disease/pest/deficiency/environment diagnosis
- smart watering and care reminders
- notifications
- AI assistant
- family sharing
- community
- expert escalation
- plant/treatment knowledge
- local shop/product discovery

## Current implementation boundary

This mobile directory contains the reusable Flutter application shell and screen architecture derived from the PlantCare Figma design system.

The existing Streamlit application and the trained 38-class PlantVillage MobileNetV3 model remain unchanged.

The diagnosis layer is intentionally abstracted behind application service/repository boundaries. The production inference transport connects through the configured HTTPS inference endpoint rather than embedding model-serving credentials in the app.

## Planned backend boundary

The UI should not depend directly on a specific cloud vendor. Authentication, storage, database, notifications and realtime features are exposed through application services/repositories.

## Run

Install the Flutter SDK, then from this directory:

    flutter pub get
    flutter run

The repository currently does not claim that Flutter has been locally compiled or deployed.

## Native Android/iOS activation

The application code under `lib/` is intentionally kept separate from Flutter's generated native platform projects.

When an environment with the Flutter CLI is available, generate the missing platform shells from the repository root without replacing the existing Dart application:

    cd mobile
    flutter create --platforms=android,ios .

If the command reports that native platform files already exist, stop and inspect them rather than regenerating them over existing configuration.

After generation, verify that these directories exist:

- `mobile/android/`
- `mobile/ios/`

Then configure platform-specific services (including Firebase/FCM/APNs) in those generated projects. Do not commit downloaded Firebase service-account credentials or other server secrets.

### Important activation guardrails

1. Do not replace `mobile/lib/`, `mobile/pubspec.yaml`, tests, or the existing application architecture with a newly generated Flutter sample.
2. Keep the existing four-tab navigation and PlantCare screens intact.
3. Add Firebase native configuration only after the Android/iOS shells exist.
4. Keep Supabase Project URL and publishable/anon client configuration in runtime-safe mobile configuration; never add a Supabase service-role key or database password.
5. Configure the inference endpoint through the existing `PLANTCARE_INFERENCE_URL` runtime define; do not hardcode a private endpoint or credential.
6. After native generation, run formatting/analyze/tests and then perform a real-device smoke test before claiming mobile activation.
7. Native Firebase/APNs delivery, camera permissions, and OS notifications are not considered live until they are exercised on an actual device/emulator.

## Production activation sequence

1. Generate official Flutter Android/iOS platform shells.
2. Add Firebase Android/iOS configuration and notification permissions.
3. Activate the configured inference hosting service and obtain a real HTTPS endpoint.
4. Verify the endpoint with `scripts/verify_inference_endpoint.py`, including a real plant image.
5. Supply `PLANTCARE_INFERENCE_URL` through `--dart-define`.
6. Supply only the Supabase mobile-safe runtime URL and publishable/anon key.
7. Run Flutter -> inference -> diagnosis persistence -> Supabase -> Plant Health Timeline E2E.
8. Verify FCM/APNs notification delivery and camera/gallery permissions on real devices.

