import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'tables/all_tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  MotorcycleModels,
  Motorcycles,
  OdometerLogs,
  ComponentTypes,
  MaintenanceRules,
  ComponentStatuses,
  ServiceRecords,
  ServiceItems,
  SelfInspections,
  InspectionAnswers,
  Complaints,
  ComplaintMessages,
  ComplaintAnalyses,
  CatalogSources,
  Spareparts,
  SparepartFitments,
  BudgetPlans,
  ServiceRecommendations,
  RecommendationItems,
  LocalReminders,
  AiModelInstalls,
  AppSettings,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 2;

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'buildhaus_db',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('worker.js'),
      ),
    );
  }

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _seedComponentTypes();
        await _seedDefaultSettings();
        await _seedMotorcycleModels();
        await _seedMaintenanceRules();
        await _seedSpareparts();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Schema v2: seed motorcycle models and maintenance rules
        if (from < 2) {
          await _seedMotorcycleModels();
          await _seedMaintenanceRules();
          await _seedSpareparts();
        }
      },
    );
  }

  Future<void> _seedComponentTypes() async {
    final components = [
      ComponentTypesCompanion.insert(
        name: 'Oli mesin', category: 'mesin', safetyCritical: const Value(true),
      ),
      ComponentTypesCompanion.insert(
        name: 'Kampas rem', category: 'pengereman', safetyCritical: const Value(true),
      ),
      ComponentTypesCompanion.insert(
        name: 'Aki', category: 'kelistrikan', safetyCritical: const Value(true),
      ),
      ComponentTypesCompanion.insert(
        name: 'Ban', category: 'roda', safetyCritical: const Value(true),
      ),
      ComponentTypesCompanion.insert(
        name: 'Filter udara', category: 'mesin',
      ),
      ComponentTypesCompanion.insert(
        name: 'Busi', category: 'mesin',
      ),
      ComponentTypesCompanion.insert(
        name: 'CVT', category: 'transmisi', appliesTo: const Value('cvt'),
      ),
      ComponentTypesCompanion.insert(
        name: 'Knalpot', category: 'mesin',
      ),
    ];

    for (final c in components) {
      await into(componentTypes).insert(c, mode: InsertMode.insertOrIgnore);
    }
  }

  Future<void> _seedSpareparts() async {
    final items = [
      // Oli Mesin
      SparepartsCompanion.insert(name: 'Pertamina Enduro 4T Max 10W-40', category: 'oli', referencePrice: const Value(42000), brand: const Value('Pertamina'), partNumber: const Value('SC-SAE10W40')),
      SparepartsCompanion.insert(name: 'Castrol Activ 4T 10W-40', category: 'oli', referencePrice: const Value(55000), brand: const Value('Castrol'), partNumber: const Value('CA-4T10W40')),
      SparepartsCompanion.insert(name: 'Shell Advance AX7 10W-40', category: 'oli', referencePrice: const Value(58000), brand: const Value('Shell'), partNumber: const Value('SH-AX7')),
      SparepartsCompanion.insert(name: 'Federal Super 4T 10W-40', category: 'oli', referencePrice: const Value(38000), brand: const Value('Federal'), partNumber: const Value('FD-4T40')),
      SparepartsCompanion.insert(name: 'Yamaha Yamalube 4T 10W-40', category: 'oli', referencePrice: const Value(65000), brand: const Value('Yamaha'), partNumber: const Value('YM-4T40')),
      SparepartsCompanion.insert(name: 'Honda Aoil 4T 10W-30', category: 'oli', referencePrice: const Value(48000), brand: const Value('Honda'), partNumber: const Value('HN-AOIL')),
      SparepartsCompanion.insert(name: 'Motul 3100 4T 10W-40', category: 'oli', referencePrice: const Value(95000), brand: const Value('Motul'), partNumber: const Value('MT-3100')),
      SparepartsCompanion.insert(name: 'Repsol Moto 4T 10W-40', category: 'oli', referencePrice: const Value(72000), brand: const Value('Repsol'), partNumber: const Value('RP-MOTO')),

      // Kampas Rem
      SparepartsCompanion.insert(name: 'Kampas Rem Depan Honda Beat', category: 'rem', referencePrice: const Value(35000), brand: const Value('astra'), partNumber: const Value('AS-BTFR')),
      SparepartsCompanion.insert(name: 'Kampas Rem Belakang Honda Beat', category: 'rem', referencePrice: const Value(28000), brand: const Value('astra'), partNumber: const Value('AS-BTBR')),
      SparepartsCompanion.insert(name: 'Kampas Rem Depan Yamaha NMAX', category: 'rem', referencePrice: const Value(55000), brand: const Value('Nissin'), partNumber: const Value('NS-NMAXFR')),
      SparepartsCompanion.insert(name: 'Kampas Rem Belakang Yamaha NMAX', category: 'rem', referencePrice: const Value(42000), brand: const Value('Nissin'), partNumber: const Value('NS-NMAXBR')),
      SparepartsCompanion.insert(name: 'Kampas Rem Depan Honda Vario', category: 'rem', referencePrice: const Value(48000), brand: const Value('akebono'), partNumber: const Value('AK-VarioFR')),
      SparepartsCompanion.insert(name: 'Kampas Rem Universal Motor', category: 'rem', referencePrice: const Value(22000), brand: const Value('generic'), partNumber: const Value('GEN-REM')),

      // Busi
      SparepartsCompanion.insert(name: 'NGK CPR8EA-9 Busi Iridium', category: 'busi', referencePrice: const Value(55000), brand: const Value('NGK'), partNumber: const Value('NGK-CPR8EA9')),
      SparepartsCompanion.insert(name: 'NGK CR7HSA Busi Standard', category: 'busi', referencePrice: const Value(25000), brand: const Value('NGK'), partNumber: const Value('NGK-CR7HSA')),
      SparepartsCompanion.insert(name: 'Denso U22FER9 Busi Iridium', category: 'busi', referencePrice: const Value(48000), brand: const Value('Denso'), partNumber: const Value('DN-U22FER9')),
      SparepartsCompanion.insert(name: 'Denso W24ESR Busi Standard', category: 'busi', referencePrice: const Value(28000), brand: const Value('Denso'), partNumber: const Value('DN-W24ESR')),
      SparepartsCompanion.insert(name: 'Bosch Iridium Busi Iridium', category: 'busi', referencePrice: const Value(62000), brand: const Value('Bosch'), partNumber: const Value('BS-IRI')),
      SparepartsCompanion.insert(name: 'Honda Genuine Busi', category: 'busi', referencePrice: const Value(35000), brand: const Value('Honda'), partNumber: const Value('HN-BUSI')),

      // Filter Udara
      SparepartsCompanion.insert(name: 'Filter Udara Honda Beat', category: 'filter', referencePrice: const Value(28000), brand: const Value('Honda'), partNumber: const Value('HN-BEATFL')),
      SparepartsCompanion.insert(name: 'Filter Udara Yamaha NMAX', category: 'filter', referencePrice: const Value(45000), brand: const Value('Yamaha'), partNumber: const Value('YM-NMAXFL')),
      SparepartsCompanion.insert(name: 'Filter Udara Honda Vario 125/150', category: 'filter', referencePrice: const Value(32000), brand: const Value('Honda'), partNumber: const Value('HN-VARFL')),
      SparepartsCompanion.insert(name: 'Filter Udara Yamaha Aerox', category: 'filter', referencePrice: const Value(38000), brand: const Value('Yamaha'), partNumber: const Value('YM-AEROFL')),
      SparepartsCompanion.insert(name: 'Filter Udara Universal', category: 'filter', referencePrice: const Value(18000), brand: const Value('generic'), partNumber: const Value('GEN-URFL')),
      SparepartsCompanion.insert(name: 'Filter Udara Honda Scoopy', category: 'filter', referencePrice: const Value(25000), brand: const Value('Honda'), partNumber: const Value('HN-SCPFL')),

      // Ban
      SparepartsCompanion.insert(name: 'IRC Tire SS-590 Depan 70/90-17', category: 'ban', referencePrice: const Value(195000), brand: const Value('IRC'), partNumber: const Value('IRC-SS590F')),
      SparepartsCompanion.insert(name: 'IRC Tire NH-210 Belakang 80/90-17', category: 'ban', referencePrice: const Value(220000), brand: const Value('IRC'), partNumber: const Value('IRC-NH210B')),
      SparepartsCompanion.insert(name: 'Michelin City Pro Depan 70/90-17', category: 'ban', referencePrice: const Value(280000), brand: const Value('Michelin'), partNumber: const Value('MC-CITYF')),
      SparepartsCompanion.insert(name: 'Michelin City Pro Belakang 80/90-17', category: 'ban', referencePrice: const Value(320000), brand: const Value('Michelin'), partNumber: const Value('MC-CITYB')),
      SparepartsCompanion.insert(name: 'Pirelli Diablo Scooter Depan', category: 'ban', referencePrice: const Value(350000), brand: const Value('Pirelli'), partNumber: const Value('PR-SCOOTF')),
      SparepartsCompanion.insert(name: 'Pirelli Diablo Scooter Belakang', category: 'ban', referencePrice: const Value(380000), brand: const Value('Pirelli'), partNumber: const Value('PR-SCOOTB')),
      SparepartsCompanion.insert(name: 'Bridgestone B-Series Depan', category: 'ban', referencePrice: const Value(250000), brand: const Value('Bridgestone'), partNumber: const Value('BT-BSF')),
      SparepartsCompanion.insert(name: 'Bridgestone B-Series Belakang', category: 'ban', referencePrice: const Value(290000), brand: const Value('Bridgestone'), partNumber: const Value('BT-BSB')),

      // Aki
      SparepartsCompanion.insert(name: 'Yuasa YTZ10S Aki MF', category: 'aki', referencePrice: const Value(480000), brand: const Value('Yuasa'), partNumber: const Value('YU-TZ10S')),
      SparepartsCompanion.insert(name: 'GS Astra MF Battery 5Ah', category: 'aki', referencePrice: const Value(380000), brand: const Value('GS Astra'), partNumber: const Value('GS-MF5Ah')),
      SparepartsCompanion.insert(name: 'Honda Aki MF 5Ah', category: 'aki', referencePrice: const Value(420000), brand: const Value('Honda'), partNumber: const Value('HN-AKIMF5')),
      SparepartsCompanion.insert(name: 'Yuasa YB16AL-A2 Aki Konvensional', category: 'aki', referencePrice: const Value(280000), brand: const Value('Yuasa'), partNumber: const Value('YU-YB16AL')),
      SparepartsCompanion.insert(name: 'Incoe MF Battery 5Ah', category: 'aki', referencePrice: const Value(320000), brand: const Value('Incoe'), partNumber: const Value('IC-MF5Ah')),

      // Rantai Kit
      SparepartsCompanion.insert(name: 'TK Chain 428H-110 Rantai Kit', category: 'rantai', referencePrice: const Value(95000), brand: const Value('TK Chain'), partNumber: const Value('TK-428H110')),
      SparepartsCompanion.insert(name: 'RK 428GF-110 Rantai Kit', category: 'rantai', referencePrice: const Value(120000), brand: const Value('RK Chain'), partNumber: const Value('RK-428GF')),
      SparepartsCompanion.insert(name: 'DID 428VX-110 Rantai Kit', category: 'rantai', referencePrice: const Value(180000), brand: const Value('DID'), partNumber: const Value('DD-428VX')),
      SparepartsCompanion.insert(name: 'Tahan Lama 415-108 Rantai Kit', category: 'rantai', referencePrice: const Value(75000), brand: const Value('Tahan Lama'), partNumber: const Value('TL-415108')),
      SparepartsCompanion.insert(name: 'Gear Depan 15 Gigi', category: 'rantai', referencePrice: const Value(35000), brand: const Value('generic'), partNumber: const Value('GEN-GF15')),
      SparepartsCompanion.insert(name: 'Gear Belakang 38 Gigi', category: 'rantai', referencePrice: const Value(55000), brand: const Value('generic'), partNumber: const Value('GEN-GB38')),

      // V-Belt / CVT
      SparepartsCompanion.insert(name: 'V-Belt Honda Beat Original', category: 'cvt', referencePrice: const Value(85000), brand: const Value('Honda'), partNumber: const Value('HN-BEATVB')),
      SparepartsCompanion.insert(name: 'V-Belt Yamaha NMAX Original', category: 'cvt', referencePrice: const Value(120000), brand: const Value('Yamaha'), partNumber: const Value('YM-NMAXVB')),
      SparepartsCompanion.insert(name: 'Dayco V-Belt Hyperflex', category: 'cvt', referencePrice: const Value(95000), brand: const Value('Dayco'), partNumber: const Value('DC-HYPER')),
      SparepartsCompanion.insert(name: 'Mitsubishi V-Belt', category: 'cvt', referencePrice: const Value(72000), brand: const Value('Mitsubishi'), partNumber: const Value('MC-VBELT')),
      SparepartsCompanion.insert(name: 'Arai V-Belt CVT Premium', category: 'cvt', referencePrice: const Value(110000), brand: const Value('Arai'), partNumber: const Value('AR-CVTPREM')),

      // Shock Absorber
      SparepartsCompanion.insert(name: 'Showa Shock Depan Honda Beat', category: 'shock', referencePrice: const Value(380000), brand: const Value('Showa'), partNumber: const Value('SH-BEATSF')),
      SparepartsCompanion.insert(name: 'Kayaba Shock Depan Yamaha NMAX', category: 'shock', referencePrice: const Value(520000), brand: const Value('Kayaba'), partNumber: const Value('KY-NMAXSF')),
      SparepartsCompanion.insert(name: 'S1 Shock Belakang Universal', category: 'shock', referencePrice: const Value(280000), brand: const Value('S1'), partNumber: const Value('S1-UNISB')),
      SparepartsCompanion.insert(name: 'Toni Shock Belakang Motor Bebek', category: 'shock', referencePrice: const Value(180000), brand: const Value('Toni'), partNumber: const Value('TN-BEKB')),
      SparepartsCompanion.insert(name: 'Showalter Rear Shock Honda Vario', category: 'shock', referencePrice: const Value(450000), brand: const Value('Showalter'), partNumber: const Value('SW-VARSB')),

      // Kopling
      SparepartsCompanion.insert(name: 'Kampas Kopling Honda Supra', category: 'kopling', referencePrice: const Value(42000), brand: const Value('Honda'), partNumber: const Value('HN-SUPRAKL')),
      SparepartsCompanion.insert(name: 'Plat Kopling Yamaha Mio', category: 'kopling', referencePrice: const Value(55000), brand: const Value('Yamaha'), partNumber: const Value('YM-MIOKL')),
      SparepartsCompanion.insert(name: 'Kampas Kopling Universal Motor', category: 'kopling', referencePrice: const Value(28000), brand: const Value('generic'), partNumber: const Value('GEN-KL')),
      SparepartsCompanion.insert(name: 'Pulley Kit Honda Beat', category: 'kopling', referencePrice: const Value(220000), brand: const Value('Honda'), partNumber: const Value('HN-BEATPK')),

      // Kelistrikan
      SparepartsCompanion.insert(name: 'Koil Pengapian Honda Beat', category: 'kelistrikan', referencePrice: const Value(85000), brand: const Value('Honda'), partNumber: const Value('HN-BEATCL')),
      SparepartsCompanion.insert(name: 'Starter Motor Honda Beat', category: 'kelistrikan', referencePrice: const Value(380000), brand: const Value('Honda'), partNumber: const Value('HN-BEATSM')),
      SparepartsCompanion.insert(name: 'Regulator Rectifier Universal', category: 'kelistrikan', referencePrice: const Value(95000), brand: const Value('generic'), partNumber: const Value('GEN-REG')),
      SparepartsCompanion.insert(name: 'Relay Starter Motor', category: 'kelistrikan', referencePrice: const Value(45000), brand: const Value('generic'), partNumber: const Value('GEN-RELAY')),
    ];

    for (final s in items) {
      await into(spareparts).insert(s, mode: InsertMode.insertOrIgnore);
    }
  }

  Future<void> _seedDefaultSettings() async {
    final defaults = {
      'theme_mode': 'dark',
      'active_motorcycle_id': '',
      'odometer_reminder_days': '30',
      'ai_model_name': 'qwen3-0.6b',
      'ai_model_status': 'not_downloaded',
      'user_name': 'Pengguna BuildHaus',
      'user_initial': 'BH',
      'backup_last_at': '',
    };

    for (final entry in defaults.entries) {
      await into(appSettings).insert(
        AppSettingsCompanion.insert(key: entry.key, value: entry.value),
        mode: InsertMode.insertOrIgnore,
      );
    }
  }

  /// Seed motorcycle_models table from JSON catalog.
  /// Idempotent: uses insertOrIgnore so re-runs are safe.
  Future<void> _seedMotorcycleModels() async {
    // Honda models
    final hondaModels = [
      ('Vario 160', 'CBS-ISS SP', '2022-sekarang', 2022),
      ('Vario 125', 'CBS-ISS', '2020-2023', 2020),
      ('Beat Street', 'Pop', '2020-sekarang', 2020),
      ('Supra X 125 FI', 'Helm In', '2019-sekarang', 2019),
      ('CBR150R', 'ABS', '2020-sekarang', 2020),
      ('PCX 160', 'ABS', '2021-sekarang', 2021),
      ('ADV 160', 'CBS-ISS', '2022-sekarang', 2022),
    ];
    for (final (model, variant, gen, year) in hondaModels) {
      await into(motorcycleModels).insert(
        MotorcycleModelsCompanion.insert(
          brand: 'Honda',
          model: model,
          variant: Value(variant),
          generation: Value(gen),
          yearStart: year,
          yearEnd: const Value(null),
          sourceUrl: const Value('https://www.astra-honda.com'),
          verifiedAt: Value(DateTime.now()),
        ),
        mode: InsertMode.insertOrIgnore,
      );
    }

    // Yamaha models
    final yamahaModels = [
      ('NMAX', 'Connected', '2020-sekarang', 2020),
      ('Aerox', 'Connected', '2020-sekarang', 2020),
      ('Mio M3', 'CW', '2021-sekarang', 2021),
      ('FreeGo', 'S', '2020-sekarang', 2020),
      ('X-Ride', '125', '2023-sekarang', 2023),
    ];
    for (final (model, variant, gen, year) in yamahaModels) {
      await into(motorcycleModels).insert(
        MotorcycleModelsCompanion.insert(
          brand: 'Yamaha',
          model: model,
          variant: Value(variant),
          generation: Value(gen),
          yearStart: year,
          yearEnd: const Value(null),
          sourceUrl: const Value('https://www.yamaha-motor.co.id'),
          verifiedAt: Value(DateTime.now()),
        ),
        mode: InsertMode.insertOrIgnore,
      );
    }

    // Suzuki models
    final suzukiModels = [
      ('Address 110', 'FI', '2021-sekarang', 2021),
      ('Nex II', 'FI', '2019-2022', 2019),
      ('Smash FI', 'R', '2020-sekarang', 2020),
    ];
    for (final (model, variant, gen, year) in suzukiModels) {
      await into(motorcycleModels).insert(
        MotorcycleModelsCompanion.insert(
          brand: 'Suzuki',
          model: model,
          variant: Value(variant),
          generation: Value(gen),
          yearStart: year,
          yearEnd: const Value(null),
          sourceUrl: const Value('https://www.suzuki.co.id'),
          verifiedAt: Value(DateTime.now()),
        ),
        mode: InsertMode.insertOrIgnore,
      );
    }

    // Kawasaki models
    final kawasakiModels = [
      ('Ninja 250SL', 'ABS', '2020-sekarang', 2020),
      ('W175', 'SE', '2019-sekarang', 2019),
      ('Z125', 'Pro', '2020-sekarang', 2020),
    ];
    for (final (model, variant, gen, year) in kawasakiModels) {
      await into(motorcycleModels).insert(
        MotorcycleModelsCompanion.insert(
          brand: 'Kawasaki',
          model: model,
          variant: Value(variant),
          generation: Value(gen),
          yearStart: year,
          yearEnd: const Value(null),
          sourceUrl: const Value('https://www.kawasaki-motor.co.id'),
          verifiedAt: Value(DateTime.now()),
        ),
        mode: InsertMode.insertOrIgnore,
      );
    }
  }

  /// Seed maintenance_rules from built-in default rules.
  /// Idempotent: safe to re-run.
  Future<void> _seedMaintenanceRules() async {
    // Get all seeded motorcycle models and component types
    final models = await select(motorcycleModels).get();
    final components = await select(componentTypes).get();
    final compByName = {for (var c in components) c.name: c};
    final modelByBrandModel = <String, int>{};
    for (var m in models) {
      modelByBrandModel['${m.brand}|${m.model}'] = m.id;
    }

    // Generic rules (modelId = null)
    final genericRules = [
      ('Oli mesin', 3000.0, 90, 2000.0),
      ('Kampas rem', 8000.0, 365, null),
      ('Aki', null, 730, null),
      ('Ban', 12000.0, 1095, null),
      ('Filter udara', 12000.0, 365, null),
      ('Busi', 16000.0, 730, null),
    ];

    for (final (name, km, days, severeKm) in genericRules) {
      final ct = compByName[name];
      if (ct == null) continue;
      await into(maintenanceRules).insert(
        MaintenanceRulesCompanion.insert(
          modelId: const Value(null),
          componentTypeId: ct.id,
          intervalKm: Value(km),
          intervalDays: Value(days),
          severeUseRule: severeKm != null
              ? Value('Pemakaian berat: ganti tiap $severeKm km')
              : const Value(null),
          sourceUrl: const Value('Panduan umum perawatan motor'),
          ruleVersion: const Value('v1'),
          verifiedAt: Value(DateTime.now()),
        ),
        mode: InsertMode.insertOrIgnore,
      );
    }

    // Model-specific rules for Honda Vario 160
    final vario160Id = modelByBrandModel['Honda|Vario 160'];
    final oliCt = compByName['Oli mesin'];
    if (vario160Id != null && oliCt != null) {
      await into(maintenanceRules).insert(
        MaintenanceRulesCompanion.insert(
          modelId: Value(vario160Id),
          componentTypeId: oliCt.id,
          intervalKm: const Value(3000),
          intervalDays: const Value(90),
          severeUseRule: const Value('Pemakaian berat: ganti tiap 2000 km'),
          sourceUrl: const Value('Buku manual Honda Vario 160 CBS-ISS SP'),
          ruleVersion: const Value('v1'),
          verifiedAt: Value(DateTime.now()),
        ),
        mode: InsertMode.insertOrIgnore,
      );
    }

    // CVT rule for Vario 160
    final cvtCt = compByName['CVT'];
    if (vario160Id != null && cvtCt != null) {
      await into(maintenanceRules).insert(
        MaintenanceRulesCompanion.insert(
          modelId: Value(vario160Id),
          componentTypeId: cvtCt.id,
          intervalKm: const Value(12000),
          intervalDays: const Value(365),
          sourceUrl: const Value('Buku manual Honda Vario 160 CBS-ISS SP'),
          ruleVersion: const Value('v1'),
          verifiedAt: Value(DateTime.now()),
        ),
        mode: InsertMode.insertOrIgnore,
      );
    }

    // Model-specific rules for Yamaha NMAX
    final nmaxId = modelByBrandModel['Yamaha|NMAX'];
    if (nmaxId != null && oliCt != null) {
      await into(maintenanceRules).insert(
        MaintenanceRulesCompanion.insert(
          modelId: Value(nmaxId),
          componentTypeId: oliCt.id,
          intervalKm: const Value(3000),
          intervalDays: const Value(90),
          severeUseRule: const Value('Pemakaian berat: ganti tiap 2000 km'),
          sourceUrl: const Value('Buku manual Yamaha NMAX'),
          ruleVersion: const Value('v1'),
          verifiedAt: Value(DateTime.now()),
        ),
        mode: InsertMode.insertOrIgnore,
      );
    }

    // CVT rule for NMAX
    if (nmaxId != null && cvtCt != null) {
      await into(maintenanceRules).insert(
        MaintenanceRulesCompanion.insert(
          modelId: Value(nmaxId),
          componentTypeId: cvtCt.id,
          intervalKm: const Value(12000),
          intervalDays: const Value(365),
          sourceUrl: const Value('Buku manual Yamaha NMAX'),
          ruleVersion: const Value('v1'),
          verifiedAt: Value(DateTime.now()),
        ),
        mode: InsertMode.insertOrIgnore,
      );
    }
  }

  // ============================================================
  // MOTORCYCLES
  // ============================================================

  Future<List<Motorcycle>> getAllMotorcycles() =>
      (select(motorcycles)..orderBy([(t) => OrderingTerm.desc(t.isPrimary)])).get();

  Stream<List<Motorcycle>> watchAllMotorcycles() =>
      (select(motorcycles)..orderBy([(t) => OrderingTerm.desc(t.isPrimary)])).watch();

  Future<Motorcycle?> getMotorcycle(int id) =>
      (select(motorcycles)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertMotorcycle(MotorcyclesCompanion m) =>
      into(motorcycles).insert(m);

  Future<bool> updateMotorcycle(MotorcyclesCompanion m, int id) =>
      (update(motorcycles)..where((t) => t.id.equals(id))).write(m).then((r) => r > 0);

  Future<int> deleteMotorcycle(int id) async {
    await (delete(odometerLogs)..where((t) => t.motorcycleId.equals(id))).go();
    await (delete(componentStatuses)..where((t) => t.motorcycleId.equals(id))).go();
    await (delete(serviceRecords)..where((t) => t.motorcycleId.equals(id))).go();
    await (delete(selfInspections)..where((t) => t.motorcycleId.equals(id))).go();
    await (delete(complaints)..where((t) => t.motorcycleId.equals(id))).go();
    await (delete(budgetPlans)..where((t) => t.motorcycleId.equals(id))).go();
    await (delete(localReminders)..where((t) => t.motorcycleId.equals(id))).go();
    return (delete(motorcycles)..where((t) => t.id.equals(id))).go();
  }

  Future<void> setPrimaryMotorcycle(int id) async {
    await (update(motorcycles)..where((t) => t.isPrimary.equals(true)))
        .write(const MotorcyclesCompanion(isPrimary: Value(false)));
    await (update(motorcycles)..where((t) => t.id.equals(id)))
        .write(const MotorcyclesCompanion(isPrimary: Value(true)));
  }

  // ============================================================
  // ODOMETER
  // ============================================================

  Future<List<OdometerLog>> getOdometerLogs(int motorcycleId) =>
      (select(odometerLogs)
        ..where((t) => t.motorcycleId.equals(motorcycleId))
        ..orderBy([(t) => OrderingTerm.desc(t.recordedAt)]))
      .get();

  Future<OdometerLog?> getLatestOdometer(int motorcycleId) =>
      (select(odometerLogs)
        ..where((t) => t.motorcycleId.equals(motorcycleId))
        ..orderBy([(t) => OrderingTerm.desc(t.recordedAt)])
        ..limit(1))
      .getSingleOrNull();

  Future<int> insertOdometerLog(OdometerLogsCompanion l) =>
      into(odometerLogs).insert(l);

  // ============================================================
  // COMPONENT TYPES
  // ============================================================

  Future<List<ComponentType>> getAllComponentTypes() => select(componentTypes).get();

  Future<List<ComponentType>> getApplicableComponents(String? usageProfile) async {
    if (usageProfile == 'cvt') return select(componentTypes).get();
    return (select(componentTypes)..where((t) => t.appliesTo.isNull() | t.appliesTo.equals('cvt').not())).get();
  }

  // ============================================================
  // COMPONENT STATUSES
  // ============================================================

  Future<List<ComponentStatus>> getComponentStatuses(int motorcycleId) =>
      (select(componentStatuses)..where((t) => t.motorcycleId.equals(motorcycleId))).get();

  Future<int> upsertComponentStatus(ComponentStatusesCompanion s) =>
      into(componentStatuses).insertOnConflictUpdate(s);

  // ============================================================
  // SERVICE RECORDS
  // ============================================================

  Future<List<ServiceRecord>> getServiceRecords(int motorcycleId) =>
      (select(serviceRecords)
        ..where((t) => t.motorcycleId.equals(motorcycleId))
        ..orderBy([(t) => OrderingTerm.desc(t.servicedAt)]))
      .get();

  Future<ServiceRecord?> getServiceRecord(int id) =>
      (select(serviceRecords)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertServiceRecord(ServiceRecordsCompanion r) =>
      into(serviceRecords).insert(r);

  Future<bool> updateServiceRecord(ServiceRecordsCompanion r, int id) =>
      (update(serviceRecords)..where((t) => t.id.equals(id))).write(r).then((r) => r > 0);

  Future<int> deleteServiceRecord(int id) async {
    await (delete(serviceItems)..where((t) => t.serviceRecordId.equals(id))).go();
    return (delete(serviceRecords)..where((t) => t.id.equals(id))).go();
  }

  // ============================================================
  // SERVICE ITEMS
  // ============================================================

  Future<List<ServiceItem>> getServiceItems(int serviceRecordId) =>
      (select(serviceItems)..where((t) => t.serviceRecordId.equals(serviceRecordId))).get();

  Future<int> insertServiceItem(ServiceItemsCompanion i) =>
      into(serviceItems).insert(i);

  Future<int> deleteServiceItem(int id) =>
      (delete(serviceItems)..where((t) => t.id.equals(id))).go();

  /// Get all service items for a specific motorcycle (joined with service records).
  /// Returns items sorted by service date descending.
  Future<List<ServiceItemWithRecord>> getAllServiceItemsForMotorcycle(int motorcycleId) async {
    final records = await (select(serviceRecords)
      ..where((t) => t.motorcycleId.equals(motorcycleId))
      ..orderBy([(t) => OrderingTerm.desc(t.servicedAt)]))
      .get();

    if (records.isEmpty) return [];

    final recordIds = records.map((r) => r.id).toList();
    final items = await (select(serviceItems)
      ..where((t) => t.serviceRecordId.isIn(recordIds)))
      .get();

    final itemsWithRecords = <ServiceItemWithRecord>[];
    for (final item in items) {
      final record = records.firstWhere((r) => r.id == item.serviceRecordId);
      itemsWithRecords.add(ServiceItemWithRecord(item: item, record: record));
    }
    itemsWithRecords.sort((a, b) => b.record.servicedAt.compareTo(a.record.servicedAt));
    return itemsWithRecords;
  }

  /// Get last service item for a specific motorcycle and component type.
  /// Returns the most recent service action for this component.
  Future<ServiceItemWithRecord?> getLastServiceForComponent(
    int motorcycleId,
    int componentTypeId,
  ) async {
    final itemsWithRecords = await getAllServiceItemsForMotorcycle(motorcycleId);
    final matching = itemsWithRecords
        .where((iwr) => iwr.item.componentTypeId == componentTypeId)
        .toList();
    return matching.isNotEmpty ? matching.first : null;
  }

  /// Get last service action for a component (replace/inspect/clean).
  /// Used by health engine to determine if component cycle was reset.
  Future<ServiceAction?> getLastActionForComponent(
    int motorcycleId,
    int componentTypeId,
  ) async {
    final last = await getLastServiceForComponent(motorcycleId, componentTypeId);
    if (last == null) return null;
    return ServiceAction(
      action: last.item.action,
      servicedAt: last.record.servicedAt,
      odometerKm: last.record.odometerKm,
    );
  }

  // ============================================================
  // SELF INSPECTIONS
  // ============================================================

  Future<List<SelfInspection>> getSelfInspections(int motorcycleId) =>
      (select(selfInspections)
        ..where((t) => t.motorcycleId.equals(motorcycleId))
        ..orderBy([(t) => OrderingTerm.desc(t.inspectedAt)]))
      .get();

  Future<int> insertSelfInspection(SelfInspectionsCompanion i) =>
      into(selfInspections).insert(i);

  Future<bool> updateSelfInspection(SelfInspectionsCompanion i, int id) =>
      (update(selfInspections)..where((t) => t.id.equals(id))).write(i).then((r) => r > 0);

  // ============================================================
  // INSPECTION ANSWERS
  // ============================================================

  Future<int> insertInspectionAnswer(InspectionAnswersCompanion a) =>
      into(inspectionAnswers).insert(a);

  // ============================================================
  // COMPLAINTS
  // ============================================================

  Future<List<Complaint>> getComplaints(int motorcycleId) =>
      (select(complaints)
        ..where((t) => t.motorcycleId.equals(motorcycleId))
        ..orderBy([(t) => OrderingTerm.desc(t.openedAt)]))
      .get();

  Future<Complaint?> getComplaint(int id) =>
      (select(complaints)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertComplaint(ComplaintsCompanion c) =>
      into(complaints).insert(c);

  Future<bool> updateComplaint(ComplaintsCompanion c, int id) =>
      (update(complaints)..where((t) => t.id.equals(id))).write(c).then((r) => r > 0);

  Future<int> deleteComplaint(int id) async {
    await (delete(complaintMessages)..where((t) => t.complaintId.equals(id))).go();
    await (delete(complaintAnalyses)..where((t) => t.complaintId.equals(id))).go();
    return (delete(complaints)..where((t) => t.id.equals(id))).go();
  }

  // ============================================================
  // COMPLAINT MESSAGES
  // ============================================================

  Future<List<ComplaintMessage>> getComplaintMessages(int complaintId) =>
      (select(complaintMessages)
        ..where((t) => t.complaintId.equals(complaintId))
        ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
      .get();

  Future<int> insertComplaintMessage(ComplaintMessagesCompanion m) =>
      into(complaintMessages).insert(m);

  // ============================================================
  // COMPLAINT ANALYSES
  // ============================================================

  Future<ComplaintAnalysis?> getLatestAnalysis(int complaintId) =>
      (select(complaintAnalyses)
        ..where((t) => t.complaintId.equals(complaintId))
        ..orderBy([(t) => OrderingTerm.desc(t.analyzedAt)])
        ..limit(1))
      .getSingleOrNull();

  Future<int> insertComplaintAnalysis(ComplaintAnalysesCompanion a) =>
      into(complaintAnalyses).insert(a);

  // ============================================================
  // MAINTENANCE RULES
  // ============================================================

  Future<List<MaintenanceRule>> getMaintenanceRules(int? modelId, int componentTypeId) {
    if (modelId != null) {
      return (select(maintenanceRules)
        ..where((t) => t.componentTypeId.equals(componentTypeId) &
            (t.modelId.equals(modelId) | t.modelId.isNull())))
      .get();
    }
    return (select(maintenanceRules)
      ..where((t) => t.componentTypeId.equals(componentTypeId)))
    .get();
  }

  Future<int> insertMaintenanceRule(MaintenanceRulesCompanion r) =>
      into(maintenanceRules).insert(r);

  // ============================================================
  // BUDGET PLANS
  // ============================================================

  Future<BudgetPlan?> getActiveBudgetPlan(int motorcycleId) =>
      (select(budgetPlans)
        ..where((t) => t.motorcycleId.equals(motorcycleId))
        ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
        ..limit(1))
      .getSingleOrNull();

  Future<int> insertBudgetPlan(BudgetPlansCompanion b) =>
      into(budgetPlans).insert(b);

  Future<bool> updateBudgetPlan(BudgetPlansCompanion b, int id) =>
      (update(budgetPlans)..where((t) => t.id.equals(id))).write(b).then((r) => r > 0);

  // ============================================================
  // SERVICE RECOMMENDATIONS
  // ============================================================

  Future<ServiceRecommendation?> getLatestRecommendation(int budgetPlanId) =>
      (select(serviceRecommendations)
        ..where((t) => t.budgetPlanId.equals(budgetPlanId))
        ..orderBy([(t) => OrderingTerm.desc(t.generatedAt)])
        ..limit(1))
      .getSingleOrNull();

  Future<int> insertServiceRecommendation(ServiceRecommendationsCompanion r) =>
      into(serviceRecommendations).insert(r);

  // ============================================================
  // RECOMMENDATION ITEMS
  // ============================================================

  Future<List<RecommendationItem>> getRecommendationItems(int recommendationId) =>
      (select(recommendationItems)
        ..where((t) => t.recommendationId.equals(recommendationId)))
      .get();

  Future<int> insertRecommendationItem(RecommendationItemsCompanion i) =>
      into(recommendationItems).insert(i);

  // ============================================================
  // LOCAL REMINDERS
  // ============================================================

  Future<List<LocalReminder>> getReminders(int motorcycleId) =>
      (select(localReminders)..where((t) => t.motorcycleId.equals(motorcycleId))).get();

  Future<int> insertReminder(LocalRemindersCompanion r) =>
      into(localReminders).insert(r);

  Future<bool> updateReminder(LocalRemindersCompanion r, int id) =>
      (update(localReminders)..where((t) => t.id.equals(id))).write(r).then((r) => r > 0);

  Future<int> deleteReminder(int id) =>
      (delete(localReminders)..where((t) => t.id.equals(id))).go();

  // ============================================================
  // AI MODEL INSTALLS
  // ============================================================

  Future<AiModelInstall?> getInstalledModel() =>
      (select(aiModelInstalls)
        ..where((t) => t.downloadStatus.equals('completed'))
        ..orderBy([(t) => OrderingTerm.desc(t.installedAt)])
        ..limit(1))
      .getSingleOrNull();

  Future<int> insertAiModelInstall(AiModelInstallsCompanion m) =>
      into(aiModelInstalls).insert(m);

  Future<bool> updateAiModelInstall(AiModelInstallsCompanion m, int id) =>
      (update(aiModelInstalls)..where((t) => t.id.equals(id))).write(m).then((r) => r > 0);

  Future<AiModelInstall?> getPendingModel() =>
      (select(aiModelInstalls)
        ..where((t) => t.downloadStatus.isIn(['pending', 'downloading', 'paused'])))
      .getSingleOrNull();

  // ============================================================
  // APP SETTINGS
  // ============================================================

  Future<String?> getSetting(String key) async {
    final s = await (select(appSettings)..where((t) => t.key.equals(key))).getSingleOrNull();
    return s?.value;
  }

  Future<void> setSetting(String key, String value) =>
      into(appSettings).insertOnConflictUpdate(
        AppSettingsCompanion.insert(key: key, value: value, updatedAt: Value(DateTime.now())),
      );

  Future<Map<String, String>> getAllSettings() async {
    final rows = await select(appSettings).get();
    return {for (var r in rows) r.key: r.value};
  }

  // ============================================================
  // MOTORCYCLE MODELS (MASTER)
  // ============================================================

  Future<List<MotorcycleModel>> getAllMotorcycleModels() => select(motorcycleModels).get();

  Future<int> insertMotorcycleModel(MotorcycleModelsCompanion m) =>
      into(motorcycleModels).insertOnConflictUpdate(m);

  Future<MotorcycleModel?> getMotorcycleModelById(int id) =>
      (select(motorcycleModels)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Look up a motorcycle model ID by brand and model name.
  /// Falls back to first matching brand if model name not found.
  Future<int?> getMotorcycleModelId(String brand, String model) async {
    final results = await (select(motorcycleModels)
      ..where((t) => t.brand.equals(brand) & t.model.equals(model)))
      .get();
    if (results.isNotEmpty) return results.first.id;

    // Fallback: match by brand only
    final brandOnly = await (select(motorcycleModels)
      ..where((t) => t.brand.equals(brand)))
      .get();
    return brandOnly.isNotEmpty ? brandOnly.first.id : null;
  }

  /// Get all models grouped by brand for dropdown selection.
  Future<Map<String, List<MotorcycleModel>>> getMotorcycleModelsGrouped() async {
    final models = await select(motorcycleModels).get();
    final grouped = <String, List<MotorcycleModel>>{};
    for (var m in models) {
      grouped.putIfAbsent(m.brand, () => []).add(m);
    }
    return grouped;
  }

  // ============================================================
  // CATALOG & SPAREPARTS
  // ============================================================

  Future<List<Sparepart>> getSparepartsByCategory(String category) =>
      (select(spareparts)..where((t) => t.category.equals(category))).get();

  Future<List<Sparepart>> getSparepartsForModel(int modelId) async {
    final fitments = await (select(sparepartFitments)..where((t) => t.modelId.equals(modelId))).get();
    final ids = fitments.map((f) => f.sparepartId).toSet().toList();
    if (ids.isEmpty) return [];
    return (select(spareparts)..where((t) => t.id.isIn(ids))).get();
  }

  Future<int> insertSparepart(SparepartsCompanion s) =>
      into(spareparts).insertOnConflictUpdate(s);

  Future<int> insertCatalogSource(CatalogSourcesCompanion s) =>
      into(catalogSources).insertOnConflictUpdate(s);

  // ============================================================
  // AGGREGATE / HELPER QUERIES
  // ============================================================

  /// Returns all component statuses joined with component type names
  Future<List<ComponentStatusWithName>> getComponentStatusesWithNames(int motorcycleId) async {
    final statuses = await getComponentStatuses(motorcycleId);
    final types = await getAllComponentTypes();
    final typeMap = {for (var t in types) t.id: t.name};

    return statuses.map((s) => ComponentStatusWithName(
      status: s,
      componentName: typeMap[s.componentTypeId] ?? 'Unknown',
    )).toList();
  }

  /// Returns upcoming (enabled + due in future) reminders
  Future<List<UpcomingReminder>> getUpcomingReminders(int motorcycleId) async {
    final reminders = await getReminders(motorcycleId);
    final types = await getAllComponentTypes();
    final typeMap = {for (var t in types) t.id: t.name};
    final now = DateTime.now();

    return reminders
        .where((r) => r.enabled &&
            (r.dueDate != null && r.dueDate!.isAfter(now)) ||
            (r.dueOdometerKm != null))
        .map((r) => UpcomingReminder(
          reminder: r,
          componentName: r.componentTypeId != null ? typeMap[r.componentTypeId] ?? 'Unknown' : 'General',
        ))
        .toList();
  }

  /// Count of upcoming reminders
  Future<int> getUpcomingRemindersCount() async {
    final motors = await getAllMotorcycles();
    int count = 0;
    for (final m in motors) {
      final rems = await getUpcomingReminders(m.id);
      count += rems.length;
    }
    return count;
  }

  /// Total count of all service records across all motors
  Future<int> getTotalServiceRecordsCount() async {
    final motors = await getAllMotorcycles();
    int total = 0;
    for (final m in motors) {
      final records = await getServiceRecords(m.id);
      total += records.length;
    }
    return total;
  }

  /// Sum of all service costs
  Future<double> getTotalMaintenanceCost() async {
    final motors = await getAllMotorcycles();
    double total = 0;
    for (final m in motors) {
      final records = await getServiceRecords(m.id);
      for (final r in records) {
        total += r.totalCost;
      }
    }
    return total;
  }

  /// Spareparts filtered by search and category
  Future<List<Sparepart>> searchSpareparts({String? category, String? query}) async {
    var q = select(spareparts);
    if (category != null && category.isNotEmpty && category != 'Semua') {
      q = q..where((t) => t.category.equals(category));
    }
    final results = await q.get();
    if (query != null && query.isNotEmpty) {
      final qLower = query.toLowerCase();
      return results.where((s) =>
        s.name.toLowerCase().contains(qLower) ||
        (s.brand?.toLowerCase().contains(qLower) ?? false) ||
        s.category.toLowerCase().contains(qLower)
      ).toList();
    }
    return results;
  }

  /// Get all distinct sparepart categories
  Future<List<String>> getAllSparepartCategories() async {
    final all = await select(spareparts).get();
    final cats = all.map((s) => s.category).toSet().toList();
    cats.sort();
    return cats;
  }

  /// Get component type names as list
  Future<List<String>> getComponentTypeNames() async {
    final types = await getAllComponentTypes();
    return types.map((t) => t.name).toList();
  }

  /// Recalculate and persist all component statuses for a motorcycle.
  /// This should be called after service records are added/updated.
  Future<void> recalculateComponentStatuses(int motorcycleId) async {
    final m = await getMotorcycle(motorcycleId);
    if (m == null) return;

    // Load all rules once (model-specific + generic)
    final allRules = await select(maintenanceRules).get();
    final allServiceItems = await getAllServiceItemsForMotorcycle(motorcycleId);
    final latestOdo = await getLatestOdometer(motorcycleId);
    final currentOdo = latestOdo?.odometerKm;
    final allComponentTypes = await getApplicableComponents(m.usageProfile);

    for (final ct in allComponentTypes) {
      // Find last replace/inspect action for this component
      ServiceAction? lastAction;
      for (final iwr in allServiceItems) {
        if (iwr.item.componentTypeId == ct.id &&
            (iwr.item.action == 'replace' || iwr.item.action == 'inspect')) {
          lastAction = ServiceAction(
            action: iwr.item.action,
            servicedAt: iwr.record.servicedAt,
            odometerKm: iwr.record.odometerKm,
          );
          break;
        }
      }

      // Find applicable rule (model-specific preferred over generic)
      final componentRules = allRules.where((r) => r.componentTypeId == ct.id).toList();
      MaintenanceRule? rule;
      if (componentRules.isNotEmpty) {
        rule = componentRules.cast<MaintenanceRule?>().firstWhere(
          (r) => r!.modelId != null,
          orElse: () => componentRules.first,
        );
      }

      String status;
      int? score;
      String explanation;
      double? kmSinceService;
      int? daysSinceService;
      final confidence = allServiceItems.length >= 3 ? 'high' : 'medium';

      if (lastAction == null) {
        // No replace/inspect action found
        bool hasOdometerRecord = allServiceItems.any((iwr) => iwr.record.odometerKm != null);
        if (!hasOdometerRecord) {
          status = 'unknown';
          score = null;
          explanation = 'Belum ada data servis. Catat servis untuk memulai pemantauan.';
        } else {
          final mostRecent = allServiceItems.isNotEmpty ? allServiceItems.first.record : null;
          if (mostRecent?.odometerKm != null) {
            kmSinceService = (currentOdo ?? mostRecent!.odometerKm!) - mostRecent.odometerKm!;
            daysSinceService = DateTime.now().difference(mostRecent.servicedAt).inDays;
            final intervalKm = rule?.intervalKm;
            if (intervalKm != null) {
              final ratio = kmSinceService / intervalKm;
              if (ratio >= 1.0) {
                status = 'inspect';
                score = 45;
                explanation = 'Sudah ${kmSinceService.toStringAsFixed(0)} km. Periksa ${ct.name}.';
              } else if (ratio >= 0.7) {
                status = 'inspect';
                score = 65;
                explanation = '${kmSinceService.toStringAsFixed(0)} km dari ${intervalKm.toStringAsFixed(0)} km.';
              } else {
                status = 'good';
                score = 80;
                explanation = 'Dalam kondisi baik.';
              }
            } else {
              status = 'good';
              score = 75;
              explanation = 'Dalam kondisi baik.';
            }
          } else {
            status = 'unknown';
            score = null;
            explanation = 'Belum ada data servis. Catat servis untuk memulai pemantauan.';
          }
        }
      } else {
        kmSinceService = (currentOdo ?? lastAction.odometerKm ?? 0) - (lastAction.odometerKm ?? 0);
        daysSinceService = DateTime.now().difference(lastAction.servicedAt).inDays;

        if (lastAction.action == 'replace') {
          final intervalKm = rule?.intervalKm;
          if (intervalKm != null) {
            final ratio = kmSinceService / intervalKm;
            if (ratio >= 1.0) {
              status = 'replace';
              score = 40;
              explanation = 'Sudah ${kmSinceService.toStringAsFixed(0)} km sejak ganti ${ct.name}.';
            } else if (ratio >= 0.7) {
              status = 'inspect';
              score = 65;
              explanation = '${kmSinceService.toStringAsFixed(0)} km dari ${intervalKm.toStringAsFixed(0)} km.';
            } else {
              status = 'good';
              score = ((1 - ratio) * 40 + 60).round().clamp(0, 100);
              explanation = 'Baru diganti. ${kmSinceService.toStringAsFixed(0)} km dari ${intervalKm.toStringAsFixed(0)} km.';
            }
          } else if (rule?.intervalDays != null && daysSinceService >= rule!.intervalDays!) {
            status = 'inspect';
            score = 60;
            explanation = 'Perlu diperiksa setelah ${daysSinceService} hari.';
          } else {
            status = 'good';
            score = 85;
            explanation = 'Baru diganti ${ct.name}.';
          }
        } else {
          status = 'inspect';
          score = 55;
          explanation = 'Terakhir diperiksa ${daysSinceService} hari lalu.';
        }

        if (ct.safetyCritical && score != null && score < 50) {
          status = 'replace';
          score = 35;
          explanation = '⚠️ KESELAMATAN. $explanation';
        }
      }

      if (score != null) score = score.clamp(0, 100);

      // Always check for existing status
      final existing = await (select(componentStatuses)
        ..where((t) => t.motorcycleId.equals(motorcycleId) & t.componentTypeId.equals(ct.id)))
        .getSingleOrNull();

      await upsertComponentStatus(ComponentStatusesCompanion(
        id: Value(existing?.id ?? 0),
        motorcycleId: Value(motorcycleId),
        componentTypeId: Value(ct.id),
        estimatedStatus: Value(status),
        score: Value(score),
        explanation: Value(explanation),
        confidence: Value(confidence),
        calculatedAt: Value(DateTime.now()),
        ruleVersion: Value(rule?.ruleVersion ?? 'unknown'),
      ));
    }
  }
}

/// Helper class: service item joined with its service record
class ServiceItemWithRecord {
  final ServiceItem item;
  final ServiceRecord record;
  ServiceItemWithRecord({required this.item, required this.record});
}

/// Helper class: last action for a component
class ServiceAction {
  final String action; // inspect, replace, clean, repair
  final DateTime servicedAt;
  final double? odometerKm;
  ServiceAction({required this.action, required this.servicedAt, this.odometerKm});

  bool get isReplacement => action == 'replace';
  bool get isInspection => action == 'inspect';
}

/// Helper class for component status with joined name
class ComponentStatusWithName {
  final ComponentStatus status;
  final String componentName;
  ComponentStatusWithName({required this.status, required this.componentName});
}

/// Helper class for upcoming reminders
class UpcomingReminder {
  final LocalReminder reminder;
  final String componentName;
  UpcomingReminder({required this.reminder, required this.componentName});
}
