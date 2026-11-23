# BuildHaus 🏍️

**Built for every ride.**  
Asisten perawatan motor pribadi untuk Android (**v1.2.0**) — *offline-first*, data tersimpan aman di SQLite lokal, dan terintegrasi Google Gemini 2.5 Flash untuk konsultasi serta manajemen riwayat keluhan motor.

![Release](https://img.shields.io/badge/Release-v1.2.0-00f5a0)
![Flutter](https://img.shields.io/badge/Flutter-3.38+-blue)
![Dart](https://img.shields.io/badge/Dart-3.10+-blue)
![Tests](https://img.shields.io/badge/Tests-240%20passed-brightgreen)
![License](https://img.shields.io/badge/License-MIT-green)

🌐 **Halaman Unduh Resmi APK (`v1.2.0`):** https://abaimann.github.io/BuildHauss/  
📦 **GitHub Release Terbaru:** https://github.com/Abaimann/BuildHauss/releases/tag/v1.2.0

---

## ⚡ Perintah Cepat (Tinggal Klik / Ketik)

Anda dapat langsung menjalankan file perintah praktis berikut dari File Explorer atau Terminal:

| File Perintah | Fungsi | Perintah Asli di Balik Layar |
| :--- | :--- | :--- |
| **`jalankan_aplikasi.bat`** | Menjalankan aplikasi ke HP atau Emulator | `flutter run` |
| **`buat_apk_rilis.bat`** | Membuat file installer APK rilis resmi (`28.6 MB`) | `flutter build apk --release` |
| **`pasang_ke_hp.bat`** | Memasang langsung APK ke smartphone via kabel data | `adb install -r buildhaus.apk` |
| **`cek_kode.bat`** | Memeriksa apakah ada kesalahan sintaks atau bug | `flutter analyze` |
| **`uji_semua_fitur.bat`** | Menjalankan 240 uji coba otomatis fitur aplikasi | `flutter test` |
| **`update_database.bat`** | Mengupdate skema database SQLite (Drift) | `dart run build_runner build` |

---

## 🛠️ Panduan Perintah Terminal Lengkap (Bahasa Indonesia)

### 1. Mempersiapkan & Menjalankan Aplikasi
```bash
# Mengunduh seluruh paket dependensi Flutter yang dibutuhkan:
flutter pub get

# Memperbarui dan men-generate tabel database SQLite Drift:
dart run build_runner build --delete-conflicting-outputs

# Menjalankan aplikasi pada perangkat HP atau emulator yang terhubung:
flutter run
```

### 2. Membuat File Installer (APK)
```bash
# Membuat APK versi Release yang optimal dan siap dibagikan (28.6 MB):
flutter build apk --release

# Lokasi file output yang dihasilkan:
# build/app/outputs/flutter-apk/app-release.apk
```

### 3. Memasang (Install) ke HP via Kabel Data (ADB)
```bash
# Memasang file APK yang sudah dibuild ke HP yang terhubung:
adb install -r build/app/outputs/flutter-apk/app-release.apk

# Membuka aplikasi secara otomatis di layar HP:
adb shell am start -n com.buildhaus.buildhaus/.MainActivity
```

### 4. Menguji & Memeriksa Kualitas Kode
```bash
# Memeriksa kesehatan kode dan memastikan 0 error:
flutter analyze

# Menjalankan seluruh pengujian unit, widget, dan database (240 tes):
flutter test
```

### 5. Menyimpan & Mengirim Perubahan ke GitHub (Git)
```bash
# Melihat status file apa saja yang telah diubah:
git status

# Menandai seluruh perubahan untuk disimpan:
git add .

# Menyimpan perubahan dengan catatan bahasa Indonesia:
git commit -m "Catatan tentang perubahan yang dilakukan"

# Mengirim commit ke repositori GitHub:
git push origin main
```

---

## 🌟 Fitur Utama BuildHaus v1.2.0

- 🔐 **Autentikasi Akun Lokal** — Login & registrasi offline dengan hashing SHA-256 salted.
- 🏍️ **Garasi Multi-Motor (5 Jenis Motor / 4 Merek Resmi)** — Kelola Honda, Yamaha, Suzuki, & Kawasaki, lengkap dengan seeder 1-klik **Muat 5 Motor Beragam Jenis** di menu Akun.
- 📊 **Telemetri Odometer & Masa Pembelajaran** — Pelacakan odometer tabular, estimasi pemakaian harian, dan indikator periode pembelajaran (`< 3` periode bulanan valid).
- 🩺 **Skor Kesehatan Adaptif & Uji Mandiri 8-Titik** — Memantau **14 komponen master** dan menyaring otomatis menjadi **11–13 komponen relevan** sesuai tipe transmisi (Matic CVT vs Manual Rantai) & sistem pendingin (`Radiator` vs `Udara`), disertai kuesioner 8 titik keselamatan fisik.
- 🤖 **AI Konsultasi & Riwayat Keluhan (Gemini 2.5 Flash + Fallback Offline)** — Analisis gejala real-time dengan fallback aturan deterministik saat offline (0 MB unduhan model) dan pengelolaan **Riwayat Keluhan** yang memengaruhi skor komponen.
- 🛒 **Katalog Sparepart Terkurasi & Modal Filter Anti-Geser** — Katalog OEM bebas duplikasi (Schema v7) dengan tombol **Filter** & **Urutkan** berbasis *Modal Bottom Sheet* multi-baris (`Wrap`).
- 💰 **Budget Advisor & Normalisasi IDR** — Input anggaran format pemisah ribuan IDR otomatis (`350000` → `350.000`) yang tersinkron langsung ke Katalog Sparepart.
- 🔔 **Riwayat Servis, Pengingat & Tombol `Contoh Pengingat`** — Ringkasan biaya Part/Jasa, log odometer, jadwal pengingat otomatis, dan tombol **Contoh Pengingat** untuk uji notifikasi instan.
- 📄 **Ekspor Laporan Kondisi `.TXT` ke `Download/`** — Salin teks ringkas atau simpan sertifikat kondisi motor langsung ke folder publik `Download/` Android.
- 💾 **Backup & Restore Terenkripsi `.bhb`** — Ekspor dan impor cadangan lokal berenkripsi **AES-256-GCM**.

---

## 📱 Struktur Halaman & Arsitektur

```
lib/
├── main.dart                  # Titik awal masuk aplikasi & inisialisasi lokal
├── core/
│   ├── ai/                    # Integrasi Gemini 2.5 Flash, Safety Guard, & Rule-Based Fallback
│   ├── backup/                # Ekspor & restore arsip .bhb terenkripsi AES-256-GCM
│   ├── database/              # SQLite lokal dengan Drift Schema v7 (22 tabel + seeder 5 motor)
│   ├── engines/               # Logika deterministik kesehatan, budget, mileage, specs, & reminder
│   ├── notifications/         # Layanan notifikasi lokal Android
│   ├── providers/             # Manajemen state reaktif Riverpod
│   ├── router/                # Rute navigasi GoRouter
│   ├── theme/                 # Palet tema Cyber-Automotive Dark & Light
│   └── utils/                 # Formatter mata uang & input IDR otomatis
├── features/
│   ├── auth/                  # Login, Registrasi, & Setup Kesehatan Motor Awal
│   ├── home/                  # Beranda Kokpit, Pemilih Multi-Motor, & Aksi Cepat
│   ├── health/                # Kesehatan Unit, Filter Komponen Adaptif, & Laporan Kondisi (.TXT)
│   ├── self_inspection/       # Kuesioner Pemeriksaan Mandiri 8-Titik Fisik
│   ├── ai_assistant/          # Konsultasi AI Gemini 2.5 Flash
│   ├── complaints/            # Daftar, Detail, & Tambah Riwayat Keluhan
│   ├── budget/                # Prioritas Servis & Ubah Budget IDR
│   ├── parts/ & spareparts/   # Katalog Suku Cadang OEM & Modal Bottom Sheet Filter
│   ├── history/ & service_history/ & mileage/ & reminders/
│   │                          # Riwayat Servis, Pengeluaran, Odometer, Pengingat & Contoh Pengingat
│   ├── motorcycles/           # Tambah & Edit Spesifikasi Motor
│   └── account/ & settings/   # Profil Rider, Garasi, Data Management, Backup & Pengaturan
└── shared/widgets/            # Logo Apex Emblem, shell navigasi 5 tab, & komponen UI
```

---

## 📄 Lisensi
Hak Cipta © 2026 BuildHaus Project. Berlisensi di bawah lisensi MIT.
