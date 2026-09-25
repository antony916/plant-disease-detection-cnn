# PlantCare AI — Product Blueprint

## Product direction
PlantCare AI is a professional AI agriculture platform for terrace and home gardeners. The consumer experience is designed for Android and iPhone, with cloud accounts, persistent gardens, AI plant analysis, reminders, knowledge, community, experts and future shop partnerships.

## Core user features
- Google and email/password authentication
- Garden dashboard
- Unlimited plant profiles
- Camera and photo upload
- Multiple-photo AI diagnosis
- Disease, pest, nutrient-deficiency, watering and environmental-problem workflows
- Plant health timeline and journal
- Smart watering reminders using plant data, recent activity and optional location/weather context
- Plant, disease, pest and treatment libraries
- AI chat assistant
- Expert escalation when AI confidence is insufficient
- Family garden sharing
- Community
- Nearby agricultural/garden shops
- Resources and expert contacts
- Push notification center
- Multi-language localization architecture

## AI safety
- Current PlantVillage model remains a 38-class classifier.
- Do not claim the current model covers every plant or disease.
- Low-confidence or out-of-distribution cases should be routed to clarification, additional photos or expert help.
- Treatment content must be knowledge-base driven and locally appropriate.
- The AI must not invent pesticide dosage or present a probabilistic image classification as certainty.

## Architecture
Mobile client -> authenticated cloud backend -> user/garden data -> AI inference services -> plant knowledge base/rules -> notifications/weather -> expert/community modules.

The existing Streamlit application remains the working AI prototype and model evaluation interface while the production mobile experience is developed.

## Admin architecture
The Admin Panel is a separate role-protected interface. Normal users do not see or access it.

Admins can manage:
- plants
- diseases
- pests
- nutrient deficiencies
- treatments and prevention guidance
- care instructions
- resources
- notification rules
- shop/product records
- expert records
- community moderation
- supported translations
- AI knowledge entries

Backend authorization must enforce admin access; hiding a UI button is not considered security.

## Design system
Figma file: https://www.figma.com/design/7BCd5SwUETIzVWPYtpzjTo

Core screens now include:
1. Welcome/Login
2. Garden Dashboard
3. AI Plant Scanner
4. Diagnosis Result
5. Plant Detail
6. AI Assistant

The Figma foundation now defines:
- PlantCare semantic color tokens with light/dark modes
- Primitive color tokens
- reusable typography styles
- elevation styles
- consistent 24px screen padding
- 8pt spacing rhythm
- 16px standard card radius and 20px featured-card radius
- 44px minimum interactive controls
- consistent bottom navigation for authenticated primary screens
- loading, empty, error and offline state patterns
- low-confidence AI escalation pattern
- localization-safe copy/layout rules

The design is intentionally a product blueprint rather than a giant static prototype. Reusable components and states are being established before the full production implementation.

## Delivery phases
1. Product/design foundation — in progress
2. Production mobile shell and authentication
3. Garden/cloud data
4. AI scanner and current 38-class model integration
5. Knowledge base and treatment workflows
6. Smart reminders and notifications
7. AI assistant
8. Family sharing/community
9. Experts and local shops
10. Admin panel
11. Expanded datasets/models and real-world evaluation
12. Store release, monitoring and iterative updates

## Current implementation boundary
- Streamlit remains the current model/demo interface.
- Production consumer UI is planned as Flutter for Android and iPhone.
- Backend services are designed around authenticated cloud data, storage, notifications and role-based access.
- The current 38-class model can be integrated first while broader plant/pest/nutrient coverage is developed separately.
- Content/knowledge and treatment rules should be server-managed so they can be updated without requiring a model retrain whenever possible.

## Versioning
GitHub is the source of truth. Future feature changes should be delivered as versioned changes (for example v1.1, v1.2). User-facing mobile releases go through the Android/iOS stores; knowledge-base and content changes should be designed to be updateable without retraining the model when possible.

## Implementation progress — mobile foundation

The production client foundation now lives under `mobile/`.

Implemented:
- reusable PlantCare theme tokens matching the Figma design system;
- six core screen routes;
- authentication, garden, diagnosis and notification service boundaries;
- localization boundary with English/Tamil/Hindi starter resources;
- cloud-ready Postgres/Supabase schema under `backend/supabase/`;
- RLS ownership policies for the initial personal-garden data model;
- demo service implementations that keep the UI runnable before cloud credentials are connected.

The current service implementations are deliberately development-only. They do not represent production authentication, push notifications, or cloud persistence.

### Next implementation sequence

1. Connect the authenticated cloud backend.
2. Add secure image storage and diagnosis history.
3. Connect the evaluated PlantVillage model through a production inference service.
4. Add real camera/gallery capture.
5. Add push notification registration and smart watering scheduling.
6. Add family sharing and role-aware RLS.
7. Expand the validated AI coverage with additional real-world datasets.
8. Add expert/community/shop modules.
9. Release Android/iOS builds and establish versioned update workflow.

