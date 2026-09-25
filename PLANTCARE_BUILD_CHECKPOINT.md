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
Cloud garden persistence + cloud diagnosis history:
- AppServices now selects DemoGardenRepository or SupabaseGardenRepository based on runtime backend configuration
- Auth and Garden use the same runtime backend selection
- Supabase default garden creation/loading is implemented
- Supabase plant CRUD is implemented and scoped by owner/garden through RLS
- Add Plant, Dashboard, Plant Detail, watering/update, and delete paths use the selected repository
- SupabaseDiagnosisRepository persists diagnosis results and loads per-plant history
- Diagnosis repository now switches with runtime backend mode

## Previous completed step
Runtime account/auth foundation:
- AppServices.initialize()
- Demo auth by default
- SupabaseAuthService selected automatically when Supabase is configured
- startup initializes AppServices before runApp

## NEXT TASK — RESUME HERE
Build cloud notification persistence:
1. Persist notification preferences and device-token state in Supabase.
2. Connect notification settings to the selected backend.
3. Keep Demo mode working without Supabase.

Then:
- family sharing foundation
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