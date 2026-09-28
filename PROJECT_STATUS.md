# PlantCare AI — Project Status

## Current status

**PlantCare AI product build: active**

The repository has evolved from the original Plant Disease Detection mini-project into the PlantCare AI application. The original CNN experiment remains the model baseline; it is not the complete product.

## Implemented product foundation

- Flutter mobile application foundation
- Garden dashboard and plant management
- Cloud garden persistence architecture
- Plant detail and care data
- AI scanner with camera/gallery capture
- Diagnosis result and history architecture
- Confidence-aware diagnosis contract
- Remote FastAPI inference service
- Model-version tracking
- Private Supabase plant-image storage
- Supabase Auth integration boundary
- Family-sharing UI and RLS hardening
- Secure family invitation acceptance
- Cloud notification persistence architecture
- Device-token persistence
- Optional Firebase Messaging provider
- Weather/location abstraction
- Care recommendation foundation
- Demo/Supabase runtime switching
- Continuous Integration foundation
- Flutter unit-test foundation
- Context-aware AI assistant foundation
- Starter plant knowledge library
- Community/expert/shop/resource support hub foundation
- Automated activation-readiness checker
- Python syntax validation
- Repository checkpoints and activation documentation

## AI model baseline

- Architecture: MobileNetV3-Large
- Dataset: `geraldmc/plantvillage-full`
- Classes: 38
- Input: 224 × 224 RGB
- Epochs: 10
- Batch size: 32
- Learning rate: 3e-4
- Optimizer: AdamW
- Loss: Cross Entropy
- Documented held-out test set: 10,948 samples
- Accuracy: 98.72%
- Weighted precision: 98.75%
- Weighted recall: 98.72%
- Weighted F1: 98.72%

These are benchmark results on the documented held-out dataset, not a claim of equivalent real-world field accuracy.

## Activation blockers

The following require external project/device assets and cannot be truthfully marked live from repository code alone:

1. Evaluated model artifact:
   - `artifacts/plant_disease_mobilenetv3.pth`
   - `artifacts/class_names.txt`
2. Flutter Android/iOS native platform folders.
3. Supabase project URL and publishable/anon key.
4. Application of Supabase migrations to the intended project.
5. Firebase/FCM native configuration if push is enabled.
6. Real-device end-to-end verification.

See `PLANTCARE_ACTIVATION_UPLOAD_CHECKLIST.md` for the activation sequence.

## Current engineering rule

Do not describe a cloud, inference, push, or mobile-native feature as live until it has been verified in a configured environment.

The durable continuation source is `PLANTCARE_BUILD_CHECKPOINT.md`.
