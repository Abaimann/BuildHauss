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
  int get schemaVersion => 1;

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
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Future migrations here
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
