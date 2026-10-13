# BuildHaus Data Dictionary

## Common Fields

| Field | Type | Notes |
|-------|------|-------|
| id | INT AUTOINCREMENT | Primary key |
| created_at | DATETIME | UTC, default NOW |
| updated_at | DATETIME | UTC, updated on change |
| motorcycle_id | INT | FK to motorcycles |

---

## T1: motorcycle_models

Referensi master model motor.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PK, AUTO | |
| brand | TEXT | NOT NULL | Merek: Honda, Yamaha, dll |
| model | TEXT | NOT NULL | Nama model |
| variant | TEXT | NULL | Varian: CBS-ISS SP, dll |
| generation | TEXT | NULL | Generasi: 2022-sekarang |
| year_start | INT | NOT NULL | Tahun mulai produksi |
| year_end | INT | NULL | Tahun akhir (null=masih produksi) |
| source_url | TEXT | NULL | URL katalog resmi |
| verified_at | DATETIME | NULL | Tanggal verifikasi terakhir |

---

## T2: motorcycles

Profil motor pengguna.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PK, AUTO | |
| model_id | INT | FK→motorcycle_models | Model referensi |
| nickname | TEXT | NOT NULL | Nama/panggilan motor |
| manufacture_year | INT | NOT NULL | Tahun pembuatan |
| plate_number | TEXT | NULL | Plat nomor |
| emoji | TEXT | DEFAULT '🏍️' | Emoji ikon |
| usage_profile | TEXT | DEFAULT 'campuran' | harian_dalam_kota/jarak_jauh/campuran |
| created_at | DATETIME | DEFAULT NOW | |
| updated_at | DATETIME | DEFAULT NOW | |
| is_primary | BOOL | DEFAULT FALSE | Motor utama aktif |

---

## T3: odometer_logs

Riwayat pembacaan odometer aktual.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PK, AUTO | |
| motorcycle_id | INT | FK→motorcycles | |
| odometer_km | REAL | NOT NULL | Nilai kilometer |
| recorded_at | DATETIME | NOT NULL, UNIQUE+c Kombined | Tanggal pembacaan |
| source | TEXT | DEFAULT 'manual' | manual/correction/service_record |
| note | TEXT | NULL | Catatan opsional |

---

## T4: component_types

Master jenis komponen motor.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PK, AUTO | |
| name | TEXT | NOT NULL, UNIQUE | Nama komponen |
| category | TEXT | NOT NULL | Kategori: mesin, pengereman, dll |
| safety_critical | BOOL | DEFAULT FALSE | Komponen keselamatan |
| applies_to | TEXT | NULL | filters: 'cvt'=hanya motor CVT |

8 seed data: Oli mesin, Kampas rem, Aki, Ban, Filter udara, Busi, CVT, Knalpot

---

## T5: maintenance_rules

Aturan perawatan per model/komponen.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PK, AUTO | |
| model_id | INT | FK→motorcycle_models, NULL | NULL=generic rule |
| component_type_id | INT | FK→component_types | |
| interval_km | REAL | NULL | Interval kilometer |
| interval_days | INT | NULL | Interval hari |
| severe_use_rule | TEXT | NULL | Aturan pemakaian berat |
| source_url | TEXT | NULL | URL sumber aturan |
| rule_version | TEXT | DEFAULT 'v1' | Versi aturan |
| verified_at | DATETIME | NULL | Tanggal verifikasi |

---

## T6: component_statuses

Cache status komponen terhitung per motor.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PK, AUTO | |
| motorcycle_id | INT | FK→motorcycles | UNIQUE+c dengan component_type_id |
| component_type_id | INT | FK→component_types | UNIQUE dengan motorcycle_id |
| estimated_status | TEXT | NOT NULL | good/inspect/replace/unknown |
| score | REAL | NULL | Skor 0-100 |
| explanation | TEXT | NOT NULL | Penjelasan status |
| confidence | REAL | NULL | Tingkat keyakinan |
| calculated_at | DATETIME | NOT NULL | Tanggal kalkulasi |
| rule_version | TEXT | NOT NULL | Versi aturan yang dipakai |

---

## T7: service_records

Catatan kunjungan servis.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PK, AUTO | |
| motorcycle_id | INT | FK→motorcycles | |
| serviced_at | DATETIME | NOT NULL | Tanggal servis |
| odometer_km | REAL | NULL | Odometer saat servis |
| workshop_name | TEXT | NULL | Nama bengkel |
| notes | TEXT | NULL | Catatan |
| total_cost | INT | DEFAULT 0 | Total biaya (Rupiah) |
| created_at | DATETIME | DEFAULT NOW | |

---

## T8: service_items

Item detail dalam satu servis.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PK, AUTO | |
| service_record_id | INT | FK→service_records | |
| component_type_id | INT | FK→component_types, NULL | |
| sparepart_id | INT | NULL | FK→spareparts |
| action | TEXT | NOT NULL | inspect/replace/clean/repair |
| parts_cost | INT | DEFAULT 0 | Biaya part |
| labor_cost | INT | DEFAULT 0 | Biaya jasa |
| total_cost | INT | DEFAULT 0 | Total |
| notes | TEXT | NULL | Catatan item |

---

## T9: self_inspections

Sesi pemeriksaan mandiri.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PK, AUTO | |
| motorcycle_id | INT | FK→motorcycles | |
| inspected_at | DATETIME | DEFAULT NOW | |
| notes | TEXT | NULL | Catatan keseluruhan |
| risk_level | TEXT | NULL | low/medium/high |
| status | TEXT | DEFAULT 'draft' | draft/completed |

---

## T10: inspection_answers

Jawaban pertanyaan inspeksi.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PK, AUTO | |
| inspection_id | INT | FK→self_inspections | |
| question_code | TEXT | NOT NULL | Kode pertanyaan |
| answer | TEXT | NOT NULL | Jawaban |
| answer_type | TEXT | NULL | Tipe jawaban |
| risk_flag | BOOL | DEFAULT FALSE | Menandai risiko |

---

## T11: complaints

Keluhan motor.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PK, AUTO | |
| motorcycle_id | INT | FK→motorcycles | |
| inspection_id | INT | FK→self_inspections, NULL | Inspeksi terkait |
| resolved_by_service_id | INT | FK→service_records, NULL | Servis penyelesaian |
| title | TEXT | NOT NULL | Judul singkat |
| description | TEXT | NOT NULL | Deskripsi lengkap |
| status | TEXT | DEFAULT ' baru' | baru/dianalisis/perlu_pemeriksaan/ditangani/selesai/dibuka_kembali |
| opened_at | DATETIME | DEFAULT NOW | |
| closed_at | DATETIME | NULL | Tanggal ditutup |
| odometer_km | REAL | NULL | Odometer saat keluhan |
| updated_at | DATETIME | DEFAULT NOW | |

---

## T12: complaint_messages

Percakapan keluhan (chat).

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PK, AUTO | |
| complaint_id | INT | FK→complaints | |
| role | TEXT | NOT NULL | user/assistant/system |
| content | TEXT | NOT NULL | Isi pesan |
| created_at | DATETIME | DEFAULT NOW | |
| analysis_mode | TEXT | NULL | llm/rule_based |

---

## T13: complaint_analyses

Hasil analisis keluhan.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PK, AUTO | |
| complaint_id | INT | FK→complaints | |
| symptoms_json | TEXT | NOT NULL | JSON array gejala |
| component_candidates_json | TEXT | NULL | JSON array kandidat komponen |
| follow_up_json | TEXT | NULL | JSON array pertanyaan lanjutan |
| historical_matches_json | TEXT | NULL | JSON array kecocokan historis |
| risk_level | TEXT | NOT NULL | high/medium/low |
| summary | TEXT | NOT NULL | Ringkasan analisis |
| model_version | TEXT | NULL | Versi model AI |
| analysis_mode | TEXT | NOT NULL | llm/rule_based |
| analyzed_at | DATETIME | DEFAULT NOW | |

---

## T14: catalog_sources

Sumber katalog sparepart resmi.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PK, AUTO | |
| provider_name | TEXT | NOT NULL | Nama penyedia |
| website_url | TEXT | NOT NULL | URL website |
| license_or_permission | TEXT | NULL | Lisensi/izin |
| verified_at | DATETIME | NULL | |
| last_checked_at | DATETIME | NULL | |

---

## T15: spareparts

Data sparepart.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PK, AUTO | |
| source_id | INT | FK→catalog_sources, NULL | |
| part_number | TEXT | NULL | Nomor part resmi |
| name | TEXT | NOT NULL | Nama sparepart |
| brand | TEXT | NULL | Merek |
| category | TEXT | NOT NULL | Kategori |
| reference_price | INT | NULL | Harga referensi (null=bukan nol) |
| product_url | TEXT | NULL | URL produk resmi |
| price_updated_at | DATETIME | NULL | |
| catalog_version | TEXT | NULL | Versi katalog |
| is_verified | BOOL | DEFAULT FALSE | Terverifikasi resmi |

---

## T16: sparepart_fitments

Kecocokan sparepart dengan model motor.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PK, AUTO | |
| sparepart_id | INT | FK→spareparts | |
| model_id | INT | FK→motorcycle_models, NULL | |
| year_start | INT | NOT NULL | Tahun mulai kompatibilitas |
| year_end | INT | NULL | Tahun akhir |
| notes | TEXT | NULL | Catatan |
| verified_at | DATETIME | NULL | |
| source_url | TEXT | NULL | |

---

## T17: budget_plans

Rencana budget servis.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PK, AUTO | |
| motorcycle_id | INT | FK→motorcycles | |
| budget_amount | INT | NOT NULL | Jumlah budget (Rupiah) |
| period | TEXT | NULL | bulanan/3bulanan/sekali |
| created_at | DATETIME | DEFAULT NOW | |
| notes | TEXT | NULL | |

---

## T18: service_recommendations

Rekomendasi servis dari budget plan.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PK, AUTO | |
| budget_plan_id | INT | FK→budget_plans | |
| estimated_total | INT | NOT NULL | Estimasi total biaya |
| rule_version | TEXT | NOT NULL | Versi aturan prioritas |
| generated_at | DATETIME | DEFAULT NOW | |
| data_freshness | TEXT | NULL | Keterkinian data |
| explanation | TEXT | NULL | Penjelasan |

---

## T19: recommendation_items

Item individual dalam rekomendasi.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PK, AUTO | |
| recommendation_id | INT | FK→service_recommendations | |
| component_type_id | INT | FK→component_types | |
| sparepart_id | INT | FK→spareparts, NULL | |
| priority | TEXT | NOT NULL | safety/high/medium/low |
| decision | TEXT | NOT NULL | selected/deferred/safety_alert/inspect |
| estimated_cost | INT | NULL | Estimasi biaya part |
| estimated_labor_cost | INT | NULL | Estimasi biaya jasa |
| reason | TEXT | NOT NULL | Alasan keputusan |
| consequence_if_delayed | TEXT | NULL | Risiko penundaan |
| requires_inspection | BOOL | DEFAULT FALSE | Butuh inspeksi |

---

## T20: local_reminders

Pengingat lokal.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PK, AUTO | |
| motorcycle_id | INT | FK→motorcycles | |
| component_type_id | INT | FK→component_types, NULL | |
| reminder_type | TEXT | NOT NULL | odometer/date/inspection/complaint |
| due_odometer_km | REAL | NULL | Tenggat kilometer |
| due_date | DATETIME | NULL | Tenggat tanggal |
| enabled | BOOL | DEFAULT TRUE | Aktif/nonaktif |
| last_scheduled_at | DATETIME | NULL | |
| notification_id | INT | NULL | ID notifikasi Android |

---

## T21: ai_model_installs

Riwayat instalasi model AI.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | INT | PK, AUTO | |
| model_name | TEXT | NOT NULL | Nama model |
| version | TEXT | NOT NULL | Versi |
| file_path | TEXT | NOT NULL | Path file di storage |
| sha256 | TEXT | NOT NULL | Checksum SHA-256 |
| file_size_bytes | INT | NULL | Ukuran file |
| download_status | TEXT | DEFAULT 'pending' | pending/downloading/paused/completed/failed |
| installed_at | DATETIME | NULL | Tanggal instalasi |
| source_url | TEXT | NULL | URL download |
| last_error | TEXT | NULL | Error terakhir |

---

## T22: app_settings

Pengaturan aplikasi key-value.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| key | TEXT | PK | Kunci pengaturan |
| value | TEXT | NOT NULL | Nilai |
| updated_at | DATETIME | DEFAULT NOW | |

Default keys: theme_mode, active_motorcycle_id, odometer_reminder_days, ai_model_name, ai_model_status, user_name, user_initial, backup_last_at
