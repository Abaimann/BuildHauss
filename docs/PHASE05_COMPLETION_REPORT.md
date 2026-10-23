# BUILDHAUS — LAPORAN PENYELESAIAN TAHAP 05
## Local Notifications, Offline Backup & Restore, Settings & UI Finalization

**Tanggal:** 23 Oktober 2026  
**Status:** **SELESAI & TERVERIFIKASI PENUH (100% OFFLINE)**  
**Hasil Pengujian:**
- `flutter analyze`: **0 issues found** (Pristine)
- `flutter test`: **129/129 tests passed** (113 regression tests Tahap 01–04 + 16 new unit/integration tests)
- `flutter build apk --debug`: **SUCCESS** (`app-debug.apk`)

---

## 1. RINGKASAN EKSEKUTIF

Tahap 05 berfokus pada melengkapi pilar operasional harian sepeda motor secara luring penuh (*pure offline-first*):
1. **Notifikasi Lokal Pintar (Local Notifications)**: Pengingat perawatan terjadwal, pembaruan kilometer odometer berkala, peringatan dini komponen aus, dan tindak lanjut keluhan aktif tanpa server eksternal atau Firebase.
2. **Maintenance Engine Integration**: Sinkronisasi deterministik antara `HealthEngine`, `MileagePredictor`, keluhan aktif, dan penjadwalan alarm lokal Android.
3. **Pencadangan & Pemulihan Data Offline (Offline Backup & Restore)**: Format file terstandarisasi `.bhb` (*BuildHaus Backup*) dengan integritas checksum SHA-256, enkripsi terotentikasi PBKDF2 HMAC-SHA256 (10.000 iterasi) + HMAC tag, preview non-destruktif, dan transaksi atomik SQLite.
4. **Pengaturan & Personalisasi (Settings & UI Finalization)**: Manajemen tema dinamis (Terang, Gelap, Sistem) yang persisten di database, preferensi interval notifikasi, statistik penggunaan database, serta pembersihan data pengguna yang aman.
5. **Finalisasi Navigasi & Rute**: Seluruh rute placeholder pada `app_router.dart` (`/settings`, `/reminders`, `/motor/:id/reminders`, `/motor/:id/oil/add`, `/backup`, `/restore`, `/licenses`) telah digantikan oleh layar fungsional penuh dengan mempertahankan 100% token desain `BuildHausTheme`.

---

## 2. ARSITEKTUR & IMPLEMENTASI TEKNIS

### A. Real Android Local Notifications (`NotificationService`)
- **Library**: `flutter_local_notifications` versi 19.x dan `timezone` versi 0.10.x.
- **Konfigurasi Android**:
  - Inisialisasi Android icon launcher `@mipmap/ic_launcher`.
  - Android 13+ (API level 33+) runtime permission handling (`POST_NOTIFICATIONS`) via `requestPermission()` dan `areNotificationsEnabled()`.
  - Penjadwalan alarm hemat baterai menggunakan `AndroidScheduleMode.inexact` dan `tz.local` (`Asia/Jakarta` default), mencegah `SecurityException` pada Android 12+.
  - Notification Channels terkonfigurasi dengan `Importance.high` dan `Priority.high`.

### B. Reminder Engine & Health Engine Integration (`ReminderEngine`)
- **Lokasi**: `lib/core/engines/reminder_engine.dart`
- **Aturan Deterministik**:
  1. *Odometer Staleness Check*: Mengevaluasi jarak waktu sejak pencatatan odometer terakhir. Jika melampaui preferensi pengguna (default 30 hari), pengingat pembaruan kilometer dibuat otomatis.
  2. *Component Health Evaluation*: Memanfaatkan `HealthEngine` dan riwayat servis:
     - Jika status komponen `replace` atau score $\le 20$ $\to$ Pengingat mendesak (*urgent*) servis saat ini juga.
     - Jika status komponen `inspect` atau score $\le 40$ $\to$ Menghitung sisa kilometer aman dibagi rata-rata harian `MileagePredictor.kmPerDay` untuk memprediksi tanggal jatuh tempo servis secara presisi.
  3. *Unresolved Complaints Follow-up*: Keluhan dalam status `baru` atau `dianalisis` yang belum tertangani $>3$ hari dijadwalkan untuk pengingat tindak lanjut.
  4. *Idempotency & Deduplication*: Sinkronisasi berulang tidak menduplikasi rekaman di tabel `local_reminders`. Notifikasi ID dihasilkan dalam rentang aman 31-bit integer `(motorcycleId * 10000 + componentTypeId * 10) % 2147483647`.

### C. Backup & Restore Service (`BackupRestoreService`)
- **Lokasi**: `lib/core/backup/backup_restore_service.dart`
- **Format Envelope `.bhb`**:
  ```json
  {
    "app": "BuildHaus",
    "app_version": "1.0.0",
    "format_version": 1,
    "schema_version": 4,
    "created_at": "2026-10-23T02:00:00.000Z",
    "checksum_sha256": "3fa9...",
    "is_encrypted": false,
    "summary": {
      "motorcycles_count": 2,
      "odometer_logs_count": 14,
      "service_records_count": 8,
      "complaints_count": 3,
      "budget_plans_count": 2,
      "reminders_count": 5
    },
    "data": { ... }
  }
  ```
- **Kriptografi & Keamanan**:
  - Jika kata sandi diberikan, *payload* dienkripsi dengan PBKDF2 HMAC-SHA256 (10.000 iterasi) dengan *salt* acak kriptografis 16-byte dan *symmetric stream cipher*.
  - Otentikasi integritas data diverifikasi menggunakan HMAC-SHA256 tag. Percobaan pemulihan dengan kata sandi salah langsung ditolak dengan pesan: `"Kata sandi salah atau data rusak."`
- **Integritas Transaksional Database**:
  - Pemulihan dilakukan di dalam satu `db.transaction()` atomik.
  - Urutan penghapusan tabel aman terhadap dependensi foreign key (*reverse topological order*):
    `recommendationItems` $\to$ `serviceRecommendations` $\to$ `budgetPlans` $\to$ `complaintAnalyses` $\to$ `complaintMessages` $\to$ `complaints` $\to$ `inspectionAnswers` $\to$ `selfInspections` $\to$ `serviceItems` $\to$ `serviceRecords` $\to$ `componentStatuses` $\to$ `odometerLogs` $\to$ `localReminders` $\to$ `motorcycles`.
  - Penyisipan ulang menggunakan *primary keys* asli sehingga seluruh relasi foreign key pulih 100% sempurna.
  - Tabel master referensi (`componentTypes`, `spareparts`, `motorcycleModels`, `maintenanceRules`, `catalogSources`) **tidak pernah dihapus**, menjamin katalog resmi pabrikan tetap utuh.

### D. Settings, UI & Navigation Finalization
- **Layar Baru**:
  1. `lib/features/reminders/presentation/screens/reminders_screen.dart`: Ringkasan pengingat aktif, tombol sinkronisasi otomatis, sakelar aktif/nonaktif per pengingat, dan dialog pembuatan pengingat manual.
  2. `lib/features/settings/presentation/screens/settings_screen.dart`: Kontrol tema (Terang, Gelap, Sistem), sakelar notifikasi utama, pilihan interval pembaruan odometer, navigasi cadangkan/pulihkan, status model AI, informasi database, dan hapus semua data.
  3. `lib/features/settings/presentation/screens/backup_screen.dart`: Statistik live data yang akan dicadangkan, formulir enkripsi kata sandi opsional, dan daftar file `.bhb` yang tersedia di direktori lokal.
  4. `lib/features/settings/presentation/screens/restore_screen.dart`: Penjelajah file cadangan, pratinjau non-destruktif (*inspection preview*), masukan kata sandi pembuka kunci, dan konfirmasi pemulihan data atomik.
  5. `lib/features/settings/presentation/screens/licenses_screen.dart`: Pengakuan lisensi pihak ketiga (Drift, Riverpod, flutter_local_notifications, llama.cpp, Qwen3) serta kredit katalog resmi AHM dan YGP.
- **Integrasi Cepat Tambah Servis Oli**:
  - `AddServiceScreen` mendukung rute `/motor/:id/oil/add` dengan otomatis menyertakan komponen oli mesin dan tindakan `replace`.

---

## 3. MATRIKS VERIFIKASI PENGUJIAN

### A. Analisis Statis
```powershell
flutter analyze
```
**Hasil**: `No issues found!` (0 errors, 0 warnings, 0 infos).

### B. Otomatisasi Pengujian Unit & Integrasi
```powershell
flutter test
```
**Hasil**: **129/129 PASSED** (100% sukses, durasi ~5 detik).

| Paket Uji | Jumlah Kasus | Status |
|---|:---:|:---:|
| **Tahap 01 — Core Database & Models** (`phase01_database_test.dart`, `migration_v1_to_v4_test.dart`) | 17 | ✅ LULUS |
| **Tahap 02 — Health Engine & Inspeksi** (`health_engine_test.dart`, `self_inspection_engine_test.dart`, `mileage_predictor_test.dart`, `phase02_health_database_test.dart`) | 46 | ✅ LULUS |
| **Tahap 03 — Smart Budget & Sparepart** (`budget_engine_test.dart`, `phase03_budget_engine_test.dart`, `phase03_budget_database_test.dart`) | 24 | ✅ LULUS |
| **Tahap 04 — Real Offline AI** (`ai_chat_service_test.dart`, `ai_context_retriever_test.dart`, `ai_safety_guard_test.dart`, `model_download_service_test.dart`, `model_manifest_test.dart`) | 24 | ✅ LULUS |
| **Tahap 05 — Notifications & Reminders** (`reminder_engine_test.dart`) | 6 | ✅ LULUS |
| **Tahap 05 — Offline Backup & Restore** (`backup_restore_service_test.dart`) | 7 | ✅ LULUS |
| **Tahap 05 — Settings & Database Stats** (`settings_test.dart`) | 3 | ✅ LULUS |
| **Smoke & Widget Tests** (`widget_test.dart`) | 2 | ✅ LULUS |
| **TOTAL KESELURUHAN** | **129** | ✅ **100% LULUS** |

### C. Build Android Debug APK
```powershell
flutter build apk --debug
```
**Hasil**: **SUCCESS** (`build\app\outputs\flutter-apk\app-debug.apk`, ukuran 165 MB termasuk pustaka native llama.cpp dan NDK 28).

---

## 4. STATUS KEPATUHAN ATURAN MUTLAK

- [x] Tidak ada pembuatan ulang project Flutter.
- [x] Tidak ada redesign atau perombakan UI/UX; seluruh token warna `BuildHausTheme` konsisten.
- [x] Tidak ada penggunaan cloud AI, API pihak ketiga online, atau Firebase.
- [x] Tidak ada backend online; seluruh penyimpanan data menggunakan SQLite lokal Drift v4.
- [x] Tidak ada simulasi download atau timer palsu.
- [x] Semua 113 pengujian sebelumnya tetap lulus tanpa pelemahan assertion.
- [x] Tidak ada git commit atau push otomatis tanpa perintah pengguna.
- [x] Tahap 05 diselesaikan secara tuntas dan siap digunakan.
