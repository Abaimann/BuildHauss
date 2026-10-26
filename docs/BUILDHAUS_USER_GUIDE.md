# BUILDHAUS — PANDUAN PENGGUNA RESMI (*USER MANUAL*)

Selamat datang di **BuildHaus** (*Built for every ride*). BuildHaus adalah asisten perawatan sepeda motor pribadi berbasis Android yang dirancang dengan filosofi **100% Offline-First**.

Seluruh data Anda—mulai dari informasi motor, kilometer, riwayat servis, kondisi komponen, keluhan, anggaran perawatan, hingga percakapan AI—disimpan secara aman di dalam database SQLite lokal smartphone Anda. Tidak ada data yang dikirim ke server online, cloud, atau pihak ketiga.

---

## 1. MEMULAI APLIKASI & MENAMBAHKAN MOTOR

Saat pertama kali membuka BuildHaus:
1. Ketuk tombol **"Tambah Motor Pertama"** di halaman Beranda.
2. Isi informasi motor Anda:
   - **Nama Panggilan Motor:** (Contoh: *Vario Harian*, *Aerox Touring*, *Scoopy Merah*).
   - **Model Pabrikan:** Pilih model motor Anda dari katalog (Honda Vario 160, Beat, Yamaha Aerox, NMAX, dll.).
   - **Tahun Pembuatan:** Masukkan tahun produksi motor Anda.
   - **Nomor Plat Kendaraan:** (Opsional, contoh: *B 1234 ABC*).
   - **Kilometer Awal:** Masukkan angka kilometer yang tertera pada speedometer saat ini.
   - **Profil Penggunaan:** Pilih antara *Harian / Santai*, *Komuter Kantor*, *Kurir / Ojek Online*, atau *Touring Jarak Jauh*.
3. Ketuk **"Simpan Kendaraan"**. Motor Anda akan langsung aktif di dashboard.

> [!TIP]
> **Dukungan Multi-Motor:** Anda dapat menambahkan lebih dari satu sepeda motor. Untuk berganti motor aktif, ketuk kartu motor di bagian atas halaman Beranda. Seluruh riwayat kilometer, servis, keluhan, dan rekomendasi budget akan otomatis menyesuaikan dengan motor yang sedang dipilih.

---

## 2. PENCATATAN KILOMETER & PREDIKSI PENGGUNAAN (*ODOMETER ENGINE*)

Akurasi perkiraan perawatan motor Anda sangat bergantung pada data kilometer.

### Cara Mencatat Kilometer Baru:
1. Di halaman Beranda, ketuk pintasan **"Catat KM"** atau buka menu Odometer.
2. Masukkan angka kilometer speedometer terbaru motor Anda.
3. Ketuk **"Simpan Catatan"**.

### Cara Kerja *Mileage Predictor*:
- **Fase Pembelajaran (3 Periode Bulanan):** Engine akan menganalisis pola berkendara Anda selama 3 rentang bulanan terpisah untuk menentukan rata-rata kilometer harian (`kmPerDay`).
- **Estimasi Harian & Bulanan:** Setelah data tercatat, BuildHaus dapat memprediksi sisa hari hingga komponen tertentu memerlukan servis rutin tanpa perlu Anda hitung manual.
- **Tahan Kesalahan (Fault-Tolerant):** Odometer engine secara otomatis mengabaikan input kilometer negatif atau penurunan drastis akibat kesalahan ketik agar tidak merusak akurasi kalkulasi.

---

## 3. PEMANTAUAN KESEHATAN KOMPONEN (*HEALTH ENGINE*)

Tab **"Sehat"** menyajikan status kesehatan dari 8 komponen kritis motor Anda:
1. **Oli Mesin**
2. **Oli Transmisi (Gardan)**
3. **Busi**
4. **Filter Udara**
5. **Kampas Rem Depan**
6. **Kampas Rem Belakang**
7. **V-Belt / Rantai Roda**
8. **Ban (Depan & Belakang)**

### Arti Status Kesehatan:
- 🟢 **Baik (*Good*):** Komponen masih dalam rentang kilometer dan waktu aman servis (Skor 70–100).
- 🟡 **Peringatan (*Warning*):** Komponen mulai mendekati batas interval penggantian (Skor 40–69).
- 🔴 **Ganti Segera (*Replace*):** Komponen telah melampaui batas jarak tempuh servis pabrikan atau terdeteksi aus parah (Skor 0–39). Segera jadwalkan penggantian.
- ⚪ **Belum Ada Data (*Unknown*):** Menunjukkan bahwa komponen ini belum pernah dicatat riwayat servisnya sejak motor ditambahkan. BuildHaus melaporkan status ini secara jujur tanpa menebak-nebak kondisi motor Anda.

---

## 4. PEMERIKSAAN MANDIRI (*SELF-INSPECTION*)

Jika motor terasa kurang nyaman tetapi Anda belum tahu pasti penyebabnya:
1. Buka tab **"Sehat"** $\to$ pilih **"Pemeriksaan Mandiri"**.
2. Jawab kuesioner gejala sederhana mengenai:
   - Kondisi pengereman dan tuas rem,
   - Bunyi decit atau getaran pada CVT/rantai,
   - Asap knalpot atau kebocoran cairan di bawah mesin,
   - Keausan alur ban dan kestabilan stang kemudi.
3. Ketuk **"Selesai & Evaluasi"**.
4. Sistem akan mendeteksi tingkat risiko dan memberikan rekomendasi tindakan apakah motor perlu segera dibawa ke bengkel resmi.

---

## 5. SMART BUDGET & REKOMENDASI BIAYA PERAWATAN

Tab **"Sparepart"** dan menu **"Smart Budget"** membantu Anda merencanakan pengeluaran servis motor secara terukur:

1. **Masukkan Anggaran Anda:** Ketik jumlah uang yang Anda siapkan (misalnya Rp 150.000, Rp 300.000, atau Rp 0).
2. **Prioritas Keselamatan Utama:**
   - Budget Engine memprioritaskan komponen keselamatan kritis (Rem dan Ban) terlebih dahulu sebelum komponen kenyamanan/performa.
   - Sparepart yang terdanai akan diberi label hijau **"Terdanai"**, sedangkan komponen yang dananya belum cukup akan diberi label **"Belum Terdanai"**.
3. **Katalog Suku Cadang Asli:**
   - Rekomendasi menggunakan kode part pabrikan resmi (AHM Honda / YGP Yamaha) lengkap dengan estimasi harga eceran tertinggi dan perkiraan ongkos jasa pasang standar bengkel.
4. **Rencana Menabung (*Savings Plan*):**
   - Jika biaya servis melebihi budget Anda, BuildHaus secara otomatis menyusun rencana tabungan mingguan dan bulanan agar motor tetap terawat tanpa membebani keuangan harian.

---

## 6. ASISTEN AI OFFLINE & KONSULTASI KELUHAN

Menu **"Konsultasi AI"** di Beranda memungkinkan Anda berkonsultasi mengenai keluhan motor dalam Bahasa Indonesia sehari-hari:

### Dua Mode Inferensi:
1. **Mode Rule-Based Fallback (Transparan & Ringan):**
   - Aktif secara bawaan tanpa perlu mengunduh file besar.
   - Menggunakan engine pencocokan gejala terstruktur dan data riwayat motor aktif.
2. **Mode Real Offline LLM (Qwen3 0.6B GGUF via llama.cpp):**
   - Menjalankan model bahasa kecerdasan buatan langsung pada prosesor ARM64 smartphone Anda.
   - Bekerja 100% tanpa internet (dalam mode pesawat sekalipun).

### Cara Memasang Model AI:
1. Buka menu **Akun $\to$ Kelola Model AI**.
2. Sambungkan smartphone ke Wi-Fi.
3. Ketuk **"Unduh Model (Qwen3 0.6B GGUF)"** (~350 MB).
4. Aplikasi akan mengunduh model dari repositori resmi dan secara otomatis memverifikasi keaslian biner menggunakan checksum SHA-256.
5. Setelah status model berubah menjadi **"Terinstal"**, Anda dapat mematikan internet dan mulai berkonsultasi secara lokal.

> [!CAUTION]
> **AI Safety Guard:** Jika Anda mengetik keluhan berbahaya seperti rem blong, kebocoran bensin, ban pecah, atau stang macet, sistem keselamatan otomatis akan memunculkan peringatan darurat merah dan melarang Anda mengendarai motor di jalan raya demi keselamatan jiwa Anda.

---

## 7. PENGINGAT LOKAL (*NOTIFICATIONS & REMINDERS*)

BuildHaus dilengkapi engine pengingat lokal yang berjalan hemat baterai:
- **Pengingat Odometer:** Muncul jika Anda belum memperbarui angka kilometer motor selama lebih dari 30 hari.
- **Pengingat Jadwal Servis:** Muncul saat komponen motor mendekati atau melewati batas jarak tempuh servis.
- **Pengingat Keluhan Terbuka:** Memberi peringatan jika ada keluhan motor yang sudah tercatat lebih dari 3 hari tetapi belum diperbaiki di bengkel.
- **Pengingat Manual:** Anda dapat menambahkan pengingat kustom dengan memilih tanggal dan catatan perawatan di menu **Akun $\to$ Pengingat Servis $\to$ Tambah Pengingat**.

---

## 8. CADANGAN DATA (*BACKUP*) & PEMULIHAN (*RESTORE*) OFFLINE

Untuk melindungi data kendaraan Anda dari kehilangan saat ganti smartphone atau reset perangkat:

### Cara Membuat Backup:
1. Buka menu **Akun $\to$ Pengaturan $\to$ Cadangkan Data**.
2. Masukkan kata sandi (*passphrase*) opsional untuk mengenkripsi file.
3. Ketuk **"Buat Cadangan (.bhb)"**.
4. File backup berformat `.bhb` (*BuildHaus Backup*) akan tersimpan di memori perangkat. File ini dilindungi oleh enkripsi standar NIST **AES-256-GCM** dan derivasi kunci **PBKDF2-HMAC-SHA256 (100.000 iterasi)**.

### Cara Memulihkan Data:
1. Buka menu **Akun $\to$ Pengaturan $\to$ Pulihkan Data**.
2. Pilih file `.bhb` yang telah Anda simpan.
3. Masukkan kata sandi enkripsi (jika file terenkripsi).
4. Layar pratinjau akan menampilkan ringkasan data (jumlah motor, log km, servis, keluhan).
5. Ketuk **"Pulihkan Sekarang"**. Seluruh data akan dipulihkan secara aman dalam satu transaksi database SQLite tanpa merusak data master katalog pabrikan.

---

## 9. PENGATURAN TEMA & PRIVASI

Di menu **Akun $\to$ Pengaturan**, Anda dapat:
- Memilih tema tampilan: **Mode Terang (*Light*)**, **Mode Gelap (*Dark*)**, atau **Mengikuti Sistem Android**.
- Mengatur interval pengingat pembaruan odometer (14, 30, atau 60 hari).
- Mengaktifkan/menonaktifkan seluruh notifikasi pengingat motor.
- Melakukan penghapusan seluruh data pengguna (*factory reset database*) dengan konfirmasi keamanan ganda.
