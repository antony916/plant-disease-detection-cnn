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

## Design
Figma blueprint: https://www.figma.com/design/7BCd5SwUETIzVWPYtpzjTo

Core screens:
1. Welcome/Login
2. Garden Dashboard
3. AI Plant Scanner
4. Diagnosis Result
5. Plant Detail
6. AI Assistant

The design system should be extended before large-scale UI implementation so components remain reusable across Android and iPhone.

## Delivery phases
1. Product/design foundation
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

## Versioning
GitHub is the source of truth. Future feature changes should be delivered as versioned changes (for example v1.1, v1.2). User-facing mobile releases go through the Android/iOS stores; knowledge-base and content changes should be designed to be updateable without retraining the model when possible.
