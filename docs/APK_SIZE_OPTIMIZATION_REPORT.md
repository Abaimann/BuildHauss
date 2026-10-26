# BuildHaus — Laporan Optimasi Ukuran APK & Kompresi Aplikasi (Tahap A–L)

**Tanggal Audit & Optimasi**: 26 Oktober 2026  
**Lingkungan Build**: Flutter `3.38.5` (stable) • Dart `3.10.4` • Android NDK `28.2.13676358` • AGP `8.11.1` • Kotlin `2.2.20`  
**Target Perangkat Uji**: Android Emulator `emulator-5554` (`x86_64`, Android API 36)

---

## 1. Ukuran APK Sebelum Optimasi (Baseline Aktual)

Sebelum perubahan apa pun dilakukan, pengukuran baseline dijalankan menggunakan `flutter build apk --release` pada kondisi kode commit `009fe46`:

| Varian Artefak / Metrik Baseline | Ukuran Byte Aktual | Ukuran Desimal (MB) | Ukuran Biner (MiB) | Status Build Awal |
| :--- | ---: | ---: | ---: | :--- |
| **Universal Release APK (`app-release.apk`)** | `72.131.330` B | **72,13 MB** | **68,79 MiB** | Berhasil |
| **Debug APK (`app-debug.apk`)** | `214.481.652` B | **214,48 MB** | **204,55 MiB** | Berhasil |
| **Split-per-ABI Release APK (`--split-per-abi`)** | — | — | — | **GAGAL (`EvalIssueException`)** |
| **Installed App Footprint (`emulator-5554`)** | `72.069.120` B (`70.380` KB) | **72,07 MB** | **68,73 MiB** | Terinstal (`base.apk` tidak terkompresi) |

> **Catatan Kegagalan Split-per-ABI pada Baseline**: Perintah `flutter build apk --release --split-per-abi` gagal pada baseline dengan error Gradle:  
> `Conflicting configuration : 'arm64-v8a,x86_64' in ndk abiFilters cannot be present when splits abi filters are set : armeabi-v7a,x86_64,arm64-v8a`.

---

## 2. Analisis Komposisi APK Sebelum Optimasi (Tahap A)

Inspeksi struktur entri ZIP pada `app-release.apk` (`72.131.330` bytes) sebelum optimasi menghasilkan rincian berikut:

| Komponen / Kategori | Jumlah Entri | Ukuran Awal di APK (Compressed) | Ukuran Uncompressed | Persentase APK | Potensi Optimasi |
| :--- | ---: | ---: | ---: | ---: | :--- |
| **1. Flutter Engine (`libflutter.so` — 3 ABI)** | 3 | `31.548.768` B (31,55 MB) | `31.548.768` B | **43,74%** | **Tinggi** — Disimpan `STORED` (0% kompresi ZIP); dapat dikompresi via `useLegacyPackaging` & dipisah per ABI |
| **2. Dart AOT Code (`libapp.so` — 3 ABI)** | 3 | `28.428.732` B (28,43 MB) | `28.428.732` B | **39,41%** | **Tinggi** — Disimpan `STORED` (0% kompresi ZIP) & memuat `444 KB`/ABI data historis `timezone/latest_all.dart` |
| **3. `llama.cpp` + `ggml` + `libomp.so` (`arm64-v8a`)** | 6 | `5.702.856` B (5,70 MB) | `5.702.856` B | **7,91%** | **Tinggi** — Disimpan `STORED` (0% kompresi ZIP); simbol debug sudah di-strip oleh `llvm-strip`, dapat dikompresi Deflate ~62% |
| **4. Native Shared Libraries Lain (`libsqlite3.so`, `libdartjni.so`, `libdatastore_shared_counter.so`)** | 9 | `4.948.964` B (4,95 MB) | `4.948.964` B | **6,86%** | **Tinggi** — Disimpan `STORED`; `libdatastore_shared_counter.so` (3 ABI) berasal dari plugin `shared_preferences` yang tidak digunakan |
| **5. Java/Kotlin Bytecode (`classes.dex`)** | 1 | `746.488` B (746,5 KB) | `1.738.516` B | **1,03%** | **Sedang** — Memuat kode plugin `shared_preferences` / AndroidX DataStore yang tidak terpakai |
| **6. Android Resources (`resources.arsc` + `res/*` + `AndroidManifest.xml`)** | 353 | `342.143` B (342,1 KB) | `419.697` B | **0,47%** | **Tinggi** — 278 resource AndroidX/AppCompat tidak terpakai dapat dipangkas dengan `isShrinkResources = true` |
| **7. Lisensi Open Source (`assets/flutter_assets/NOTICES.Z`)** | 1 | `119.261` B (119,3 KB) | `121.271` B | **0,17%** | **Rendah-Sedang** — Berkurang otomatis saat dependency tidak terpakai dihapus |
| **8. Material Icons (`MaterialIcons-Regular.otf`)** | 1 | `8.075` B (8,1 KB) | `13.812` B | **0,01%** | **Sudah Optimal** — Telah ter-*tree-shake* 99,2% dari `1.645.184` B menjadi `13.812` B |
| **9. Flutter Shaders (`ink_sparkle.frag`, `stretch_effect.frag`)** | 2 | `8.576` B (8,6 KB) | `38.688` B | **0,01%** | **Wajib Dipertahankan** (Material 3 visual effects) |
| **10. JSON Catalogs (`spareparts.json`, `rules_v1.json`, `motorcycle_models.json`)** | 3 | `2.586` B (2,6 KB) | `15.759` B | **<0,01%** | **Rendah** — Pemadatan whitespace lossless (tanpa mengubah isi semantik) |
| **11. Ikon & Manifest Asset (`assets/icons/*`, `AssetManifest.bin`, `FontManifest.json`)** | 10 | `2.150` B (2,2 KB) | `6.492` B | **<0,01%** | **Dipertahankan** |
| **12. Font Plus Jakarta Sans (`.ttf`)** | 0 | `0` B | `0` B | **0,00%** | **Sudah Optimal** — Dimuat & di-cache secara on-demand oleh `google_fonts` tanpa membebani ukuran APK |
| **13. Metadata, `kotlin/`, `META-INF/`, `DebugProbesKt.bin` & Padding 16KB Alignment** | 70 | `172.731` B (172,7 KB) | `61.344` B + pad | **0,39%** | **Tinggi** — `DebugProbesKt.bin`, `kotlin-tooling-metadata.json`, dan padding `STORED` 16KB dapat dihapus |
| **TOTAL UNIVERSAL APK (BASELINE)** | **463** | **`72.131.330` B (72,13 MB)** | **`72.033.038` B** | **100,00%** | — |

---

## 3. Penyebab Utama Ukuran APK (Root Cause Based on Evidence)

Berdasarkan bukti aktual di atas, terdapat **4 penyebab utama** mengapa APK release berukuran **72,13 MB (68,79 MiB)**:

1. **Native Libraries (`.so`) Disimpan Tanpa Kompresi (`STORED`, 100% Ratio) — Kontribusi 97,92% (`70,63 MB`)**:
   - Karena `minSdk = 26` ($\ge 23$) dan `packaging.jniLibs.useLegacyPackaging` tidak dikonfigurasi, Android Gradle Plugin (AGP) menyimpan seluruh 21 file `.so` secara **tidak terkompresi (`STORED`)** beserta *16 KB page-alignment padding* di dalam file APK.
   - Dampaknya ganda: ukuran file/unduhan APK membengkak lebih dari 2x lipat, dan ketika pengguna menginstal Universal APK, ketiganya (`arm64-v8a` 27,59 MB + `x86_64` 23,32 MB + `armeabi-v7a` 19,72 MB) tetap tersimpan secara tidak terkompresi di dalam `/data/app/.../base.apk` (`70,38 MB`), padahal perangkat hanya memakai 1 arsitektur ABI.
2. **Penggabungan 3 ABI Sekaligus di Universal APK & Konflik `--split-per-abi`**:
   - Meskipun `defaultConfig.ndk.abiFilters` di `android/app/build.gradle.kts` menulis `listOf("arm64-v8a", "x86_64")`, plugin `dev.flutter.flutter-gradle-plugin` menyuntikkan `armeabi-v7a`, `arm64-v8a`, dan `x86_64` ke `buildTypes.release.ndk.abiFilters`.
   - Selain itu, deklarasi `ndk.abiFilters` tanpa pengecekan `!project.hasProperty("split-per-abi")` menyebabkan perintah `flutter build apk --release --split-per-abi` gagal total.
3. **Database Timezone Historis Abad ke-19 (`timezone/data/latest_all.dart`) di `libapp.so`**:
   - File `lib/core/notifications/notification_service.dart` mengimpor `package:timezone/data/latest_all.dart` (`1,33 MB` source Dart yang menyematkan `444.520` bytes konstanta biner timezone historis sejak abad ke-19 ke dalam `libapp.so` untuk setiap ABI = ~`1,08 MB` di Universal APK).
4. **Dependency Tidak Terpakai di `pubspec.yaml` & Resource Android Belum Di-shrink Secara Eksplisit**:
   - Empat package di `dependencies:` (`shared_preferences`, `flutter_svg`, `uuid`, `riverpod_annotation`) memiliki **0 import** di seluruh kode aplikasi (`lib/` maupun `test/`).
   - Keberadaan `shared_preferences` mendaftarkan `SharedPreferencesPlugin` secara otomatis di `GeneratedPluginRegistrant.java`, menarik pustaka AndroidX DataStore ke `classes.dex`, dan menyertakan 3 file native `libdatastore_shared_counter.so`.

---

## 4. Teknik Optimasi yang Dilakukan (Tahap B–F)

Seluruh optimasi dilakukan secara terukur tanpa menghapus fitur, tanpa menurunkan kualitas visual/UI, dan tanpa mengurangi kompatibilitas perangkat:

1. **Kompresi Deflate Native Libraries (`useLegacyPackaging = true`) & Pembersihan Metadata Build (`Tahap B`)**:
   - Mengaktifkan `packaging.jniLibs.useLegacyPackaging = true` pada `android/app/build.gradle.kts` sehingga seluruh file `.so` dikompresi dengan algoritma Deflate di dalam APK (mengurangi ukuran `lib/*` di dalam Universal APK dari `70,63 MB` menjadi `30,71 MB`).
   - Menambahkan pengecualian metadata debug Kotlin (`DebugProbesKt.bin`, `kotlin-tooling-metadata.json`, `META-INF/*.version`, `META-INF/proguard/**`).
2. **Aktivasi Eksplisit R8 Minification, Resource Shrinking & Aturan Keamanan ProGuard (`Tahap B`)**:
   - Menetapkan `isMinifyEnabled = true` dan `isShrinkResources = true` secara eksplisit pada `buildTypes.release` di `android/app/build.gradle.kts`.
   - Menambahkan aturan `-keep class com.dexterous.flutterlocalnotifications.** { *; }` dan `-keepattributes Signature, InnerClasses, EnclosingMethod, RuntimeVisibleAnnotations` pada `android/app/proguard-rules.pro` untuk menjamin serialisasi Gson pada fitur notifikasi lokal tetap aman dari R8.
   - Hasil: `resources.arsc` menyusut **69,4%** (`179,2 KB` $\rightarrow$ `54,8 KB`), file di `res/` menyusut dari **351 file (`160,9 KB`) menjadi 73 file (`32,0 KB`)**, dan `classes.dex` menyusut **32,5%** (`746,5 KB` $\rightarrow$ `503,8 KB`).
3. **Perbaikan Konfigurasi ABI & Dukungan Penuh `--split-per-abi` (`Tahap C`)**:
   - Membungkus `ndk.abiFilters` di `android/app/build.gradle.kts` dengan kondisi `if (!project.hasProperty("split-per-abi"))` sehingga:
     - Pembuatan **Universal APK** (`flutter build apk --release`) tetap mempertahankan ketiga ABI (`arm64-v8a`, `x86_64`, `armeabi-v7a`).
     - Pembuatan **ABI-Specific APK** (`flutter build apk --release --split-per-abi`) kini berhasil tanpa error dan menghasilkan APK terpisah untuk `arm64-v8a` (**12,48 MB / 11,90 MiB**), `x86_64` (**10,54 MB / 10,05 MiB**), dan `armeabi-v7a` (**9,98 MB / 9,52 MiB**).
4. **Evaluasi & Rollback Eksperimen Flag CMake `-O3` pada Native `llama.cpp` (`Tahap D & K`)**:
   - Selama eksperimen Tahap D, diuji penambahan override `-DCMAKE_C_FLAGS_RELWITHDEBINFO=-O3 -DNDEBUG` pada subproject `:llama_flutter_android`.
   - Pengukuran byte-per-byte menunjukkan bahwa `-O3` menyebabkan Clang melakukan *aggressive loop unrolling* dan *template inlining* yang justru menambah ukuran *uncompressed* `libggml-cpu.so`, `libggml.so`, dan `libllama_jni.so` sebesar `+500,7 KB` (`+221,4 KB` *compressed*).
   - Sesuai aturan **Tahap K**, override `-O3` tersebut **di-rollback**, sehingga pustaka native `llama.cpp` tetap menggunakan konfigurasi ukuran yang lebih ramping (`27,25 MB` *uncompressed* / `11,72 MB` *compressed* untuk seluruh `lib/arm64-v8a`).
5. **Pemadatan Lossless JSON Catalogs (`Tahap E`)**:
   - Memadatkan spasi/indentasi secara *lossless* (dengan memverifikasi *round-trip semantic equivalence* `jsonEncode(jsonDecode(x))`) pada `assets/catalogs/motorcycle_models.json` (`3.951` B $\rightarrow$ `3.398` B), `assets/catalogs/spareparts.json` (`6.522` B $\rightarrow$ `5.022` B), dan `assets/maintenance_rules/rules_v1.json` (`5.286` B $\rightarrow$ `3.993` B). Seluruh data model motor, sparepart, dan aturan servis 100% identik.
6. **Optimasi Database Timezone & Pembersihan Dependency Tidak Terpakai (`Tahap F`)**:
   - Mengganti `import 'package:timezone/data/latest_all.dart'` menjadi `import 'package:timezone/data/latest_10y.dart'` pada `lib/core/notifications/notification_service.dart` (baris 4), yang memangkas ukuran biner `libapp.so` sebesar **`1.081.344` bytes (`1,08 MB` *uncompressed*)** secara total di 3 ABI tanpa mengubah fungsi `Asia/Jakarta` maupun `UTC`.
   - Menghapus 4 dependency tidak terpakai (`shared_preferences`, `flutter_svg`, `uuid`, `riverpod_annotation`) serta 3 dev_dependencies tidak terpakai (`riverpod_generator`, `custom_lint`, `riverpod_lint`) dari `pubspec.yaml`, yang menghilangkan `SharedPreferencesPlugin` dan 3 file native `libdatastore_shared_counter.so`.

---

## 5. File Konfigurasi & Kode yang Berubah

| File | Perubahan yang Dilakukan |
| :--- | :--- |
| `android/app/build.gradle.kts` | Menambahkan guard `if (!project.hasProperty("split-per-abi"))` pada `ndk.abiFilters`, menambahkan `packaging.jniLibs.useLegacyPackaging = true` & eksklusi metadata debug, serta mengaktifkan `isMinifyEnabled = true` dan `isShrinkResources = true` secara eksplisit pada `buildTypes.release`. |
| `android/app/proguard-rules.pro` | Menambahkan aturan keep untuk `com.dexterous.flutterlocalnotifications.**` dan atribut refleksi Gson (`Signature, InnerClasses, EnclosingMethod, RuntimeVisibleAnnotations`). |
| `pubspec.yaml` | Menghapus package yang memiliki 0 referensi pemakaian (`shared_preferences`, `flutter_svg`, `uuid`, `riverpod_annotation`, `riverpod_generator`, `custom_lint`, `riverpod_lint`). |
| `pubspec.lock` | Diperbarui otomatis melalui `flutter pub get`. |
| `lib/core/notifications/notification_service.dart` | Mengganti import `package:timezone/data/latest_all.dart` menjadi `package:timezone/data/latest_10y.dart` (baris 4). |
| `assets/catalogs/motorcycle_models.json` | Lossless JSON whitespace compaction (`3.951` B $\rightarrow$ `3.398` B). |
| `assets/catalogs/spareparts.json` | Lossless JSON whitespace compaction (`6.522` B $\rightarrow$ `5.022` B). |
| `assets/maintenance_rules/rules_v1.json` | Lossless JSON whitespace compaction (`5.286` B $\rightarrow$ `3.993` B). |

---

## 6. Daftar Asset yang Dioptimalkan & Dipertahankan

| Asset Path | Ukuran Raw Sebelum | Ukuran Raw Sesudah | Ukuran di APK (Compressed) | Status Kualitas & Isi |
| :--- | ---: | ---: | ---: | :--- |
| `assets/catalogs/spareparts.json` | `6.522` B | `5.022` B | `985` B | **Lossless JSON** — 100% data identik |
| `assets/maintenance_rules/rules_v1.json` | `5.286` B | `3.993` B | `757` B | **Lossless JSON** — 100% data identik |
| `assets/catalogs/motorcycle_models.json` | `3.951` B | `3.398` B | `709` B | **Lossless JSON** — 100% data identik |
| `assets/flutter_assets/NOTICES.Z` | `121.271` B | `113.125` B | `111.505` B | Otomatis menyusut `8.146` B karena penghapusan package tidak terpakai |
| `assets/flutter_assets/fonts/MaterialIcons-Regular.otf` | `13.812` B | `13.812` B | `8.075` B | **100% Identik** (Tree-shaken 99,2% dari 1,64 MB) |
| `assets/icons/logo_buildhaus.svg` & `logo_simple.svg` | `2.696` B | `2.696` B | `905` B | **100% Identik** |
| `assets/icons/ic_launcher*.xml` | `2.887` B | `2.887` B | `917` B | **100% Identik** |

---

## 7. Native Libraries (`.so`) yang Dipertahankan vs Dihapus

### A. Dipertahankan Sepenuhnya (18 File `.so` di Universal APK; 10 File di `arm64-v8a`)
| Library Native (`.so`) | ABI Tersedia | Ukuran Uncompressed (`arm64-v8a`) | Ukuran di APK (`DEFLATED`) | Fungsi Kritis yang Dipertahankan |
| :--- | :--- | ---: | ---: | :--- |
| `libflutter.so` | `arm64-v8a`, `x86_64`, `armeabi-v7a` | `11.107.920` B (10,85 MB) | `5.253.283` B (5,13 MB) | Engine utama Flutter & Impeller/Skia |
| `libapp.so` | `arm64-v8a`, `x86_64`, `armeabi-v7a` | `8.782.768` B (8,58 MB) | `3.500.286` B (3,42 MB) | Kode aplikasi Dart AOT (menyusut `327 KB` di ARM64 / `1,08 MB` total 3 ABI) |
| `libllama.so` | `arm64-v8a` | `2.857.984` B (2,79 MB) | `1.066.102` B (1,04 MB) | Core inference engine `llama.cpp` untuk model GGUF Qwen3 |
| `libsqlite3.so` | `arm64-v8a`, `x86_64`, `armeabi-v7a` | `1.526.536` B (1,49 MB) | `781.176` B (762,9 KB) | Mesin database SQLite FFI (`drift` + `sqlite3_flutter_libs`) |
| `libggml-base.so` | `arm64-v8a` | `980.920` B (957,9 KB) | `375.707` B (366,9 KB) | Tensor & quantization library dasar GGML |
| `libomp.so` | `arm64-v8a` | `965.024` B (942,4 KB) | `334.806` B (327,0 KB) | Runtime multithreading OpenMP untuk inferensi CPU `ggml` |
| `libggml-cpu.so` | `arm64-v8a` | `734.056` B (716,9 KB) | `306.378` B (299,2 KB) | Backend akselerasi instruksi ARM NEON / CPU GGML |
| `libdartjni.so` | `arm64-v8a`, `x86_64`, `armeabi-v7a` | `131.400` B (128,3 KB) | `26.051` B (25,4 KB) | Bridge JNI untuk `path_provider` |
| `libggml.so` | `arm64-v8a` | `119.672` B (116,9 KB) | `52.349` B (51,1 KB) | Registrasi backend GGML |
| `libllama_jni.so` | `arm64-v8a` | `45.200` B (44,1 KB) | `20.136` B (19,7 KB) | Wrapper JNI `llama_flutter_android` |

### B. Dihapus karena Tidak Digunakan (3 File `.so`)
- `lib/arm64-v8a/libdatastore_shared_counter.so` (`7.112` B)
- `lib/x86_64/libdatastore_shared_counter.so` (`6.224` B)
- `lib/armeabi-v7a/libdatastore_shared_counter.so` (`4.416` B)  
*(Ketiganya berasal dari plugin `shared_preferences` yang sama sekali tidak digunakan karena BuildHaus menyimpan seluruh pengaturan di tabel SQLite `app_settings` melalui Drift).*

---

## 8 & 9. Hasil Ukuran Setelah Optimasi & Persentase Pengurangan Aktual (Tahap K)

Rumus yang digunakan:  
$$\text{Pengurangan (\%)} = \frac{\text{Ukuran Awal} - \text{Ukuran Akhir}}{\text{Ukuran Awal}} \times 100$$

### A. Perbandingan Langsung pada Artefak yang Sama (Apple-to-Apple: Universal APK 3 ABI)

| Metrik | Sebelum Optimasi | Sesudah Optimasi | Perubahan Absolut | Persentase Pengurangan |
| :--- | ---: | ---: | ---: | ---: |
| **Universal Release APK (`app-release.apk` — 3 ABI)** | `72.131.330` B (**72,13 MB** / 68,79 MiB) | `31.474.493` B (**31,47 MB** / 30,02 MiB) | **`-40.656.837` B (-40,66 MB)** | **`-56,37%`** |
| **Native Libraries di Universal APK (Compressed)** | `70.629.320` B (70,63 MB) | `30.712.932` B (30,71 MB) | `-39.916.388` B (-39,92 MB) | **`-56,52%`** |
| **Native Libraries di Universal APK (Uncompressed)** | `70.629.320` B (70,63 MB) | `69.530.224` B (69,53 MB) | `-1.099.096` B (-1,10 MB) | **`-1,56%`** |
| **Dart AOT `libapp.so` (Uncompressed — Total 3 ABI)** | `28.428.732` B (28,43 MB) | `27.347.388` B (27,35 MB) | `-1.081.344` B (-1,08 MB) | **`-3,80%`** |
| **Dart AOT `libapp.so` (Compressed di Universal APK)** | `28.428.732` B (28,43 MB) | `10.911.958` B (10,91 MB) | `-17.516.774` B (-17,52 MB) | **`-61,62%`** |
| **`classes.dex` (Compressed di APK)** | `746.488` B (746,5 KB) | `503.815` B (503,8 KB) | `-242.673` B (-242,7 KB) | **`-32,51%`** |
| **Android Resources (`resources.arsc` + `res/*`)** | `340.071` B (340,1 KB, 352 file) | `86.780` B (86,8 KB, 74 file) | `-253.291` B (-253,3 KB) | **`-74,48%`** |
| **Flutter Assets (`assets/flutter_assets/*` Compressed)** | `140.648` B (140,6 KB) | `132.757` B (132,8 KB) | `-7.891` B (-7,9 KB) | **`-5,61%`** |
| **Flutter Assets (`assets/flutter_assets/*` Uncompressed)** | `196.022` B (196,0 KB) | `184.530` B (184,5 KB) | `-11.492` B (-11,5 KB) | **`-5,86%`** |
| **Installed App Size di Perangkat (Universal APK)** | `70.380` KB (**72,07 MB** / 68,73 MiB) | `53.168` KB (**54,44 MB** / 51,92 MiB) | **`-17.212` KB (-17,63 MB)** | **`-24,46%`** |
| **Debug APK (`app-debug.apk`)** | `214.481.652` B (**214,48 MB**) | `86.809.098` B (**86,81 MB**) | **`-127.672.554` B (-127,67 MB)** | **`-59,53%`** |

### B. Pengurangan Tambahan dari ABI-Specific Packaging (`--split-per-abi`)

Selain pengurangan pada Universal APK di atas, pemisahan APK per arsitektur prosesor (`flutter build apk --release --split-per-abi`) menghilangkan duplikasi binary lintas-ABI sehingga menghasilkan ukuran distribusi dan ukuran instalasi yang jauh lebih kecil:

| Varian ABI-Specific APK | Ukuran Sebelum (Baseline Universal) | Ukuran Sesudah (ABI-Specific APK) | Pengurangan vs Baseline Universal | Installed App Size di Perangkat |
| :--- | ---: | ---: | ---: | ---: |
| **ARM64 APK (`app-arm64-v8a-release.apk`)** *(HP Android 64-bit + Full Native AI `llama.cpp`)* | `72.131.330` B (72,13 MB / 68,79 MiB) | **`12.476.825` B (12,48 MB / 11,90 MiB)** | **`-59.654.505` B (`-82,70%`)** | **~39,73 MB** (`-44,87%` vs baseline) |
| **x86_64 APK (`app-x86_64-release.apk`)** *(Emulator / Perangkat x86_64 + Fallback AI)* | `72.131.330` B (72,13 MB / 68,79 MiB) | **`10.535.259` B (10,54 MB / 10,05 MiB)** | **`-61.596.071` B (`-85,40%`)** | **`32.720` KB / 33,51 MB** (`-53,51%` vs baseline) |
| **ARMv7 APK (`app-armeabi-v7a-release.apk`)** *(HP Android 32-bit lama + Fallback AI)* | `72.131.330` B (72,13 MB / 68,79 MiB) | **`9.980.951` B (9,98 MB / 9,52 MiB)** | **`-62.150.379` B (`-86,16%`)** | **~29,33 MB** (`-59,30%` vs baseline) |

---

## 10, 11 & 12. Hasil Verifikasi Build, Static Analysis & Automated Tests (Tahap I)

| Pemeriksaan | Perintah | Hasil Sebelum | Hasil Sesudah | Status |
| :--- | :--- | :--- | :--- | :--- |
| **Code Generation** | `dart run build_runner build --delete-conflicting-outputs` | 156 outputs | 156 outputs (0 errors) | **LULUS** |
| **Static Analysis** | `flutter analyze` | 0 issues found | **0 issues found** (7,1s) | **LULUS** |
| **Unit, Database, Engine, AI & Widget Tests** | `flutter test` | 152/152 passed | **152/152 passed** (100%) | **LULUS** |
| **Release Universal APK Build** | `flutter build apk --release` | 68,79 MiB (72,13 MB) | **30,02 MiB (31,47 MB)** | **LULUS** |
| **Release Split-per-ABI Build** | `flutter build apk --release --split-per-abi` | Gagal (`EvalIssueException`) | **Berhasil (11,90 MiB ARM64 / 10,05 MiB x86_64 / 9,52 MiB ARMv7)** | **LULUS** |
| **Debug APK Build** | `flutter build apk --debug` | 204,55 MiB (214,48 MB) | **82,79 MiB (86,81 MB)** | **LULUS** |

---

## 13, 14 & 15. Hasil Verifikasi Android Emulator, Visual Regression & Pengujian AI (Tahap H & J)

Pengujian langsung dilakukan pada `emulator-5554` dengan menginstal APK release hasil optimasi secara *in-place* (`adb install -r`) tanpa menghapus data pengguna:

1. **Instalasi & Penyimpanan**:
   - Baik `app-release.apk` (Universal) maupun `app-x86_64-release.apk` (Split ABI) berhasil diinstal dan dijalankan tanpa error.
   - Seluruh data SQLite yang sudah ada (3 motor: *Vario 160 Hitam*, *Aerox Biru Doff*, *Beat Street Putih*, riwayat servis, log odometer, rencana budget, dan pengingat) tetap utuh 100%.
2. **Visual Regression Testing (5 Tab Utama & Modal)**:
   - **Tab 1 — Beranda**: Logo BuildHaus, toggle tema Malam/Siang, kartu pemilih multi-motor, kartu Motor Utama (`Beat Street Putih`, `34,100 km`), dan tombol Aksi Cepat (`Kesehatan`, `Konsultasi AI`) tampil identik tanpa perubahan font, warna, radius, maupun spacing.
   - **Tab 2 — Sehat**: Lingkaran Skor Kesehatan (`74 BAIK`), kartu *Estimasi Penggunaan Terkalibrasi* (`219 km/minggu`, `937 km/bulan`), kartu *Pemeriksaan Mandiri Motor*, dan daftar status 14 komponen tampil normal.
   - **Tab 3 — Sparepart**: Header `Katalog Sparepart`, banner konteks `Beat Street Putih` (`Anggaran: Rp 350.000`, badge `3 Budget`, `37 Servis`), chip filter pintar (`Semua`, `Rekomendasi Budget`, `Perhatian Kesehatan`), dan kartu sparepart dengan Material Icons tampil sempurna. Aturan `expect(find.text('Sparepart'), findsOneWidget)` tetap terjaga.
   - **Tab 4 — Riwayat**: Daftar riwayat servis (`Rp 73.000`, `Rp 927.000`), tab `Odometer`, dan tab `Pengingat` tampil identik.
   - **Tab 5 — Akun**: Kartu profil `Rider BuildHaus (Offline Mode)`, kartu `AI Offline Qwen3 (378 MB)`, ringkasan statistik (`6 Servis`, `Rp 3.8jt`, `1 Reminders`), dan daftar `Motor Saya` berfungsi penuh.
3. **Status Pengujian AI Offline & Matriks Dukungan ABI**:
   - **Rule-Based Fallback AI & Safety Guard**: Terverifikasi berjalan normal pada `emulator-5554` (`x86_64`) dan lulus seluruh pengujian unit `ai_chat_service_test.dart` serta `ai_context_retriever_test.dart`.
   - **Native `llama.cpp` Runtime (`libllama.so`, `libggml*.so`, `libllama_jni.so`, `libomp.so`)**: Seluruh 6 pustaka native AI tetap utuh di dalam `lib/arm64-v8a/` baik pada `app-release.apk` (Universal) maupun `app-arm64-v8a-release.apk`. *(Catatan jujur: Pengujian inferensi native GGUF pada perangkat fisik ARM64 belum dijalankan di sesi ini karena hanya emulator `x86_64` yang terhubung).*

---

## 16. Risiko, Batasan, dan Transparansi Teknis

1. **Dukungan Arsitektur Native `llama.cpp` Berdasarkan ABI**:
   - Plugin `llama_flutter_android` hanya menyediakan dan mengompilasi kode C++ `llama.cpp` untuk arsitektur **`arm64-v8a`** (standar seluruh smartphone Android modern 64-bit).
   - Pada varian **`x86_64`** (emulator PC) dan **`armeabi-v7a`** (perangkat 32-bit lawas), aplikasi tetap berjalan lancar sepenuhnya menggunakan **Transparent Rule-Based AI Fallback** yang terintegrasi di `AiChatService`.
2. **Perilaku `useLegacyPackaging = true`**:
   - Mengaktifkan `useLegacyPackaging = true` mengompresi file `.so` di dalam APK sehingga memangkas ukuran file APK secara drastis (`-56,37%` pada Universal APK dan `-82,70%` pada ARM64 APK) serta memangkas ukuran instalasi Universal APK di perangkat sebesar `-24,46%`.
   - Saat APK diinstal, sistem Android mengekstrak pustaka `.so` khusus untuk ABI perangkat tersebut ke direktori `/data/app/.../lib/<abi>/`.

---

## 17. Rekomendasi Distribusi APK yang Paling Efisien

1. **Untuk Distribusi Langsung ke Pengguna HP Android Modern (Rekomendasi Utama)**:
   - Gunakan **`app-arm64-v8a-release.apk` (`12,48 MB` / `11,90 MiB`)** yang dihasilkan dari perintah:
     ```powershell
     flutter build apk --release --split-per-abi
     ```
   - Varian ini **82,70% lebih ringan** dibanding APK awal (`72,13 MB`), memuat **seluruh fitur aplikasi + mesin AI native `llama.cpp` lengkap**, dan kompatibel dengan semua smartphone Android 64-bit (ARM64).
2. **Untuk Pengujian pada Android Emulator PC (`x86_64`)**:
   - Gunakan **`app-x86_64-release.apk` (`10,54 MB` / `10,05 MiB`)** atau Universal APK.
3. **Untuk Distribusi Satu File Tunggal Lintas Semua Perangkat (Universal Sideload)**:
   - Gunakan **`app-release.apk` (`31,47 MB` / `30,02 MiB`)** yang dihasilkan dari perintah:
     ```powershell
     flutter build apk --release
     ```
   - Varian ini mencakup ketiga arsitektur (`arm64-v8a`, `x86_64`, `armeabi-v7a`) dalam satu file yang kini **56,37% lebih kecil** dibandingkan ukuran sebelum optimasi (`72,13 MB`).
