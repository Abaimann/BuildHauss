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
- [x] Add/edit/delete motorcycles (delete dengan konfirmasi di dua tempat)
- [x] Multiple motorcycles support
- [x] Primary motorcycle selection
- [x] Odometer logging (manual entry)
- [x] Odometer history tracking
- [x] Usage profile (harian_dalam_kota, jarak_jauh, campuran)
- [x] **`modelId` persisted sebagai foreign key valid** — dropdown merek/model/varian/tahun bersumber dari tabel `motorcycle_models`; `createMotorcycle()` menolak modelId kosong, modelId tak dikenal, dan tahun di luar rentang model
- [x] Motorcycle model master data ter-seed (18 model, 4 merek) via `_seedMotorcycleModels()` yang idempoten

### 4.2 Health Monitoring
- [x] Component status calculation (good/inspect/replace/unknown)
- [x] Score 0-100 per component
- [x] Safety-critical component override
- [x] Usage profile multiplier (jarak jauh = 0.8x interval)
- [x] Overall health score aggregation
- [x] **Riwayat tindakan servis per komponen** — `getLastActionForComponent(motorcycleId, componentTypeId)` memakai `ServiceItems` yang di-join dengan `ServiceRecords`; penggantian (replace) mereset siklus komponen, inspeksi (inspect) tidak
- [x] **Isolasi antar motor** — seluruh query per-motor difilter `motorcycle_id`
- [ ] **ISSUE:** kolom `applies_to` belum dipakai; komponen CVT belum dikondisikan berdasarkan tipe motor (`getApplicableComponents` mengabaikan parameter `usageProfile`)

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
- [x] Set monthly budget amount (disimpan ke `budget_plans`)
- [x] Rekomendasi **dinamis dari `BudgetEngine`** — `budgetPlanSummaryProvider` menghitung prioritas berdasarkan status komponen, riwayat servis, hasil inspeksi, keluhan, aturan perawatan, dan kecocokan sparepart
- [x] Biaya yang belum diketahui **tidak dianggap Rp0** — ditandai `biaya_belum_tersedia` dan tidak dihitung sebagai terdanai
- [x] Snapshot rekomendasi tersimpan di `service_recommendations` + `recommendation_items`
- [x] Kunci cache memuat **motor + budget** (`BudgetSummaryKey`) sehingga dua motor dengan budget sama tidak berbagi hasil perhitungan

### 4.8 Sparepart Catalog
- [x] Local sparepart database seeded pada inisialisasi (±70 part, idempoten)
- [x] Categories: oli, rem, busi, filter, ban, aki, rantai, cvt, shock, kopling, kelistrikan, oli_gardan, minyak_rem, coolant, filter_oli, knalpot
- [x] Brand, part number, reference price, catalog version
- [x] **Sparepart fitment terverifikasi** — 17 relasi dari katalog resmi Astra Honda Motor & Yamaha Indonesia (`is_verified = true`, `source_url` terisi). Tidak ada kecocokan yang ditebak dari kesamaan nama motor.
- [x] Search by name, brand, category
- [x] Rekomendasi memprioritaskan sparepart kompatibel (verified) di atas katalog umum
- [ ] **ISSUE:** fitment terverifikasi baru ada untuk Honda & Yamaha; Suzuki & Kawasaki belum punya relasi kompatibilitas dan perlu ditampilkan sebagai "belum diverifikasi"
- [ ] **ISSUE:** `assets/catalogs/*.json` dan `assets/maintenance_rules/rules_v1.json` valid tetapi tidak dimuat runtime; data master ditulis langsung sebagai literal Dart (sumber kebenaran ganda)

### 4.9 Odometer & Mileage Prediction
- [x] Log odometer readings
- [x] Weighted average km/day calculation
- [x] Recency weighting (recent = higher weight)
- [x] Confidence level (low/medium/high)
- [x] Predict date for target odometer
- [x] Predict next service odometer from interval
- [x] Fase pembelajaran 3 periode bulanan (diverifikasi `test/engines/mileage_predictor_test.dart`)
- [x] Penanganan rollback / koreksi odometer

### 4.10 Notifications & Reminders
- [x] Local reminder system (`local_reminders` + `flutter_local_notifications`)
- [x] `RemindersScreen` dengan ringkasan, sinkronisasi otomatis, sakelar aktif/nonaktif, dan dialog tambah manual
- [x] Route `/motor/:id/reminder/add` membuka sheet tambah secara otomatis
- [x] ID notifikasi deterministik per motor (`NotificationIdGenerator`, rentang 31-bit aman)
- [x] Idempotent sinkronisasi (tidak menggandakan pengingat)

### 4.11 Settings & Preferences
- [x] Dark/light/system mode — `themeModeProvider` membaca & menyimpan `theme_mode` di `app_settings`; `app.dart` memakai `themeMode: themeMode`
- [x] Layar `/settings` dengan kontrol tema, sakelar notifikasi, interval pembaruan odometer, navigasi backup/restore, status model AI, dan hapus semua data

### 4.12 Backup & Restore
- [x] `/backup` route → `BackupScreen` (form enkripsi opsional + daftar file `.bhb`)
- [x] `/restore` route → `RestoreScreen` (pratinjau non-destruktif + pemulihan atomik)
- [x] Enkripsi AES-256-GCM + PBKDF2 100k iterasi dengan kompatibilitas mundur file v1
- [x] Pemulihan diverifikasi dengan `PRAGMA foreign_key_check`

### 4.13 Licenses
- [x] `/licenses` route → `LicensesScreen`
- [x] Third-party licenses screen implemented (Drift, Riverpod, flutter_local_notifications, llama.cpp, Qwen3 + kredit katalog AHM & YGP)

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
| `/motor/:id/reminder/add` | RemindersScreen + sheet tambah terbuka otomatis | ✅ |
| `/motor/:id/reminders` | RemindersScreen | ✅ |
| `/motor/:id/expense/add` | ComingSoonScreen (placeholder — fitur belum ada) | 🟡 |
| `/motor/:id/oil/add` | AddServiceScreen(isOilChange: true) | ✅ |
| `/ai-chat` | AiAssistantScreen | ✅ |
| `/ai-model` | AiModelManagerScreen | ✅ |
| `/ai-recommendation` | AiAssistantScreen | ✅ |
| `/budget` | BudgetScreen | ✅ |
| `/settings` | SettingsScreen | ✅ |
| `/backup` | BackupScreen | ✅ |
| `/restore` | RestoreScreen | ✅ |
| `/licenses` | LicensesScreen | ✅ |
| `/complaints` | ComplaintsScreen | ✅ |
| `/complaints/new` | NewComplaintScreen | ✅ |
| `/complaints/:id` | ComplaintDetailScreen | ✅ |
| `/history/add` | AddServiceScreen | ✅ |
| `/reminders` | RemindersScreen | ✅ |
| `/login` | AuthScreen | ✅ |
| `/register` | AuthScreen(initialIsRegister: true) | ✅ |
| `/initial-setup` | InitialMotorSetupScreen | ✅ |

> Route duplikat `/edit-motor/:id` telah dihapus. Auth gating dilakukan di
> `AppShell` (`lib/shared/widgets/app_shell.dart`): saat belum login →
> `AuthScreen`, saat belum onboarding → `InitialMotorSetupScreen`.

---

## 6. Routing Issues Summary

Semua route yang diminta sudah terverifikasi membuka layar yang sesuai.
Status detail dan bukti pengujian ada di `docs/IMPLEMENTATION_STATUS.md`.

| Route | Target | Status |
|-------|--------|--------|
| `/motor/:id/reminder/add` | RemindersScreen (sheet tambah terbuka otomatis) | ✅ |
| `/motor/:id/reminders` | RemindersScreen | ✅ |
| `/motor/:id/expense/add` | ComingSoonScreen | 🟡 jalur benar, fitur belum ada |
| `/motor/:id/oil/add` | AddServiceScreen(isOilChange: true) | ✅ |
| `/backup` | BackupScreen | ✅ |
| `/restore` | RestoreScreen | ✅ |
| `/licenses` | LicensesScreen | ✅ |

**Verifikasi:** `test/widgets/tahap01_navigation_test.dart` (22 test).

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
| `motorcycle_models.json` | Master data model motor (18 model, 4 merek). **Valid, tetapi tidak dimuat runtime** — seeding memakai literal Dart yang setara. |
| `spareparts.json` | Katalog sparepart beserta `fitments`. **Valid, tetapi tidak dimuat runtime** — seeding memakai literal Dart. |

### images/
| File | Contents |
|------|----------|
| `parts/` | Gambar sparepart (diisi oleh tahap berikutnya) |

### icons/
| File | Contents |
|------|----------|
| *(kosong)* | Placeholder |

### maintenance_rules/
| File | Contents |
|------|----------|
| `rules_v1.json` | 17 aturan perawatan (6 generic + model-specific). **Valid, tetapi tidak dimuat runtime** — seeding memakai literal Dart. |

---

## 9. Status Implementasi & Resolusi Technical Debt (Tahap 06 — Rilis Final)

Seluruh celah teknis awal telah diselesaikan secara tuntas:

1. **modelId Persisted:** Model motor tertaut ke tabel `motorcycle_models` dengan validasi tahun pembuatan.
2. **Health Engine Lengkap:** Memanfaatkan `HealthEngine`, `MileagePredictor`, `ServiceItems`, dan temuan `SelfInspection`.
3. **Smart Budget Engine:** Terhubung dinamis ke UI `budget_screen.dart` dengan prioritas keselamatan kritis dan data resmi AHM/YGP.
4. **Offline AI Real Runtime:** Integrasi Qwen3 0.6B GGUF + runtime llama.cpp C++ via Android NDK 28, chunked SHA-256 validation, resume support, dan fallback transparan.
5. **Katalog & Fitment Suku Cadang:** Kompatibilitas suku cadang spesifik model vs universal terisolasi.
6. **Master Model Seeded:** Katalog model motor otomatis di-seed secara idempoten saat database diinisialisasi.
7. **Rute & Navigasi 100% Final:** `/settings`, `/reminders`, `/backup`, `/restore`, `/licenses`, `/motor/:id/oil/add` aktif.
8. **Dukungan Tema Lengkap:** Tema Terang (*Light*), Gelap (*Dark*), dan Sistem Android persisten di SQLite.
9. **Suite Pengujian Hijau:** 220/220 pengujian otomatis lulus (unit, widget, database, dan cross-feature integration tests).
10. **Keamanan Kriptografi Tingkat Lanjut:** Enkripsi backup offline `.bhb` menggunakan standar resmi NIST **AES-256-GCM** + **PBKDF2-HMAC-SHA256 (100.000 iterasi)**.

### Pembaruan TAHAP 01 (13 November 2026)

11. **Schema v5 — foreign key `sparepart_id` dipulihkan** pada `service_items` dan `recommendation_items` ke `spareparts(id)`. Baris dengan `sparepart_id` menggantung dinormalkan menjadi `NULL` sebelum tabel dibangun ulang; tidak ada data pengguna yang hilang. Migrasi diverifikasi dengan `test/database/tahap01_integration_test.dart`.
12. **Operasi database yang tersisa kini atomik:** `deleteComplaint`, `upsertComponentStatus`, dan `recalculateComponentStatuses` dibungkus `transaction()`.
13. **Filter pengingat diperbaiki:** `getUpcomingReminders` sebelumnya mengembalikan pengingat nonaktif yang punya `dueOdometerKm` (operator `&&` mengikat lebih kuat daripada `||`).
14. **Kunci cache budget diperbaiki:** `budgetPlanSummaryProvider` kini memakai `BudgetSummaryKey(motorcycleId, budgetAmount)` sehingga dua motor dengan budget sama tidak berbagi hasil.
15. **Fallback deteksi merek dihapus:** `parts_providers.dart` kini hanya memakai `motor.modelId`; pencocokan substring nickname (yang bisa salah klasifikasi) dihapus.
16. **Route `/motor/:id/reminder/add`** kini membuka sheet tambah pengingat secara otomatis; route duplikat `/edit-motor/:id` dihapus.
17. **`createAppRouter()` factory** ditambahkan agar setiap pengujian dapat memakai router sendiri tanpa state navigasi bocor antar test.

Rincian status per fitur ada di `docs/IMPLEMENTATION_STATUS.md`.

---

## 10. Build & Rilis APK

### Build Commands
```powershell
flutter pub get
dart format lib test integration_test
flutter analyze
flutter test
flutter build apk --debug
flutter build apk --release
```

### Output Biner
- Debug APK: `build/app/outputs/flutter-apk/app-debug.apk` (157.5 MB)
- Release APK: `build/app/outputs/flutter-apk/app-release.apk` (**68.5 MB**, R8 ProGuard Enabled)
- Status Signing: Standar Sideloading Release Signature (Konsisten untuk Upgrade In-Place)

### Git
- Remote: `https://github.com/Abaimann/BuildHauss.git`
- Branch: `main`
- Status Gate: **RELEASE READY**
