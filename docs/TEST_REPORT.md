# BuildHaus Test Report
**Release Version:** 1.0.0 (Build 1) — Tahap 06 Final Release  
**Tanggal Pengujian:** 23 Oktober 2026  
**Status Gate:** **RELEASE READY**

---

## 1. Lingkungan Build & Eksekusi

- **Sistem Operasi**: Windows 11
- **Flutter**: 3.38.5
- **Dart**: 3.10.4
- **Android SDK**: 36
- **Android NDK**: 28.2.13676358
- **CMake**: 3.22.1
- **JDK**: Temurin 17
- **Perangkat Uji**: Android Emulator `BuildHaus_Pixel` (API 36, x86_64)

---

## 2. Status Pipeline Verifikasi

### A. Static Code Analyzer
```powershell
flutter analyze
```
✅ **SUCCESS** — `No issues found!` (0 errors, 0 warnings, 0 infos).

### B. Dependencies & Code Generation
```powershell
flutter pub get
dart format lib test integration_test
```
✅ **SUCCESS** — 74 file terformat dengan benar, dependency tree bersih dan kompatibel.

### C. Automated Test Suite
```powershell
flutter test
```
✅ **SUCCESS** — **143/143 passed (100% pass rate, 0 failed, 0 skipped)**

#### Rincian Distribusi 143 Pengujian Otomatis:
1. `test/widget_test.dart` (2 tests): Logo branding BuildHaus dan tagline smoke test.
2. `test/database/migration_v1_to_v4_test.dart` (3 tests): Migrasi SQLite skema v1 $\to$ v4, v2 $\to$ v4, v3 $\to$ v4 menggunakan file biner database SQLite nyata.
3. `test/database/phase01_database_test.dart` (14 tests): Isolasi multi-motor, transaksi atomik, lookup katalog model, validasi foreign key.
4. `test/database/phase02_health_database_test.dart` (5 tests): Persistensi pemeriksaan mandiri, rekalkulasi status dinamis, reset keausan pasca-servis, timestamp identik, isolasi multi-motor.
5. `test/database/phase03_budget_database_test.dart` (6 tests): Reset keausan servis memperbarui rekomendasi, odometer melewati interval memicu penggantian, inspeksi mandiri memicu safety alert, snapshot SQLite budget plan, transactional rollback.
6. `test/engines/budget_engine_test.dart` (8 tests): Pengujian dasar budget engine.
7. `test/engines/phase03_budget_engine_test.dart` (16 tests): Budget Rp0, budget kecil, budget besar, komponen keselamatan melebihi budget, biaya tidak diketahui, suku cadang tidak kompatibel, isolasi merek Honda vs Yamaha, pemisahan tindakan inspect vs replace, sorting multi-prioritas, pencegahan double-counting.
8. `test/engines/mileage_predictor_test.dart` (19 tests): Masa pembelajaran 3 periode bulanan, prediksi km harian/mingguan/bulanan, kalibrasi ulang, penanganan rollback odometer, low usage.
9. `test/engines/health_engine_test.dart` (17 tests): Aturan model-specific vs generic, isolasi komponen, inspect vs replace actions, safety overrides, ambang batas rasio keausan.
10. `test/engines/self_inspection_engine_test.dart` (5 tests): Evaluasi semantik, deteksi red flag keselamatan (rem, bocor bensin, ban, kemudi), pemetaan komponen.
11. `test/ai/model_manifest_test.dart` (6 tests): Parameter default model Qwen3 0.6B GGUF, ChatML formatting, validasi URL resmi Hugging Face, exact SHA-256, penolakan manifest tidak valid.
12. `test/ai/ai_safety_guard_test.dart` (6 tests): Deteksi bahaya rem, kebocoran bensin, ban pecah, kemudi oleng; override kebal manipulasi LLM; evaluasi input aman.
13. `test/ai/ai_context_retriever_test.dart` (3 tests): Pengambilan konteks motor aktif, agregasi rasio keausan komponen, isolasi ketat antar-motor, deteksi keluhan berulang.
14. `test/ai/model_download_service_test.dart` (4 tests): Status reporting, verifikasi SHA-256 chunked streaming, penolakan & pembersihan file korup, penghapusan model dari disk dan SQLite.
15. `test/ai/ai_chat_service_test.dart` (4 tests): Fallback transparan saat model belum terinstal, pemicu safety alert otomatis, persistensi pesan dan analisis ke SQLite, multi-turn history loading.
16. `test/notifications/reminder_engine_test.dart` (6 tests): Deteksi kelalaian odometer (>30 hari), non-trigger saat log baru, servis jatuh tempo, follow-up keluhan terbuka (>3 hari), idempotensi sinkronisasi, isolasi multi-motor.
17. `test/notifications/notification_id_generator_test.dart` (3 tests): Validasi rentang aman 31-bit integer positif, zero collision pada 1.980 kombinasi, deterministik dan stabil.
18. `test/backup/backup_restore_service_test.dart` (9 tests): Ekspor `.bhb` polos dengan SHA-256, ekspor terenkripsi NIST AES-256-GCM + PBKDF2 (100k iterasi), pratinjau non-destruktif, restorasi atomik skema penuh dengan `PRAGMA foreign_key_check`, dekripsi kata sandi benar, penolakan kata sandi salah, penolakan file korup, penolakan ciphertext hasil manipulasi (*tampering*), dan kompatibilitas mundur pemulihan file v1 lama.
19. `test/settings/settings_test.dart` (3 tests): Set/get pengaturan SQLite, kalkulasi statistik database lintas tabel, pembersihan seluruh data pengguna tanpa merusak katalog referensi.
20. `test/integration/cross_feature_e2e_test.dart` (7 tests): Pengujian integrasi end-to-end lintas modul (Fresh install $\to$ Tambah motor $\to$ Odometer $\to$ Health $\to$ Servis refresh $\to$ Pemeriksaan mandiri $\to$ Smart budget $\to$ Notifikasi deterministik $\to$ Full backup & restore terenkripsi).
21. `test/widgets/app_navigation_test.dart` (2 tests): Bootstrapping `BuildHausApp`, rendering `AppShell`, navigasi mulus tab Beranda, Sehat, Sparepart, Riwayat, dan Akun tanpa unhandled exceptions.

---

## 3. Kompilasi Biner Android

### A. Debug APK
```powershell
flutter build apk --debug
```
✅ **SUCCESS** — `build/app/outputs/flutter-apk/app-debug.apk` (157.5 MB).

### B. Release APK (Produksi & Distribusi Mandiri)
```powershell
flutter build apk --release
```
✅ **SUCCESS** — `build/app/outputs/flutter-apk/app-release.apk` (**68.5 MB** / 71.850.834 bytes).  
- **SHA-256:** `33409A1E71CB9D0F77F4B0E5810D42FECB525D08B6060194089A9E3ABC4B9453`  
- **Optimasi:** R8 ProGuard Enabled, Font Tree-Shaking (99.4% reduction).  
- **Kompatibilitas ABI:** Dual-ABI (`arm64-v8a` untuk smartphone fisik, `x86_64` untuk emulator).

---

## 4. Hasil Pengujian Nyata pada Perangkat Android

- **Perangkat:** Android Emulator `BuildHaus_Pixel` (API Level 36, x86_64).
- **Hasil Sideload:** `adb install -r build/app/outputs/flutter-apk/app-release.apk` $\to$ **Success** (5.6 detik).
- **Pengujian Upgrade:** Berhasil dipasang di atas instalasi sebelumnya tanpa kehilangan data.
- **Pengujian Navigasi:**
  - Halaman Beranda memuat dengan sempurna.
  - Tambah motor pertama membuka form lengkap dengan pemilih emoji, merek, dan model.
  - Tab Sehat, Sparepart, Riwayat, dan Akun berpindah secara instan tanpa jank atau overflow.
  - Menu Pengaturan dan Backup Data Lokal (.bhb) berfungsi normal.
