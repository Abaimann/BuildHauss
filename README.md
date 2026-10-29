# BuildHaus 🏍️

**Built for every ride.**  
Asisten perawatan motor pribadi untuk Android — *offline-first*, data tersimpan aman di perangkat lokal, dan ditenagai kecerdasan buatan Google Gemini 2.5 Flash.

![Flutter](https://img.shields.io/badge/Flutter-3.38.5-blue)
![Dart](https://img.shields.io/badge/Dart-3.10.4-blue)
![License](https://img.shields.io/badge/License-MIT-green)

---

## ⚡ Perintah Cepat (Tinggal Klik / Ketik)

Anda dapat langsung menjalankan file perintah praktis berikut dari File Explorer atau Terminal:

| File Perintah | Fungsi | Perintah Asli di Balik Layar |
| :--- | :--- | :--- |
| **`jalankan_aplikasi.bat`** | Menjalankan aplikasi ke HP atau Emulator | `flutter run` |
| **`buat_apk_rilis.bat`** | Membuat file installer APK rilis resmi (`28.3 MB`) | `flutter build apk --release` |
| **`pasang_ke_hp.bat`** | Memasang langsung APK ke smartphone via kabel data | `adb install -r buildhaus.apk` |
| **`cek_kode.bat`** | Memeriksa apakah ada kesalahan sintaks atau bug | `flutter analyze` |
| **`uji_semua_fitur.bat`** | Menjalankan 159 uji coba otomatis fitur aplikasi | `flutter test` |
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
# Membuat APK versi Release yang optimal dan siap dibagikan (28.3 MB):
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

# Menjalankan seluruh pengujian unit, widget, dan database (159 tes):
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

## 🌟 Fitur Utama BuildHaus

- 🔐 **Autentikasi Akun Lokal** — Login & registrasi aman tanpa butuh server luar.
- 🏍️ **Setup Kesehatan Motor Pertama** — Pengisian kondisi awal saat registrasi untuk langsung mengkalkulasi status kesehatan motor.
- 🔧 **Multi-Motor** — Kelola beberapa motor harian dan akhir pekan dalam satu akun.
- 📊 **Telemetri Odometer** — Tampilan instrumen kokpit modern dengan odometer tabular dan estimasi penggunaan mingguan.
- 🩺 **Skor Kesehatan Deterministik** — Memantau **14 komponen kritis** (oli mesin, rem, CVT, aki, ban, busi, coolant, rantai, oli gardan, filter udara, filter oli, shockbreaker, knalpot, minyak rem) berbasis pedoman resmi pabrikan.
- 🤖 **AI Teman Riding (Gemini 2.5 Flash)** — Konsultasi gejala motor dengan bahasa santai, respon cepat, dan hemat memori (0 MB unduhan model).
- 🛒 **Katalog Suku Cadang** — Referensi suku cadang resmi lengkap dengan foto asli WebP offline (Honda & Yamaha terisolasi rapi).
- 💰 **Budget Advisor** — Alokasi anggaran servis bulanan transparan.
- 💾 **Backup & Restore Terenkripsi** — Ekspor dan impor data lokal dalam format `.bhb` dengan enkripsi AES-256-GCM.
- 🌙 **Tema Cyber-Automotive Stealth Dark** — Palet instrumen kokpit superbike modern (`#090D14` obsidian dengan aksen cyber emerald `#00F5A0`).

---

## 📱 Struktur Halaman & Arsitektur

```
lib/
├── main.dart                  # Titik awal masuk aplikasi
├── core/
│   ├── ai/                    # Integrasi Google Gemini 2.5 Flash & Safety Guard
│   ├── database/              # SQLite lokal dengan Drift (22 tabel)
│   ├── engines/               # Logika deterministik kalkulasi kesehatan & odometer
│   ├── providers/             # Manajemen state global dengan Riverpod
│   ├── router/                # Rute navigasi aplikasi (GoRouter)
│   └── theme/                 # Palet tema Cyber-Automotive Stealth Dark
├── features/
│   ├── auth/                  # Layar Login, Register, & Setup Motor Wajib
│   ├── home/                  # Beranda Telemetri Kokpit & Aksi Cepat
│   ├── health/                # Indikator skor kesehatan 14 komponen motor
│   ├── ai_assistant/          # Layar chat konsultasi AI Gemini 2.5 Flash
│   ├── parts/                 # Katalog suku cadang dan rekomendasi budget
│   ├── service_history/       # Log riwayat servis dan penggantian part
│   └── account/               # Profil pengguna, motor terdaftar, & pengaturan
└── shared/widgets/            # Logo Apex Emblem, animasi taktil, & tombol reusable
```

---

## 📄 Lisensi
Hak Cipta © 2026 BuildHaus Project. Berlisensi di bawah lisensi MIT.
