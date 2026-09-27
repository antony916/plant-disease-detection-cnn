# PlantCare AI — Master Build Checkpoint / New-Chat Handoff

Last updated: 2026-09-25
Owner: Renio
Repository: https://github.com/antony916/plant-disease-detection-cnn
Waste project repository (paused): https://github.com/antony916/ai-waste-classification

## 0. CRITICAL RESUME RULE

This file is the durable source of truth for continuing PlantCare AI after a chat reaches its message limit.

DO NOT restart the project.
DO NOT recreate architecture from zero.
Read this checkpoint first, then inspect the current GitHub files before modifying anything.
If this file and the code disagree, trust the actual code, resolve the discrepancy, and update this checkpoint.

New-chat resume command:

"Resume PlantCare AI from PLANTCARE_BUILD_CHECKPOINT.md in the GitHub repo antony916/plant-disease-detection-cnn. Do not restart the project. Read and verify the checkpoint against the current repo, then continue from NEXT TASK. Preserve all existing architecture, Figma design decisions, and completed work."

## 1. PRODUCT DIRECTION

PlantCare AI is being developed as a professional AI agriculture/home-gardening product for terrace, balcony, indoor and home gardeners.

Long-term product goals:
- Android + iPhone.
- Flutter mobile application.
- Professional AI agriculture UX.
- User accounts and persistent garden data.
- Camera and image upload diagnosis.
- Unlimited plants.
- AI diagnosis for diseases, pests, nutrient/environmental problems as coverage expands.
- Smart watering/care reminders.
- Weather-aware care recommendations.
- Plant health timeline/journal.
- AI assistant/chat.
- Family sharing.
- Community/expert support.
- Optional location.
- Localization architecture intended to support many languages.
- Future partner shops/products/monetization.
- Security, privacy, AI confidence thresholds and expert escalation.

Current baseline model does NOT provide universal plant/disease coverage. Do not claim that it does.

## 2. ARCHITECTURE

Current intended stack:
- Mobile product: Flutter.
- AI/model layer: Python + PyTorch + MobileNetV3.
- Streamlit: internal AI/model testing, research and demonstration, not the long-term consumer mobile UI.
- Cloud backend: Supabase/Postgres/Auth/Storage/notifications data.
- Figma: product UX/design blueprint.
- GitHub: source of truth for implementation.
- Notion: project documentation.
- Exa/web research: reference research when needed.

Do not upgrade the stack unnecessarily or replace working architecture without a clear reason.

## 3. AI BASELINE — PLANT DISEASE DETECTION

Repo:
https://github.com/antony916/plant-disease-detection-cnn

Dataset:
- Curated PlantVillage release.
- 38 classes.
- Current train/test split is derived from the dataset's split metadata.
- 10,948 test samples.

Model:
- MobileNetV3.
- Image size 224.
- Batch size 32.
- 10 epochs.
- Learning rate 3e-4.
- max 300 images/class in the current training configuration.
- RTX 5060 Laptop GPU used.

Final evaluation:
- Test accuracy: 98.72%
- Weighted precision: 98.75%
- Weighted recall: 98.72%
- Weighted F1: 98.72%
- Test samples: 10,948
- CUDA/RTX 5060

Outputs:
- outputs/classification_report.txt
- outputs/confusion_matrix.csv
- outputs/confusion_matrix.png
- artifacts/plant_disease_mobilenetv3.pth
- artifacts/class_names.txt

38-class coverage currently includes:
Apple (scab, black rot, cedar apple rust, healthy),
Blueberry healthy,
Cherry (powdery mildew, healthy),
Corn (gray leaf spot, common rust, northern leaf blight, healthy),
Grape (black rot, Esca, leaf blight, healthy),
Orange (Huanglongbing),
Peach (bacterial spot, healthy),
Bell pepper (bacterial spot, healthy),
Potato (early blight, late blight, healthy),
Raspberry healthy,
Soybean healthy,
Squash powdery mildew,
Strawberry (leaf scorch, healthy),
Tomato (bacterial spot, early blight, late blight, leaf mold, Septoria leaf spot, spider mites, target spot, yellow leaf curl virus, mosaic virus, healthy).

Important model limitation:
PlantVillage is relatively controlled compared with arbitrary phone photos. Additional real-world datasets may be needed later for broader garden coverage and out-of-distribution testing. Never mix external evaluation into the 98.72% figure without clearly identifying the evaluation set.

## 4. EXISTING STREAMLIT / AGRICULTURE ASSISTANCE

Plant Streamlit app already has:
- Detection.
- Disease Details.
- Treatment & Products.
- Nearby Agri Shops.
- Agricultural Experts.
- Resources.
- Expert Help.
- Upload-analysis loading sequence.
- Confidence-aware result handling.
- OSM Nominatim nearby shop support.
- Official agriculture resources including Kisan Call Centre and Tamil Nadu horticulture contacts.

Do not replace this unexpectedly.

## 5. FLUTTER MOBILE IMPLEMENTATION STATUS

Mobile root:
mobile/

Core models/services already present include:
- Plant
- Garden
- GardenTask
- DiagnosisRecord
- WeatherSnapshot
- CareRecommendation
- CareNotification
- NotificationPreferences
- NotificationCenterItem
- AuthService
- CloudAuthService
- DemoAuthService
- SupabaseAuthService
- CloudBackend
- SupabaseRuntimeConfig
- GardenRepository
- CloudGardenRepository
- DemoGardenRepository
- SupabaseGardenService
- SupabaseGardenRepository
- DiagnosisRepository
- DemoDiagnosisRepository
- SupabaseDiagnosisRepository
- DiagnosisService
- DemoDiagnosisService
- NotificationService
- NotificationCenterService
- NotificationCoordinator
- Demo notification services
- WeatherService / OpenMeteoWeatherService
- LocationService / SelectedLocationService
- CareService / RuleBasedCareService
- localization foundation
- AppServices

Implemented user-facing behavior:
- Repository-backed Garden Dashboard.
- Add Plant flow.
- Add Plant captures:
  - name
  - species
  - sunlight
  - garden location
  - soil type
  - watering interval 1–14 days
  - notes
- Plant Detail is repository-backed.
- Watering action updates last watered and next watering.
- Health timeline.
- Diagnosis history attached to plants.
- Scanner garden-plant selection.
- Scanner diagnosis integration.
- Low-confidence/expert-review preparation.
- PlantCare bottom navigation.
- Notification center.
- Notification settings.
- Event-driven notification coordinator.
- Weather-aware rule-based care recommendation foundation.
- English/Tamil/Hindi localization foundation.
- Demo backend so development can continue without credentials.

## 6. SUPABASE STATUS — VERY IMPORTANT

Supabase is PREPARED but not live.

The repo contains:
- backend/supabase/001_initial_schema.sql
- supabase_flutter dependency
- SUPABASE_URL runtime configuration
- SUPABASE_PUBLISHABLE_KEY runtime configuration
- Supabase auth service
- Supabase garden service/repository
- Supabase diagnosis repository
- runtime backend selection

Current startup behavior:
- AppServices.initialize() runs before runApp().
- No valid runtime Supabase credentials -> Demo backend.
- Valid runtime configuration -> Supabase client is initialized and auth/garden/diagnosis implementations are selected.
- Credentials are not stored in GitHub.

Current AppServices runtime selection is already implemented for:
- Auth.
- Garden repository.
- Diagnosis repository.

Supabase garden behavior already includes:
- default garden creation/loading via SupabaseGardenService.
- plant CRUD.
- fields for species, health, image URL, sunlight, soil, location, notes, watering interval, last watered, next watering.
- owner/garden scoping.
- RLS foundation.

Supabase diagnosis behavior already includes:
- saving diagnosis results.
- loading diagnosis history.
- per-plant history.
- model version marker for current mobile diagnosis service.

Current important limitation:
- No live Supabase project has been supplied/configured.
- SQL schema has not been applied to a user's live project.
- Live cloud testing has NOT been claimed.

When the code is ready for activation later, the user needs only:
- Supabase Project URL.
- Supabase Publishable/Anon client key.
Never ask the user for database password or service-role key.

## 7. CURRENT SUPABASE SCHEMA

backend/supabase/001_initial_schema.sql contains:
- gardens
- plants
- diagnoses
- garden_tasks
- family_members
- device_tokens
- indexes
- initial owner-oriented RLS policies.

Family-sharing RLS is intentionally not finalized yet.

## 8. NOTIFICATION SYSTEM STATUS

Already implemented locally/demo:
- notification center.
- read/unread state.
- mark-all-read.
- notification settings:
  - watering reminders
  - care alerts
  - diagnosis alerts
  - quiet hours.
- quiet-hour handling.
- deterministic watering notification IDs.
- notification coordinator syncing garden tasks.

Cloud persistence status after 2026-09-25 build:
- notification preferences: Supabase persistence implemented.
- notification center records: Supabase persistence implemented.
- device-token persistence: Supabase registration service implemented.
- actual OS push delivery / FCM/APNs scheduling: NOT yet live.
- the notification coordinator now works through the runtime-selected notification-center service.

Cloud implementation files:
- backend/supabase/002_notification_persistence.sql
- mobile/lib/core/services/supabase_notification_center_service.dart
- mobile/lib/core/services/supabase_notification_service.dart

The Demo notification center/service remains the fallback when Supabase is not configured.

## 9. WEATHER / LOCATION

Weather:
- Open-Meteo service.
- current temperature/humidity/rain/precipitation probability.
- graceful null/error behavior.

Location:
- selected/user-provided location abstraction.
- no silent precise GPS.
- do not infer or use precise user location.

Care recommendation rules currently include:
- overdue -> water.
- due today -> water.
- high rain probability + rain amount -> may postpone watering.
- otherwise wait/monitor.

## 10. FIGMA PRODUCT BLUEPRINT

Figma:
https://www.figma.com/design/7BCd5SwUETIzVWPYtpzjTo

Name:
PlantCare AI — Product Blueprint

Core audited screens:
1. 01 — Welcome / Login — node 4:152 — 390×844
2. 02 — Garden Dashboard — node 4:164 — 390×844
3. 03 — AI Plant Scanner — node 4:198 — 390×844
4. 04 — Diagnosis Result — node 4:222 — 390×844
5. 05 — Plant Detail — node 4:251 — 390×844
6. 06 — AI Assistant — node 4:277 — 390×844
7. 00 — Design System — node 4:299

Design system:
- Inter typography.
- 24px screen padding.
- 8pt spacing rhythm.
- 16px standard card radius.
- 20px featured radius.
- 44px minimum interactive targets.
- Light/dark semantic variables.
- Green brand system with neutral/semantic colors.
- H1 28/34 Inter Bold.
- H2 22/28 Inter Bold.
- H3 18/24 Inter Semi Bold.
- Body Medium 14/20.
- Body Small 12/18.
- Label Medium 12/16.

Current bottom navigation source of truth on authenticated screens:
- Garden
- Scan
- Library
- Profile
- four equal slots.
- active item green.
- This exact style was explicitly approved by the user.
- Scanner uses a soft centered green plus cue and no leaf illustration.
- Bottom navigation geometry is aligned across Pages 2–6.

Figma visual flow is intentionally not the current priority. The user previously only wanted the page designs checked, not a full prototype-flow rebuild. Do not start changing Figma flow unless explicitly asked.

## 11. PRODUCT UI REFERENCES

Research references used:
- Plantix official: https://plantix.net/en/
- Agrio official: https://agrio.app/

Use them as product research references, not as designs to copy.

PlantCare should retain its own:
- spacing
- typography
- green visual language
- hierarchy
- AI confidence/escalation patterns.

## 12. USER-REQUESTED PRODUCT CAPABILITIES

Important longer-term features:
- accounts.
- persistent cloud garden.
- image capture/upload.
- unlimited plants.
- AI chat assistant.
- family sharing.
- community.
- expert support.
- smart notifications.
- optional location.
- multiple languages.
- future shop/product/partner integrations.
- disease + pest + nutrient/environment coverage as datasets/models expand.
- professional AI agriculture positioning.

AI safety requirements:
- do not fabricate diagnoses/treatment.
- low confidence -> ask for better/more photos or escalate.
- do not invent pesticide dosage.
- product/treatment information should be label-based and appropriately qualified.
- do not claim unsupported plant/disease coverage.

## 13. PROJECT 2 STATUS — DO NOT RESUME UNLESS ASKED

AI-Based Waste Classification:
https://github.com/antony916/ai-waste-classification

Status:
PAUSED.

Do not switch to Project 2 unless the user explicitly asks.

## 14. NOTION / DOCUMENTATION

Waste project Notion hub:
https://app.notion.com/p/3e3affff06ed81f1af54e9c960d998ca?pvs=204

Use Notion when project documentation needs updating.

## 15. CONNECTED TOOLS / PLUGINS

The workflow has used:
- GitHub integration for source changes.
- Figma integration for editable product design.
- Notion integration for documentation.
- Exa/web research for current product/reference research.

The durable project state is in GitHub, especially this checkpoint file. A new chat does NOT need the old transcript to understand the project.

If a connected integration is available in the new chat, use it normally. If a connector is not exposed/connected there, do not pretend it was used; continue from GitHub and reconnect the integration only when necessary.

## 16. WORKING RULES FOR THE ASSISTANT

Before changing code/files:
- Tell Renio exactly what will change.
- Explain why the change is needed.
- Then make the change.

Preferences:
- Do the building through connected tools whenever possible.
- Avoid repeatedly asking Renio to run PowerShell commands.
- Keep explanations direct and practical.
- Do not restart completed work.
- Do not claim a Flutter build/test unless Flutter CLI was actually available and executed.
- Do not claim Supabase is live until a real project is configured and tested.
- Preserve the approved Figma design.
- Keep Demo mode functional while cloud integration is being prepared.
- Continue from the checkpoint rather than asking Renio to repeat old history.

## Auth/session bootstrap status

Completed in this build:
- unified application/cloud auth contracts;
- session-aware AuthGate at application startup;
- Supabase session restoration when a persisted session exists;
- Demo mode remains available when Supabase is not configured;
- existing email login UI now invokes the runtime auth service;
- Google login remains behind the mobile OAuth redirect configuration boundary and is not claimed live.

## Family-sharing foundation status

Completed in this build:
- family member role model: owner/editor/viewer;
- membership states: pending/active/removed;
- invite email/inviter metadata;
- role-aware RLS helper functions;
- member read access to shared garden data;
- owner/editor write access for plants and tasks;
- owner-only family membership management;
- pending invite records do not grant garden access;
- Supabase family-sharing service boundary;
- shared-garden lookup support for active family members;
- plant writes preserve the garden owner's ownership.

## 17. NEXT TASK — CONTINUE HERE

Cloud Garden Persistence is now explicitly wired and documented:
- default garden loading/creation is exposed through `GardenRepository.getGarden()`;
- Supabase resolves the authenticated user's owned garden first, then an active shared garden, then creates `My Garden` when needed;
- Demo mode exposes a stable `demo-garden` for `demo-user`;
- Supabase plant CRUD is scoped to the resolved garden for reads, updates and deletes;
- Add Plant already writes through the runtime-selected garden repository;
- Dashboard now loads the resolved garden and displays its cloud/demo garden name;
- Plant Detail exposes delete and existing watering update through the same repository;
- Demo mode remains the fallback when Supabase is not configured.

Cloud Garden Persistence does not require a live Supabase project yet. Live activation still waits for real project credentials and schema application.

NEXT TASK: USER UPLOAD / ACTIVATION GATE — provide the model artifact and Flutter/Firebase native configuration listed in PLANTCARE_ACTIVATION_UPLOAD_CHECKLIST.md. After those assets are available, continue with deployment, live cloud wiring, end-to-end testing, and fixes.

Completed in this build session:
1. Supabase notification preference persistence.
2. Supabase notification-center persistence.
3. Device-token persistence service.
4. Runtime Demo/Supabase notification service switching.
5. Demo fallback preserved.

Remaining sequence:
1. Connect an actual mobile push provider (FCM/APNs) and OS scheduling/permission handling. [CODE PREPARED 2026-09-25: Firebase Messaging provider and runtime switch; native Firebase/APNs configuration still required.]
2. Build family-sharing UI: invite/accept, member list, role management and leave/remove flows. [UI + cloud RLS hardening prepared 2026-09-25; secure invite acceptance remains part of live activation/testing.]
3. Build account/profile UI and logout UX on top of the session foundation already implemented. [COMPLETED 2026-09-25: Profile screen, account display, Family Sharing/Notification Settings entry points, and sign-out flow.]
4. Add secure image storage and production image-upload path. [COMPLETED 2026-09-25: private storage boundary, gallery/camera capture, cloud image upload, and diagnosis image-reference separation.]
5. Connect the evaluated PlantVillage model through a production inference service while preserving the current 38-class baseline and confidence safeguards. [CODE PREPARED 2026-09-25: FastAPI inference service, Dockerfile, mobile remote inference client, configurable endpoint; deployment waits for the model artifact.]
6. Add real camera/gallery capture. [COMPLETED 2026-09-25 in Dart layer; native Android/iOS project configuration is still required for device testing.]
7. Security/testing audit.
8. Only then activate and live-test a real Supabase project.
9. Continue expanded datasets/models, community, experts, shops and admin panel according to PRODUCT_BLUEPRINT.md.

Do not ask Renio to create the Supabase project yet unless the code is actually ready for activation.

## 18. NEW CHAT RECOVERY INSTRUCTION

In the new conversation, send exactly:

Resume PlantCare AI from PLANTCARE_BUILD_CHECKPOINT.md in the GitHub repo antony916/plant-disease-detection-cnn. Read and verify the checkpoint against the current repo. Do not restart, do not make me repeat the project history, and do not switch to Project 2. Continue from NEXT TASK — cloud notification persistence. Before any code/file change, tell me exactly what you will change and why.

Then continue building.


## 19. CHAT-CONTINUITY CONTRACT

The user wants the same project to continue across chats without restarting. The conversation transcript is NOT the source of truth. GitHub is.

When a new chat begins:
- Read PLANTCARE_NEW_CHAT_RESUME.md first.
- Read PLANTCARE_BUILD_CHECKPOINT.md second.
- Verify the stated status against actual repository files/commits before changing anything.
- Read PRODUCT_BLUEPRINT.md for product direction.
- Do not switch to Project 2.
- Do not ask the user to repeat project history that is already documented.
- Do not replace the approved Figma design.
- Use connected GitHub/Figma/Notion/research resources when available and useful.
- Before every code/file change, tell Renio exactly what will change and why.
- Continue building rather than merely explaining what could be built.
- If a resource/connector is unavailable in the new chat, continue from GitHub without pretending it was accessed.
- Never claim cloud/live/push/build/test functionality is live unless it has actually been configured and verified.

## 20. APPROVED CONVERSATIONAL STYLE

Use the established casual style: direct, practical, concise, friendly, and naturally using "machi". Keep continuity with the existing PlantCare terminology. Avoid making Renio repeat commands unnecessarily. The assistant should act as the builder/technical lead, using available tools to make the changes rather than handing the user long manual setup instructions.

## 21. KEY RESOURCES

GitHub repo:
https://github.com/antony916/plant-disease-detection-cnn

Figma:
https://www.figma.com/design/7BCd5SwUETIzVWPYtpzjTo
Name: PlantCare AI — Product Blueprint

Notion/project documentation:
Use the connected Notion workspace and existing PlantCare/project pages when available. The waste-project Notion page is not the PlantCare source of truth.

Reference research:
- Plantix: https://plantix.net/en/
- Agrio: https://agrio.app/

The Figma and reference products are inputs to the product design; PlantCare's own design system remains the source of truth for implementation.

## 22. INFERENCE API HARDENING — 2026-09-27

Completed:
- Added strict expected-class-count validation to `api/main.py` (default 38, configurable through `PLANTCARE_EXPECTED_CLASS_COUNT`).
- Added duplicate class-name validation.
- Added explicit MobileNetV3 state-dict compatibility validation before the model is exposed.
- Added normal `io` import for image decoding.
- Health endpoint now returns HTTP 503 when the model is not ready.

Commit:
- `d8efb151014403eab9008d424882fedbc747b992` — Harden PlantCare inference artifact validation.

This does NOT mean the inference service is live. The actual evaluated `.pth` model artifact and deployment environment are still required before live inference testing.

## 23. MOBILE INFERENCE / DIAGNOSIS HARDENING — 2026-09-27

Completed:
- Diagnosis result contract now carries `modelVersion`, with a safe `unknown` default for older/demo callers.
- Remote inference client now validates the endpoint URI before sending.
- Remote inference requests have a 30-second timeout.
- Network timeout and socket failures produce actionable service errors.
- Remote inference responses must be non-empty, valid JSON objects.
- Required diagnosis fields (`plant_name`, `condition`, `explanation`) are validated.
- Confidence must be finite and within 0..1.
- Low-confidence results always remain marked for expert review.
- Server `model_version` is required and retained in the diagnosis result.
- Supabase diagnosis persistence now stores the actual diagnosis `modelVersion` instead of the previous hardcoded demo value.

Commits:
- `ab637b19a4a7344075b16bca723e7c08f9b64fe8` — Track diagnosis model version in result contract.
- `038e2683b326a9181ff89d2a352192ae8fe69ce5` — Harden mobile remote inference response handling.
- `3139a4025605353012464b7550c3361ef579df40` — Persist diagnosis inference model version.

Verification status:
- Repository changes were committed through GitHub.
- Flutter CLI/device tests were not executed in this environment.
- Live inference, Supabase, FCM/APNs, and production model deployment remain unverified.

## 24. SUPABASE DIAGNOSIS OWNERSHIP HARDENING — 2026-09-27

Completed:
- Added `backend/supabase/005_diagnosis_ownership_hardening.sql`.
- Diagnosis creation now requires the referenced plant to belong to the signed-in user, unless the write is through an authorized shared-garden editor path.
- Diagnosis updates enforce the same plant ownership/shared-garden relationship.
- Diagnosis reads remain available to owners and active shared-garden members.
- Diagnosis deletes are restricted to the diagnosis owner or authorized shared-garden editor path.
- Migration explicitly drops/recreates affected policies so it can be applied after the existing family-sharing migration without duplicate-policy failures.

Commit:
- `0b20200dd5e734d6261850e2e35a7922bb5f08bf` — Make diagnosis RLS migration replayable.

Verification status:
- SQL was reviewed against the existing 001/004 policy structure.
- Live Supabase execution has not been performed because no project is configured.

## 25. SHARED DIAGNOSIS ACCESS CONSISTENCY — 2026-09-27

Completed:
- Supabase diagnosis history no longer filters only by `owner_id`; RLS now determines whether the signed-in user can see owner/shared-garden diagnoses.
- Shared-garden diagnosis writes now resolve the referenced plant's `owner_id` before insertion.
- This keeps family-editor diagnosis creation compatible with the hardened diagnosis RLS without weakening ownership controls.
- Plant ownership is verified before a diagnosis is inserted.

Commit:
- `d3099980cf4d432662bd17dd0c73ce2c5a5c5eca` — Preserve garden owner on shared diagnosis writes.

Verification status:
- Repository logic was reviewed against the current family-sharing RLS.
- Flutter compilation/device tests and live Supabase execution remain unverified.

## 26. CONTINUOUS QUALITY / PROVENANCE FOUNDATION — 2026-09-27

Completed:
- Added `.github/workflows/plantcare-ci.yml`.
- CI runs Flutter dependency installation, `flutter analyze`, and `flutter test` on pushes/PRs to `main`.
- CI runs Python bytecode compilation checks for `api`, `src`, and `config.py`.
- Added the first Flutter unit tests at `mobile/test/core/services/diagnosis_service_test.dart` for the diagnosis result/model-version contract.
- The project now has an automated quality gate rather than relying only on manual inspection.

AI-authorship/provenance approach:
- Do not attempt to manipulate AI-detector scores or use “humanizer”/evasion techniques.
- Build authenticity through original product decisions, real tests, traceable Git history, architecture documentation, security review, reproducible CI, and human verification.
- Current research indicates AI-generated source-code detectors have poor practical performance/generalizability, while GitHub recommends testing, static analysis, security review, dependency scrutiny, and human oversight for AI-assisted code.
- Release-stage artifact provenance/attestations can be added later.

Commits:
- `5363053ec77994b5c70d4684193a1673906fda16` — Add diagnosis contract unit tests.
- `daf9a5b18b8ff8c6dab17170647c4bc674706cdf` — Add PlantCare Flutter and Python CI.

Verification status:
- CI configuration and test source were committed through GitHub.
- GitHub Actions execution has not been independently verified from this environment yet.
- No claim is made that Flutter analyze/test currently passes until an actual workflow run reports success.

## 27. CI QUALITY GATE HARDENING — 2026-09-27

Completed:
- Flutter CI now checks Dart formatting before analysis and tests.
- Existing Flutter analysis/test and Python syntax checks remain enabled.
- Commit: `f66b78d1429f18e1caf52eb7cf18c454c5e95562`.

Verification:
- GitHub reports no status result yet for this commit from the connected status endpoint.
- CI is therefore not being represented as passed.

## 28. Family Invitation Acceptance — 2026-09-27

Completed:
- Added pending-invitation discovery to the family-sharing service contract.
- Added secure invite acceptance for Supabase accounts.
- Added RLS allowing only the authenticated account matching `invite_email` to claim its own pending invitation.
- Acceptance sets `user_id = auth.uid()` and `status = active`.
- Added a mobile invitation inbox and Profile entry point.
- Demo runtime supports the same invitation flow.
- Commits: `1434a647`, `d8bde474`, `a6a923f8`, `9eeafad3`, `94878adf`, `63cc29dd`.

Verification:
- Database policy is scoped to pending rows and the authenticated email.
- Existing owner/editor garden permissions remain unchanged.
- Full Flutter/CI execution is still not verified from this environment.

## 29. Shared Garden Permission Consistency — 2026-09-27

Completed:
- Fixed cloud task loading so shared garden members see tasks by garden/plant rather than only by task owner.
- Preserved database ownership semantics: garden tasks remain owned by the garden owner while editor/viewer access is granted through garden membership RLS.
- Hardened family invitation acceptance:
  - Removed the broad invitee UPDATE policy.
  - Added `accept_family_invitation(uuid)` SECURITY DEFINER RPC.
  - RPC verifies authenticated email matches the pending invitation.
  - RPC changes only the membership's `user_id` and `status`.
  - Function execution is revoked from public and granted only to authenticated users.
- Mobile acceptance now calls the RPC instead of directly updating membership rows.
- Commits: `c03f8ad0`, `4fbee183`, `9df226af`.

Verification:
- Shared task visibility now matches the RLS access model.
- Invitation role cannot be changed as part of the claim operation.
- Live Supabase execution remains unverified until a project is connected.

## 30. Release-Readiness Documentation and Security Automation — 2026-09-27

Completed:
- Replaced stale project-status language with the current PlantCare AI product state.
- Documented explicit activation blockers rather than implying cloud/native features are live.
- Added Dependabot coverage for root Python dependencies, inference API Python dependencies, Flutter/Dart dependencies, and GitHub Actions.
- Added scheduled/on-change Python CodeQL scanning.
- Commits: `3461a3bf`, `6a2e83be`, `8316ac5b`.

Verification:
- Repository documentation now distinguishes the original 38-class CNN benchmark from the larger PlantCare product.
- Security automation is configured in GitHub but its first runs are not yet verified from this environment.

## 31. Multi-track Reliability Hardening — 2026-09-27

Completed:
- Removed the obsolete duplicate `003_family_sharing_rls.sql` migration so the Supabase migration sequence is unambiguous.
- Hardened cloud notification `markRead` with explicit current-user scoping in the client query.
- Added notification quiet-hour boundary unit tests.
- Added remote inference contract tests for:
  - forced expert review below the confidence threshold,
  - missing model-version rejection,
  - out-of-range confidence rejection.
- Commits: `0b49f983`, `ba02f13a`, `a1bb6a72`, `e71f61f3`.

Verification:
- Current Supabase migration tree is now numbered 001 through 006 without duplicate numeric prefixes.
- Latest GitHub status API currently reports no commit status entries for the test commit, so CI execution remains unverified until GitHub publishes a run result.

## 32. Family Sharing Reliability Pass — 2026-09-27

Completed:
- Added family-sharing service regression tests covering:
  - pending invitation creation/discovery,
  - invitation acceptance preserving the same membership and activating it,
  - role changes preserving membership identity, garden identity, and active status.
- Added mobile-side invitation input validation:
  - trims and lowercases the invitation email,
  - rejects blank invitation addresses before the Supabase insert.
- No restrictive email-format regex was added; account identity remains governed by Supabase Auth.

Commits:
- `4ae841c2` — Add family invitation contract tests.
- `f2274187` — Validate family invitation email input.

Verification:
- Test source is committed.
- GitHub status endpoint has not yet exposed a CI result for the latest commits, so Flutter execution remains unverified in this environment.
