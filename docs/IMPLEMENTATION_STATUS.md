# BuildHaus — Implementation Status (19 October 2026)

## Status: Tahap 01 sedang dikerjakan, **belum diverifikasi build**

Ini adalah catatan hasil modifikasi source dalam sesi ini, bukan klaim bahwa aplikasi sudah berjalan pada perangkat Android.

| Area | Kondisi codebase setelah perubahan | Verifikasi |
|---|---|---|
| Data motor | `createMotorcycle` menulis profil + odometer awal dalam transaksi. Form tambah menggunakan `modelId` eksplisit dan validasi tahun. | Tes ditambahkan; belum dijalankan |
| Edit motor | Pilihan brand/model/tahun ditambahkan dan update profil+odometer ditransaksikan. | Tes manual UI belum dijalankan |
| Penghapusan motor | Urutan hapus dependensi (chat/keluhan/inspeksi/servis/budget) dibuat eksplisit, transaksional. | Tes ditambahkan; belum dijalankan |
| Model & katalog | Seeding idempotent menggunakan lookup sebelum insert; `getMotorcycleModelId` tidak mengembalikan model lain saat tidak ditemukan. | Tes ditambahkan; belum dijalankan |
| Maintenance rule | Query hanya mengembalikan rule motor aktif dan generic. Data seed yang tidak diverifikasi tidak ditandai sebagai aturan resmi. | Tes ditambahkan; belum dijalankan |
| Komponen | Upsert berdasarkan pasangan `(motorcycle_id, component_type_id)` tanpa `id=0`, confidence bertipe double. | Tes ditambahkan; belum dijalankan |
| Servis | Satu operasi atomik untuk record, detail biaya, odometer, dan kalkulasi status. | Tes ditambahkan; belum dijalankan |
| Skema/migrasi | Schema version 3 untuk re-seed master data pada database lama; tidak mengubah bentuk tabel. | Uji migrasi v1/v2 ke v3 belum dijalankan |
| Katalog fitment | Query `getSparepartsForModel` hanya menghasilkan fitment yang mempunyai sumber HTTPS, `verifiedAt`, dan sparepart `isVerified`; katalog umum diberi label referensi. Data resmi belum diisi. | Belum lengkap |
| AI Offline Qwen | Masih di luar cakupan Tahap 01. | Belum diimplementasikan |
| Health Engine menyeluruh | Kalkulasi transaksi dibuat konservatif; health UI menampilkan "Belum cukup data" ketika seluruh skor null. HealthEngine terpisah perlu disatukan pada Tahap 02. | Belum selesai |
| Budget engine | Di luar cakupan Tahap 01. | Belum selesai |
| Pengujian Flutter | Terdapat `test/database/phase01_database_test.dart`. | **Belum dijalankan: Flutter/Dart SDK tidak ada di lingkungan audit ini** |

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
