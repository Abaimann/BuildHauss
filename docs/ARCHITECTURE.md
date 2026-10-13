# BuildHaus Architecture

## Overview

BuildHaus is an offline-first Android motorcycle maintenance assistant built with Flutter 3.38.5 / Dart 3.10.4.

## Technology Stack

- **Framework**: Flutter 3.38.5, Dart 3.10.4
- **State Management**: flutter_riverpod
- **Navigation**: go_router
- **Database**: SQLite + Drift (drift_flutter)
- **Networking**: dio
- **Notifications**: flutter_local_notifications
- **Storage**: path_provider, shared_preferences

## Project Structure

```
lib/
├── main.dart                    # Entry point
├── app/
│   ├── app.dart                # MaterialApp with theme/router
│   ├── router/                 # go_router configuration
│   └── theme/                  # BuildHausTheme (dark/light)
├── core/
│   ├── database/               # Drift database, tables, DAOs
│   │   ├── app_database.dart   # Main DB class + all queries
│   │   └── tables/             # 22 table definitions
│   ├── providers/              # Riverpod providers
│   ├── engines/                # Domain logic engines
│   │   ├── mileage_predictor.dart   # Odometer prediction
│   │   ├── health_engine.dart       # Component health calculation
│   │   └── budget_engine.dart        # Budget prioritization
│   ├── router/                 # Navigation
│   ├── theme/                 # Design tokens from prototype
│   └── utils/                 # Formatters, helpers
├── features/                   # Feature-based modules
│   ├── home/
│   ├── motorcycles/
│   ├── health/
│   ├── spareparts/
│   ├── budget/
│   ├── complaints/
│   ├── service_history/
│   ├── self_inspection/
│   ├── ai_assistant/
│   ├── mileage/
│   └── account/
├── shared/
│   └── widgets/               # Shared components (MainScaffold)
└── shared/                     # Shared models, constants
```

## Architecture Pattern

Feature-based + Clean Architecture layers:
- **Presentation**: Screens, Widgets, Providers (Riverpod)
- **Domain**: Engines (business logic, testable without Flutter)
- **Data**: Database tables, DAOs, repositories via Drift

## Navigation

Shell route with bottom navigation:
- Beranda (Home)
- Sehat (Health)
- Sparepart (Parts)
- Riwayat (History)
- Akun (Account)

Other screens accessed via `go_router` push/pop navigation.

## State Management

Riverpod providers for:
- Active motorcycle selection
- Motorcycles list (stream)
- Odometer logs
- Component statuses
- Service records
- Complaints
- AI model status
- Theme preference

## Database Schema

22 SQLite tables via Drift, organized in 3 groups:
1. **Motorcycle & Health** (13 tables): motorcycles, odometer_logs, component_types, maintenance_rules, component_statuses, service_records, service_items, self_inspections, inspection_answers, complaints, complaint_messages, complaint_analyses
2. **Catalog & Budget** (7 tables): catalog_sources, spareparts, sparepart_fitments, budget_plans, service_recommendations, recommendation_items, local_reminders
3. **AI & Settings** (2 tables): ai_model_installs, app_settings

## AI / Offline LLM Strategy

- Initial release: Rule-based complaint analyzer (deterministic)
- Phase 2: Qwen3 0.6B GGUF via llama.cpp Android (JNI bridge)
- Model manager with download progress, checksum verification, SHA-256
- All data stays on-device; no cloud API calls

## Design Tokens

Based on prototype CSS:
- Dark mode default: `--bg #101010`, `--surface #1b1b1b`, `--ink #f0f0f0`, etc.
- Status colors: ok `#3da96e`, warn `#c9913a`, danger `#c0544a`
- Light mode available via theme toggle
