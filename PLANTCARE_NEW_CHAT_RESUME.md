# PlantCare AI — New Chat Resume Instructions

## READ THIS FIRST

You are continuing an existing long-running PlantCare AI build owned by Renio.

Do NOT restart the project.
Do NOT redesign the architecture from scratch.
Do NOT make the user repeat the project history.
Do NOT switch to Project 2.

The durable source of truth is the GitHub repository, not the previous chat transcript.

## FIRST ACTIONS IN A NEW CHAT

1. Open and read this file completely.
2. Open and read PLANTCARE_BUILD_CHECKPOINT.md.
3. Open PRODUCT_BLUEPRINT.md.
4. Inspect the current repository files relevant to the NEXT TASK and verify that the checkpoint matches the code.
5. Continue from the checkpoint's NEXT TASK.

The user's exact recovery request is:

> Resume PlantCare AI from PLANTCARE_BUILD_CHECKPOINT.md in the GitHub repo antony916/plant-disease-detection-cnn. Read and verify the checkpoint against the current repo. Do not restart, do not make me repeat the project history, and do not switch to Project 2. Continue from NEXT TASK. Before any code/file change, tell me exactly what you will change and why.

## PROJECT

Product: PlantCare AI

GitHub:
https://github.com/antony916/plant-disease-detection-cnn

Figma:
https://www.figma.com/design/7BCd5SwUETIzVWPYtpzjTo

Figma file name:
PlantCare AI — Product Blueprint

Product goal:
A professional AI agriculture/home-gardening product for terrace, balcony, indoor and home gardeners on Android and iPhone.

## APPROVED ARCHITECTURE

- Flutter mobile client for Android/iPhone.
- Python + PyTorch + MobileNetV3 for AI/model work.
- Streamlit remains the existing AI/model evaluation/demo interface.
- Supabase/Postgres/Auth/Storage/cloud notification data for backend.
- Figma for product design.
- GitHub as implementation source of truth.
- Notion for project documentation.
- Exa/web research for current references when needed.

Do not replace working architecture without a real technical reason.

## IMPORTANT CURRENT STATUS

The project already contains substantial implemented work. It is NOT a fresh README-only project.

### AI

- PlantVillage curated dataset.
- 38-class classifier.
- MobileNetV3.
- Test accuracy 98.72%.
- Weighted precision 98.75%.
- Weighted recall 98.72%.
- Weighted F1 98.72%.
- 10,948 test samples.
- RTX 5060 Laptop GPU / CUDA used.
- Model/artifacts and evaluation outputs are in the repo.

Do not claim universal plant/disease coverage.

### Streamlit

Existing Streamlit agriculture assistant contains:
- disease detection
- disease details
- treatment/products
- nearby agri shops
- agricultural experts
- resources
- expert help
- upload analysis states
- confidence-aware handling

Do not throw this away.

### Flutter mobile

Already implemented:
- typed routing
- Welcome/Login foundation
- Garden Dashboard
- Add Plant
- AI Plant Scanner
- Diagnosis Result
- Plant Detail
- AI Assistant foundation
- repository-backed garden state
- plant care profiles
- diagnosis history
- notification center
- notification settings
- notification coordinator
- weather service
- care recommendation rules
- localization foundation
- demo services

### Cloud

Supabase is prepared but not live.

Implemented:
- runtime Supabase configuration
- startup backend initialization
- runtime Demo/Supabase switching
- Supabase auth service
- default garden provisioning
- Supabase garden repository
- plant CRUD/persistence
- Supabase diagnosis repository
- notification preference persistence schema/service
- notification center persistence schema/service
- device-token persistence service
- owner-oriented RLS foundation

NOT live:
- no real Supabase project credentials have been configured
- SQL migrations have not been applied to the user's live project
- actual OS push delivery has not been verified
- FCM/APNs integration is not yet complete

Never pretend those are live.

## LATEST COMPLETED CLOUD NOTIFICATION WORK

Files:
- backend/supabase/002_notification_persistence.sql
- mobile/lib/core/services/supabase_notification_center_service.dart
- mobile/lib/core/services/supabase_notification_service.dart

AppServices now switches notification persistence/service implementations according to runtime backend mode.

Demo mode must remain fully functional when Supabase is absent.

Actual push delivery is a separate milestone.

## FIGMA — DO NOT CHANGE APPROVED DESIGN UNLESS ASKED

Figma core screens:
1. Welcome / Login
2. Garden Dashboard
3. AI Plant Scanner
4. Diagnosis Result
5. Plant Detail
6. AI Assistant
7. Design System

Approved visual system:
- Inter
- 24px screen padding
- 8pt spacing
- 16px standard card radius
- 20px featured radius
- 44px minimum interactive targets
- light/dark semantic tokens
- PlantCare green brand system
- approved bottom navigation: Garden / Scan / Library / Profile
- four equal bottom-nav slots
- active item green
- scanner uses a soft centered green plus cue
- scanner leaf illustration was intentionally removed

Important:
The user previously asked to check page design, not rebuild prototype flow. Do not start random Figma navigation redesign.

## PRODUCT FEATURES TO PRESERVE

Long-term plan includes:
- accounts
- persistent cloud gardens
- camera/gallery
- unlimited plants
- AI disease/pest/nutrient/environment diagnosis as coverage expands
- health timeline/journal
- smart watering
- weather-aware care
- notification center
- AI assistant
- multiple languages
- family sharing
- community
- expert help
- nearby shops
- future partner/product integrations
- admin panel
- content knowledge base
- security/privacy
- AI confidence and expert escalation
- Android/iPhone release workflow

## AI SAFETY

Never:
- fabricate diagnoses or treatment.
- present low-confidence classifications as certain.
- invent pesticide dosage.
- claim the current 38-class model covers every plant/disease.

Low-confidence cases should ask for better/more photos, more information, or expert escalation.

## WORKING STYLE

The user expects the assistant to behave as the builder/technical lead.

Tone:
- friendly and direct
- casual machi style
- practical
- no unnecessary repetition
- no long lists of manual terminal commands when connected tools can make the change directly

Before ANY code/file change:
- tell the user exactly what will change
- tell the user why
- then make the change

After changes:
- report what was actually changed
- do not claim compile/test/live verification unless actually performed

## NEXT TASK

Continue from the current checkpoint.

Priority order:
1. Production mobile push delivery using a real provider (FCM/APNs) and permission/token lifecycle.
2. Family sharing foundation and role-aware RLS.
3. Account/profile UI, session restoration and logout.
4. Secure image storage/upload path.
5. Production inference integration for the existing 38-class model.
6. Camera/gallery capture.
7. Security/testing audit.
8. Activate and live-test Supabase.
9. Continue expanded datasets/models, AI assistant, experts, community, shops, admin, release preparation.

## USER'S SUPABASE SETUP TIMING

Do NOT ask Renio to create the Supabase project too early.

When the code is truly ready for activation, tell the user to create the Supabase project and provide only:
- Project URL
- Publishable/Anon client key

Never request:
- database password
- service-role key
- other private secrets in chat

## RESOURCE USAGE

When the required connector is available:
- GitHub: inspect and modify the actual repo.
- Figma: inspect the existing PlantCare blueprint and preserve it.
- Notion: use for project documentation when needed.
- Exa/web research: use for up-to-date product/reference research when needed.

If a connector is unavailable in a new chat, do not pretend it was used. Continue from the GitHub checkpoint.

## FINAL RULE

The previous chat being unavailable does NOT mean the project should restart.

The new chat should continue from the repository checkpoint and current code, using this file + PLANTCARE_BUILD_CHECKPOINT.md + PRODUCT_BLUEPRINT.md as the durable memory.