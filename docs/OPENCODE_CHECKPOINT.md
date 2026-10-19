# BuildHaus — Checkpoint kelanjutan Tahap 01

**Tanggal:** 2026-10-19  
**Status:** Implementasi sumber parsial, belum diverifikasi runtime dan migrasi.

## Perubahan di sesi ChatGPT ini

- `lib/core/database/app_database.dart`: transaksi CRUD, seeding yang tidak bergantung pada `insertOrIgnore` tanpa unique constraint, pembatasan rule model, perbaikan status komponen, schemaVersion 3 dengan re-seed untuk DB lama.
- `lib/features/motorcycles/presentation/screens/add_motorcycle_screen.dart`: simpan melalui `createMotorcycle`, validasi pemilihan model/tahun.
- `lib/features/motorcycles/presentation/screens/edit_motorcycle_screen.dart`: editor model/tahun dan update atomik.
- `lib/features/service_history/presentation/screens/add_service_screen.dart`: penyimpanan servis melalui `createServiceWithItems`.
- `lib/features/health/presentation/screens/health_screen.dart`: status tanpa bukti tidak ditampilkan sebagai skor 0 / kondisi sangat buruk.
- `lib/features/spareparts/presentation/screens/spareparts_screen.dart` dan `lib/features/parts/presentation/screens/parts_catalog_screen.dart`: label referensi pada data harga/part.
- `lib/core/providers/app_providers.dart`: fallback motor aktif setelah dihapus.
- `test/database/phase01_database_test.dart`: regresi database dan operasi atomik.
- `docs/IMPLEMENTATION_STATUS.md`: status berbasis temuan source.

## Status pengujian

Tidak ada Flutter SDK/Dart SDK di lingkungan audit saat file ini dibuat. Perintah `flutter analyze`, `flutter test`, dan build APK **tidak dijalankan**, sehingga compile/runtime correctness belum terverifikasi.

## Yang harus dikerjakan berikutnya oleh OpenCode atau di VS Code

1. Jalankan `flutter pub get`, `dart run build_runner build --delete-conflicting-outputs`, `dart format lib test`, `flutter analyze`, `flutter test` serta `flutter build apk --debug` pada Windows user.
2. Perbaiki semua error compile/test yang muncul terlebih dahulu. Jangan mengklaim fase selesai sebelum command lulus.
3. Periksa migrasi upgrade v1/v2 ke v3 dengan SQLite asli dari versi lama, termasuk pengguna yang sudah punya model/servis berulang; buat uji migrasi berbasis snapshot database historis.
4. Pastikan referensi model motor dan katalog tidak duplikat pada database legacy. Jangan menghapus data atau deduplikasi otomatis jika belum ada backup, konfirmasi, dan pemetaan relasi yang benar.
5. Selesaikan kompatibilitas sparepart yang terbukti dari sumber pabrikan; saat ini katalog lokal hanya data contoh yang belum tervalidasi.
6. Periksa UI edit motor, tambah motor, hapus motor, servis, dan status baru pada perangkat/emulator; jangan ubah desain dari prototipe.
7. Tambahkan widget tests bermakna dan perbarui dokumentasi ERD hanya jika skema tabel berubah.

**Jangan lanjut ke Tahap 02 sebelum masalah di atas dinyatakan aman.**
