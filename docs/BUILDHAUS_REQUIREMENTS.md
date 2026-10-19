# BuildHaus — Project Requirements & Specifications

> **Version:** 1.0.0
> **Last Updated:** 2026-10-19
> **Status:** Active Development

---

## 1. Project Overview

**BuildHaus** is a personal motorcycle maintenance assistant app for Indonesian motorcyclists. It runs 100% offline on Android, stores all data locally, and uses an on-device LLM for complaint analysis.

### Core Value Proposition
> "Built for every ride. Asisten perawatan motor pribadi."

### Target Users
- Indonesian motorcycle owners (automatic/matic scooter dominant: Honda Beat, Vario, Yamaha NMAX, etc.)
- Users with limited mechanical knowledge
- Users who service at local independent mechanics (bengkel)

---

## 2. Technology Stack

### Framework & Language
| Component | Technology |
|-----------|-----------|
| Framework | Flutter 3.38.x |
| Language | Dart 3.10.x |
| Min Android | API 24 (Android 7.0) |
| Target Android | API 35 (Android 15) |
| Build Target | Debug APK (direct install, no Play Store) |

### Key Dependencies
| Package | Version | Purpose |
|---------|---------|---------|
| flutter_riverpod | ^2.6.1 | State management |
| go_router | ^14.8.1 | Declarative routing |
| drift | ^2.26.0 | SQLite ORM |
| drift_flutter | ^0.2.4 | SQLite for mobile/web |
| sqlite3_flutter_libs | ^0.5.31 | Native SQLite bindings |
| google_fonts | ^6.2.1 | Plus Jakarta Sans font |
| flutter_local_notifications | ^18.0.1 | Local reminders |
| dio | ^5.8.0 | HTTP client (future API calls) |
| uuid | ^4.5.1 | ID generation |
| intl | ^0.20.2 | Indonesian date formatting |

### Dev Dependencies
| Package | Purpose |
|---------|---------|
| drift_dev | Drift code generation |
| riverpod_generator | Riverpod code generation |
| build_runner | Code generation runner |

### Backend / Cloud
- **None.** Zero cloud dependencies.
- All data stored in local SQLite via Drift.
- AI analysis runs locally via Qwen3-0.6B GGUF model.

### Development Environment
- **OS:** Windows 10/11
- **Editor:** VS Code
- **No Android Studio required** (CLI-only build)
- **No physical Android device connected** (uses emulator for testing)

---

## 3. Database Schema

### Entity-Relationship Summary
```
MotorcycleModels (master)
    └── Motorcycles (user's bikes)
            ├── OdometerLogs
            ├── ComponentStatuses
            ├── SelfInspections / InspectionAnswers
            ├── ServiceRecords / ServiceItems
            ├── Complaints / ComplaintMessages / ComplaintAnalyses
            ├── BudgetPlans / ServiceRecommendations / RecommendationItems
            ├── LocalReminders
            └── SparepartFitments ← Spareparts (catalog)
                    └── CatalogSources

AppSettings (key-value)
AiModelInstalls (model download state)
MaintenanceRules (service intervals)
```

### Tables (22 total)
See `docs/ERD.md` for full ERD and `docs/DATA_DICTIONARY.md` for column details.

---

## 4. Feature Specifications

### 4.1 Motorcycle Management
- [x] Add/edit/delete motorcycles
- [x] Multiple motorcycles support
- [x] Primary motorcycle selection
- [x] Odometer logging (manual entry)
- [x] Odometer history tracking
- [x] Usage profile (harian_dalam_kota, jarak_jauh, campuran)
- [ ] **ISSUE:** `modelId` not persisted when adding motorcycle (form uses brand/model strings, not linked to `MotorcycleModels` table)
- [ ] Motorcycle model master data not seeded

### 4.2 Health Monitoring
- [x] Component status calculation (good/inspect/replace/unknown)
- [x] Score 0-100 per component
- [x] Safety-critical component override
- [x] Usage profile multiplier (jarak jauh = 0.8x interval)
- [x] Overall health score aggregation
- [ ] **ISSUE:** Health engine uses last service record globally, not per-component (lines 52-54 of health_engine.dart)
- [ ] **ISSUE:** `ServiceItems` table not queried — last action (replace/inspect) per component not tracked

### 4.3 Self Inspection
- [x] Step-by-step guided inspection
- [x] 11 questions covering engine, brakes, tires, electrical, CVT, exhaust
- [x] Risk level calculation (low/medium/high)
- [x] Inspection result saved to database
- [ ] **ISSUE:** CVT question always shown (not conditional on usage profile)

### 4.4 Service History
- [x] Record service with date, odometer, workshop, cost
- [x] Multiple service items per record
- [x] Actions: inspect, replace, clean, repair
- [x] Auto-update odometer from service record
- [x] Total cost aggregation

### 4.5 Complaints & AI Analysis
- [x] New complaint form (title, description, odometer)
- [x] Complaint chat thread
- [x] Rule-based response (keyword matching)
- [x] Safety keyword detection (rem, ban, fuel leak)
- [ ] **ISSUE:** AI chat is keyword matching only, not LLM
- [ ] **ISSUE:** Complaint-Motorcycle link not enforced (motorcycleId nullable)

### 4.6 AI Assistant
- [ ] Native llama.cpp bridge (requires NDK + JNI setup)
- [x] Model download manager UI (simulated)
- [ ] **ISSUE:** AI model download is simulation (no actual HTTP download + storage)
- [ ] Qwen3-0.6B GGUF model file not available

### 4.7 Budget & Service Priority
- [x] Set monthly budget amount
- [x] Static priority recommendations (hardcoded items)
- [ ] **ISSUE:** Budget engine (`BudgetEngine`) exists but is NOT called from UI — hardcoded static items displayed instead
- [ ] Budget recommendations should come from engine based on component health

### 4.8 Sparepart Catalog
- [x] Local sparepart database seeded on first run
- [x] Categories: oli, rem, busi, filter, ban, aki, rantai, cvt, shock, kopling, kelistrikan
- [x] Brand, part number, reference price
- [ ] **ISSUE:** Sparepart fitment (motorcycle-to-sparepart compatibility) not set up
- [x] Search by name, brand, category
- [ ] **ISSUE:** Motorcycle model catalog (`motorcycle_models.json`) exists but not loaded into database

### 4.9 Odometer & Mileage Prediction
- [x] Log odometer readings
- [x] Weighted average km/day calculation
- [x] Recency weighting (recent = higher weight)
- [x] Confidence level (low/medium/high)
- [x] Predict date for target odometer
- [x] Predict next service odometer from interval
- [ ] **ISSUE:** Algorithm says "3 months learning" but only requires 2 data points

### 4.10 Notifications & Reminders
- [x] Local reminder system (database schema)
- [ ] **ISSUE:** Reminder UI/screen not implemented — route `/motor/:id/reminder/add` points to `AddServiceScreen`

### 4.11 Settings & Preferences
- [ ] **ISSUE:** Dark/light mode hardcoded to dark (app.dart line 16)
- [ ] Theme preference not saved or loaded
- [ ] User name/initial stored but settings screen incomplete

### 4.12 Backup & Restore
- [ ] **ISSUE:** `/backup` route points to `BudgetScreen`
- [ ] **ISSUE:** `/restore` route points to `BudgetScreen`
- [ ] Backup/restore functionality not implemented

### 4.13 Licenses
- [ ] **ISSUE:** `/licenses` route points to `BudgetScreen`
- [ ] Third-party licenses screen not implemented

---

## 5. Navigation Routes

### Shell Routes (Bottom Navigation)
| Route | Screen |
|-------|--------|
| `/home` | HomeScreen |
| `/health` | HealthScreen |
| `/parts` | PartsCatalogScreen |
| `/history` | HistoryScreen |
| `/account` | AccountScreen |

### Modal/Overlay Routes
| Route | Screen | Status |
|-------|--------|--------|
| `/add-motor` | AddMotorcycleScreen | ✅ |
| `/motor/:id/edit` | EditMotorcycleScreen | ✅ |
| `/motor/:id/odometer` | OdometerScreen | ✅ |
| `/motor/:id/odometer-history` | OdometerHistoryScreen | ✅ |
| `/motor/:id/inspection` | SelfInspectionScreen | ✅ |
| `/motor/:id/service/add` | AddServiceScreen | ✅ |
| `/motor/:id/reminder/add` | **AddServiceScreen (WRONG)** | ❌ |
| `/motor/:id/reminders` | **AddServiceScreen (WRONG)** | ❌ |
| `/motor/:id/expense/add` | **AddServiceScreen (WRONG)** | ❌ |
| `/motor/:id/oil/add` | **AddServiceScreen (WRONG)** | ❌ |
| `/ai-chat` | AiAssistantScreen | ✅ |
| `/ai-model` | AiModelManagerScreen | ✅ |
| `/ai-recommendation` | AiAssistantScreen | ✅ |
| `/budget` | BudgetScreen | ✅ |
| `/complaints` | ComplaintsScreen | ✅ |
| `/complaints/new` | NewComplaintScreen | ✅ |
| `/complaints/:id` | ComplaintDetailScreen | ✅ |
| `/history/add` | AddServiceScreen | ✅ |
| `/backup` | **BudgetScreen (WRONG)** | ❌ |
| `/restore` | **BudgetScreen (WRONG)** | ❌ |
| `/licenses` | **BudgetScreen (WRONG)** | ❌ |

---

## 6. Routing Issues Summary

| Route | Current Target | Should Be |
|-------|---------------|-----------|
| `/motor/:id/reminder/add` | AddServiceScreen | CreateReminderScreen (not implemented) |
| `/motor/:id/reminders` | AddServiceScreen | RemindersListScreen (not implemented) |
| `/motor/:id/expense/add` | AddServiceScreen | AddExpenseScreen (not implemented) |
| `/motor/:id/oil/add` | AddServiceScreen | AddServiceScreen (but filtered to oil) |
| `/backup` | BudgetScreen | BackupScreen (not implemented) |
| `/restore` | BudgetScreen | RestoreScreen (not implemented) |
| `/licenses` | BudgetScreen | LicensesScreen (not implemented) |

---

## 7. Architecture

### Layered Architecture
```
lib/
├── app/              # App entry, theme
├── core/
│   ├── database/     # Drift tables + generated code + queries
│   ├── engines/       # Business logic (Health, Budget, Mileage)
│   ├── providers/     # Riverpod providers
│   ├── router/        # GoRouter configuration
│   ├── theme/         # Theme definitions
│   └── utils/          # Formatters, helpers
├── features/
│   ├── account/
│   ├── ai_assistant/
│   ├── budget/
│   ├── complaints/
│   ├── health/
│   ├── history/
│   ├── mileage/
│   ├── motorcycles/
│   ├── parts/
│   ├── self_inspection/
│   ├── service_history/
│   └── spareparts/
└── shared/
    └── widgets/       # AppShell, BuildHausLogo, MainScaffold
```

### State Management
- **Riverpod** for all application state
- `databaseProvider` — singleton AppDatabase instance
- `activeMotorcycleProvider` — current selected motorcycle
- `motorcyclesProvider` — stream of all motorcycles
- Feature-specific providers for async data

---

## 8. Asset Catalog

### catalogs/
| File | Contents |
|------|----------|
| `motorcycle_models.json` | Master data for motorcycle brands/models (NOT loaded into DB) |
| `spareparts.json` | Local sparepart catalog (seeded via `_seedSpareparts()`) |

### images/
| File | Contents |
|------|----------|
| *(empty)* | No images currently |

### icons/
| File | Contents |
|------|----------|
| *(empty)* | No icons currently |

### maintenance_rules/
| File | Contents |
|------|----------|
| *(empty)* | No maintenance rule files loaded |

---

## 9. Known Gaps & Technical Debt

1. **modelId not persisted** — Motorcycle form uses string brand/model, not linked to `MotorcycleModels` table
2. **Health engine partial** — Last service per component not tracked via `ServiceItems`
3. **Budget engine unused** — UI shows static strings instead of engine-generated recommendations
4. **AI is simulation** — No real LLM integration, no llama.cpp, no model download
5. **Sparepart fitment incomplete** — Compatibility data not loaded
6. **Motorcycle model master not seeded** — `motorcycle_models.json` not loaded to DB
7. **4 routes miswired** — Backup, restore, licenses, reminders → wrong screens
8. **Theme locked to dark** — No light mode, no user preference
9. **Widget test skipped** — Needs DB mocking setup
10. **`build.yaml` web builder warning** — `build_web_compilers:entrypoint` not recognized

---

## 10. Build & Deployment

### Build Commands
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter build apk --debug
```

### Output
- Debug APK: `build/app/outputs/flutter-apk/app-debug.apk`
- Web: `build/web/` (with drift sqlite3.wasm)

### Git
- Remote: `https://github.com/Abaimann/BuildHauss.git`
- Branch: `main`
- Last commit: `feat: replace motor emoji with brand name + add Plus Jakarta Sans font + drift web support + overflow fix`
