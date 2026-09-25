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

This first mobile commit contains the reusable application shell and screen architecture derived from the PlantCare Figma design system.

The existing Streamlit application and the trained 38-class PlantVillage MobileNetV3 model remain unchanged.

The diagnosis layer is intentionally abstracted behind a repository/service boundary. The production inference transport can later be connected to the existing Python model service or a converted mobile model without changing the screen architecture.

## Planned backend boundary

The UI should not depend directly on a specific cloud vendor. Authentication, storage, database, notifications and realtime features will be exposed through application services/repositories.

## Run

Install Flutter, then from this directory:

    flutter pub get
    flutter run

The repository currently does not claim that Flutter has been locally compiled or deployed.
