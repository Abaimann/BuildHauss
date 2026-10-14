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
    return driftDatabase(name: 'buildhaus_db');
  }

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _seedComponentTypes();
        await _seedDefaultSettings();
        await _seedSpareparts();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Seed spareparts on first upgrade to schema v2+
        if (from < 2) {
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

  Future<List<ServiceItem>> getLastServiceForComponent(int motorcycleId, int componentTypeId) =>
      (select(serviceItems)
        ..where((t) => t.componentTypeId.equals(componentTypeId))
        ..orderBy([(t) => OrderingTerm.desc(t.id)]))
      .get();

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
