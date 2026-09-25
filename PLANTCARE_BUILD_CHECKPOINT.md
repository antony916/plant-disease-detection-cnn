# PlantCare AI — Build Checkpoint

Last updated: 2026-09-25

Project: PlantCare AI — professional AI agriculture / home-gardening product.
Repository: https://github.com/antony916/plant-disease-detection-cnn

## Product
- Android + iPhone target.
- Flutter mobile foundation.
- Python/PyTorch AI model layer.
- Streamlit for internal AI/model testing and research.
- Future cloud backend: Supabase.
- Future accounts, push notifications, family sharing, community, shop/partner modules.
- Figma product blueprint is already established and visually audited.

## AI baseline
- MobileNetV3.
- Curated PlantVillage dataset.
- 38 classes.
- Test samples: 10,948.
- Test accuracy: 98.72%.
- Weighted precision: 98.75%.
- Weighted recall: 98.72%.
- Weighted F1: 98.72%.
- RTX 5060 Laptop GPU used for training/evaluation.
- The current model is not a claim of universal plant/disease coverage.

## Implemented Flutter features
- typed Plant model and garden tasks
- repository-backed dashboard
- Add Plant flow with care profile
- repository-backed Plant Detail
- watering/update behavior
- diagnosis service integration
- diagnosis history
- confidence-aware diagnosis preparation
- garden plant selection in scanner
- PlantCare bottom navigation
- notification center and settings
- notification coordinator
- Open-Meteo weather service
- user-selected location abstraction; no silent precise GPS
- rule-based care recommendations
- localization foundation: English/Tamil/Hindi
- Demo services for development

## Supabase status
NOT LIVE yet.

Prepared:
- backend/supabase/001_initial_schema.sql
- gardens, plants, diagnoses, garden_tasks, family_members, device_tokens
- indexes and RLS foundation
- supabase_flutter dependency
- SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY runtime configuration
- SupabaseAuthService
- SupabaseGardenRepository
- runtime backend initialization

Runtime behavior:
- no credentials => Demo backend
- valid credentials => Supabase initializes
- credentials are not stored in GitHub

## Latest completed step
Runtime account/auth foundation:
- AppServices.initialize()
- Demo auth by default
- SupabaseAuthService selected automatically when Supabase is configured
- startup initializes AppServices before runApp

## NEXT TASK — RESUME HERE
Build cloud garden persistence:
1. Create/get each authenticated user's default garden.
2. Connect plants to that garden.
3. Improve Supabase Plant mapping to preserve the current Plant model fields.
4. Connect Add Plant to cloud when Supabase mode is active.
5. Load cloud plants into Dashboard / Plant Detail.
6. Update/delete cloud plants.
7. Keep Demo mode working when Supabase is not configured.

Then:
- cloud diagnosis history
- notification data/preferences persistence
- family sharing foundation
- account/profile UI
- security/testing
- only then activate a real Supabase project and perform live cloud testing

## Working rules
- Before changing code/files, tell the user what will change and why.
- Prefer building through connected tools rather than repeatedly sending PowerShell commands.
- Do not claim Flutter compilation/testing unless Flutter CLI was actually available and tested.
- Do not claim Supabase is live until credentials/project are configured.
- Keep the existing PlantCare visual design language.

## New-chat resume command
Resume PlantCare AI from PLANTCARE_BUILD_CHECKPOINT.md. Continue from NEXT TASK — cloud garden persistence. Do not restart the project.