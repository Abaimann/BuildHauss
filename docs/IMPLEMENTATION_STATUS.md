# BuildHaus — Status Implementasi Fitur

> **Tanggal audit:** 13 November 2026
> **Commit baseline:** `9272e56` (branch `main`)
> **Schema database:** v5
> **Flutter:** 3.38.x · **Dart:** 3.10.x

Dokumen ini mencerminkan **kondisi aktual kode**, bukan rencana. Setiap status
diperksa terhadap berkas implementasi nyata. Legenda:

| Simbol | Arti |
|--------|------|
| ✅ | Selesai — ada implementasi dan/oral sudah ada pengujian otomatis |
| 🟡 | Parsial — ada implementasi tetapi ada celah yang diketahui |
| ❌ | Belum tersedia / masih simulasi |
| 🚧 | Sedang dikerjakan pada tahap ini |

---

## 1. Ringkasan

| Area | Selesai | Parsial | Belum | Total |
|------|---------|---------|-------|-------|
| Struktur database & migrasi | 7 | 1 | 0 | 8 |
| Data motor (CRUD) | 8 | 1 | 0 | 9 |
| Master data & katalog | 7 | 2 | 0 | 9 |
| Navigasi | 10 | 2 | 0 | 12 |
| Repository & persistensi | 10 | 0 | 0 | 10 |
| **Total** | **42** | **6** | **0** | **48** |

---

## 2. Target 1 — Struktur Database

### 2.1 Skema 22 tabel inti — ✅

Seluruh 22 tabel pada ERD ada dan terverifikasi pada skema SQLite runtime
(bukan hanya di metadata Drift).

| Tabel | PK | FK | Constraint | Status |
|-------|----|----|------------|--------|
| motorcycle_models | id | — | text length 1..100 | ✅ |
| motorcycles | id | model_id → motorcycle_models | — | ✅ |
| odometer_logs | id | motorcycle_id → motorcycles | UNIQUE dikepas (v4) | ✅ |
| component_types | id | — | **UNIQUE(name)** | ✅ |
| maintenance_rules | id | model_id, component_type_id | rule_version default v1 | ✅ |
| component_statuses | id | motorcycle_id, component_type_id | **UNIQUE(motorcycle_id, component_type_id)** | ✅ |
| service_records | id | motorcycle_id | total_cost default 0 | ✅ |
| service_items | id | service_record_id, component_type_id, **sparepart_id** | — | ✅ (FK sparepart dipulihkan, v5) |
| self_inspections | id | motorcycle_id | status default draft | ✅ |
| inspection_answers | id | inspection_id | risk_flag default false | ✅ |
| complaints | id | motorcycle_id, inspection_id, resolved_by_service_id | status default 'baru' | ✅ |
| complaint_messages | id | complaint_id | — | ✅ |
| complaint_analyses | id | complaint_id | — | ✅ |
| catalog_sources | id | — | — | ✅ |
| spareparts | id | source_id | is_verified default false | ✅ |
| sparepart_fitments | id | sparepart_id, model_id | — | ✅ |
| budget_plans | id | motorcycle_id | — | ✅ |
| service_recommendations | id | budget_plan_id | — | ✅ |
| recommendation_items | id | recommendation_id, component_type_id, **sparepart_id** | — | ✅ (FK sparepart dipulihkan, v5) |
| local_reminders | id | motorcycle_id, component_type_id | enabled default true | ✅ |
| ai_model_installs | id | — | download_status default pending | ✅ |
| app_settings | key | — | — | ✅ |

**Bukti:** `lib/core/database/tables/all_tables.dart`,
`test/database/tahap01_integration_test.dart` (grup "Integritas skema").

### 2.2 Foreign key enforcement — ✅

`PRAGMA foreign_keys = ON` dijalankan pada setiap pembukaan database di
`beforeOpen` (`app_database.dart:70`). Diuji dengan mencoba menyisipkan
`odometer_logs` bermotor `999999` — operasi ditolak.

### 2.3 Migrasi database — ✅

| Dari | Ke | Aksi |
|------|----|------|
| — | v1 | `createAll()` + seed data master |
| v1/v2 | v3 | Backfill data master (`_seedReferenceData`) |
| v3 | v4 | Lepas `UNIQUE(motorcycle_id, recorded_at)` pada `odometer_logs`; Drift membangun ulang tabel dan menyalin data |
| v4 | v5 | **Pulihkan FK `sparepart_id`** pada `service_items` & `recommendation_items` |

Migrasi v5 menormalkan `sparepart_id` yang menggantung menjadi `NULL` sebelum
tabel dibangun ulang, sehingga **tidak ada data pengguna yang hilang**.

**Bukti:** `test/database/migration_v1_to_v4_test.dart` (25 test),
`test/database/tahap01_integration_test.dart` (grup "Migrasi v4 ke v5").

### 2.4 Tanpa drop-and-recreate — ✅

Tidak ada `DROP TABLE` pada data pengguna. `deleteMotorcycle` menghapus data
turunan secara manual dalam satu `transaction()` dengan urutan anak → induk.

### 2.5 Index — 🟡

SQLite otomatis membuat index pada PK dan FK. Belum ada index eksplisit untuk
query umum seperti `odometer_logs(motorcycle_id, recorded_at)` atau
`component_statuses(motorcycle_id)`. Pada skala data pribadi (ribuan baris)
ini belum menjadi bottleneck, tetapi perlu dipertimbangkan bila data bertambah.

---

## 3. Target 2 — Data Motor

| Fitur | Status | Bukti |
|-------|--------|-------|
| Tambah motor | ✅ | `add_motorcycle_screen.dart`, `createMotorcycle()` |
| Edit motor | ✅ | `edit_motorcycle_screen.dart`, `updateMotorcycleWithOdometer()` |
| Hapus motor + konfirmasi | ✅ | `edit_motorcycle_screen.dart:319`, `account_screen.dart:535` |
| Pilih merek / model / varian / tahun | ✅ | Dropdown berbasis DB (`getMotorcycleModelsGrouped()`) |
| **Simpan `modelId` FK valid** | ✅ | Validasi berlapis: UI + `createMotorcycle()` menolak modelId null/tidak dikenal |
| Odometer awal | ✅ | Disimpan atomik bersama motor (`createMotorcycle`) |
| Profil penggunaan | ✅ | `harian_dalam_kota` / `jarak_jauh` / `campuran` |
| Lebih dari satu motor | ✅ | `getAllMotorcycles()`, tepat satu `isPrimary` |
| Motor aktif dipakai semua layar | ✅ | `activeMotorcycleProvider` + `active_motorcycle_id` di `app_settings` |
| Validasi tahun terhadap rentang model | ✅ | Menolak tahun di luar `[yearStart, yearEnd]` |
| Hapus motor melepas `active_motorcycle_id` | ✅ | `deleteMotorcycle` menghapus setting & memindahkan status primary |

**Catatan:** kolom `motorcycles.model_id` tetap `NULLABLE` di skema agar data
motor lama yang dibuat sebelum relaksi ini terpasang tidak rusak saat migrasi,
namun seluruh jalur penulisan baru mewajibkan modelId valid
(`createMotorcycle` melempar `ArgumentError` bila kosong).

---

## 4. Isolasi Data Multi-Motor — ✅

Seluruh query per-motor difilter `motorcycle_id`. Tidak ada kebocoran data
antar motor pada histori, rekomendasi, keluhan, inspeksi, pengingat, maupun
status komponen.

**Bukti:** `test/database/tahap01_integration_test.dart` grup "Isolasi data
multi-motor" (5 test) — mencakup histori servis, keluhan, riwayat tindakan per
komponen, status komponen, dan pengingat.

### Perbaikan yang diterapkan pada tahap ini

- `budgetPlanSummaryProvider` semula memakai `budgetAmount` sebagai kunci cache
  family sehingga dua motor dengan budget sama berbagi entri cache. Kunci kini
  berupa `BudgetSummaryKey(motorcycleId, budgetAmount)`.
- `RemindersScreen` dengan `motorcycleId` eksplisit yang tidak dikenal
  sebelumnya diam-diam menampilkan pengingat **motor aktif**. Kini motor
  di-resolve dari daftar motor; bila id tidak ditemukan, layar menampilkan
  "Pilih sepeda motor aktif" dan **tidak** menampilkan data motor lain.

---

## 5. Target 3 — Master Data & Katalog

| Aspek | Status | Catatan |
|-------|--------|---------|
| `assets/catalogs/motorcycle_models.json` | 🟡 | Valid secara struktur, tetapi **tidak dimuat oleh kode**. Seeding memakai data yang ditulis langsung di Dart (`_seedMotorcycleModels`) dengan 18 model. |
| `assets/catalogs/spareparts.json` | 🟡 | **Tidak dimuat oleh kode.** `_seedSpareparts` menyemai ±70 part langsung dari Dart. |
| `assets/maintenance_rules/rules_v1.json` | 🟡 | **Tidak dimuat oleh kode.** `_seedMaintenanceRules` menyemai 14 aturan generic + 4 aturan spesifik model dari Dart. |
| Seeding idempoten | ✅ | `ensureReferenceData()` dibungkus `transaction()`; tiap sub-seeder melakukan pre-check + `insertOrIgnore`. Dijalankan dua kali tidak menggandakan data. |
| Seeder jalan di `beforeOpen` | ✅ | Master data selalu lengkap kapan pun DB dibuka. |
| Transaction saat seeding | ✅ | `ensureReferenceData()` → `transaction(_seedReferenceData)`. |
| `sparepart_fitments` hanya dari data terverifikasi | ✅ | 17 fitment berasal dari sumber katalog Astra Honda & Yamaha Indonesia dengan `is_verified = true` dan `source_url`. Tidak ada kecocokan yang ditebak dari kesamaan nama motor. |
| Deteksi kecocokan motor di katalog | ✅ | `parts_providers.dart` memetakan merek lewat `motor.modelId`. Fallback lama berbasis substring nickname (yang bisa salah klasifikasi, mis. motor nicknamed "Mio Beat" dianggap Honda) **telah dihapus** pada tahap ini. |

### Kekurangan data katalog yang tercatat

1. **JSON asset adalah data mati.** Tiga berkas JSON di `assets/` valid dan
   terdaftar di `pubspec.yaml`, tetapi tidak pernah dibaca runtime. Data
   master tersebar ganda (JSON vs literal Dart) dan sudah mulai berbeda —
   contoh: JSON menyatakan `Vario 125` berakhir tahun 2023, sedangkan seeder
   Dart mengisi `yearEnd = NULL` untuk semua model.
2. **Cakupan merek terbatas**: 18 model dari 4 merek (Honda,
   Yamaha, Suzuki, Kawasaki). Motor Indonesia lain (Honda Scoopy, Yamaha
   Mio M3, Kawasaki Ninja 150) belum lengkap.
3. **Fitment hanya 2 merek.** Tidak ada fitment terverifikasi untuk Suzuki
   dan Kawasaki, sehingga rekomendasi sparepart untuk motor tersebut hanya
   memakai katalog umum dan diberi status belum terverifikasi.

---

## 6. Target 4 — Navigasi

Audit terhadap seluruh `context.go` / `context.push` di `lib/`:
**tidak ada tombol yang mengarah ke route yang tidak terdaftar.**

### Route yang diminta pada tahap ini

| Route | Sebelum | Sekarang | Status |
|-------|---------|----------|--------|
| `/backup` | `BudgetScreen` ❌ | `BackupScreen` | ✅ sudah benar sebelum tahap ini |
| `/restore` | `BudgetScreen` ❌ | `RestoreScreen` | ✅ sudah benar sebelum tahap ini |
| `/licenses` | `BudgetScreen` ❌ | `LicensesScreen` | ✅ sudah benar sebelum tahap ini |
| `/motor/:id/reminders` | daftar pengingat | tetap daftar pengingat | ✅ |
| `/motor/:id/reminder/add` | daftar pengingat (dead-end) | daftar pengingat **+ sheet tambah terbuka otomatis** | ✅ diperbaiki |
| `/motor/:id/expense/add` | — | `ComingSoonScreen` (placeholder) | 🟡 jalur benar, fitur belum ada |
| `/motor/:id/oil/add` | — | `AddServiceScreen(isOilChange: true)` | ✅ |

### Perbaikan lain pada tahap ini

- Route duplikat `/edit-motor/:id` **dihapus**; hanya `/motor/:id/edit` yang
  dipakai.
- `app_router.dart` direfaktor menjadi `createAppRouter()` factory +
  `appRouter` singleton. Router dapat dibuat ulang per pengujian sehingga
  state navigasi tidak bocor antar test.
- Route yang tidak dikenal ditolak GoRouter tanpa membuka layar yang salah.

**Bukti:** `test/widgets/tahap01_navigation_test.dart` (22 test) memverifikasi
setiap route membuka layar yang sesuai labelnya.

---

## 7. Target 5 — Repository & Persistensi

### Operasi atomik (dibungkus `transaction()`)

| Operasi | Status |
|---------|--------|
| `createMotorcycle` (motor + odometer awal) | ✅ |
| `createMotorcycleWithInitialHealth` (motor + odometer + riwayat + status + inspeksi) | ✅ |
| `updateMotorcycleWithOdometer` | ✅ |
| `deleteMotorcycle` (9 tabel turunan) | ✅ |
| `setPrimaryMotorcycle` | ✅ |
| `createServiceWithItems` (record + item + odometer + resolusi keluhan + status) | ✅ |
| `deleteServiceRecord` (+ item) | ✅ |
| `saveCompleteSelfInspection` (+ jawaban) | ✅ |
| `saveCompleteBudgetPlan` (+ rekomendasi + item) | ✅ |
| `deleteBudgetPlan` (+ rekomendasi) | ✅ |
| `clearAllUserData` | ✅ |
| `ensureReferenceData` | ✅ |

### Operasi **belum** atomik

Tidak ada lagi. Ketiga operasi berikut kini dibungkus `transaction()` pada
tahap ini:

| Operasi | Perbaikan |
|---------|-----------|
| `deleteComplaint` | Tiga DELETE (pesan, analisis, keluhan) kini satu transaksi; kegagalan di tengah tidak meninggalkan data yatim. |
| `upsertComponentStatus` | Select-lalu-update/insert dibungkus transaksi agar dua pemanggilan bersamaan tidak melanggar `UNIQUE(motorcycle_id, component_type_id)`. |
| `recalculateComponentStatuses` | Loop seluruh komponen dibungkus satu transaksi; kegagalan di tengah tidak menyisakan status yang hanya ter-update sebagian. |

### Validasi di lapisan database

- `createMotorcycle` menolak: modelId kosong, modelId tidak dikenal, tahun
  di luar rentang model, odometer negatif/NaN.
- `createServiceWithItems` menolak: item kosong, motor tidak dikenal,
  componentTypeId kosong/tidak dikenal, action di luar
  `inspect|replace|repair|clean`, biaya negatif.
- Kegagalan validasi **membatalkan seluruh transaksi** — tidak ada record
  atau log odometer yang tertinggal (terverifikasi lewat test).

### Catatan penting

- `getComponentStatusesWithNames` menulis ke database (recalculate) di dalam
  metode baca. Ini self-healing yang disengaja agar status selalu lengkap,
  tetapi membuat metode baca tidak murni dan perlu dipantau.
- `getApplicableComponents(usageProfile)` mengabaikan parameter dan selalu
  mengembalikan seluruh komponen; kolom `applies_to` belum dipakai.

---

## 8. Ringkasan Perubahan Skema

| Versi | Perubahan | Dampak pengguna |
|-------|-----------|------------------|
| v5 | FK `sparepart_id` pada `service_items` dan `recommendation_items` | Tidak ada data hilang. `sparepart_id` yang menggantung menjadi `NULL`. Insert dengan sparepartId tidak valid kini ditolak database. |

---

## 9. Blocker untuk Tahap Berikutnya

### Prioritas tinggi

1. **Data katalog JSON tidak terpakai.** `assets/catalogs/*.json` dan
   `assets/maintenance_rules/rules_v1.json` valid tetapi mati. Pilih salah
   satu: (a) muat JSON sebagai sumber tunggal dan hapus literal Dart, atau
   (b) hapus aset JSON agar tidak menyesatkan. Ketiganya saat ini membuat
   sumber kebenaran ganda.
2. **Kredensial plaintext tersemai di database.**
   `app_database.dart` menulis `registered_users_json` berisi password
   (`Aiman123`) dan **menimpa ulang password pada setiap pembukaan aplikasi**
   lewat `beforeOpen` → `ensureReferenceData()`. Ini harus dihapus sebelum
   rilis.
3. **Fitment terverifikasi hanya untuk Honda & Yamaha.** Suzuki & Kawasaki
   belum punya relasi kompatibilitas; tampilkan status "belum diverifikasi"
   pada UI, jangan menebak dari nama motor.

### Prioritas menengah

4. **Indeks database** untuk `odometer_logs(motorcycle_id, recorded_at)` dan
   `component_statuses(motorcycle_id)` belum dibuat.
5. **Komponen CVT** belum dikondisikan berdasarkan tipe motor —
   `applies_to` belum dipakai di query mana pun.
6. **`getComponentStatusesWithNames` menulis ke database** saat dipanggil
   (self-healing). Perbaikannya: jadikan metode baca ini murni dengan
   memisahkan penghitungan ke service eksplisit agar tidak ada efek samping
   saat dibaca.

### Di luar lingkup tahap ini (menunggu tahap AI)

7. AI Chat masih berbasis keyword matching, belum LLM.
8. Unduhan model AI masih simulasi; bridge llama.cpp belum ada.
9. `lib/core/database/app_database.dart` menyemai kredensial akun plaintext
   (`registered_users_json`) dan **menimpa ulang password pada setiap
   pembukaan aplikasi**. Ini harus dihapus sebelum rilis.

---

## 10. Hasil Verifikasi

| Perintah | Hasil |
|----------|-------|
| `flutter pub get` | ✅ Berhasil |
| `dart run build_runner build --delete-conflicting-outputs` | ✅ 174 output ditulis |
| `flutter analyze` | ✅ **No issues found** |
| `flutter test` | ✅ **220 test lulus** (baseline 164, +56 test baru) |
| `flutter build apk --debug` | ✅ `build/app/outputs/flutter-apk/app-debug.apk` |

### Pengujian baru pada tahap ini

| Berkas | Jumlah | Cakupan |
|--------|--------|---------|
| `test/database/tahap01_integration_test.dart` | 36 | CRUD motor, FK model, isolasi multi-motor, seeder idempoten, CRUD servis + item, constraint sparepart, migrasi v4→v5, integritas skema |
| `test/widgets/tahap01_navigation_test.dart` | 22 | Setiap route penting membuka layar yang sesuai; rute duplikat dihapus; `/motor/:id/reminder/add` membuka form tambah |
