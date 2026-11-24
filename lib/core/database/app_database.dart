import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'tables/all_tables.dart';
import '../engines/self_inspection_engine.dart';
import '../engines/budget_engine.dart';
import '../engines/health_engine.dart';
import '../engines/motorcycle_specs.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
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
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 7;

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
        await _seedReferenceData();
        await _createPerformanceIndexes();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // v3: backfill missing master records.
        if (from < 3) await _seedReferenceData();
        // v4: drop the invalid UNIQUE(motorcycle_id, recorded_at) constraint.
        // Drift rebuilds the table and copies existing odometer readings.
        if (from < 4) {
          await m.alterTable(TableMigration(odometerLogs));
        }
        // v5: restore the missing foreign key from service_items.sparepart_id and
        // recommendation_items.sparepart_id to spareparts(id).
        //
        // Both columns are nullable, so orphan rows (sparepart_id pointing at a
        // deleted part) are cleaned to NULL before the table rebuild. Drift's
        // TableMigration recreates the table and copies the surviving rows, so
        // no user data is lost.
        if (from < 5) {
          await _nullOrphanSparepartIds();
          await m.alterTable(TableMigration(serviceItems));
          await m.alterTable(TableMigration(recommendationItems));
        }
        // v6: add query performance indexes and backfill component applies_to
        // tags so matic/manual/liquid-cooled filtering works on upgraded DBs.
        if (from < 6) {
          await _createPerformanceIndexes();
          await _backfillComponentAppliesTo();
        }
        // v7: merge duplicate sparepart rows caused by mismatched local vs OEM
        // part numbers between offline seeds and verified catalog fitments.
        if (from < 7) {
          await _deduplicateSpareparts();
        }
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
        await ensureReferenceData();
      },
    );
  }

  Future<void> _createPerformanceIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_odometer_logs_motor_date '
      'ON odometer_logs (motorcycle_id, recorded_at DESC);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_component_statuses_motor '
      'ON component_statuses (motorcycle_id);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_service_records_motor_date '
      'ON service_records (motorcycle_id, serviced_at DESC);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_local_reminders_motor_enabled '
      'ON local_reminders (motorcycle_id, enabled);',
    );
  }

  Future<void> _backfillComponentAppliesTo() async {
    const updates = {
      'CVT': 'matic',
      'Oli gardan': 'matic',
      'Rantai & gir': 'manual',
      'Radiator coolant': 'liquid_cooled',
    };
    for (final entry in updates.entries) {
      await (update(componentTypes)..where((t) => t.name.equals(entry.key)))
          .write(ComponentTypesCompanion(appliesTo: Value(entry.value)));
    }
  }

  /// Set `sparepart_id` to NULL where it references a row that no longer exists.
  /// Required before adding the foreign key constraint so the rebuild cannot
  /// fail on legacy orphan rows.
  Future<void> _nullOrphanSparepartIds() async {
    await customStatement(
      'UPDATE service_items SET sparepart_id = NULL '
      'WHERE sparepart_id IS NOT NULL '
      'AND sparepart_id NOT IN (SELECT id FROM spareparts)',
    );
    await customStatement(
      'UPDATE recommendation_items SET sparepart_id = NULL '
      'WHERE sparepart_id IS NOT NULL '
      'AND sparepart_id NOT IN (SELECT id FROM spareparts)',
    );
  }

  /// Merges duplicate sparepart entries sharing the same product name so the
  /// catalog and service picker never display repeated identical parts.
  Future<void> _deduplicateSpareparts() async {
    await (update(spareparts)..where(
          (t) => t.name.equals('Yamaha Yamalube Brake Fluid DOT 4 50ml'),
        ))
        .write(
          const SparepartsCompanion(
            name: Value('Yamalube Brake Fluid DOT 4 50ml'),
          ),
        );

    final allParts = await (select(
      spareparts,
    )..orderBy([(t) => OrderingTerm.asc(t.id)])).get();
    final byNormalizedName = <String, List<Sparepart>>{};
    for (final part in allParts) {
      final key = part.name.trim().toLowerCase();
      byNormalizedName.putIfAbsent(key, () => []).add(part);
    }

    for (final group in byNormalizedName.values) {
      if (group.length <= 1) continue;

      group.sort((a, b) {
        if (a.isVerified != b.isVerified) return a.isVerified ? -1 : 1;
        return a.id.compareTo(b.id);
      });
      final keeper = group.first;
      final duplicates = group.skip(1).toList();

      String? bestPartNumber = keeper.partNumber;
      String? bestBrand = keeper.brand;
      int? bestPrice = keeper.referencePrice;
      int? bestSourceId = keeper.sourceId;
      String? bestProductUrl = keeper.productUrl;
      DateTime? bestPriceUpdatedAt = keeper.priceUpdatedAt;
      String? bestCatalogVersion = keeper.catalogVersion;
      bool bestVerified = keeper.isVerified;

      for (final dup in duplicates) {
        if (dup.isVerified && !bestVerified) {
          bestVerified = true;
          bestPartNumber = dup.partNumber ?? bestPartNumber;
          bestPrice = dup.referencePrice ?? bestPrice;
          bestSourceId = dup.sourceId ?? bestSourceId;
          bestProductUrl = dup.productUrl ?? bestProductUrl;
          bestPriceUpdatedAt = dup.priceUpdatedAt ?? bestPriceUpdatedAt;
          bestCatalogVersion = dup.catalogVersion ?? bestCatalogVersion;
        } else {
          bestPartNumber ??= dup.partNumber;
          bestPrice ??= dup.referencePrice;
          bestSourceId ??= dup.sourceId;
          bestProductUrl ??= dup.productUrl;
          bestPriceUpdatedAt ??= dup.priceUpdatedAt;
          bestCatalogVersion ??= dup.catalogVersion;
        }
        bestBrand ??= dup.brand;

        await (update(serviceItems)
              ..where((t) => t.sparepartId.equals(dup.id)))
            .write(ServiceItemsCompanion(sparepartId: Value(keeper.id)));
        await (update(recommendationItems)
              ..where((t) => t.sparepartId.equals(dup.id)))
            .write(RecommendationItemsCompanion(sparepartId: Value(keeper.id)));

        final dupFitments = await (select(
          sparepartFitments,
        )..where((t) => t.sparepartId.equals(dup.id))).get();
        for (final fitment in dupFitments) {
          final existingForKeeper = await (select(sparepartFitments)
                ..where(
                  (t) =>
                      t.sparepartId.equals(keeper.id) &
                      (fitment.modelId == null
                          ? t.modelId.isNull()
                          : t.modelId.equals(fitment.modelId!)),
                ))
              .get();
          if (existingForKeeper.isEmpty) {
            await (update(sparepartFitments)
                  ..where((t) => t.id.equals(fitment.id)))
                .write(
                  SparepartFitmentsCompanion(sparepartId: Value(keeper.id)),
                );
          } else {
            await (delete(
              sparepartFitments,
            )..where((t) => t.id.equals(fitment.id))).go();
          }
        }

        await (delete(spareparts)..where((t) => t.id.equals(dup.id))).go();
      }

      await (update(spareparts)..where((t) => t.id.equals(keeper.id))).write(
        SparepartsCompanion(
          partNumber: Value(bestPartNumber),
          brand: Value(bestBrand),
          referencePrice: Value(bestPrice),
          sourceId: Value(bestSourceId),
          productUrl: Value(bestProductUrl),
          priceUpdatedAt: Value(bestPriceUpdatedAt),
          catalogVersion: Value(bestCatalogVersion),
          isVerified: Value(bestVerified),
        ),
      );
    }
  }

  Future<void> _seedReferenceData() async {
    await _seedComponentTypes();
    await _seedDefaultSettings();
    await _seedMotorcycleModels();
    await _seedMaintenanceRules();
    await _seedSpareparts();
    await _seedCatalogSourcesAndFitments();
  }

  /// Safe to repeat on an existing database; never overwrites user records.
  Future<void> ensureReferenceData() => transaction(_seedReferenceData);

  Future<void> _seedComponentTypes() async {
    final components = [
      ComponentTypesCompanion.insert(
        name: 'Oli mesin',
        category: 'mesin',
        safetyCritical: const Value(true),
      ),
      ComponentTypesCompanion.insert(
        name: 'Kampas rem',
        category: 'pengereman',
        safetyCritical: const Value(true),
      ),
      ComponentTypesCompanion.insert(
        name: 'Aki',
        category: 'kelistrikan',
        safetyCritical: const Value(true),
      ),
      ComponentTypesCompanion.insert(
        name: 'Ban',
        category: 'roda',
        safetyCritical: const Value(true),
      ),
      ComponentTypesCompanion.insert(name: 'Filter udara', category: 'mesin'),
      ComponentTypesCompanion.insert(name: 'Busi', category: 'mesin'),
      ComponentTypesCompanion.insert(
        name: 'CVT',
        category: 'transmisi',
        appliesTo: const Value('matic'),
      ),
      ComponentTypesCompanion.insert(name: 'Knalpot', category: 'mesin'),
      ComponentTypesCompanion.insert(
        name: 'Oli gardan',
        category: 'transmisi',
        appliesTo: const Value('matic'),
      ),
      ComponentTypesCompanion.insert(
        name: 'Minyak rem',
        category: 'pengereman',
        safetyCritical: const Value(true),
      ),
      ComponentTypesCompanion.insert(
        name: 'Radiator coolant',
        category: 'pendingin',
        appliesTo: const Value('liquid_cooled'),
      ),
      ComponentTypesCompanion.insert(
        name: 'Rantai & gir',
        category: 'transmisi',
        safetyCritical: const Value(true),
        appliesTo: const Value('manual'),
      ),
      ComponentTypesCompanion.insert(
        name: 'Suspensi',
        category: 'suspensi',
        safetyCritical: const Value(true),
      ),
      ComponentTypesCompanion.insert(
        name: 'Filter oli',
        category: 'mesin',
      ),
    ];

    for (final c in components) {
      await into(componentTypes).insert(c, mode: InsertMode.insertOrIgnore);
    }
    await _backfillComponentAppliesTo();
  }

  Future<void> _seedSpareparts() async {
    final items = [
      // Oli Mesin
      SparepartsCompanion.insert(
        name: 'Pertamina Enduro 4T Max 10W-40',
        category: 'oli',
        referencePrice: const Value(42000),
        brand: const Value('Pertamina'),
        partNumber: const Value('SC-SAE10W40'),
      ),
      SparepartsCompanion.insert(
        name: 'Castrol Activ 4T 10W-40',
        category: 'oli',
        referencePrice: const Value(55000),
        brand: const Value('Castrol'),
        partNumber: const Value('CA-4T10W40'),
      ),
      SparepartsCompanion.insert(
        name: 'Shell Advance AX7 10W-40',
        category: 'oli',
        referencePrice: const Value(58000),
        brand: const Value('Shell'),
        partNumber: const Value('SH-AX7'),
      ),
      SparepartsCompanion.insert(
        name: 'Federal Super 4T 10W-40',
        category: 'oli',
        referencePrice: const Value(38000),
        brand: const Value('Federal'),
        partNumber: const Value('FD-4T40'),
      ),
      SparepartsCompanion.insert(
        name: 'Yamaha Yamalube 4T 10W-40',
        category: 'oli',
        referencePrice: const Value(65000),
        brand: const Value('Yamaha'),
        partNumber: const Value('YM-4T40'),
      ),
      SparepartsCompanion.insert(
        name: 'Honda Aoil 4T 10W-30',
        category: 'oli',
        referencePrice: const Value(48000),
        brand: const Value('Honda'),
        partNumber: const Value('HN-AOIL'),
      ),
      SparepartsCompanion.insert(
        name: 'Motul 3100 4T 10W-40',
        category: 'oli',
        referencePrice: const Value(95000),
        brand: const Value('Motul'),
        partNumber: const Value('MT-3100'),
      ),
      SparepartsCompanion.insert(
        name: 'Repsol Moto 4T 10W-40',
        category: 'oli',
        referencePrice: const Value(72000),
        brand: const Value('Repsol'),
        partNumber: const Value('RP-MOTO'),
      ),

      // Kampas Rem
      SparepartsCompanion.insert(
        name: 'Kampas Rem Depan Honda Beat',
        category: 'rem',
        referencePrice: const Value(35000),
        brand: const Value('astra'),
        partNumber: const Value('AS-BTFR'),
      ),
      SparepartsCompanion.insert(
        name: 'Kampas Rem Belakang Honda Beat',
        category: 'rem',
        referencePrice: const Value(28000),
        brand: const Value('astra'),
        partNumber: const Value('AS-BTBR'),
      ),
      SparepartsCompanion.insert(
        name: 'Kampas Rem Depan Yamaha NMAX',
        category: 'rem',
        referencePrice: const Value(55000),
        brand: const Value('Nissin'),
        partNumber: const Value('NS-NMAXFR'),
      ),
      SparepartsCompanion.insert(
        name: 'Kampas Rem Belakang Yamaha NMAX',
        category: 'rem',
        referencePrice: const Value(42000),
        brand: const Value('Nissin'),
        partNumber: const Value('NS-NMAXBR'),
      ),
      SparepartsCompanion.insert(
        name: 'Kampas Rem Depan Honda Vario',
        category: 'rem',
        referencePrice: const Value(48000),
        brand: const Value('akebono'),
        partNumber: const Value('AK-VarioFR'),
      ),
      SparepartsCompanion.insert(
        name: 'Kampas Rem Universal Motor',
        category: 'rem',
        referencePrice: const Value(22000),
        brand: const Value('generic'),
        partNumber: const Value('GEN-REM'),
      ),

      // Busi
      SparepartsCompanion.insert(
        name: 'NGK CPR8EA-9 Busi Iridium',
        category: 'busi',
        referencePrice: const Value(55000),
        brand: const Value('NGK'),
        partNumber: const Value('NGK-CPR8EA9'),
      ),
      SparepartsCompanion.insert(
        name: 'NGK CR7HSA Busi Standard',
        category: 'busi',
        referencePrice: const Value(25000),
        brand: const Value('NGK'),
        partNumber: const Value('NGK-CR7HSA'),
      ),
      SparepartsCompanion.insert(
        name: 'Denso U22FER9 Busi Iridium',
        category: 'busi',
        referencePrice: const Value(48000),
        brand: const Value('Denso'),
        partNumber: const Value('DN-U22FER9'),
      ),
      SparepartsCompanion.insert(
        name: 'Denso W24ESR Busi Standard',
        category: 'busi',
        referencePrice: const Value(28000),
        brand: const Value('Denso'),
        partNumber: const Value('DN-W24ESR'),
      ),
      SparepartsCompanion.insert(
        name: 'Bosch Iridium Busi Iridium',
        category: 'busi',
        referencePrice: const Value(62000),
        brand: const Value('Bosch'),
        partNumber: const Value('BS-IRI'),
      ),
      SparepartsCompanion.insert(
        name: 'Honda Genuine Busi',
        category: 'busi',
        referencePrice: const Value(35000),
        brand: const Value('Honda'),
        partNumber: const Value('HN-BUSI'),
      ),

      // Filter Udara
      SparepartsCompanion.insert(
        name: 'Filter Udara Honda Beat',
        category: 'filter',
        referencePrice: const Value(28000),
        brand: const Value('Honda'),
        partNumber: const Value('HN-BEATFL'),
      ),
      SparepartsCompanion.insert(
        name: 'Filter Udara Yamaha NMAX',
        category: 'filter',
        referencePrice: const Value(45000),
        brand: const Value('Yamaha'),
        partNumber: const Value('YM-NMAXFL'),
      ),
      SparepartsCompanion.insert(
        name: 'Filter Udara Honda Vario 125/150',
        category: 'filter',
        referencePrice: const Value(32000),
        brand: const Value('Honda'),
        partNumber: const Value('HN-VARFL'),
      ),
      SparepartsCompanion.insert(
        name: 'Filter Udara Yamaha Aerox',
        category: 'filter',
        referencePrice: const Value(38000),
        brand: const Value('Yamaha'),
        partNumber: const Value('YM-AEROFL'),
      ),
      SparepartsCompanion.insert(
        name: 'Filter Udara Universal',
        category: 'filter',
        referencePrice: const Value(18000),
        brand: const Value('generic'),
        partNumber: const Value('GEN-URFL'),
      ),
      SparepartsCompanion.insert(
        name: 'Filter Udara Honda Scoopy',
        category: 'filter',
        referencePrice: const Value(25000),
        brand: const Value('Honda'),
        partNumber: const Value('HN-SCPFL'),
      ),

      // Ban
      SparepartsCompanion.insert(
        name: 'IRC Tire SS-590 Depan 70/90-17',
        category: 'ban',
        referencePrice: const Value(195000),
        brand: const Value('IRC'),
        partNumber: const Value('IRC-SS590F'),
      ),
      SparepartsCompanion.insert(
        name: 'IRC Tire NH-210 Belakang 80/90-17',
        category: 'ban',
        referencePrice: const Value(220000),
        brand: const Value('IRC'),
        partNumber: const Value('IRC-NH210B'),
      ),
      SparepartsCompanion.insert(
        name: 'Michelin City Pro Depan 70/90-17',
        category: 'ban',
        referencePrice: const Value(280000),
        brand: const Value('Michelin'),
        partNumber: const Value('MC-CITYF'),
      ),
      SparepartsCompanion.insert(
        name: 'Michelin City Pro Belakang 80/90-17',
        category: 'ban',
        referencePrice: const Value(320000),
        brand: const Value('Michelin'),
        partNumber: const Value('MC-CITYB'),
      ),
      SparepartsCompanion.insert(
        name: 'Pirelli Diablo Scooter Depan',
        category: 'ban',
        referencePrice: const Value(350000),
        brand: const Value('Pirelli'),
        partNumber: const Value('PR-SCOOTF'),
      ),
      SparepartsCompanion.insert(
        name: 'Pirelli Diablo Scooter Belakang',
        category: 'ban',
        referencePrice: const Value(380000),
        brand: const Value('Pirelli'),
        partNumber: const Value('PR-SCOOTB'),
      ),
      SparepartsCompanion.insert(
        name: 'Bridgestone B-Series Depan',
        category: 'ban',
        referencePrice: const Value(250000),
        brand: const Value('Bridgestone'),
        partNumber: const Value('BT-BSF'),
      ),
      SparepartsCompanion.insert(
        name: 'Bridgestone B-Series Belakang',
        category: 'ban',
        referencePrice: const Value(290000),
        brand: const Value('Bridgestone'),
        partNumber: const Value('BT-BSB'),
      ),

      // Aki
      SparepartsCompanion.insert(
        name: 'Yuasa YTZ10S Aki MF',
        category: 'aki',
        referencePrice: const Value(480000),
        brand: const Value('Yuasa'),
        partNumber: const Value('YU-TZ10S'),
      ),
      SparepartsCompanion.insert(
        name: 'GS Astra MF Battery 5Ah',
        category: 'aki',
        referencePrice: const Value(380000),
        brand: const Value('GS Astra'),
        partNumber: const Value('GS-MF5Ah'),
      ),
      SparepartsCompanion.insert(
        name: 'Honda Aki MF 5Ah',
        category: 'aki',
        referencePrice: const Value(420000),
        brand: const Value('Honda'),
        partNumber: const Value('HN-AKIMF5'),
      ),
      SparepartsCompanion.insert(
        name: 'Yuasa YB16AL-A2 Aki Konvensional',
        category: 'aki',
        referencePrice: const Value(280000),
        brand: const Value('Yuasa'),
        partNumber: const Value('YU-YB16AL'),
      ),
      SparepartsCompanion.insert(
        name: 'Incoe MF Battery 5Ah',
        category: 'aki',
        referencePrice: const Value(320000),
        brand: const Value('Incoe'),
        partNumber: const Value('IC-MF5Ah'),
      ),

      // Rantai Kit
      SparepartsCompanion.insert(
        name: 'TK Chain 428H-110 Rantai Kit',
        category: 'rantai',
        referencePrice: const Value(95000),
        brand: const Value('TK Chain'),
        partNumber: const Value('TK-428H110'),
      ),
      SparepartsCompanion.insert(
        name: 'RK 428GF-110 Rantai Kit',
        category: 'rantai',
        referencePrice: const Value(120000),
        brand: const Value('RK Chain'),
        partNumber: const Value('RK-428GF'),
      ),
      SparepartsCompanion.insert(
        name: 'DID 428VX-110 Rantai Kit',
        category: 'rantai',
        referencePrice: const Value(180000),
        brand: const Value('DID'),
        partNumber: const Value('DD-428VX'),
      ),
      SparepartsCompanion.insert(
        name: 'Tahan Lama 415-108 Rantai Kit',
        category: 'rantai',
        referencePrice: const Value(75000),
        brand: const Value('Tahan Lama'),
        partNumber: const Value('TL-415108'),
      ),
      SparepartsCompanion.insert(
        name: 'Gear Depan 15 Gigi',
        category: 'rantai',
        referencePrice: const Value(35000),
        brand: const Value('generic'),
        partNumber: const Value('GEN-GF15'),
      ),
      SparepartsCompanion.insert(
        name: 'Gear Belakang 38 Gigi',
        category: 'rantai',
        referencePrice: const Value(55000),
        brand: const Value('generic'),
        partNumber: const Value('GEN-GB38'),
      ),

      // V-Belt / CVT
      SparepartsCompanion.insert(
        name: 'V-Belt Honda Beat Original',
        category: 'cvt',
        referencePrice: const Value(85000),
        brand: const Value('Honda'),
        partNumber: const Value('HN-BEATVB'),
      ),
      SparepartsCompanion.insert(
        name: 'V-Belt Yamaha NMAX Original',
        category: 'cvt',
        referencePrice: const Value(120000),
        brand: const Value('Yamaha'),
        partNumber: const Value('YM-NMAXVB'),
      ),
      SparepartsCompanion.insert(
        name: 'Dayco V-Belt Hyperflex',
        category: 'cvt',
        referencePrice: const Value(95000),
        brand: const Value('Dayco'),
        partNumber: const Value('DC-HYPER'),
      ),
      SparepartsCompanion.insert(
        name: 'Mitsubishi V-Belt',
        category: 'cvt',
        referencePrice: const Value(72000),
        brand: const Value('Mitsubishi'),
        partNumber: const Value('MC-VBELT'),
      ),
      SparepartsCompanion.insert(
        name: 'Arai V-Belt CVT Premium',
        category: 'cvt',
        referencePrice: const Value(110000),
        brand: const Value('Arai'),
        partNumber: const Value('AR-CVTPREM'),
      ),

      // Shock Absorber
      SparepartsCompanion.insert(
        name: 'Showa Shock Depan Honda Beat',
        category: 'shock',
        referencePrice: const Value(380000),
        brand: const Value('Showa'),
        partNumber: const Value('SH-BEATSF'),
      ),
      SparepartsCompanion.insert(
        name: 'Kayaba Shock Depan Yamaha NMAX',
        category: 'shock',
        referencePrice: const Value(520000),
        brand: const Value('Kayaba'),
        partNumber: const Value('KY-NMAXSF'),
      ),
      SparepartsCompanion.insert(
        name: 'S1 Shock Belakang Universal',
        category: 'shock',
        referencePrice: const Value(280000),
        brand: const Value('S1'),
        partNumber: const Value('S1-UNISB'),
      ),
      SparepartsCompanion.insert(
        name: 'Toni Shock Belakang Motor Bebek',
        category: 'shock',
        referencePrice: const Value(180000),
        brand: const Value('Toni'),
        partNumber: const Value('TN-BEKB'),
      ),
      SparepartsCompanion.insert(
        name: 'Showalter Rear Shock Honda Vario',
        category: 'shock',
        referencePrice: const Value(450000),
        brand: const Value('Showalter'),
        partNumber: const Value('SW-VARSB'),
      ),

      // Kopling
      SparepartsCompanion.insert(
        name: 'Kampas Kopling Honda Supra',
        category: 'kopling',
        referencePrice: const Value(42000),
        brand: const Value('Honda'),
        partNumber: const Value('HN-SUPRAKL'),
      ),
      SparepartsCompanion.insert(
        name: 'Plat Kopling Yamaha Mio',
        category: 'kopling',
        referencePrice: const Value(55000),
        brand: const Value('Yamaha'),
        partNumber: const Value('YM-MIOKL'),
      ),
      SparepartsCompanion.insert(
        name: 'Kampas Kopling Universal Motor',
        category: 'kopling',
        referencePrice: const Value(28000),
        brand: const Value('generic'),
        partNumber: const Value('GEN-KL'),
      ),
      SparepartsCompanion.insert(
        name: 'Pulley Kit Honda Beat',
        category: 'kopling',
        referencePrice: const Value(220000),
        brand: const Value('Honda'),
        partNumber: const Value('HN-BEATPK'),
      ),

      // Kelistrikan
      SparepartsCompanion.insert(
        name: 'Koil Pengapian Honda Beat',
        category: 'kelistrikan',
        referencePrice: const Value(85000),
        brand: const Value('Honda'),
        partNumber: const Value('HN-BEATCL'),
      ),
      SparepartsCompanion.insert(
        name: 'Starter Motor Honda Beat',
        category: 'kelistrikan',
        referencePrice: const Value(380000),
        brand: const Value('Honda'),
        partNumber: const Value('HN-BEATSM'),
      ),
      SparepartsCompanion.insert(
        name: 'Regulator Rectifier Universal',
        category: 'kelistrikan',
        referencePrice: const Value(95000),
        brand: const Value('generic'),
        partNumber: const Value('GEN-REG'),
      ),
      SparepartsCompanion.insert(
        name: 'Relay Starter Motor',
        category: 'kelistrikan',
        referencePrice: const Value(45000),
        brand: const Value('generic'),
        partNumber: const Value('GEN-RELAY'),
      ),

      // Oli Gardan
      SparepartsCompanion.insert(
        name: 'AHM Oil Scooter Gear Oil 120ml',
        category: 'oli_gardan',
        referencePrice: const Value(16000),
        brand: const Value('Honda'),
        partNumber: const Value('HN-GEAR120'),
      ),
      SparepartsCompanion.insert(
        name: 'Yamalube Motor Gear Oil 100ml',
        category: 'oli_gardan',
        referencePrice: const Value(17500),
        brand: const Value('Yamaha'),
        partNumber: const Value('YM-GEAR100'),
      ),
      SparepartsCompanion.insert(
        name: 'Castrol Scooter Gear Oil 80W-90 120ml',
        category: 'oli_gardan',
        referencePrice: const Value(22000),
        brand: const Value('Castrol'),
        partNumber: const Value('CA-GEAR80W'),
      ),
      SparepartsCompanion.insert(
        name: 'Motul Scooter Gear Oil 80W-90 120ml',
        category: 'oli_gardan',
        referencePrice: const Value(35000),
        brand: const Value('Motul'),
        partNumber: const Value('MT-GEAR80W'),
      ),
      SparepartsCompanion.insert(
        name: 'Federal Gear Oil Matic 120ml',
        category: 'oli_gardan',
        referencePrice: const Value(15000),
        brand: const Value('Federal'),
        partNumber: const Value('FD-GEAR120'),
      ),

      // Minyak Rem
      SparepartsCompanion.insert(
        name: 'Honda Genuine Brake Fluid DOT 4 50ml',
        category: 'minyak_rem',
        referencePrice: const Value(18000),
        brand: const Value('Honda'),
        partNumber: const Value('HN-BFDOT4'),
      ),
      SparepartsCompanion.insert(
        name: 'Yamalube Brake Fluid DOT 4 50ml',
        category: 'minyak_rem',
        referencePrice: const Value(20000),
        brand: const Value('Yamaha'),
        partNumber: const Value('YM-BFDOT4'),
      ),
      SparepartsCompanion.insert(
        name: 'Prestone Brake Fluid DOT 4 300ml',
        category: 'minyak_rem',
        referencePrice: const Value(38000),
        brand: const Value('Prestone'),
        partNumber: const Value('PR-BFDOT4'),
      ),
      SparepartsCompanion.insert(
        name: 'Jumbo Brake Fluid DOT 3 300ml',
        category: 'minyak_rem',
        referencePrice: const Value(22000),
        brand: const Value('Jumbo'),
        partNumber: const Value('JB-BFDOT3'),
      ),

      // Radiator Coolant
      SparepartsCompanion.insert(
        name: 'AHM Radiator Coolant Pre-mix 1L',
        category: 'coolant',
        referencePrice: const Value(24000),
        brand: const Value('Honda'),
        partNumber: const Value('HN-COOL1L'),
      ),
      SparepartsCompanion.insert(
        name: 'Yamalube Yamacoolant 1L',
        category: 'coolant',
        referencePrice: const Value(38000),
        brand: const Value('Yamaha'),
        partNumber: const Value('YM-COOL1L'),
      ),
      SparepartsCompanion.insert(
        name: 'Prestone Ready to Use Coolant 1L',
        category: 'coolant',
        referencePrice: const Value(45000),
        brand: const Value('Prestone'),
        partNumber: const Value('PR-COOL1L'),
      ),
      SparepartsCompanion.insert(
        name: 'Megacool Radiator Coolant 1L',
        category: 'coolant',
        referencePrice: const Value(18000),
        brand: const Value('Megacool'),
        partNumber: const Value('MG-COOL1L'),
      ),

      // Filter Oli
      SparepartsCompanion.insert(
        name: 'Filter Oli Saringan Kasa Honda Vario',
        category: 'filter_oli',
        referencePrice: const Value(18000),
        brand: const Value('Honda'),
        partNumber: const Value('HN-FLTOIL'),
      ),
      SparepartsCompanion.insert(
        name: 'Filter Oli Yamaha NMAX/Aerox Original',
        category: 'filter_oli',
        referencePrice: const Value(28000),
        brand: const Value('Yamaha'),
        partNumber: const Value('YM-FLTOIL'),
      ),

      // Knalpot & Exhaust
      SparepartsCompanion.insert(
        name: 'Gasket Paking Knalpot Tembaga Matic Universal',
        category: 'knalpot',
        referencePrice: const Value(15000),
        brand: const Value('OEM'),
        partNumber: const Value('EX-GSK01'),
      ),
      SparepartsCompanion.insert(
        name: 'Knalpot Standar Racing Bobok Beat/Vario/Aerox',
        category: 'knalpot',
        referencePrice: const Value(350000),
        brand: const Value('Rob1'),
        partNumber: const Value('EX-STD02'),
      ),
    ];

    for (final item in items) {
      final code = item.partNumber.value;
      final nameVal = item.name.value;
      final existing = code != null
          ? await (select(spareparts)..where(
                (t) => t.partNumber.equals(code) | t.name.equals(nameVal),
              )).get()
          : await (select(
              spareparts,
            )..where((t) => t.name.equals(nameVal))).get();
      if (existing.isNotEmpty) continue;
      // These entries are local examples, not official manufacturer catalog data.
      // Keep isVerified=false and do not claim that prices or fitments are current.
      await into(spareparts).insert(item);
    }
  }

  Future<int> _ensureCatalogSource(String providerName, String websiteUrl) async {
    final existing = await (select(catalogSources)
          ..where((t) => t.providerName.equals(providerName)))
        .getSingleOrNull();
    if (existing != null) return existing.id;
    return into(catalogSources).insert(
      CatalogSourcesCompanion.insert(
        providerName: providerName,
        websiteUrl: websiteUrl,
        licenseOrPermission: const Value('Public catalog reference'),
        verifiedAt: Value(DateTime(2026, 1, 15)),
      ),
    );
  }

  Future<void> _seedCatalogSourcesAndFitments() async {
    // 1. Seed official catalog sources across all 3 supported brands
    final astraId = await _ensureCatalogSource(
      'Astra Honda Motor',
      'https://www.astra-honda.com',
    );
    final yamahaId = await _ensureCatalogSource(
      'Yamaha Indonesia',
      'https://www.yamaha-motor.co.id',
    );
    final kawasakiId = await _ensureCatalogSource(
      'Kawasaki Motor Indonesia',
      'https://www.kawasaki-motor.co.id',
    );

    // 2. Fetch models by (brand, model)
    final models = await select(motorcycleModels).get();
    final modelById = <int, MotorcycleModel>{for (final m in models) m.id: m};
    final modelIdByKey = <String, int>{
      for (final m in models) '${m.brand}|${m.model}': m.id,
    };
    List<int> resolveModels(List<(String, String)> keys) => keys
        .map((k) => modelIdByKey['${k.$1}|${k.$2}'])
        .whereType<int>()
        .toList();

    // 3. Verified spareparts & fitments covering Honda, Yamaha, and Kawasaki
    final verifiedCatalogParts =
        <(String, String, String, String, int, int, String, List<int>)>[
          // --- HONDA ---
          (
            'Oli Mesin Honda ASM 10W-30 SL',
            'ASM 10W-30 SL',
            'oli_mesin',
            'Honda',
            65000,
            astraId,
            'https://www.astra-honda.com',
            resolveModels([
              ('Honda', 'Vario 160'),
              ('Honda', 'Vario 150'),
              ('Honda', 'Vario 125'),
              ('Honda', 'Vario 110'),
              ('Honda', 'Vario 110 eSP'),
              ('Honda', 'Beat Street'),
              ('Honda', 'Beat FI'),
              ('Honda', 'Beat Karbu'),
              ('Honda', 'Scoopy'),
              ('Honda', 'Scoopy FI'),
              ('Honda', 'Genio'),
              ('Honda', 'Spacy'),
              ('Honda', 'Spacy Helm-In FI'),
              ('Honda', 'PCX 150'),
              ('Honda', 'PCX 160'),
              ('Honda', 'ADV 150'),
              ('Honda', 'ADV 160'),
              ('Honda', 'Stylo 160'),
            ]),
          ),
          (
            'Oli Mesin Honda ASM 20W-50 SG',
            'ASM 20W-50 SG',
            'oli_mesin',
            'Honda',
            58000,
            astraId,
            'https://www.astra-honda.com',
            resolveModels([
              ('Honda', 'Astrea Prima'),
              ('Honda', 'Astrea Grand'),
              ('Honda', 'Astrea Legenda'),
              ('Honda', 'Supra 100'),
              ('Honda', 'Supra Fit'),
              ('Honda', 'Karisma 125'),
              ('Honda', 'Supra X 125'),
              ('Honda', 'Supra X 125 FI'),
              ('Honda', 'Supra GTR 150'),
              ('Honda', 'Revo'),
              ('Honda', 'Revo FI'),
              ('Honda', 'Blade 110'),
              ('Honda', 'Blade 125 FI'),
              ('Honda', 'CS1'),
              ('Honda', 'Sonic 150R'),
              ('Honda', 'Win 100'),
              ('Honda', 'GL Pro'),
              ('Honda', 'GL Max'),
              ('Honda', 'Tiger 2000'),
              ('Honda', 'MegaPro'),
              ('Honda', 'New MegaPro FI'),
              ('Honda', 'Verza 150'),
              ('Honda', 'CB150R Streetfire'),
              ('Honda', 'CBR150R'),
              ('Honda', 'CBR250RR'),
              ('Honda', 'CRF150L'),
            ]),
          ),
          (
            'Kampas Rem Depan Honda Vario 160/125',
            '45251-KVR-E10',
            'kampas_rem',
            'Honda',
            85000,
            astraId,
            'https://www.astra-honda.com',
            resolveModels([
              ('Honda', 'Vario 160'),
              ('Honda', 'Vario 150'),
              ('Honda', 'Vario 125'),
              ('Honda', 'Vario 110'),
              ('Honda', 'Vario 110 eSP'),
              ('Honda', 'Beat Street'),
              ('Honda', 'Beat FI'),
              ('Honda', 'Beat Karbu'),
              ('Honda', 'Scoopy FI'),
              ('Honda', 'Genio'),
              ('Honda', 'PCX 150'),
              ('Honda', 'PCX 160'),
              ('Honda', 'ADV 150'),
              ('Honda', 'ADV 160'),
              ('Honda', 'Stylo 160'),
            ]),
          ),
          (
            'Filter Udara Honda Vario 160',
            '17210-K15-T00',
            'filter_udara',
            'Honda',
            55000,
            astraId,
            'https://www.astra-honda.com',
            resolveModels([
              ('Honda', 'Vario 160'),
              ('Honda', 'PCX 160'),
              ('Honda', 'ADV 160'),
              ('Honda', 'Stylo 160'),
            ]),
          ),
          (
            'Busi NGK CR7HSA',
            'CR7HSA',
            'busi',
            'NGK',
            35000,
            astraId,
            'https://www.astra-honda.com',
            resolveModels([
              ('Honda', 'Vario 160'),
              ('Honda', 'Vario 125'),
              ('Honda', 'Beat Street'),
              ('Honda', 'Beat Karbu'),
              ('Honda', 'Supra X 125 FI'),
              ('Honda', 'Supra X 125'),
              ('Honda', 'Astrea Grand'),
              ('Honda', 'Win 100'),
            ]),
          ),
          (
            'Aki GS YTZ6V MF',
            'YTZ6V',
            'aki',
            'GS',
            180000,
            astraId,
            'https://www.astra-honda.com',
            resolveModels([
              ('Honda', 'Vario 160'),
              ('Honda', 'Vario 150'),
              ('Honda', 'Vario 125'),
              ('Honda', 'PCX 150'),
              ('Honda', 'PCX 160'),
              ('Honda', 'ADV 150'),
              ('Honda', 'ADV 160'),
              ('Honda', 'Stylo 160'),
              ('Honda', 'CB150R Streetfire'),
              ('Honda', 'CBR150R'),
              ('Honda', 'Sonic 150R'),
              ('Honda', 'Supra GTR 150'),
            ]),
          ),
          (
            'Sabuk CVT (V-Belt) Honda Vario 160',
            '23100-KYZ-E00',
            'cvt',
            'Honda',
            145000,
            astraId,
            'https://www.astra-honda.com',
            resolveModels([
              ('Honda', 'Vario 160'),
              ('Honda', 'PCX 160'),
              ('Honda', 'ADV 160'),
              ('Honda', 'Stylo 160'),
            ]),
          ),
          (
            'V-Belt Honda Beat Original',
            'HN-BEATVB',
            'cvt',
            'Honda',
            85000,
            astraId,
            'https://www.astra-honda.com',
            resolveModels([
              ('Honda', 'Beat Street'),
              ('Honda', 'Beat FI'),
              ('Honda', 'Beat Karbu'),
              ('Honda', 'Scoopy'),
              ('Honda', 'Scoopy FI'),
              ('Honda', 'Genio'),
              ('Honda', 'Vario 110'),
              ('Honda', 'Vario 110 eSP'),
              ('Honda', 'Vario 125'),
            ]),
          ),
          (
            'AHM Oil Scooter Gear Oil 120ml',
            '08234-M99-K0NZ1',
            'oli_gardan',
            'Honda',
            16000,
            astraId,
            'https://www.astra-honda.com',
            resolveModels([
              ('Honda', 'Vario 160'),
              ('Honda', 'Vario 150'),
              ('Honda', 'Vario 125'),
              ('Honda', 'Vario 110'),
              ('Honda', 'Vario 110 eSP'),
              ('Honda', 'Beat Street'),
              ('Honda', 'Beat FI'),
              ('Honda', 'Beat Karbu'),
              ('Honda', 'Scoopy'),
              ('Honda', 'Scoopy FI'),
              ('Honda', 'Genio'),
              ('Honda', 'Spacy'),
              ('Honda', 'Spacy Helm-In FI'),
              ('Honda', 'PCX 150'),
              ('Honda', 'PCX 160'),
              ('Honda', 'ADV 150'),
              ('Honda', 'ADV 160'),
              ('Honda', 'Stylo 160'),
            ]),
          ),
          (
            'Honda Genuine Brake Fluid DOT 4 50ml',
            '08260-M99-01NZ1',
            'minyak_rem',
            'Honda',
            18000,
            astraId,
            'https://www.astra-honda.com',
            resolveModels([
              ('Honda', 'Vario 160'),
              ('Honda', 'PCX 160'),
              ('Honda', 'ADV 160'),
              ('Honda', 'Stylo 160'),
              ('Honda', 'CBR150R'),
              ('Honda', 'CBR250RR'),
              ('Honda', 'CB150R Streetfire'),
              ('Honda', 'Supra X 125 FI'),
              ('Honda', 'Supra GTR 150'),
              ('Honda', 'CRF150L'),
            ]),
          ),
          (
            'AHM Radiator Coolant Pre-mix 1L',
            '08CLA-G01-W01',
            'coolant',
            'Honda',
            24000,
            astraId,
            'https://www.astra-honda.com',
            resolveModels([
              ('Honda', 'Vario 160'),
              ('Honda', 'Vario 150'),
              ('Honda', 'Vario 125'),
              ('Honda', 'Vario 110'),
              ('Honda', 'PCX 150'),
              ('Honda', 'PCX 160'),
              ('Honda', 'ADV 150'),
              ('Honda', 'ADV 160'),
              ('Honda', 'Stylo 160'),
              ('Honda', 'Supra GTR 150'),
              ('Honda', 'CS1'),
              ('Honda', 'Sonic 150R'),
              ('Honda', 'CB150R Streetfire'),
              ('Honda', 'CBR150R'),
              ('Honda', 'CBR250RR'),
            ]),
          ),
          (
            'Saringan Kasa Filter Oli Honda Vario 160',
            '15421-K0R-V00',
            'filter_oli',
            'Honda',
            18000,
            astraId,
            'https://www.astra-honda.com',
            resolveModels([
              ('Honda', 'Vario 160'),
              ('Honda', 'PCX 160'),
              ('Honda', 'ADV 160'),
              ('Honda', 'Stylo 160'),
            ]),
          ),
          (
            'Rantai Set AHM Supra X / CBR150R',
            '06401-K45-N00',
            'rantai',
            'Honda',
            195000,
            astraId,
            'https://www.astra-honda.com',
            resolveModels([
              ('Honda', 'Astrea Prima'),
              ('Honda', 'Astrea Grand'),
              ('Honda', 'Astrea Legenda'),
              ('Honda', 'Supra 100'),
              ('Honda', 'Supra Fit'),
              ('Honda', 'Karisma 125'),
              ('Honda', 'Supra X 125'),
              ('Honda', 'Supra X 125 FI'),
              ('Honda', 'Supra GTR 150'),
              ('Honda', 'Revo'),
              ('Honda', 'Revo FI'),
              ('Honda', 'Blade 110'),
              ('Honda', 'Blade 125 FI'),
              ('Honda', 'CS1'),
              ('Honda', 'Sonic 150R'),
              ('Honda', 'Win 100'),
              ('Honda', 'GL Pro'),
              ('Honda', 'GL Max'),
              ('Honda', 'Tiger 2000'),
              ('Honda', 'MegaPro'),
              ('Honda', 'New MegaPro FI'),
              ('Honda', 'Verza 150'),
              ('Honda', 'CB150R Streetfire'),
              ('Honda', 'CBR150R'),
              ('Honda', 'CRF150L'),
            ]),
          ),

          // --- YAMAHA ---
          (
            'Oli Mesin Yamalube Matic 10W-40',
            'Yamalube 10W-40',
            'oli_mesin',
            'Yamaha',
            70000,
            yamahaId,
            'https://www.yamaha-motor.co.id',
            resolveModels([
              ('Yamaha', 'NMAX'),
              ('Yamaha', 'Aerox'),
              ('Yamaha', 'XMAX'),
              ('Yamaha', 'Lexi'),
              ('Yamaha', 'Mio Sporty'),
              ('Yamaha', 'Mio Soul'),
              ('Yamaha', 'Mio J / GT'),
              ('Yamaha', 'Mio M3'),
              ('Yamaha', 'Fino Karbu'),
              ('Yamaha', 'Fino 125 FI'),
              ('Yamaha', 'Xeon 125'),
              ('Yamaha', 'Xeon RC / GT 125'),
              ('Yamaha', 'FreeGo'),
              ('Yamaha', 'X-Ride'),
              ('Yamaha', 'Gear 125'),
              ('Yamaha', 'Fazzio'),
              ('Yamaha', 'Grand Filano'),
            ]),
          ),
          (
            'Yamalube Sport 4T 10W-40 1L',
            '90793-AJ414',
            'oli_mesin',
            'Yamaha',
            72000,
            yamahaId,
            'https://www.yamaha-motor.co.id',
            resolveModels([
              ('Yamaha', 'Vega'),
              ('Yamaha', 'Vega ZR'),
              ('Yamaha', 'Vega Force'),
              ('Yamaha', 'Jupiter Z'),
              ('Yamaha', 'Jupiter Z1'),
              ('Yamaha', 'Jupiter MX 135'),
              ('Yamaha', 'MX King 150'),
              ('Yamaha', 'Scorpio Z'),
              ('Yamaha', 'Byson'),
              ('Yamaha', 'Byson FI'),
              ('Yamaha', 'Vixion'),
              ('Yamaha', 'R15'),
              ('Yamaha', 'R25'),
              ('Yamaha', 'MT-15'),
              ('Yamaha', 'XSR 155'),
              ('Yamaha', 'WR 155 R'),
            ]),
          ),
          (
            'Yamalube 2T Oil 0.7L',
            '90793-AJ201',
            'oli_mesin',
            'Yamaha',
            58000,
            yamahaId,
            'https://www.yamaha-motor.co.id',
            resolveModels([
              ('Yamaha', 'Alfa'),
              ('Yamaha', 'Force 1'),
              ('Yamaha', 'F1ZR'),
              ('Yamaha', 'RX-S'),
              ('Yamaha', 'RX-King'),
            ]),
          ),
          (
            'Kampas Rem Depan Yamaha NMAX Genuine',
            'NS-NMAXFR-GEN',
            'kampas_rem',
            'Yamaha',
            60000,
            yamahaId,
            'https://www.yamaha-motor.co.id',
            resolveModels([
              ('Yamaha', 'NMAX'),
              ('Yamaha', 'Aerox'),
              ('Yamaha', 'XMAX'),
              ('Yamaha', 'Lexi'),
              ('Yamaha', 'Mio M3'),
              ('Yamaha', 'FreeGo'),
              ('Yamaha', 'X-Ride'),
              ('Yamaha', 'Gear 125'),
              ('Yamaha', 'Fazzio'),
              ('Yamaha', 'Grand Filano'),
            ]),
          ),
          (
            'Filter Udara Yamaha NMAX Genuine',
            'YM-NMAXFL-GEN',
            'filter_udara',
            'Yamaha',
            50000,
            yamahaId,
            'https://www.yamaha-motor.co.id',
            resolveModels([
              ('Yamaha', 'NMAX'),
              ('Yamaha', 'Aerox'),
              ('Yamaha', 'Lexi'),
            ]),
          ),
          (
            'Yamalube Motor Gear Oil 100ml',
            '90793-AJ827',
            'oli_gardan',
            'Yamaha',
            17500,
            yamahaId,
            'https://www.yamaha-motor.co.id',
            resolveModels([
              ('Yamaha', 'NMAX'),
              ('Yamaha', 'Aerox'),
              ('Yamaha', 'XMAX'),
              ('Yamaha', 'Lexi'),
              ('Yamaha', 'Mio Sporty'),
              ('Yamaha', 'Mio Soul'),
              ('Yamaha', 'Mio J / GT'),
              ('Yamaha', 'Mio M3'),
              ('Yamaha', 'Fino Karbu'),
              ('Yamaha', 'Fino 125 FI'),
              ('Yamaha', 'Xeon 125'),
              ('Yamaha', 'Xeon RC / GT 125'),
              ('Yamaha', 'FreeGo'),
              ('Yamaha', 'X-Ride'),
              ('Yamaha', 'Gear 125'),
              ('Yamaha', 'Fazzio'),
              ('Yamaha', 'Grand Filano'),
            ]),
          ),
          (
            'Yamalube Brake Fluid DOT 4 50ml',
            '90793-AJ811',
            'minyak_rem',
            'Yamaha',
            20000,
            yamahaId,
            'https://www.yamaha-motor.co.id',
            resolveModels([
              ('Yamaha', 'NMAX'),
              ('Yamaha', 'Aerox'),
              ('Yamaha', 'XMAX'),
              ('Yamaha', 'Lexi'),
              ('Yamaha', 'Vixion'),
              ('Yamaha', 'R15'),
              ('Yamaha', 'R25'),
              ('Yamaha', 'MT-15'),
              ('Yamaha', 'XSR 155'),
              ('Yamaha', 'WR 155 R'),
              ('Yamaha', 'MX King 150'),
            ]),
          ),
          (
            'Yamalube Yamacoolant 1L',
            '90793-AJ803',
            'coolant',
            'Yamaha',
            38000,
            yamahaId,
            'https://www.yamaha-motor.co.id',
            resolveModels([
              ('Yamaha', 'NMAX'),
              ('Yamaha', 'Aerox'),
              ('Yamaha', 'XMAX'),
              ('Yamaha', 'Lexi'),
              ('Yamaha', 'Xeon 125'),
              ('Yamaha', 'Xeon RC / GT 125'),
              ('Yamaha', 'Jupiter MX 135'),
              ('Yamaha', 'MX King 150'),
              ('Yamaha', 'Vixion'),
              ('Yamaha', 'R15'),
              ('Yamaha', 'R25'),
              ('Yamaha', 'MT-15'),
              ('Yamaha', 'XSR 155'),
              ('Yamaha', 'WR 155 R'),
            ]),
          ),
          (
            'V-Belt Yamaha Genuine Aerox/NMAX',
            'B65-E7641-00',
            'cvt',
            'Yamaha',
            135000,
            yamahaId,
            'https://www.yamaha-motor.co.id',
            resolveModels([
              ('Yamaha', 'NMAX'),
              ('Yamaha', 'Aerox'),
              ('Yamaha', 'Lexi'),
            ]),
          ),
          (
            'V-Belt Yamaha Mio M3 / FreeGo Genuine',
            '2PH-E7641-00',
            'cvt',
            'Yamaha',
            98000,
            yamahaId,
            'https://www.yamaha-motor.co.id',
            resolveModels([
              ('Yamaha', 'Mio M3'),
              ('Yamaha', 'FreeGo'),
              ('Yamaha', 'X-Ride'),
              ('Yamaha', 'Gear 125'),
              ('Yamaha', 'Fazzio'),
              ('Yamaha', 'Grand Filano'),
              ('Yamaha', 'Fino 125 FI'),
            ]),
          ),
          (
            'Rantai & Gir Set Yamaha Vixion / R15 / MX King',
            '3C1-WF01A-00',
            'rantai',
            'Yamaha',
            215000,
            yamahaId,
            'https://www.yamaha-motor.co.id',
            resolveModels([
              ('Yamaha', 'Vega'),
              ('Yamaha', 'Vega ZR'),
              ('Yamaha', 'Vega Force'),
              ('Yamaha', 'Jupiter Z'),
              ('Yamaha', 'Jupiter Z1'),
              ('Yamaha', 'Jupiter MX 135'),
              ('Yamaha', 'MX King 150'),
              ('Yamaha', 'RX-King'),
              ('Yamaha', 'Scorpio Z'),
              ('Yamaha', 'Byson'),
              ('Yamaha', 'Byson FI'),
              ('Yamaha', 'Vixion'),
              ('Yamaha', 'R15'),
              ('Yamaha', 'MT-15'),
              ('Yamaha', 'XSR 155'),
              ('Yamaha', 'WR 155 R'),
            ]),
          ),

          // --- KAWASAKI ---
          (
            'Oli Mesin Kawasaki Genuine 4T 10W-40 1L',
            'KGO-10W40-1L',
            'oli_mesin',
            'Kawasaki',
            88000,
            kawasakiId,
            'https://www.kawasaki-motor.co.id',
            resolveModels([
              ('Kawasaki', 'Ninja 250SL'),
              ('Kawasaki', 'Ninja 250R Karbu'),
              ('Kawasaki', 'Ninja 250 FI'),
              ('Kawasaki', 'Ninja ZX-25R'),
              ('Kawasaki', 'W175'),
              ('Kawasaki', 'Estrella / W250'),
              ('Kawasaki', 'KLX 150'),
              ('Kawasaki', 'KLX 230'),
              ('Kawasaki', 'D-Tracker 150'),
              ('Kawasaki', 'Versys-X 250'),
              ('Kawasaki', 'Z125'),
              ('Kawasaki', 'Z250'),
              ('Kawasaki', 'Kaze'),
              ('Kawasaki', 'Blitz'),
              ('Kawasaki', 'Athlete'),
              ('Kawasaki', 'Edge'),
            ]),
          ),
          (
            'Oli Samping Kawasaki 2T Genuine 1L',
            'KGO-2T-1L',
            'oli_mesin',
            'Kawasaki',
            92000,
            kawasakiId,
            'https://www.kawasaki-motor.co.id',
            resolveModels([
              ('Kawasaki', 'Ninja 150 R'),
              ('Kawasaki', 'Ninja 150 SS'),
              ('Kawasaki', 'Ninja 150 RR'),
            ]),
          ),
          (
            'Filter Oli Kawasaki Ninja 250SL Genuine',
            '52010-1053',
            'filter_oli',
            'Kawasaki',
            45000,
            kawasakiId,
            'https://www.kawasaki-motor.co.id',
            resolveModels([
              ('Kawasaki', 'Ninja 250SL'),
              ('Kawasaki', 'Ninja 250 FI'),
              ('Kawasaki', 'Ninja ZX-25R'),
              ('Kawasaki', 'KLX 150'),
              ('Kawasaki', 'KLX 230'),
              ('Kawasaki', 'D-Tracker 150'),
              ('Kawasaki', 'Versys-X 250'),
              ('Kawasaki', 'Z125'),
              ('Kawasaki', 'Z250'),
            ]),
          ),
          (
            'Rantai & Gir Set Kawasaki W175 / Ninja 250SL',
            'KAW-428H-KIT',
            'rantai',
            'Kawasaki',
            265000,
            kawasakiId,
            'https://www.kawasaki-motor.co.id',
            resolveModels([
              ('Kawasaki', 'Ninja 150 R'),
              ('Kawasaki', 'Ninja 150 SS'),
              ('Kawasaki', 'Ninja 150 RR'),
              ('Kawasaki', 'Ninja 250R Karbu'),
              ('Kawasaki', 'Ninja 250 FI'),
              ('Kawasaki', 'Ninja 250SL'),
              ('Kawasaki', 'KLX 150'),
              ('Kawasaki', 'KLX 230'),
              ('Kawasaki', 'D-Tracker 150'),
              ('Kawasaki', 'W175'),
              ('Kawasaki', 'Estrella / W250'),
              ('Kawasaki', 'Versys-X 250'),
              ('Kawasaki', 'Z125'),
              ('Kawasaki', 'Z250'),
              ('Kawasaki', 'Kaze'),
              ('Kawasaki', 'Blitz'),
              ('Kawasaki', 'Athlete'),
              ('Kawasaki', 'Edge'),
            ]),
          ),
          (
            'Kawasaki Alabaster Coolant Pre-Mix 1L',
            'KAW-COOL-1L',
            'coolant',
            'Kawasaki',
            48000,
            kawasakiId,
            'https://www.kawasaki-motor.co.id',
            resolveModels([
              ('Kawasaki', 'Ninja 150 R'),
              ('Kawasaki', 'Ninja 150 SS'),
              ('Kawasaki', 'Ninja 150 RR'),
              ('Kawasaki', 'Ninja 250R Karbu'),
              ('Kawasaki', 'Ninja 250 FI'),
              ('Kawasaki', 'Ninja 250SL'),
              ('Kawasaki', 'Ninja ZX-25R'),
              ('Kawasaki', 'Versys-X 250'),
              ('Kawasaki', 'Z250'),
            ]),
          ),
        ];

    await _deduplicateSpareparts();

    for (final (name, pNum, cat, brand, price, sourceId, url, targetModelIds)
        in verifiedCatalogParts) {
      final existingMatches = await (select(spareparts)
            ..where((t) => t.partNumber.equals(pNum) | t.name.equals(name))
            ..orderBy([(t) => OrderingTerm.asc(t.id)]))
          .get();
      final existing = existingMatches.isEmpty ? null : existingMatches.first;

      final int partId;
      if (existing == null) {
        partId = await into(spareparts).insert(
          SparepartsCompanion.insert(
            name: name,
            partNumber: Value(pNum),
            category: cat,
            brand: Value(brand),
            referencePrice: Value(price),
            sourceId: Value(sourceId),
            productUrl: Value(url),
            priceUpdatedAt: Value(DateTime(2026, 1, 15)),
            catalogVersion: const Value('1.0.0'),
            isVerified: const Value(true),
          ),
        );
      } else {
        partId = existing.id;
        await (update(spareparts)..where((t) => t.id.equals(partId))).write(
          SparepartsCompanion(
            partNumber: Value(pNum),
            category: Value(cat),
            brand: Value(brand),
            isVerified: const Value(true),
            sourceId: Value(sourceId),
            productUrl: Value(url),
            referencePrice: Value(price),
            priceUpdatedAt: Value(DateTime(2026, 1, 15)),
            catalogVersion: const Value('1.0.0'),
          ),
        );
      }

      // Add fitment for every verified target model that exists in DB
      for (final targetModelId in targetModelIds) {
        final existingFitment =
            await (select(sparepartFitments)..where(
                  (t) =>
                      t.sparepartId.equals(partId) &
                      t.modelId.equals(targetModelId),
                ))
                .getSingleOrNull();

        if (existingFitment == null) {
          final modelYearStart = modelById[targetModelId]?.yearStart ?? 2019;
          await into(sparepartFitments).insert(
            SparepartFitmentsCompanion.insert(
              sparepartId: partId,
              modelId: Value(targetModelId),
              yearStart: modelYearStart,
              verifiedAt: Value(DateTime(2026, 1, 15)),
              sourceUrl: Value(url),
            ),
          );
        }
      }
    }
  }

  Future<void> _seedDefaultSettings() async {
    final defaults = {
      'theme_mode': 'dark',
      'active_motorcycle_id': '',
      'odometer_reminder_days': '30',
      'ai_model_name': 'qwen3-0.6b',
      'ai_model_status': 'not_downloaded',
      'user_name': 'Rider BuildHaus',
      'user_email': '',
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

  /// Seed motorcycle_models table from Indonesian Honda, Yamaha, Kawasaki catalog (1990-present).
  /// Removes legacy Suzuki models that are no longer referenced by user motorcycles,
  /// and keeps existing model IDs stable via in-place sync.
  Future<void> _seedMotorcycleModels() async {
    final existingModels = await select(motorcycleModels).get();
    final usedModelIds = (await select(motorcycles).get())
        .map((m) => m.modelId)
        .whereType<int>()
        .toSet();

    final unusedSuzukiIds = existingModels
        .where(
          (m) =>
              m.brand.trim().toLowerCase() == 'suzuki' &&
              !usedModelIds.contains(m.id),
        )
        .map((m) => m.id)
        .toList();

    if (unusedSuzukiIds.isNotEmpty) {
      await (delete(sparepartFitments)
            ..where((t) => t.modelId.isIn(unusedSuzukiIds)))
          .go();
      await (delete(maintenanceRules)
            ..where((t) => t.modelId.isIn(unusedSuzukiIds)))
          .go();
      await (delete(motorcycleModels)
            ..where((t) => t.id.isIn(unusedSuzukiIds)))
          .go();
    }

    final existingByKey = <String, MotorcycleModel>{
      for (final m in existingModels)
        if (!unusedSuzukiIds.contains(m.id))
          '${m.brand.trim().toLowerCase()}|${m.model.trim().toLowerCase()}': m,
    };

    const hondaUrl = 'https://www.astra-honda.com';
    const yamahaUrl = 'https://www.yamaha-motor.co.id';
    const kawasakiUrl = 'https://www.kawasaki-motor.co.id';

    // (brand, model, variant, generation, yearStart, yearEnd, sourceUrl)
    const catalogSpecs = <(String, String, String, String, int, int?, String)>[
      // Honda (Vario 160 tetap pertama untuk konsistensi default UI & test)
      ('Honda', 'Vario 160', 'CBS-ISS SP', '2022-sekarang', 2022, null, hondaUrl),
      ('Honda', 'Vario 125', 'CBS-ISS', '2012-sekarang', 2012, null, hondaUrl),
      ('Honda', 'Vario 150', 'eSP Exclusive', '2015-2022', 2015, 2022, hondaUrl),
      ('Honda', 'Vario 110', 'CW / Techno', '2006-2013', 2006, 2013, hondaUrl),
      ('Honda', 'Vario 110 eSP', 'PGM-FI / CBS', '2014-2019', 2014, 2019, hondaUrl),
      ('Honda', 'Beat Street', 'CBS / eSP', '2016-sekarang', 2016, null, hondaUrl),
      ('Honda', 'Beat FI', 'CBS / eSP Deluxe', '2012-sekarang', 2012, null, hondaUrl),
      ('Honda', 'Beat Karbu', 'CW / CBS', '2008-2012', 2008, 2012, hondaUrl),
      ('Honda', 'Scoopy', 'Karburator', '2010-2012', 2010, 2012, hondaUrl),
      ('Honda', 'Scoopy FI', 'eSP / Prestige', '2013-sekarang', 2013, null, hondaUrl),
      ('Honda', 'Genio', 'CBS-ISS', '2019-sekarang', 2019, null, hondaUrl),
      ('Honda', 'Spacy', 'Karburator CW', '2011-2012', 2011, 2012, hondaUrl),
      ('Honda', 'Spacy Helm-In FI', 'PGM-FI', '2012-2018', 2012, 2018, hondaUrl),
      ('Honda', 'PCX 150', 'CBU / Lokal ABS', '2010-2021', 2010, 2021, hondaUrl),
      ('Honda', 'PCX 160', 'ABS', '2021-sekarang', 2021, null, hondaUrl),
      ('Honda', 'ADV 150', 'CBS / ABS', '2019-2022', 2019, 2022, hondaUrl),
      ('Honda', 'ADV 160', 'CBS-ISS', '2022-sekarang', 2022, null, hondaUrl),
      ('Honda', 'Stylo 160', 'ABS / CBS', '2024-sekarang', 2024, null, hondaUrl),
      ('Honda', 'Astrea Prima', 'Star / Limited', '1990-1991', 1990, 1991, hondaUrl),
      ('Honda', 'Astrea Grand', 'Bulbus / Impressa', '1991-2000', 1991, 2000, hondaUrl),
      ('Honda', 'Astrea Legenda', 'Legenda 2', '2001-2004', 2001, 2004, hondaUrl),
      ('Honda', 'Supra 100', 'X / XX / V', '1997-2005', 1997, 2005, hondaUrl),
      ('Honda', 'Supra Fit', 'New / S / R', '2003-2009', 2003, 2009, hondaUrl),
      ('Honda', 'Karisma 125', 'X / D', '2002-2006', 2002, 2006, hondaUrl),
      ('Honda', 'Supra X 125', 'Karburator', '2005-2013', 2005, 2013, hondaUrl),
      ('Honda', 'Supra X 125 FI', 'Helm In', '2014-sekarang', 2014, null, hondaUrl),
      ('Honda', 'Supra GTR 150', 'Exclusive / Sporty', '2016-sekarang', 2016, null, hondaUrl),
      ('Honda', 'Revo', '100 / Absolute', '2007-2013', 2007, 2013, hondaUrl),
      ('Honda', 'Revo FI', 'X / Fit', '2014-sekarang', 2014, null, hondaUrl),
      ('Honda', 'Blade 110', 'R / Repsol', '2008-2013', 2008, 2013, hondaUrl),
      ('Honda', 'Blade 125 FI', 'R / Repsol', '2014-2018', 2014, 2018, hondaUrl),
      ('Honda', 'CS1', 'City Sport One 125', '2008-2014', 2008, 2014, hondaUrl),
      ('Honda', 'Sonic 150R', 'Standard / Racing', '2015-sekarang', 2015, null, hondaUrl),
      ('Honda', 'Win 100', 'Trail / Standard', '1990-2005', 1990, 2005, hondaUrl),
      ('Honda', 'GL Pro', 'Neotech 160', '1990-1999', 1990, 1999, hondaUrl),
      ('Honda', 'GL Max', 'Neotech 125', '1990-2005', 1990, 2005, hondaUrl),
      ('Honda', 'Tiger 2000', 'GL200 / Revo', '1993-2013', 1993, 2013, hondaUrl),
      ('Honda', 'MegaPro', 'Primus / New Karbu', '1999-2013', 1999, 2013, hondaUrl),
      ('Honda', 'New MegaPro FI', 'PGM-FI', '2014-2018', 2014, 2018, hondaUrl),
      ('Honda', 'Verza 150', 'PGM-FI / CB150 Verza', '2013-sekarang', 2013, null, hondaUrl),
      ('Honda', 'CB150R Streetfire', 'Special Edition', '2012-sekarang', 2012, null, hondaUrl),
      ('Honda', 'CBR150R', 'ABS', '2011-sekarang', 2011, null, hondaUrl),
      ('Honda', 'CBR250RR', 'ABS Quick Shifter', '2016-sekarang', 2016, null, hondaUrl),
      ('Honda', 'CRF150L', 'Standard / Extreme', '2017-sekarang', 2017, null, hondaUrl),

      // Yamaha
      ('Yamaha', 'NMAX', 'Connected', '2015-sekarang', 2015, null, yamahaUrl),
      ('Yamaha', 'Aerox', 'Connected', '2016-sekarang', 2016, null, yamahaUrl),
      ('Yamaha', 'XMAX', 'Connected 250', '2017-sekarang', 2017, null, yamahaUrl),
      ('Yamaha', 'Lexi', '125 / LX 155', '2018-sekarang', 2018, null, yamahaUrl),
      ('Yamaha', 'Mio Sporty', 'Smile / CW Karbu', '2003-2012', 2003, 2012, yamahaUrl),
      ('Yamaha', 'Mio Soul', 'Karburator', '2007-2012', 2007, 2012, yamahaUrl),
      ('Yamaha', 'Mio J / GT', 'YMJET-FI', '2012-2015', 2012, 2015, yamahaUrl),
      ('Yamaha', 'Mio M3', 'CW', '2014-sekarang', 2014, null, yamahaUrl),
      ('Yamaha', 'Fino Karbu', 'Classic / Fashion', '2012-2013', 2012, 2013, yamahaUrl),
      ('Yamaha', 'Fino 125 FI', 'Grande / Premium', '2014-sekarang', 2014, null, yamahaUrl),
      ('Yamaha', 'Xeon 125', 'Karburator', '2010-2012', 2010, 2012, yamahaUrl),
      ('Yamaha', 'Xeon RC / GT 125', 'YMJET-FI', '2013-2016', 2013, 2016, yamahaUrl),
      ('Yamaha', 'X-Ride', '125', '2013-sekarang', 2013, null, yamahaUrl),
      ('Yamaha', 'FreeGo', 'S', '2018-sekarang', 2018, null, yamahaUrl),
      ('Yamaha', 'Gear 125', 'S Version', '2020-sekarang', 2020, null, yamahaUrl),
      ('Yamaha', 'Fazzio', 'Hybrid Neo / Lux', '2022-sekarang', 2022, null, yamahaUrl),
      ('Yamaha', 'Grand Filano', 'Hybrid Neo / Lux', '2023-sekarang', 2023, null, yamahaUrl),
      ('Yamaha', 'Alfa', 'IIR / Champ 2-Tak', '1990-1996', 1990, 1996, yamahaUrl),
      ('Yamaha', 'Force 1', 'F1 / F1Z 2-Tak', '1992-1997', 1992, 1997, yamahaUrl),
      ('Yamaha', 'F1ZR', 'Full Clutch 2-Tak', '1997-2004', 1997, 2004, yamahaUrl),
      ('Yamaha', 'RX-S', 'Special 115 2-Tak', '1990-1999', 1990, 1999, yamahaUrl),
      ('Yamaha', 'RX-King', 'Cobra / Master 2-Tak', '1990-2009', 1990, 2009, yamahaUrl),
      ('Yamaha', 'Vega', 'Crypton / Vega R', '1997-2009', 1997, 2009, yamahaUrl),
      ('Yamaha', 'Vega ZR', 'Karbu / RR', '2009-2015', 2009, 2015, yamahaUrl),
      ('Yamaha', 'Vega Force', 'FI CW', '2013-sekarang', 2013, null, yamahaUrl),
      ('Yamaha', 'Jupiter Z', 'Burhan / Robot Karbu', '2001-2012', 2001, 2012, yamahaUrl),
      ('Yamaha', 'Jupiter Z1', 'FI CW', '2012-sekarang', 2012, null, yamahaUrl),
      ('Yamaha', 'Jupiter MX 135', 'LC / New 5-Speed', '2005-2015', 2005, 2015, yamahaUrl),
      ('Yamaha', 'MX King 150', 'FI / Monster', '2015-sekarang', 2015, null, yamahaUrl),
      ('Yamaha', 'Scorpio Z', '225 Karbu', '2002-2014', 2002, 2014, yamahaUrl),
      ('Yamaha', 'Byson', 'Karburator', '2010-2014', 2010, 2014, yamahaUrl),
      ('Yamaha', 'Byson FI', 'Fuel Injection', '2015-2018', 2015, 2018, yamahaUrl),
      ('Yamaha', 'Vixion', 'NVA / R', '2007-sekarang', 2007, null, yamahaUrl),
      ('Yamaha', 'R15', 'V3 / Connected M', '2014-sekarang', 2014, null, yamahaUrl),
      ('Yamaha', 'R25', 'ABS', '2014-sekarang', 2014, null, yamahaUrl),
      ('Yamaha', 'MT-15', 'Standard', '2019-sekarang', 2019, null, yamahaUrl),
      ('Yamaha', 'XSR 155', 'Heritage', '2019-sekarang', 2019, null, yamahaUrl),
      ('Yamaha', 'WR 155 R', 'Dual Purpose', '2019-sekarang', 2019, null, yamahaUrl),

      // Kawasaki
      ('Kawasaki', 'Ninja 250SL', 'ABS', '2014-sekarang', 2014, null, kawasakiUrl),
      ('Kawasaki', 'W175', 'SE', '2017-sekarang', 2017, null, kawasakiUrl),
      ('Kawasaki', 'Z125', 'Pro', '2016-sekarang', 2016, null, kawasakiUrl),
      ('Kawasaki', 'Ninja 150 R', '2-Tak Super KIPS', '1996-2015', 1996, 2015, kawasakiUrl),
      ('Kawasaki', 'Ninja 150 SS', '2-Tak Round Lamp', '2011-2015', 2011, 2015, kawasakiUrl),
      ('Kawasaki', 'Ninja 150 RR', '2-Tak Fairing', '2002-2015', 2002, 2015, kawasakiUrl),
      ('Kawasaki', 'Ninja 250R Karbu', 'EX250J Karburator', '2008-2012', 2008, 2012, kawasakiUrl),
      ('Kawasaki', 'Ninja 250 FI', 'ABS SE', '2012-sekarang', 2012, null, kawasakiUrl),
      ('Kawasaki', 'Ninja ZX-25R', 'ABS SE 4-Silinder', '2020-sekarang', 2020, null, kawasakiUrl),
      ('Kawasaki', 'Kaze', 'R / VR / ZX130', '1995-2009', 1995, 2009, kawasakiUrl),
      ('Kawasaki', 'Blitz', 'R / Joy 125', '2003-2008', 2003, 2008, kawasakiUrl),
      ('Kawasaki', 'Athlete', '125 Pro', '2008-2016', 2008, 2016, kawasakiUrl),
      ('Kawasaki', 'Edge', 'R / VR 115', '2010-2013', 2010, 2013, kawasakiUrl),
      ('Kawasaki', 'KLX 150', 'S / BF / SE Karbu', '2009-sekarang', 2009, null, kawasakiUrl),
      ('Kawasaki', 'KLX 230', 'S / SE / SM', '2019-sekarang', 2019, null, kawasakiUrl),
      ('Kawasaki', 'D-Tracker 150', 'SE Supermoto', '2010-sekarang', 2010, null, kawasakiUrl),
      ('Kawasaki', 'Estrella / W250', 'BJ250 Classic FI', '2014-2022', 2014, 2022, kawasakiUrl),
      ('Kawasaki', 'Versys-X 250', 'Tourer ABS', '2017-sekarang', 2017, null, kawasakiUrl),
      ('Kawasaki', 'Z250', 'SL / Twin FI', '2013-2022', 2013, 2022, kawasakiUrl),
    ];

    for (final (brand, model, variant, gen, yearStart, yearEnd, sourceUrl)
        in catalogSpecs) {
      final key = '${brand.toLowerCase()}|${model.toLowerCase()}';
      final existing = existingByKey[key];
      if (existing == null) {
        await into(motorcycleModels).insert(
          MotorcycleModelsCompanion.insert(
            brand: brand,
            model: model,
            variant: Value(variant),
            generation: Value(gen),
            yearStart: yearStart,
            yearEnd: Value(yearEnd),
            sourceUrl: Value(sourceUrl),
            verifiedAt: const Value(null),
          ),
          mode: InsertMode.insertOrIgnore,
        );
      } else if (existing.variant != variant ||
          existing.generation != gen ||
          existing.yearStart != yearStart ||
          existing.yearEnd != yearEnd ||
          existing.sourceUrl != sourceUrl) {
        await (update(motorcycleModels)..where((t) => t.id.equals(existing.id)))
            .write(
              MotorcycleModelsCompanion(
                variant: Value(variant),
                generation: Value(gen),
                yearStart: Value(yearStart),
                yearEnd: Value(yearEnd),
                sourceUrl: Value(sourceUrl),
              ),
            );
      }
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
    for (final m in models) {
      modelByBrandModel.putIfAbsent('${m.brand}|${m.model}', () => m.id);
    }

    // Generic rules (modelId = null)
    final genericRules = [
      ('Oli mesin', 3000.0, 90, 2000.0),
      ('Kampas rem', 8000.0, 365, null),
      ('Aki', null, 730, null),
      ('Ban', 12000.0, 1095, null),
      ('Filter udara', 12000.0, 365, null),
      ('Busi', 16000.0, 730, null),
      ('CVT', 12000.0, 365, 8000.0),
      ('Oli gardan', 8000.0, 120, 6000.0),
      ('Minyak rem', 20000.0, 730, null),
      ('Radiator coolant', 12000.0, 365, null),
      ('Rantai & gir', 15000.0, 365, null),
      ('Suspensi', 24000.0, 730, null),
      ('Filter oli', 8000.0, 180, null),
      ('Knalpot', 24000.0, 730, null),
    ];

    for (final (name, km, days, severeKm) in genericRules) {
      final ct = compByName[name];
      if (ct == null) continue;
      final existing =
          await (select(maintenanceRules)..where(
                (t) =>
                    t.modelId.isNull() &
                    t.componentTypeId.equals(ct.id) &
                    t.ruleVersion.equals('v1'),
              ))
              .get();
      if (existing.isNotEmpty) continue;
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
          verifiedAt: const Value(null),
        ),
        mode: InsertMode.insertOrIgnore,
      );
    }

    // Model-specific rules for Honda Vario 160
    final vario160Id = modelByBrandModel['Honda|Vario 160'];
    final oliCt = compByName['Oli mesin'];
    if (vario160Id != null &&
        oliCt != null &&
        !(await _hasMaintenanceRule(vario160Id, oliCt.id))) {
      await into(maintenanceRules).insert(
        MaintenanceRulesCompanion.insert(
          modelId: Value(vario160Id),
          componentTypeId: oliCt.id,
          intervalKm: const Value(3000),
          intervalDays: const Value(90),
          severeUseRule: const Value('Pemakaian berat: ganti tiap 2000 km'),
          sourceUrl: const Value('Buku manual Honda Vario 160 CBS-ISS SP'),
          ruleVersion: const Value('v1'),
          verifiedAt: const Value(null),
        ),
        mode: InsertMode.insertOrIgnore,
      );
    }

    // CVT rule for Vario 160
    final cvtCt = compByName['CVT'];
    if (vario160Id != null &&
        cvtCt != null &&
        !(await _hasMaintenanceRule(vario160Id, cvtCt.id))) {
      await into(maintenanceRules).insert(
        MaintenanceRulesCompanion.insert(
          modelId: Value(vario160Id),
          componentTypeId: cvtCt.id,
          intervalKm: const Value(12000),
          intervalDays: const Value(365),
          sourceUrl: const Value('Buku manual Honda Vario 160 CBS-ISS SP'),
          ruleVersion: const Value('v1'),
          verifiedAt: const Value(null),
        ),
        mode: InsertMode.insertOrIgnore,
      );
    }

    // Model-specific rules for Yamaha NMAX
    final nmaxId = modelByBrandModel['Yamaha|NMAX'];
    if (nmaxId != null &&
        oliCt != null &&
        !(await _hasMaintenanceRule(nmaxId, oliCt.id))) {
      await into(maintenanceRules).insert(
        MaintenanceRulesCompanion.insert(
          modelId: Value(nmaxId),
          componentTypeId: oliCt.id,
          intervalKm: const Value(3000),
          intervalDays: const Value(90),
          severeUseRule: const Value('Pemakaian berat: ganti tiap 2000 km'),
          sourceUrl: const Value('Buku manual Yamaha NMAX'),
          ruleVersion: const Value('v1'),
          verifiedAt: const Value(null),
        ),
        mode: InsertMode.insertOrIgnore,
      );
    }

    // CVT rule for NMAX
    if (nmaxId != null &&
        cvtCt != null &&
        !(await _hasMaintenanceRule(nmaxId, cvtCt.id))) {
      await into(maintenanceRules).insert(
        MaintenanceRulesCompanion.insert(
          modelId: Value(nmaxId),
          componentTypeId: cvtCt.id,
          intervalKm: const Value(12000),
          intervalDays: const Value(365),
          sourceUrl: const Value('Buku manual Yamaha NMAX'),
          ruleVersion: const Value('v1'),
          verifiedAt: const Value(null),
        ),
        mode: InsertMode.insertOrIgnore,
      );
    }
  }

  Future<bool> _hasMaintenanceRule(int modelId, int componentId) async {
    return (await (select(maintenanceRules)..where(
              (t) =>
                  t.modelId.equals(modelId) &
                  t.componentTypeId.equals(componentId) &
                  t.ruleVersion.equals('v1'),
            ))
            .get())
        .isNotEmpty;
  }

  // ============================================================
  // MOTORCYCLES
  // ============================================================

  Future<List<Motorcycle>> getAllMotorcycles() => (select(
    motorcycles,
  )..orderBy([(t) => OrderingTerm.desc(t.isPrimary)])).get();

  Stream<List<Motorcycle>> watchAllMotorcycles() => (select(
    motorcycles,
  )..orderBy([(t) => OrderingTerm.desc(t.isPrimary)])).watch();

  Future<Motorcycle?> getMotorcycle(int id) =>
      (select(motorcycles)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertMotorcycle(MotorcyclesCompanion m) =>
      into(motorcycles).insert(m);

  Future<bool> updateMotorcycle(MotorcyclesCompanion m, int id) => (update(
    motorcycles,
  )..where((t) => t.id.equals(id))).write(m).then((r) => r > 0);

  /// Insert a motorcycle and its initial reading as one atomic operation.
  Future<int> createMotorcycle({
    required MotorcyclesCompanion motorcycle,
    double? initialOdometerKm,
  }) => transaction(() async {
    if (!motorcycle.modelId.present || motorcycle.modelId.value == null) {
      throw ArgumentError('Pilih model motor yang terdaftar.');
    }
    final model = await getMotorcycleModelById(motorcycle.modelId.value!);
    if (model == null) throw ArgumentError('Model motor tidak ditemukan.');
    if (motorcycle.manufactureYear.present &&
        (motorcycle.manufactureYear.value < model.yearStart ||
            (model.yearEnd != null &&
                motorcycle.manufactureYear.value > model.yearEnd!))) {
      throw ArgumentError('Tahun motor tidak sesuai model yang dipilih.');
    }
    if (initialOdometerKm != null &&
        (!initialOdometerKm.isFinite || initialOdometerKm < 0)) {
      throw ArgumentError('Odometer awal tidak valid.');
    }
    final existing = await getAllMotorcycles();
    final id = await into(
      motorcycles,
    ).insert(motorcycle.copyWith(isPrimary: Value(existing.isEmpty)));
    if (initialOdometerKm != null) {
      await into(odometerLogs).insert(
        OdometerLogsCompanion.insert(
          motorcycleId: id,
          odometerKm: initialOdometerKm,
          recordedAt: DateTime.now(),
          source: const Value('manual'),
        ),
      );
    }
    return id;
  });

  /// Creates a motorcycle and initializes its baseline odometer, component service
  /// history, and initial physical self-inspection so that all 14 component health
  /// statuses are calculated immediately on day 1.
  Future<int> createMotorcycleWithInitialHealth({
    required MotorcyclesCompanion motorcycle,
    required double initialOdometerKm,
    String oilHistory = 'baru', // 'baru', 'sedang', 'lama', 'belum_tahu'
    String transmissionHistory = 'baru',
    String brakeHistory = 'baru',
    String generalHistory = 'baru',
    Map<String, String>? initialInspectionAnswers,
  }) => transaction(() async {
    final motorId = await createMotorcycle(
      motorcycle: motorcycle,
      initialOdometerKm: initialOdometerKm,
    );

    final now = DateTime.now();
    if (initialOdometerKm > 300) {
      await into(odometerLogs).insert(
        OdometerLogsCompanion.insert(
          motorcycleId: motorId,
          odometerKm: (initialOdometerKm - 600).clamp(0.0, initialOdometerKm),
          recordedAt: now.subtract(const Duration(days: 30)),
          source: const Value('manual'),
          note: const Value('Odometer awal baseline'),
        ),
      );
    }

    double wearForLevel(String level) {
      switch (level) {
        case 'baru':
          return 0.15;
        case 'sedang':
          return 0.45;
        case 'lama':
          return 0.80;
        case 'belum_tahu':
          return 0.90;
        default:
          return 0.30;
      }
    }

    final motor = await getMotorcycle(motorId);
    final motorModel = (motor?.modelId != null)
        ? await getMotorcycleModelById(motor!.modelId!)
        : null;
    final usageMultiplier = motor?.usageProfile == 'jarak_jauh' ? 0.8 : 1.0;
    final allComponents = await getApplicableComponentsForModel(motor?.modelId);

    final Map<String, List<(ComponentType, String)>> buckets = {};
    final Map<String, (DateTime, double)> bucketMeta = {};

    for (final comp in allComponents) {
      final lowerName = comp.name.toLowerCase();
      String level = generalHistory;
      if (lowerName.contains('oli mesin') || lowerName.contains('filter oli')) {
        level = oilHistory;
      } else if (lowerName.contains('cvt') ||
          lowerName.contains('gardan') ||
          lowerName.contains('rantai')) {
        level = transmissionHistory;
      } else if (lowerName.contains('rem')) {
        level = brakeHistory;
      }

      final wear = wearForLevel(level);
      final candidateRules = await getMaintenanceRules(motor?.modelId, comp.id);
      final specific = candidateRules
          .where((r) => r.modelId == motor?.modelId && r.modelId != null)
          .toList();
      final generic = candidateRules.where((r) => r.modelId == null).toList();
      final rule = specific.isNotEmpty
          ? specific.first
          : (generic.isNotEmpty ? generic.first : null);
      final ageMultiplier = MotorcycleSpecs.ageIntervalMultiplier(
        motor?.manufactureYear,
        model: motorModel,
        componentName: comp.name,
      );

      final effKm = (rule?.intervalKm != null && rule!.intervalKm! > 0)
          ? rule.intervalKm! * usageMultiplier * ageMultiplier
          : 4000.0 * ageMultiplier;
      final effDays = (rule?.intervalDays != null && rule!.intervalDays! > 0)
          ? (rule.intervalDays! * ageMultiplier).round().clamp(1, 3650)
          : (180 * ageMultiplier).round().clamp(1, 3650);

      final usedKm = effKm * wear;
      final usedDays = (effDays * wear).round().clamp(1, 1500);
      final servicedOdo = (initialOdometerKm - usedKm).clamp(
        0.0,
        initialOdometerKm,
      );
      final servicedDate = now.subtract(Duration(days: usedDays));

      final key = '${usedDays}_${servicedOdo.round()}';
      buckets.putIfAbsent(key, () => []).add((comp, level));
      bucketMeta.putIfAbsent(key, () => (servicedDate, servicedOdo));
    }

    for (final entry in buckets.entries) {
      final (servicedDate, servicedOdo) = bucketMeta[entry.key]!;
      final compNames = entry.value.map((e) => e.$1.name).join(', ');
      final recId = await into(serviceRecords).insert(
        ServiceRecordsCompanion.insert(
          motorcycleId: motorId,
          servicedAt: servicedDate,
          odometerKm: Value(servicedOdo),
          workshopName: const Value('Data Kondisi Awal (Onboarding)'),
          notes: Value('Kondisi awal terdaftar: $compNames'),
          totalCost: const Value(0),
        ),
      );

      for (final (comp, level) in entry.value) {
        await into(serviceItems).insert(
          ServiceItemsCompanion.insert(
            serviceRecordId: recId,
            componentTypeId: Value(comp.id),
            action: 'replace',
            partsCost: const Value(0),
            laborCost: const Value(0),
            totalCost: const Value(0),
            notes: Value('Kondisi awal: $level'),
          ),
        );
      }
    }

    if (initialInspectionAnswers != null &&
        initialInspectionAnswers.isNotEmpty) {
      final eval = SelfInspectionEngine.evaluate(initialInspectionAnswers);
      await saveCompleteSelfInspection(
        motorcycleId: motorId,
        riskLevel: eval.riskLevel,
        answers: initialInspectionAnswers,
        notes: 'Pemeriksaan mandiri awal saat pendaftaran motor pertama.',
      );
    } else {
      await recalculateComponentStatuses(motorId);
    }

    return motorId;
  });

  /// Update profile and optional reading atomically.
  Future<void> updateMotorcycleWithOdometer({
    required int motorcycleId,
    required MotorcyclesCompanion changes,
    double? odometerKm,
  }) => transaction(() async {
    final motor = await getMotorcycle(motorcycleId);
    if (motor == null) throw ArgumentError('Motor tidak ditemukan.');
    final newModelId = changes.modelId.present
        ? changes.modelId.value
        : motor.modelId;
    if (newModelId == null) {
      throw ArgumentError('Pilih model motor yang valid.');
    }
    final model = await getMotorcycleModelById(newModelId);
    if (model == null) throw ArgumentError('Model motor tidak ditemukan.');
    final year = changes.manufactureYear.present
        ? changes.manufactureYear.value
        : motor.manufactureYear;
    if (year < model.yearStart ||
        (model.yearEnd != null && year > model.yearEnd!)) {
      throw ArgumentError('Tahun tidak sesuai dengan model motor.');
    }
    if (odometerKm != null && (!odometerKm.isFinite || odometerKm < 0)) {
      throw ArgumentError('Odometer tidak valid.');
    }
    if (odometerKm != null) {
      final latest = await getLatestOdometer(motorcycleId);
      if (latest != null && odometerKm < latest.odometerKm) {
        throw ArgumentError(
          'Odometer tidak boleh lebih rendah dari catatan terakhir.',
        );
      }
    }
    await updateMotorcycle(changes, motorcycleId);
    if (odometerKm != null) {
      final latest = await getLatestOdometer(motorcycleId);
      if (latest == null || odometerKm > latest.odometerKm) {
        await into(odometerLogs).insert(
          OdometerLogsCompanion.insert(
            motorcycleId: motorcycleId,
            odometerKm: odometerKm,
            recordedAt: DateTime.now(),
            source: const Value('manual'),
          ),
        );
      }
    }
    await recalculateComponentStatuses(motorcycleId);
  });

  Future<int> deleteMotorcycle(int id) => transaction(() async {
    if (await getMotorcycle(id) == null) return 0;
    final inspections = await (select(
      selfInspections,
    )..where((t) => t.motorcycleId.equals(id))).get();
    for (final item in inspections) {
      await (delete(
        inspectionAnswers,
      )..where((t) => t.inspectionId.equals(item.id))).go();
    }
    final complaintsForMotor = await getComplaints(id);
    for (final c in complaintsForMotor) {
      await (delete(
        complaintMessages,
      )..where((t) => t.complaintId.equals(c.id))).go();
      await (delete(
        complaintAnalyses,
      )..where((t) => t.complaintId.equals(c.id))).go();
    }
    // Complaints reference service records via resolved_by_service_id.
    await (delete(complaints)..where((t) => t.motorcycleId.equals(id))).go();
    await (delete(
      selfInspections,
    )..where((t) => t.motorcycleId.equals(id))).go();
    final plans = await (select(
      budgetPlans,
    )..where((t) => t.motorcycleId.equals(id))).get();
    for (final plan in plans) {
      final recs = await (select(
        serviceRecommendations,
      )..where((t) => t.budgetPlanId.equals(plan.id))).get();
      for (final rec in recs) {
        await (delete(
          recommendationItems,
        )..where((t) => t.recommendationId.equals(rec.id))).go();
      }
      await (delete(
        serviceRecommendations,
      )..where((t) => t.budgetPlanId.equals(plan.id))).go();
    }
    await (delete(budgetPlans)..where((t) => t.motorcycleId.equals(id))).go();
    final records = await getServiceRecords(id);
    for (final record in records) {
      await (delete(
        serviceItems,
      )..where((t) => t.serviceRecordId.equals(record.id))).go();
    }
    await (delete(
      serviceRecords,
    )..where((t) => t.motorcycleId.equals(id))).go();
    await (delete(odometerLogs)..where((t) => t.motorcycleId.equals(id))).go();
    await (delete(
      componentStatuses,
    )..where((t) => t.motorcycleId.equals(id))).go();
    await (delete(
      localReminders,
    )..where((t) => t.motorcycleId.equals(id))).go();
    final deleted = await (delete(
      motorcycles,
    )..where((t) => t.id.equals(id))).go();
    if (await getSetting('active_motorcycle_id') == id.toString()) {
      await setSetting('active_motorcycle_id', '');
    }
    final remaining = await getAllMotorcycles();
    if (remaining.isNotEmpty && !remaining.any((m) => m.isPrimary)) {
      await setPrimaryMotorcycle(remaining.first.id);
    }
    return deleted;
  });

  Future<void> setPrimaryMotorcycle(int id) => transaction(() async {
    if (await getMotorcycle(id) == null) {
      throw ArgumentError('Motor tidak ditemukan');
    }
    await (update(motorcycles)..where((t) => t.isPrimary.equals(true))).write(
      const MotorcyclesCompanion(isPrimary: Value(false)),
    );
    await (update(motorcycles)..where((t) => t.id.equals(id))).write(
      const MotorcyclesCompanion(isPrimary: Value(true)),
    );
  });

  // ============================================================
  // ODOMETER
  // ============================================================

  Future<List<OdometerLog>> getOdometerLogs(int motorcycleId) =>
      (select(odometerLogs)
            ..where((t) => t.motorcycleId.equals(motorcycleId))
            // Timestamps may tie at second precision; the newer row wins.
            ..orderBy([
              (t) => OrderingTerm.desc(t.recordedAt),
              (t) => OrderingTerm.desc(t.id),
            ]))
          .get();

  Future<OdometerLog?> getLatestOdometer(int motorcycleId) =>
      (select(odometerLogs)
            ..where((t) => t.motorcycleId.equals(motorcycleId))
            ..orderBy([
              (t) => OrderingTerm.desc(t.recordedAt),
              (t) => OrderingTerm.desc(t.id),
            ])
            ..limit(1))
          .getSingleOrNull();

  Future<int> insertOdometerLog(OdometerLogsCompanion l) =>
      into(odometerLogs).insert(l);

  // ============================================================
  // COMPONENT TYPES
  // ============================================================

  Future<List<ComponentType>> getAllComponentTypes() =>
      select(componentTypes).get();

  Future<List<ComponentType>> getApplicableComponentsForModel(
    int? modelId,
  ) async {
    final all = await getAllComponentTypes();
    if (modelId == null) return all;
    final model = await getMotorcycleModelById(modelId);
    if (model == null) return all;
    return all
        .where((c) => MotorcycleSpecs.isComponentApplicable(model, c))
        .toList();
  }

  Future<List<ComponentType>> getApplicableComponents(
    String? usageProfile, {
    int? modelId,
  }) async {
    return getApplicableComponentsForModel(modelId);
  }

  // ============================================================
  // COMPONENT STATUSES
  // ============================================================

  Future<List<ComponentStatus>> getComponentStatuses(int motorcycleId) =>
      (select(
        componentStatuses,
      )..where((t) => t.motorcycleId.equals(motorcycleId))).get();

  /// Menyimpan status komponen untuk satu motor.
  ///
  /// Operasi ini berupa select-lalu-update/insert sehingga dibungkus transaksi
  /// agar dua pemanggilan bersamaan tidak membuat baris duplikat dan
  /// melanggar constraint UNIQUE(motorcycle_id, component_type_id).
  Future<int> upsertComponentStatus(ComponentStatusesCompanion s) =>
      transaction(() async {
        if (!s.motorcycleId.present || !s.componentTypeId.present) {
          throw ArgumentError('Status memerlukan motorcycleId dan componentTypeId');
        }
        final existing =
            await (select(componentStatuses)..where(
                  (t) =>
                      t.motorcycleId.equals(s.motorcycleId.value) &
                      t.componentTypeId.equals(s.componentTypeId.value),
                ))
                .getSingleOrNull();
        if (existing != null) {
          await (update(componentStatuses)..where((t) => t.id.equals(existing.id)))
              .write(s.copyWith(id: const Value.absent()));
          return existing.id;
        }
        return into(componentStatuses).insert(s.copyWith(id: const Value.absent()));
      });

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
      (update(
        serviceRecords,
      )..where((t) => t.id.equals(id))).write(r).then((r) => r > 0);

  /// Save a service visit, all actions, and an optional odometer reading atomically.
  Future<int> createServiceWithItems({
    required ServiceRecordsCompanion record,
    required List<ServiceItemsCompanion> items,
    double? odometerKm,
    bool resolveComplaints = true,
  }) => transaction(() async {
    if (items.isEmpty) {
      throw ArgumentError('Minimal satu tindakan servis diperlukan.');
    }
    if (!record.motorcycleId.present ||
        await getMotorcycle(record.motorcycleId.value) == null) {
      throw ArgumentError('Motor servis tidak ditemukan.');
    }
    if (odometerKm != null && (!odometerKm.isFinite || odometerKm < 0)) {
      throw ArgumentError('Odometer tidak valid.');
    }
    final total = items.fold<int>(
      0,
      (sum, i) =>
          sum +
          (i.partsCost.present ? i.partsCost.value : 0) +
          (i.laborCost.present ? i.laborCost.value : 0),
    );
    // Keep service_records.odometer_km consistent with the history log.
    final recordId = await into(serviceRecords).insert(
      record.copyWith(
        totalCost: Value(total),
        odometerKm: odometerKm != null ? Value(odometerKm) : record.odometerKm,
      ),
    );
    for (final item in items) {
      if (!item.componentTypeId.present || item.componentTypeId.value == null) {
        throw ArgumentError('Komponen servis harus dipilih.');
      }
      if (!const [
        'inspect',
        'replace',
        'repair',
        'clean',
      ].contains(item.action.value)) {
        throw ArgumentError('Tindakan servis tidak valid.');
      }
      final parts = item.partsCost.present ? item.partsCost.value : 0;
      final labor = item.laborCost.present ? item.laborCost.value : 0;
      if (parts < 0 || labor < 0) {
        throw ArgumentError('Biaya tidak boleh negatif.');
      }
      await into(serviceItems).insert(
        item.copyWith(
          serviceRecordId: Value(recordId),
          totalCost: Value(parts + labor),
        ),
      );
    }
    if (odometerKm != null) {
      final previous = await getLatestOdometer(record.motorcycleId.value);
      if (previous == null || odometerKm > previous.odometerKm) {
        await into(odometerLogs).insert(
          OdometerLogsCompanion.insert(
            motorcycleId: record.motorcycleId.value,
            odometerKm: odometerKm,
            recordedAt: record.servicedAt.value,
            source: const Value('service_record'),
          ),
        );
      }
    }

    // Automatically resolve open complaints that match any serviced component
    if (resolveComplaints) {
      final allTypes = await getAllComponentTypes();
      final typeNameById = {for (final t in allTypes) t.id: t.name};
      var openComplaints = (await getComplaints(record.motorcycleId.value))
          .where(
            (c) =>
                c.closedAt == null &&
                c.status.trim() != 'selesai' &&
                c.status.trim() != 'ditangani',
          )
          .toList();

      for (final item in items) {
        final compId = item.componentTypeId.value;
        final compName = compId != null ? typeNameById[compId] : null;
        if (compName == null || openComplaints.isEmpty) continue;

        while (true) {
          final matched = HealthEngine.findMatchingActiveComplaint(
            compName,
            openComplaints,
          );
          if (matched == null) break;
          await updateComplaint(
            ComplaintsCompanion(
              status: const Value('selesai'),
              closedAt: Value(record.servicedAt.value),
              resolvedByServiceId: Value(recordId),
              updatedAt: Value(DateTime.now()),
            ),
            matched.id,
          );
          openComplaints.removeWhere((c) => c.id == matched.id);
        }
      }
    }

    await recalculateComponentStatuses(record.motorcycleId.value);
    return recordId;
  });

  Future<int> deleteServiceRecord(int id) => transaction(() async {
    final record = await getServiceRecord(id);
    if (record == null) return 0;
    // Avoid dangling complaint references to deleted service.
    await (update(complaints)..where((t) => t.resolvedByServiceId.equals(id)))
        .write(const ComplaintsCompanion(resolvedByServiceId: Value(null)));
    await (delete(
      serviceItems,
    )..where((t) => t.serviceRecordId.equals(id))).go();
    final deleted = await (delete(
      serviceRecords,
    )..where((t) => t.id.equals(id))).go();
    await recalculateComponentStatuses(record.motorcycleId);
    return deleted;
  });

  // ============================================================
  // SERVICE ITEMS
  // ============================================================

  Future<List<ServiceItem>> getServiceItems(int serviceRecordId) => (select(
    serviceItems,
  )..where((t) => t.serviceRecordId.equals(serviceRecordId))).get();

  Future<int> insertServiceItem(ServiceItemsCompanion i) =>
      into(serviceItems).insert(i);

  Future<int> deleteServiceItem(int id) =>
      (delete(serviceItems)..where((t) => t.id.equals(id))).go();

  /// Get all service items for a specific motorcycle (joined with service records).
  /// Returns items sorted by service date descending.
  Future<List<ServiceItemWithRecord>> getAllServiceItemsForMotorcycle(
    int motorcycleId,
  ) async {
    final records =
        await (select(serviceRecords)
              ..where((t) => t.motorcycleId.equals(motorcycleId))
              ..orderBy([(t) => OrderingTerm.desc(t.servicedAt)]))
            .get();

    if (records.isEmpty) return [];

    final recordIds = records.map((r) => r.id).toList();
    final items = await (select(
      serviceItems,
    )..where((t) => t.serviceRecordId.isIn(recordIds))).get();

    final itemsWithRecords = <ServiceItemWithRecord>[];
    for (final item in items) {
      final record = records.firstWhere((r) => r.id == item.serviceRecordId);
      itemsWithRecords.add(ServiceItemWithRecord(item: item, record: record));
    }
    itemsWithRecords.sort(
      (a, b) => b.record.servicedAt.compareTo(a.record.servicedAt),
    );
    return itemsWithRecords;
  }

  /// Get last service item for a specific motorcycle and component type.
  /// Returns the most recent service action for this component.
  Future<ServiceItemWithRecord?> getLastServiceForComponent(
    int motorcycleId,
    int componentTypeId,
  ) async {
    final itemsWithRecords = await getAllServiceItemsForMotorcycle(
      motorcycleId,
    );
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
    final last = await getLastServiceForComponent(
      motorcycleId,
      componentTypeId,
    );
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
      (update(
        selfInspections,
      )..where((t) => t.id.equals(id))).write(i).then((r) => r > 0);

  Future<SelfInspection?> getLatestSelfInspection(int motorcycleId) =>
      (select(selfInspections)
            ..where((t) => t.motorcycleId.equals(motorcycleId))
            ..orderBy([
              (t) => OrderingTerm.desc(t.inspectedAt),
              (t) => OrderingTerm.desc(t.id),
            ])
            ..limit(1))
          .getSingleOrNull();

  Future<int> saveCompleteSelfInspection({
    required int motorcycleId,
    required String riskLevel,
    required Map<String, String> answers,
    String? notes,
  }) => transaction(() async {
    final inspectionId = await into(selfInspections).insert(
      SelfInspectionsCompanion.insert(
        motorcycleId: motorcycleId,
        riskLevel: Value(riskLevel),
        status: const Value('completed'),
        notes: Value(notes),
      ),
    );
    for (final entry in answers.entries) {
      final q = SelfInspectionEngine.questions
          .where((item) => item.code == entry.key)
          .firstOrNull;
      final opt = q?.getSelectedOption(entry.value);
      await into(inspectionAnswers).insert(
        InspectionAnswersCompanion.insert(
          inspectionId: inspectionId,
          questionCode: entry.key,
          answer: entry.value,
          answerType: const Value('multiple_choice'),
          riskFlag: Value(opt?.isIssue ?? false),
        ),
      );
    }
    await recalculateComponentStatuses(motorcycleId);
    return inspectionId;
  });

  // ============================================================
  // INSPECTION ANSWERS
  // ============================================================

  Future<List<InspectionAnswer>> getInspectionAnswers(int inspectionId) =>
      (select(
        inspectionAnswers,
      )..where((t) => t.inspectionId.equals(inspectionId))).get();

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

  Future<bool> updateComplaint(ComplaintsCompanion c, int id) => (update(
    complaints,
  )..where((t) => t.id.equals(id))).write(c).then((r) => r > 0);

  /// Menghapus keluhan beserta seluruh pesan dan analisisnya.
  ///
  /// Ketiga operasi dibungkus satu transaksi agar kegagalan di tengah tidak
  /// meninggalkan pesan atau analisis yang menggantung pada keluhan yang sudah
  /// tidak ada.
  Future<int> deleteComplaint(int id) => transaction(() async {
    await (delete(
      complaintMessages,
    )..where((t) => t.complaintId.equals(id))).go();
    await (delete(
      complaintAnalyses,
    )..where((t) => t.complaintId.equals(id))).go();
    return (delete(complaints)..where((t) => t.id.equals(id))).go();
  });

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

  Future<List<MaintenanceRule>> getMaintenanceRules(
    int? modelId,
    int componentTypeId,
  ) {
    if (modelId != null) {
      return (select(maintenanceRules)..where(
            (t) =>
                t.componentTypeId.equals(componentTypeId) &
                (t.modelId.equals(modelId) | t.modelId.isNull()),
          ))
          .get();
    }
    return (select(maintenanceRules)..where(
          (t) => t.componentTypeId.equals(componentTypeId) & t.modelId.isNull(),
        ))
        .get();
  }

  Future<List<MaintenanceRule>> getAllMaintenanceRules() =>
      select(maintenanceRules).get();

  Future<int> insertMaintenanceRule(MaintenanceRulesCompanion r) =>
      into(maintenanceRules).insert(r);

  // ============================================================
  // BUDGET PLANS
  // ============================================================

  Future<BudgetPlan?> getActiveBudgetPlan(int motorcycleId) =>
      (select(budgetPlans)
            ..where((t) => t.motorcycleId.equals(motorcycleId))
            ..orderBy([
              (t) => OrderingTerm.desc(t.createdAt),
              (t) => OrderingTerm.desc(t.id),
            ])
            ..limit(1))
          .getSingleOrNull();

  Future<int> insertBudgetPlan(BudgetPlansCompanion b) =>
      into(budgetPlans).insert(b);

  Future<bool> updateBudgetPlan(BudgetPlansCompanion b, int id) => (update(
    budgetPlans,
  )..where((t) => t.id.equals(id))).write(b).then((r) => r > 0);

  Future<int> saveCompleteBudgetPlan({
    required int motorcycleId,
    required int budgetAmount,
    required String period,
    required List<BudgetRecommendation> recommendations,
    String? notes,
  }) => transaction(() async {
    final planId = await into(budgetPlans).insert(
      BudgetPlansCompanion.insert(
        motorcycleId: motorcycleId,
        budgetAmount: budgetAmount,
        period: Value(period),
        notes: Value(notes),
        createdAt: Value(DateTime.now()),
      ),
    );

    final totalEstimated = recommendations
        .where((r) => r.hasKnownCost)
        .fold<int>(0, (sum, r) => sum + r.estimatedCost);

    final recId = await into(serviceRecommendations).insert(
      ServiceRecommendationsCompanion.insert(
        budgetPlanId: planId,
        estimatedTotal: totalEstimated,
        ruleVersion: 'v1',
        generatedAt: Value(DateTime.now()),
        dataFreshness: const Value('fresh'),
        explanation: Value('Alokasi budget $period'),
      ),
    );

    for (final r in recommendations) {
      if (r.componentTypeId != null) {
        await into(recommendationItems).insert(
          RecommendationItemsCompanion.insert(
            recommendationId: recId,
            componentTypeId: r.componentTypeId!,
            sparepartId: Value(r.matchedSparepart?.id),
            priority: r.priority,
            decision: r.decision,
            estimatedCost: Value(r.hasKnownCost ? r.estimatedCost : null),
            estimatedLaborCost: Value(r.estimatedLaborCost),
            reason: r.reason,
            consequenceIfDelayed: Value(r.consequenceIfDelayed),
            requiresInspection: Value(r.requiresInspection),
          ),
        );
      }
    }
    return planId;
  });

  Future<List<BudgetPlan>> getBudgetPlanHistory(int motorcycleId) =>
      (select(budgetPlans)
            ..where((t) => t.motorcycleId.equals(motorcycleId))
            ..orderBy([
              (t) => OrderingTerm.desc(t.createdAt),
              (t) => OrderingTerm.desc(t.id),
            ]))
          .get();

  Future<int> deleteBudgetPlan(int id) => transaction(() async {
    final recs = await (select(
      serviceRecommendations,
    )..where((t) => t.budgetPlanId.equals(id))).get();
    for (final rec in recs) {
      await (delete(
        recommendationItems,
      )..where((t) => t.recommendationId.equals(rec.id))).go();
    }
    await (delete(
      serviceRecommendations,
    )..where((t) => t.budgetPlanId.equals(id))).go();
    return (delete(budgetPlans)..where((t) => t.id.equals(id))).go();
  });

  Future<List<RecommendationItemWithComponent>> getRecommendationWithItems(
    int recommendationId,
  ) async {
    final items = await getRecommendationItems(recommendationId);
    final types = await getAllComponentTypes();
    final typeMap = {for (var t in types) t.id: t.name};
    final parts = await getAllSpareparts();
    final partMap = {for (var p in parts) p.id: p};

    return items.map((item) {
      return RecommendationItemWithComponent(
        item: item,
        componentName: typeMap[item.componentTypeId] ?? 'Komponen',
        sparepart: item.sparepartId != null ? partMap[item.sparepartId] : null,
      );
    }).toList();
  }

  Future<List<Sparepart>> getAllSpareparts() => select(spareparts).get();
  Future<List<SparepartFitment>> getAllSparepartFitments() =>
      select(sparepartFitments).get();
  Future<List<CatalogSource>> getAllCatalogSources() =>
      select(catalogSources).get();

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

  Future<List<RecommendationItem>> getRecommendationItems(
    int recommendationId,
  ) => (select(
    recommendationItems,
  )..where((t) => t.recommendationId.equals(recommendationId))).get();

  Future<int> insertRecommendationItem(RecommendationItemsCompanion i) =>
      into(recommendationItems).insert(i);

  // ============================================================
  // LOCAL REMINDERS
  // ============================================================

  Future<List<LocalReminder>> getReminders(int motorcycleId) => (select(
    localReminders,
  )..where((t) => t.motorcycleId.equals(motorcycleId))).get();

  Future<int> insertReminder(LocalRemindersCompanion r) =>
      into(localReminders).insert(r);

  Future<bool> updateReminder(LocalRemindersCompanion r, int id) => (update(
    localReminders,
  )..where((t) => t.id.equals(id))).write(r).then((r) => r > 0);

  Future<int> deleteReminder(int id) =>
      (delete(localReminders)..where((t) => t.id.equals(id))).go();

  Future<List<LocalReminder>> getAllReminders() => select(localReminders).get();

  Future<LocalReminder?> getReminderById(int id) =>
      (select(localReminders)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<bool> setReminderEnabled(int id, bool enabled) =>
      (update(localReminders)..where((t) => t.id.equals(id)))
          .write(LocalRemindersCompanion(enabled: Value(enabled)))
          .then((r) => r > 0);

  /// Returns aggregated database statistics for settings and backup previews.
  Future<Map<String, int>> getDatabaseStats() async {
    final motors = await select(motorcycles).get();
    final odos = await select(odometerLogs).get();
    final services = await select(serviceRecords).get();
    final complaintsCount = await select(complaints).get();
    final inspectionsCount = await select(selfInspections).get();
    final budgetCount = await select(budgetPlans).get();
    final remindersCount = await select(localReminders).get();

    return {
      'motorcycles': motors.length,
      'odometer_logs': odos.length,
      'service_records': services.length,
      'complaints': complaintsCount.length,
      'self_inspections': inspectionsCount.length,
      'budget_plans': budgetCount.length,
      'local_reminders': remindersCount.length,
    };
  }

  /// Wipes all user-generated data safely while preserving master catalog reference tables.
  Future<void> clearAllUserData() async {
    await transaction(() async {
      await delete(recommendationItems).go();
      await delete(serviceRecommendations).go();
      await delete(budgetPlans).go();
      await delete(complaintAnalyses).go();
      await delete(complaintMessages).go();
      await delete(complaints).go();
      await delete(inspectionAnswers).go();
      await delete(selfInspections).go();
      await delete(serviceItems).go();
      await delete(serviceRecords).go();
      await delete(componentStatuses).go();
      await delete(odometerLogs).go();
      await delete(localReminders).go();
      await delete(motorcycles).go();
      await (delete(appSettings)..where(
            (t) => t.key.isIn(['active_motorcycle_id', 'backup_last_at']),
          ))
          .go();
    });
  }

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
      (update(
        aiModelInstalls,
      )..where((t) => t.id.equals(id))).write(m).then((r) => r > 0);

  Future<AiModelInstall?> getPendingModel() =>
      (select(aiModelInstalls)..where(
            (t) => t.downloadStatus.isIn(['pending', 'downloading', 'paused']),
          ))
          .getSingleOrNull();

  // ============================================================
  // APP SETTINGS
  // ============================================================

  Future<String?> getSetting(String key) async {
    final s = await (select(
      appSettings,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return s?.value;
  }

  Future<void> setSetting(String key, String value) =>
      into(appSettings).insertOnConflictUpdate(
        AppSettingsCompanion.insert(
          key: key,
          value: value,
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<Map<String, String>> getAllSettings() async {
    final rows = await select(appSettings).get();
    return {for (var r in rows) r.key: r.value};
  }

  // ============================================================
  // MOTORCYCLE MODELS (MASTER)
  // ============================================================

  Future<List<MotorcycleModel>> getAllMotorcycleModels() =>
      select(motorcycleModels).get();

  Future<int> insertMotorcycleModel(MotorcycleModelsCompanion m) =>
      into(motorcycleModels).insertOnConflictUpdate(m);

  Future<MotorcycleModel?> getMotorcycleModelById(int id) => (select(
    motorcycleModels,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Look up a motorcycle model ID by brand and model name.
  /// Never silently substitute another model from the same brand.
  Future<int?> getMotorcycleModelId(String brand, String model) async {
    final results = await (select(
      motorcycleModels,
    )..where((t) => t.brand.equals(brand) & t.model.equals(model))).get();
    if (results.isNotEmpty) return results.first.id;

    return null;
  }

  /// Get all models grouped by brand for dropdown selection.
  Future<Map<String, List<MotorcycleModel>>>
  getMotorcycleModelsGrouped() async {
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
    final fitments =
        await (select(sparepartFitments)..where(
              (t) => t.modelId.equals(modelId) & t.verifiedAt.isNotNull(),
            ))
            .get();
    // A record without a trustworthy source is not proof of fitment.
    final trusted = fitments.where((f) {
      final url = Uri.tryParse(f.sourceUrl ?? '');
      return url != null && url.scheme == 'https' && url.host.isNotEmpty;
    });
    final ids = trusted.map((f) => f.sparepartId).toSet().toList();
    if (ids.isEmpty) return [];
    return (select(
      spareparts,
    )..where((t) => t.id.isIn(ids) & t.isVerified.equals(true))).get();
  }

  Future<int> insertSparepart(SparepartsCompanion s) =>
      into(spareparts).insertOnConflictUpdate(s);

  Future<int> insertCatalogSource(CatalogSourcesCompanion s) =>
      into(catalogSources).insertOnConflictUpdate(s);

  // ============================================================
  // AGGREGATE / HELPER QUERIES
  // ============================================================

  /// Returns all applicable component statuses joined with component type names
  Future<List<ComponentStatusWithName>> getComponentStatusesWithNames(
    int motorcycleId,
  ) async {
    final motor = await getMotorcycle(motorcycleId);
    final applicable = await getApplicableComponentsForModel(motor?.modelId);
    final applicableIds = applicable.map((c) => c.id).toSet();
    var statuses = (await getComponentStatuses(motorcycleId))
        .where((s) => applicableIds.contains(s.componentTypeId))
        .toList();
    if (statuses.length != applicable.length) {
      await recalculateComponentStatuses(motorcycleId);
      statuses = (await getComponentStatuses(motorcycleId))
          .where((s) => applicableIds.contains(s.componentTypeId))
          .toList();
    }
    final typeMap = {for (var t in applicable) t.id: t.name};

    return statuses
        .map(
          (s) => ComponentStatusWithName(
            status: s,
            componentName: typeMap[s.componentTypeId] ?? 'Unknown',
          ),
        )
        .toList();
  }

  /// Ringkasan biaya perawatan dan pengeluaran untuk satu motor.
  Future<MotorcycleExpenseSummary> getMotorcycleExpenseSummary(
    int motorcycleId,
  ) async {
    final records = await getServiceRecords(motorcycleId);
    final itemsWithRecords = await getAllServiceItemsForMotorcycle(motorcycleId);
    final now = DateTime.now();

    int totalAll = 0;
    int totalThisMonth = 0;
    int totalParts = 0;
    int totalLabor = 0;

    for (final rec in records) {
      totalAll += rec.totalCost;
      if (rec.servicedAt.year == now.year &&
          rec.servicedAt.month == now.month) {
        totalThisMonth += rec.totalCost;
      }
    }

    for (final entry in itemsWithRecords) {
      totalParts += entry.item.partsCost;
      totalLabor += entry.item.laborCost;
    }

    return MotorcycleExpenseSummary(
      totalAllCost: totalAll,
      totalMonthCost: totalThisMonth,
      totalPartsCost: totalParts,
      totalLaborCost: totalLabor,
      recordCount: records.length,
    );
  }

  /// Returns upcoming (enabled + due in future) reminders
  Future<List<UpcomingReminder>> getUpcomingReminders(int motorcycleId) async {
    final reminders = await getReminders(motorcycleId);
    final types = await getAllComponentTypes();
    final typeMap = {for (var t in types) t.id: t.name};
    final now = DateTime.now();

    // Hanya pengingat aktif yang ditampilkan. Perhatikan tanda kurung: tanpa
    // kurung, operator `&&` mengikat lebih kuat daripada `||` sehingga pengingat
    // nonaktif yang punya dueOdometerKm tetap ikut terbawa.
    return reminders
        .where(
          (r) =>
              r.enabled &&
              ((r.dueDate != null && r.dueDate!.isAfter(now)) ||
                  r.dueOdometerKm != null),
        )
        .map(
          (r) => UpcomingReminder(
            reminder: r,
            componentName: r.componentTypeId != null
                ? typeMap[r.componentTypeId] ?? 'Unknown'
                : 'General',
          ),
        )
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
  Future<List<Sparepart>> searchSpareparts({
    String? category,
    String? query,
  }) async {
    var q = select(spareparts);
    if (category != null && category.isNotEmpty && category != 'Semua') {
      q = q..where((t) => t.category.equals(category));
    }
    final results = await q.get();
    if (query != null && query.isNotEmpty) {
      final qLower = query.toLowerCase();
      return results
          .where(
            (s) =>
                s.name.toLowerCase().contains(qLower) ||
                (s.brand?.toLowerCase().contains(qLower) ?? false) ||
                s.category.toLowerCase().contains(qLower),
          )
          .toList();
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
  /// This should be called after service records, odometer logs, inspections, or complaints are added/updated.
  ///
  /// Seluruh perhitungan disimpan dalam satu transaksi agar kegagalan di
  /// tengah loop tidak menyisakan status komponen yang hanya ter-update
  /// sebagian (misalnya 5 dari 14 komponen).
  Future<void> recalculateComponentStatuses(int motorcycleId) =>
      transaction(() => _recalculateComponentStatuses(motorcycleId));

  String _componentTechnicalContextNote({
    required Motorcycle motor,
    required MotorcycleModel? model,
    required ComponentType component,
    required double ageMultiplier,
  }) {
    final compLower = component.name.toLowerCase();
    final twoStroke = MotorcycleSpecs.is2Stroke(model);
    final carb = MotorcycleSpecs.isCarburetor(
      model,
      manufactureYear: motor.manufactureYear,
    );
    final isElectricalOrSeal =
        compLower.contains('aki') ||
        compLower.contains('suspensi') ||
        compLower.contains('minyak rem') ||
        compLower.contains('radiator');
    final isFuelOrIgnition =
        compLower.contains('busi') ||
        compLower.contains('filter udara') ||
        compLower.contains('knalpot') ||
        compLower.contains('oli mesin');

    final notes = <String>[];
    if (twoStroke && isFuelOrIgnition) {
      notes.add('mesin 2-tak');
    } else if (carb && isFuelOrIgnition) {
      notes.add('sistem karburator');
    }

    if (motor.manufactureYear <= 2015) {
      final ageCat = MotorcycleSpecs.ageCategoryLabel(motor.manufactureYear);
      if (isElectricalOrSeal) {
        notes.add(
          'motor ${motor.manufactureYear} ($ageCat, sensitivitas kelistrikan/seal)',
        );
      } else {
        notes.add('motor ${motor.manufactureYear} ($ageCat)');
      }
    }

    if (notes.isEmpty) return '';
    final pct = (ageMultiplier * 100).round();
    return ' Penyesuaian interval $pct% untuk ${notes.join(' & ')}.';
  }

  Future<void> _recalculateComponentStatuses(int motorcycleId) async {
    final motor = await getMotorcycle(motorcycleId);
    if (motor == null) return;
    final model = motor.modelId != null
        ? await getMotorcycleModelById(motor.modelId!)
        : null;
    final current = (await getLatestOdometer(motorcycleId))?.odometerKm;
    final history = await getAllServiceItemsForMotorcycle(motorcycleId);
    final components = await getApplicableComponentsForModel(motor.modelId);
    final applicableIds = components.map((c) => c.id).toList();
    if (applicableIds.isNotEmpty) {
      await (delete(componentStatuses)..where(
            (t) =>
                t.motorcycleId.equals(motorcycleId) &
                t.componentTypeId.isNotIn(applicableIds),
          ))
          .go();
    }
    final activeComplaints = await getComplaints(motorcycleId);
    final usageMultiplier = motor.usageProfile == 'jarak_jauh' ? 0.8 : 1.0;
    final now = DateTime.now();

    final latestInspection = await getLatestSelfInspection(motorcycleId);
    List<InspectionFinding> inspectionFindings = [];
    if (latestInspection != null) {
      final answers = await getInspectionAnswers(latestInspection.id);
      final answerMap = {for (var a in answers) a.questionCode: a.answer};
      final eval = SelfInspectionEngine.evaluate(answerMap);
      inspectionFindings = eval.allFindings;
    }

    for (final component in components) {
      final candidateRules = await getMaintenanceRules(
        motor.modelId,
        component.id,
      );
      final specific = candidateRules
          .where((r) => r.modelId == motor.modelId && r.modelId != null)
          .toList();
      final generic = candidateRules.where((r) => r.modelId == null).toList();
      final MaintenanceRule? rule = specific.isNotEmpty
          ? specific.first
          : (generic.isNotEmpty ? generic.first : null);
      final replacements = history
          .where(
            (entry) =>
                entry.item.componentTypeId == component.id &&
                entry.item.action == 'replace',
          )
          .toList();
      final replaced = replacements.isEmpty ? null : replacements.first.record;
      final ageMultiplier = MotorcycleSpecs.ageIntervalMultiplier(
        motor.manufactureYear,
        model: model,
        componentName: component.name,
      );
      final contextNote = _componentTechnicalContextNote(
        motor: motor,
        model: model,
        component: component,
        ageMultiplier: ageMultiplier,
      );
      final effectiveIntervalKm =
          (rule?.intervalKm != null && rule!.intervalKm! > 0)
          ? rule.intervalKm! * usageMultiplier * ageMultiplier
          : null;
      final effectiveIntervalDays =
          (rule?.intervalDays != null && rule!.intervalDays! > 0)
          ? (rule.intervalDays! * ageMultiplier).round().clamp(1, 3650)
          : null;

      String state = 'unknown';
      String explanation =
          'Belum ada data perawatan dan interval tervalidasi untuk ${component.name}.$contextNote';
      double? score;
      double? confidence;

      if (rule != null && replaced != null) {
        final km = (current != null && replaced.odometerKm != null)
            ? current - replaced.odometerKm!
            : null;
        final days = now.difference(replaced.servicedAt).inDays;
        final kmValid =
            km != null &&
            km >= 0 &&
            effectiveIntervalKm != null &&
            effectiveIntervalKm > 0;
        final daysValid =
            days >= 0 &&
            effectiveIntervalDays != null &&
            effectiveIntervalDays > 0;
        if (kmValid || daysValid) {
          final kmFraction =
              (km != null &&
                  effectiveIntervalKm != null &&
                  effectiveIntervalKm > 0)
              ? km / effectiveIntervalKm
              : 0.0;
          final dayFraction =
              daysValid ? days / effectiveIntervalDays : 0.0;
          final progress = kmFraction > dayFraction ? kmFraction : dayFraction;
          if (progress >= 0.7) {
            state = 'inspect';
            explanation = progress >= 1
                ? 'Jadwal perawatan ${component.name} telah tercapai; periksakan sesuai panduan pabrikan.$contextNote'
                : 'Jadwal perawatan ${component.name} mulai mendekat; rencanakan pemeriksaan.$contextNote';
          } else {
            state = 'good';
            explanation =
                'Belum mencapai jadwal perawatan estimasi ${component.name}; ini bukan pengukuran kondisi fisik.$contextNote';
          }
          score = (100 * (1 - progress.clamp(0.0, 1.0)))
              .clamp(0.0, 100.0)
              .toDouble();
          confidence = 0.6;
        }
      } else if (rule == null) {
        explanation =
            'Interval ${component.name} belum diverifikasi untuk model ini. Periksa buku manual atau bengkel.$contextNote';
      } else {
        final intervalHints = <String>[
          if (effectiveIntervalKm != null) '${effectiveIntervalKm.round()} km',
          if (effectiveIntervalDays != null) '$effectiveIntervalDays hari',
        ];
        final intervalText = intervalHints.isNotEmpty
            ? ' (estimasi interval ${intervalHints.join(' / ')})'
            : '';
        final fuelLabel = MotorcycleSpecs.fuelSystemLabel(
          model,
          manufactureYear: motor.manufactureYear,
        );
        final ageLabel = MotorcycleSpecs.ageCategoryLabel(
          motor.manufactureYear,
        );
        final baselineNote = contextNote.isNotEmpty
            ? contextNote
            : ' Baseline untuk motor ${motor.manufactureYear} ($ageLabel, $fuelLabel).';
        explanation =
            'Belum ada riwayat penggantian ${component.name}; pemeriksaan awal diperlukan$intervalText.$baselineNote';
      }

      // Integrate self-inspection findings
      final finding = inspectionFindings
          .where(
            (f) =>
                f.componentName.toLowerCase() == component.name.toLowerCase(),
          )
          .firstOrNull;
      if (finding != null) {
        if (finding.isSafetyCritical) {
          state = 'replace';
          score = (score ?? 50.0).clamp(0.0, 40.0);
          confidence ??= 0.7;
          explanation =
              '⚠️ KESELAMATAN: ${finding.advice} (${finding.answerLabel})';
        } else if (finding.riskLevel == 'high') {
          state = 'replace';
          score = (score ?? 50.0).clamp(0.0, 45.0);
          confidence ??= 0.7;
          explanation =
              '⚠️ Perhatian: Ditemukan indikasi masalah: ${finding.advice}';
        } else if (finding.riskLevel == 'medium' &&
            (state == 'good' || state == 'unknown')) {
          state = 'inspect';
          score = (score ?? 60.0).clamp(50.0, 65.0);
          confidence ??= 0.6;
          explanation = 'Pemeriksaan mandiri mencatat: ${finding.advice}';
        }
      }

      // Integrate active complaints from AI Chat / Complaint History
      final activeComplaint = HealthEngine.findMatchingActiveComplaint(
        component.name,
        activeComplaints,
      );
      if (activeComplaint != null) {
        // Apply complaint if there was no subsequent replacement after the complaint was opened
        final isNotResolvedByNewerReplace =
            replaced == null ||
            !replaced.servicedAt.isAfter(activeComplaint.openedAt);
        if (isNotResolvedByNewerReplace) {
          if (HealthEngine.isCriticalComplaint(activeComplaint)) {
            state = 'replace';
            score = (score ?? 40.0).clamp(0.0, 40.0);
            confidence ??= 0.7;
            explanation =
                '⚠️ KELUHAN KRITIS: "${activeComplaint.title}". Segera periksa komponen ini di bengkel.';
          } else if (state == 'good' || state == 'unknown') {
            state = 'inspect';
            score = (score ?? 60.0).clamp(50.0, 65.0);
            confidence ??= 0.6;
            explanation =
                'Keluhan aktif: "${activeComplaint.title}". Perlu pengecekan fisik.';
          } else if (state == 'inspect' &&
              !explanation.contains('Keluhan aktif')) {
            score = ((score ?? 60.0) - 5.0).clamp(45.0, 65.0);
            explanation =
                '$explanation (Keluhan aktif: "${activeComplaint.title}")';
          }
        }
      }

      // Safety critical component override
      if (component.safetyCritical && score != null && score < 50) {
        state = 'replace';
        if (!explanation.contains('KESELAMATAN')) {
          explanation = '⚠️ KESELAMATAN: Komponen perlu diganti. $explanation';
        }
      }

      await upsertComponentStatus(
        ComponentStatusesCompanion(
          motorcycleId: Value(motorcycleId),
          componentTypeId: Value(component.id),
          estimatedStatus: Value(state),
          score: Value(score),
          explanation: Value(explanation),
          confidence: Value(confidence),
          calculatedAt: Value(now),
          ruleVersion: Value(rule?.ruleVersion ?? 'unverified'),
        ),
      );
    }
  }
}

/// Ringkasan total biaya servis & pengeluaran motor.
class MotorcycleExpenseSummary {
  final int totalAllCost;
  final int totalMonthCost;
  final int totalPartsCost;
  final int totalLaborCost;
  final int recordCount;

  const MotorcycleExpenseSummary({
    required this.totalAllCost,
    required this.totalMonthCost,
    required this.totalPartsCost,
    required this.totalLaborCost,
    required this.recordCount,
  });
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
  ServiceAction({
    required this.action,
    required this.servicedAt,
    this.odometerKm,
  });

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

/// Helper class for recommendation items with joined component and sparepart
class RecommendationItemWithComponent {
  final RecommendationItem item;
  final String componentName;
  final Sparepart? sparepart;

  RecommendationItemWithComponent({
    required this.item,
    required this.componentName,
    this.sparepart,
  });
}
