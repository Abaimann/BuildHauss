# BUILDHAUS — PANDUAN INSTALASI MANUAL APK ANDROID

Dokumen ini merupakan panduan resmi instalasi mandiri (*offline sideloading*) untuk aplikasi **BuildHaus** pada perangkat Android tanpa melalui Google Play Store.

---

## 1. PERSYARATAN PERANGKAT (*SYSTEM REQUIREMENTS*)

| Komponen | Spesifikasi Minimum | Rekomendasi Optimal |
| :--- | :--- | :--- |
| **Sistem Operasi** | Android 8.0 (API Level 26, Oreo) | Android 11.0 (API Level 30) ke atas |
| **Arsitektur CPU** | ARM64-v8a atau x86_64 | ARM64-v8a (64-bit ARM) |
| **Memori RAM** | 2.0 GB RAM | 4.0 GB RAM atau lebih (untuk inferensi AI lokal) |
| **Penyimpanan Bebas** | 200 MB (Aplikasi dasar + SQLite DB) | 800 MB (Termasuk model AI Qwen3 0.6B GGUF) |
| **Konektivitas** | 100% Offline (Tidak perlu internet) | Internet hanya saat unduh model AI satu kali |

---

## 2. INFORMASI FILE RILIS APK

- **Nama Aplikasi:** BuildHaus
- **Package ID:** `com.buildhaus.buildhaus`
- **Versi Aplikasi:** `1.0.0`
- **Build Number:** `1`
- **Target SDK:** Android API 36
- **Minimum SDK:** Android API 26
- **Lokasi File Output:** `build/app/outputs/flutter-apk/app-release.apk`
- **Format File:** Standar Android Application Package (`.apk`)

---

## 3. LANGKAH INSTALASI LANGSUNG (SIDELOADING)

### Langkah 1: Pindahkan File APK ke Smartphone
Salin file `app-release.apk` ke penyimpanan smartphone Anda menggunakan:
- Kabel data USB (MTP file transfer),
- Kartu MicroSD, atau
- Wi-Fi Direct / Local Share (misal: Nearby Share / Quick Share).

### Langkah 2: Izinkan Instalasi Aplikasi dari Sumber Tidak Dikenal
Di Android, instalasi manual di luar Google Play Store memerlukan izin keamanan satu kali:
1. Buka **Pengaturan (Settings)** di Android Anda.
2. Masuk ke **Keamanan & Privasi (Security & Privacy)** $\to$ **Instal Aplikasi Tidak Dikenal (Install Unknown Apps)**.
3. Pilih aplikasi *File Manager* atau *Browser* yang Anda gunakan untuk membuka file APK.
4. Aktifkan toggle **"Izinkan dari sumber ini" (Allow from this source)**.

### Langkah 3: Pasang APK
1. Buka aplikasi *File Manager* dan arahkan ke folder tempat `app-release.apk` disimpan (misalnya folder `Download`).
2. Ketuk file `app-release.apk`.
3. Pilih **Install (Pasang)**.
4. Tunggu beberapa detik hingga sistem Android menyelesaikan verifikasi paket dan instalasi.

### Langkah 4: Penanganan Peringatan Google Play Protect
Karena BuildHaus didistribusikan secara mandiri tanpa Google Play Store:
- Google Play Protect mungkin menampilkan pop-up bertuliskan *"Unrecognized app"* atau *"Blocked by Play Protect"*.
- Ketuk **"More details" (Rincian selengkapnya)**.
- Pilih **"Install anyway" (Tetap pasang)**.
- Aplikasi BuildHaus dijamin bersih 100%, bebas dari pelacak, iklan, malware, dan tidak mengirim data apa pun ke internet.

---

## 4. PROSEDUR PEMBARUAN / UPGRADE APLIKASI

BuildHaus dirancang dengan integritas database SQLite backward-compatible. Untuk memperbarui aplikasi ke versi yang lebih baru:

1. **Lakukan Backup Data:**
   Buka menu **Akun $\to$ Pengaturan $\to$ Cadangkan Data**. Simpan file backup `.bhb` ke folder aman.
2. **Instal APK Versi Baru Langsung:**
   Pasang file APK versi baru **tanpa menghapus (uninstall) versi lama**.
3. Sistem Android secara otomatis akan memperbarui biner aplikasi dan menjalankan skrip migrasi database (`onUpgrade`), sehingga seluruh motor, riwayat kilometer, servis, dan pengingat tetap tersimpan utuh.

---

## 5. PEMECAHAN MASALAH (*TROUBLESHOOTING*)

### Masalah 1: "App Not Installed" / "Aplikasi Tidak Terpasang"
- **Penyebab A:** Sisa cache dari versi debug yang memiliki sertifikat signing berbeda.
  - *Solusi:* Jika sebelumnya memasang APK debug, hapus versi debug terlebih dahulu atau pastikan signing key konsisten.
- **Penyebab B:** Ruang penyimpanan internal penuh.
  - *Solusi:* Kosongkan minimal 300 MB penyimpanan internal Android Anda.

### Masalah 2: "Parse Error / Kesalahan Penguraian Paket"
- **Penyebab:** Versi Android di bawah Android 8.0 (API 26), atau file APK rusak saat transfer.
  - *Solusi:* Pastikan perangkat menjalankan Android 8.0 ke atas dan periksa ulang ukuran file APK.

### Masalah 3: Notifikasi Pengingat Servis Tidak Muncul
- **Penyebab:** Android 13 ke atas membatasi izin notifikasi secara default, atau fitur penghemat baterai (*battery optimization*) menonaktifkan alarm.
  - *Solusi:*
    1. Buka **Pengaturan $\to$ Aplikasi $\to$ BuildHaus $\to$ Notifikasi**, pastikan toggle notifikasi aktif.
    2. Pada menu **Baterai $\to$ Penggunaan Baterai Aplikasi**, pilih **"Tanpa Batasan" (Unrestricted)** agar pengingat servis dapat berbunyi tepat waktu.
