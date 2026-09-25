# PlantCare AI — Activation Upload Gate

This checkpoint is the handoff point after the code-side work that can be completed without external project credentials or platform configuration.

## Already prepared in GitHub

- Account/Profile screen and logout flow.
- Family-sharing UI and cloud RLS hardening migration.
- Private Supabase plant-image bucket and user-scoped storage policies.
- Gallery/camera image capture boundary.
- Cloud image upload path.
- Diagnosis image-reference separation.
- Configurable remote inference client.
- FastAPI PlantCare inference service.
- Inference Dockerfile and requirements.
- Optional Firebase Cloud Messaging provider.
- Demo fallback remains available.

## Required assets before the next implementation phase

### 1. Model artifacts

Upload these files into the repository's existing artifact locations:

- artifacts/plant_disease_mobilenetv3.pth
- artifacts/class_names.txt

The .pth file must be the evaluated 38-class MobileNetV3 model corresponding to the documented 98.72% test result. Do not replace it with a different checkpoint without documenting the evaluation.

### 2. Flutter native platform configuration

The current GitHub mobile folder contains the Dart application layer but does not contain the Android/iOS native project folders.

Before production mobile testing, provide the generated Flutter platform project:

- android/
- ios/

If Firebase is being enabled, also provide the generated Firebase configuration:

- mobile/lib/firebase_options.dart
- Android Firebase configuration: android/app/google-services.json
- iOS Firebase configuration: ios/Runner/GoogleService-Info.plist

These are configuration assets, not Supabase service-role credentials.

### 3. Supabase activation values

When the code is ready to activate cloud services, provide only:

- Supabase Project URL
- Supabase Publishable/Anon key

Never provide:

- Supabase database password
- Supabase service-role key
- other private server secrets

The SQL migrations in backend/supabase/ must be applied to the intended Supabase project before live cloud testing.

### 4. Push delivery credentials

For Android FCM, Firebase project configuration is required.

For iOS push, the APNs authentication key must be configured in Firebase/Apple tooling. Do NOT upload the APNs .p8 private key to GitHub or this chat.

## What happens after the upload gate

1. Verify the uploaded model artifact against the 38 class names.
2. Complete the FastAPI inference deployment configuration.
3. Connect the mobile app to the deployed inference endpoint.
4. Configure Firebase Messaging and verify device-token registration.
5. Apply Supabase migrations and verify Auth, Garden, Family Sharing, Storage and Notifications with RLS.
6. Run end-to-end mobile testing.
7. Fix any build/runtime issues found during that verification.
8. Only then move to expanded AI coverage, richer camera UX, assistant/community/expert features and production release hardening.

Do not treat any service as live until it has been tested on a real configured environment.
