# BuildHaus

**Built for every ride.**

Asisten perawatan motor pribadi untuk Android — offline-first, data tersimpan lokal.

![Flutter](https://img.shields.io/badge/Flutter-3.38.5-blue)
![Dart](https://img.shields.io/badge/Dart-3.10.4-blue)
![License](https://img.shields.io/badge/License-MIT-green)

## Fitur Utama

- 🔧 **Multi-Motor** — Kelola beberapa motor dalam satu aplikasi
- 📊 **Odometer & Prediksi** — Catat kilometer dan estimasi pemakaian
- ❤️ **Kesehatan Sparepart** — Monitor 8 komponen: oli, rem, aki, ban, filter udara, busi, CVT, knalpot
- 🔍 **Pemeriksaan Mandiri** — Alur pertanyaan dinamis untuk inspeksi motor sendiri
- 📝 **Keluhan** — Catat dan analisis keluhan berbahasa Indonesia
- 🤖 **AI Offline** — Analisis keluhan lokal tanpa internet (rule-based aktif; LLM plan)
- 🛒 **Katalog Sparepart** — Referensi dari sumber resmi
- 💰 **Budget Advisor** — Prioritas servis sesuai anggaran
- 🔔 **Pengingat** — Notifikasi jadwal perawatan
- 💾 **Backup/Restore** — Ekspor-impor data lokal
- 🌙 **Dark/Light Theme** — Default gelap

## Screenshoot Prototipe

10 layar fungsional: Beranda, Data Motor, Tambah Motor, Kesehatan, Sparepart, Katalog, Budget, Keluhan, Riwayat Servis, Akun.

## Teknologi

| Stack | Pilihan |
|-------|---------|
| Framework | Flutter 3.38.5 / Dart 3.10.4 |
| State Management | flutter_riverpod |
| Navigation | go_router |
| Database | SQLite + Drift |
| AI | Qwen3 0.6B GGUF (plan) + rule-based |
| Notifications | flutter_local_notifications |

## Persiapan

### Tanpa Android Studio

```bash
# 1. Install Flutter SDK
# https://docs.flutter.dev/get-started/install

# 2. Verify
flutter --version

# 3. Clone / extract project
cd BuildHaus

# 4. Get dependencies
flutter pub get

# 5. Generate Drift code
dart run build_runner build --delete-conflicting-outputs

# 6. Build debug APK
flutter build apk --debug

# 7. Install on device
flutter install
```

### Build Release APK

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

## Struktur Project

```
lib/
├── main.dart                    # Entry point
├── app/app.dart               # MaterialApp config
├── core/
│   ├── database/              # Drift 22 tables + DAOs
│   ├── providers/             # Riverpod providers
│   ├── engines/               # Domain logic (testable)
│   ├── router/                # go_router
│   ├── theme/                 # Design tokens prototype
│   └── utils/                 # Formatters
├── features/                   # Feature modules
│   ├── home/                  # Beranda
│   ├── motorcycles/            # CRUD motor
│   ├── health/                # Kesehatan sparepart
│   ├── spareparts/            # Katalog sparepart
│   ├── budget/                # Prioritas servis
│   ├── complaints/            # Keluhan & analisis
│   ├── service_history/      # Riwayat servis
│   ├── self_inspection/       # Inspeksi mandiri
│   ├── ai_assistant/          # Chat AI
│   ├── mileage/               # Odometer
│   └── account/               # Akun & pengaturan
└── shared/widgets/            # Shared scaffold
```

## Database — 22 Tabel

**Motor & Kesehatan** (13): motorcycle_models, motorcycles, odometer_logs, component_types, maintenance_rules, component_statuses, service_records, service_items, self_inspections, inspection_answers, complaints, complaint_messages, complaint_analyses

**Katalog & Budget** (7): catalog_sources, spareparts, sparepart_fitments, budget_plans, service_recommendations, recommendation_items, local_reminders

**AI & Settings** (2): ai_model_installs, app_settings

## Menjalankan Tests

```bash
# Unit tests
flutter test

# Engine tests (domain logic tanpa Flutter)
dart test test/engines/

# Widget tests
flutter test test/widget_test.dart

# Integration tests (butuh emulator/device)
flutter test integration_test/
```

## AI Offline

- **Saat ini**: Analisis rule-based aktif — keyword matching + safety rules
- **Plan**: Model Qwen3 0.6B GGUF via llama.cpp Android
- **Download**: UI manager tersedia, perlu URL resmi untuk download model
- **Privasi**: Semua data keluhan TIDAK dikirim ke server manapun

## Dokumentasi

- [ARCHITECTURE.md](docs/ARCHITECTURE.md) — Arsitektur aplikasi
- [ERD.md](docs/ERD.md) — Diagram relasi 22 tabel
- [DATA_DICTIONARY.md](docs/DATA_DICTIONARY.md) — Deskripsi kolom
- [OFFLINE_AI.md](docs/OFFLINE_AI.md) — Strategi AI offline
- [SOURCES_AND_LICENSES.md](docs/SOURCES_AND_LICENSES.md) — Sumber data & lisensi
- [TEST_REPORT.md](docs/TEST_REPORT.md) — Laporan pengujian

## APK Debug

```
build/app/outputs/flutter-apk/app-debug.apk (~150 MB)
```

Install langsung di HP Android (aktifkan "Sumber tidak dikenal").

## Privasi

- Data motor dan keluhan tersimpan di HP saja
- Tidak ada login, tidak ada cloud
- Uninstall = data hilang (kecuali sudah backup)
- AI analisis dilakukan lokal

## Lisensi

MIT License
