# BuildHaus — Implementation Status (20 October 2026)

## Status: Tahap 01 Selesai & Terverifikasi Build (Google Antigravity)

Hasil pengujian otomatis dan build APK pada lingkungan lokal Windows (Flutter 3.38.5 / Dart 3.10.4):

| Area | Kondisi codebase setelah perubahan | Verifikasi |
|---|---|---|
| Data motor | `createMotorcycle` menulis profil + odometer awal dalam transaksi. Form tambah menggunakan `modelId` eksplisit dan validasi tahun. | ✅ Terverifikasi unit test (`phase01_database_test.dart`) |
| Edit motor | Pilihan brand/model/tahun ditambahkan dan update profil+odometer ditransaksikan. | ✅ Analyzer bersih, form validation & model isolation terverifikasi |
| Penghapusan motor | Urutan hapus dependensi (chat/keluhan/inspeksi/servis/budget) dibuat eksplisit, transaksional. | ✅ Terverifikasi unit test |
| Model & katalog | Seeding idempotent menggunakan lookup sebelum insert; `getMotorcycleModelId` tidak mengembalikan model lain saat tidak ditemukan. | ✅ Terverifikasi unit test |
| Maintenance rule | Query hanya mengembalikan rule motor aktif dan generic. Data seed yang tidak diverifikasi tidak ditandai sebagai aturan resmi. | ✅ Terverifikasi unit test |
| Komponen | Upsert berdasarkan pasangan `(motorcycle_id, component_type_id)` tanpa `id=0`, confidence bertipe double. | ✅ Terverifikasi unit test |
| Servis | Satu operasi atomik untuk record, detail biaya, odometer, dan kalkulasi status. | ✅ Terverifikasi unit test |
| Skema/migrasi | Schema version 4: backfill master data (v3) dan alter table `odometerLogs` tanpa unique constraint (v4). | ✅ Terverifikasi test migrasi nyata (`migration_v1_to_v4_test.dart`) |
| Pengujian Flutter | 42 unit/widget/migration tests berjalan. | ✅ **Lulus 42/42 (flutter test)** |
| Statis Analyzer | Pembersihan 46 issues analyzer. | ✅ **0 issues found (flutter analyze)** |
| Build Debug APK | `flutter build apk --debug` menghasilkan `app-debug.apk`. | ✅ **Sukses dikompilasi (194.8 MB)** |
| Android Emulator Runtime | Menjalankan APK pada emulator `BuildHaus_Pixel` (API 35). | ✅ **Sukses terpasang dan berjalan (PID 3832, Impeller OpenGLES, Beranda aktif)** |
| Katalog fitment | Query `getSparepartsForModel` hanya menghasilkan fitment yang mempunyai sumber HTTPS, `verifiedAt`, dan sparepart `isVerified`; katalog umum diberi label referensi. | Katalog lokal data contoh terisolasi |
| AI Offline Qwen | Di luar cakupan Tahap 01. | Tahap 02 |
| Health Engine & Budget Engine UI wiring | Mesin domain lulus uji unit; integrasi dinamis UI lanjutan masuk Tahap 02. | Tahap 02 |

## Konsekuensi data historis dan batasan

- Sebagian versi terdahulu mungkin telah mencatat model, sparepart, atau interval berulang. Perubahan seeder mencegah penambahan baru melalui `ensureReferenceData()`, tetapi **tidak menghapus data duplikat lama** untuk melindungi referensi pengguna. Perlu audit migrasi menggunakan salinan SQLite nyata.
- Angka harga, nomor part, dan interval yang tertanam dalam seed bukan bukti dari website resmi. Verifikasi katalog/aturan spesifik masih diperlukan.
- `verifiedAt` dari seed baru disetel `null`. Legacy rules yang memakai sumber teks biasa juga diabaikan dalam status perawatan, walaupun dulu pernah diberi timestamp verifikasi otomatis.
- UI dan beberapa mesin lama masih memiliki kode yang tidak diselesaikan di Tahap 01; jangan klaim selesai end-to-end.
- Backup database pengguna sebelum pertama kali menjalankan APK dari hasil patch; jangan uji migrasi pertama kali pada data tunggal yang penting.

## Langkah verifikasi di PC Windows pengguna

```powershell
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart format lib test
flutter analyze
flutter test test/database/phase01_database_test.dart
flutter test
flutter build apk --debug
```

Jika gagal, simpan output dan perbaiki error sebelum melanjutkan Tahap 02. Pastikan tes database native bisa dijalankan di Windows dan SQLite tersedia.
