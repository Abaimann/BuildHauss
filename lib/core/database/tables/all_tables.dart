import 'package:drift/drift.dart';

// ============================================================
// KELOMPOK 1: Data Motor, Kesehatan, Inspeksi, Keluhan, Servis
// ============================================================

// Tabel 1: motorcycle_models
class MotorcycleModels extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get brand => text().withLength(min: 1, max: 100)();
  TextColumn get model => text().withLength(min: 1, max: 100)();
  TextColumn get variant => text().nullable()();
  TextColumn get generation => text().nullable()();
  IntColumn get yearStart => integer()();
  IntColumn get yearEnd => integer().nullable()();
  TextColumn get sourceUrl => text().nullable()();
  DateTimeColumn get verifiedAt => dateTime().nullable()();
}

// Tabel 2: motorcycles
class Motorcycles extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get modelId => integer().nullable().references(MotorcycleModels, #id)();
  TextColumn get nickname => text().withLength(min: 1, max: 100)();
  IntColumn get manufactureYear => integer()();
  TextColumn get plateNumber => text().nullable()();
  TextColumn get emoji => text().withDefault(const Constant('🏍️'))();
  TextColumn get usageProfile => text().withDefault(const Constant('campuran'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isPrimary => boolean().withDefault(const Constant(false))();
}

// Tabel 3: odometer_logs
class OdometerLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get motorcycleId => integer().references(Motorcycles, #id)();
  RealColumn get odometerKm => real()();
  DateTimeColumn get recordedAt => dateTime()();
  TextColumn get source => text().withDefault(const Constant('manual'))();
  TextColumn get note => text().nullable()();

  // Multiple readings can be recorded in the same second. The primary key
  // distinguishes these events; a UNIQUE(motorcycle_id, recorded_at) constraint
  // would incorrectly reject valid service and manual entries.
}

// Tabel 4: component_types
class ComponentTypes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get category => text()();
  BoolColumn get safetyCritical => boolean().withDefault(const Constant(false))();
  TextColumn get appliesTo => text().nullable()(); // e.g. "cvt" for CVT-specific

  @override
  List<String> get customConstraints => [
    'UNIQUE(name)',
  ];
}

// Tabel 5: maintenance_rules
class MaintenanceRules extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get modelId => integer().nullable().references(MotorcycleModels, #id)();
  IntColumn get componentTypeId => integer().references(ComponentTypes, #id)();
  RealColumn get intervalKm => real().nullable()();
  IntColumn get intervalDays => integer().nullable()();
  TextColumn get severeUseRule => text().nullable()();
  TextColumn get sourceUrl => text().nullable()();
  TextColumn get ruleVersion => text().withDefault(const Constant('v1'))();
  DateTimeColumn get verifiedAt => dateTime().nullable()();
}

// Tabel 6: component_statuses
@DataClassName('ComponentStatus')
class ComponentStatuses extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get motorcycleId => integer().references(Motorcycles, #id)();
  IntColumn get componentTypeId => integer().references(ComponentTypes, #id)();
  TextColumn get estimatedStatus => text()();
  RealColumn get score => real().nullable()();
  TextColumn get explanation => text()();
  RealColumn get confidence => real().nullable()();
  DateTimeColumn get calculatedAt => dateTime()();
  TextColumn get ruleVersion => text()();

  @override
  List<String> get customConstraints => [
    'UNIQUE(motorcycle_id, component_type_id)',
  ];
}

// Tabel 7: service_records
class ServiceRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get motorcycleId => integer().references(Motorcycles, #id)();
  DateTimeColumn get servicedAt => dateTime()();
  RealColumn get odometerKm => real().nullable()();
  TextColumn get workshopName => text().nullable()();
  TextColumn get notes => text().nullable()();
  IntColumn get totalCost => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// Tabel 8: service_items
class ServiceItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get serviceRecordId => integer().references(ServiceRecords, #id)();
  IntColumn get componentTypeId => integer().nullable().references(ComponentTypes, #id)();
  IntColumn get sparepartId => integer().nullable()();
  TextColumn get action => text()(); // inspect, replace, repair, clean
  IntColumn get partsCost => integer().withDefault(const Constant(0))();
  IntColumn get laborCost => integer().withDefault(const Constant(0))();
  IntColumn get totalCost => integer().withDefault(const Constant(0))();
  TextColumn get notes => text().nullable()();
}

// Tabel 9: self_inspections
class SelfInspections extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get motorcycleId => integer().references(Motorcycles, #id)();
  DateTimeColumn get inspectedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get notes => text().nullable()();
  TextColumn get riskLevel => text().nullable()(); // low, medium, high
  TextColumn get status => text().withDefault(const Constant('draft'))();
}

// Tabel 10: inspection_answers
class InspectionAnswers extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get inspectionId => integer().references(SelfInspections, #id)();
  TextColumn get questionCode => text()();
  TextColumn get answer => text()();
  TextColumn get answerType => text().nullable()();
  BoolColumn get riskFlag => boolean().withDefault(const Constant(false))();
}

// Tabel 11: complaints
class Complaints extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get motorcycleId => integer().references(Motorcycles, #id)();
  IntColumn get inspectionId => integer().nullable().references(SelfInspections, #id)();
  IntColumn get resolvedByServiceId => integer().nullable().references(ServiceRecords, #id)();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get status => text().withDefault(const Constant(' baru'))(); // baru, dianalisis, perlu_pemeriksaan, ditangani, selesai, dibuka_kembali
  DateTimeColumn get openedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get closedAt => dateTime().nullable()();
  RealColumn get odometerKm => real().nullable()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// Tabel 12: complaint_messages
class ComplaintMessages extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get complaintId => integer().references(Complaints, #id)();
  TextColumn get role => text()(); // user, assistant, system
  TextColumn get content => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get analysisMode => text().nullable()(); // llm, rule_based
}

// Tabel 13: complaint_analyses
@DataClassName('ComplaintAnalysis')
class ComplaintAnalyses extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get complaintId => integer().references(Complaints, #id)();
  TextColumn get symptomsJson => text()();
  TextColumn get componentCandidatesJson => text().nullable()();
  TextColumn get followUpJson => text().nullable()();
  TextColumn get historicalMatchesJson => text().nullable()();
  TextColumn get riskLevel => text()();
  TextColumn get summary => text()();
  TextColumn get modelVersion => text().nullable()();
  TextColumn get analysisMode => text()(); // llm, rule_based
  DateTimeColumn get analyzedAt => dateTime().withDefault(currentDateAndTime)();
}

// ============================================================
// KELOMPOK 2: Katalog, Budget, Rekomendasi, Pengingat
// ============================================================

// Tabel 14: catalog_sources
class CatalogSources extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get providerName => text()();
  TextColumn get websiteUrl => text()();
  TextColumn get licenseOrPermission => text().nullable()();
  DateTimeColumn get verifiedAt => dateTime().nullable()();
  DateTimeColumn get lastCheckedAt => dateTime().nullable()();
}

// Tabel 15: spareparts
class Spareparts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sourceId => integer().nullable().references(CatalogSources, #id)();
  TextColumn get partNumber => text().nullable()();
  TextColumn get name => text()();
  TextColumn get brand => text().nullable()();
  TextColumn get category => text()();
  IntColumn get referencePrice => integer().nullable()();
  TextColumn get productUrl => text().nullable()();
  DateTimeColumn get priceUpdatedAt => dateTime().nullable()();
  TextColumn get catalogVersion => text().nullable()();
  BoolColumn get isVerified => boolean().withDefault(const Constant(false))();
}

// Tabel 16: sparepart_fitments
class SparepartFitments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sparepartId => integer().references(Spareparts, #id)();
  IntColumn get modelId => integer().nullable().references(MotorcycleModels, #id)();
  IntColumn get yearStart => integer()();
  IntColumn get yearEnd => integer().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get verifiedAt => dateTime().nullable()();
  TextColumn get sourceUrl => text().nullable()();
}

// Tabel 17: budget_plans
class BudgetPlans extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get motorcycleId => integer().references(Motorcycles, #id)();
  IntColumn get budgetAmount => integer()();
  TextColumn get period => text().nullable()(); // bulanan, 3bulanan, sekali
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get notes => text().nullable()();
}

// Tabel 18: service_recommendations
class ServiceRecommendations extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get budgetPlanId => integer().references(BudgetPlans, #id)();
  IntColumn get estimatedTotal => integer()();
  TextColumn get ruleVersion => text()();
  DateTimeColumn get generatedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get dataFreshness => text().nullable()();
  TextColumn get explanation => text().nullable()();
}

// Tabel 19: recommendation_items
class RecommendationItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get recommendationId => integer().references(ServiceRecommendations, #id)();
  IntColumn get componentTypeId => integer().references(ComponentTypes, #id)();
  IntColumn get sparepartId => integer().nullable()();
  TextColumn get priority => text()(); // safety, high, medium, low
  TextColumn get decision => text()(); // selected, deferred, safety_alert, inspect
  IntColumn get estimatedCost => integer().nullable()();
  IntColumn get estimatedLaborCost => integer().nullable()();
  TextColumn get reason => text()();
  TextColumn get consequenceIfDelayed => text().nullable()();
  BoolColumn get requiresInspection => boolean().withDefault(const Constant(false))();
}

// Tabel 20: local_reminders
class LocalReminders extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get motorcycleId => integer().references(Motorcycles, #id)();
  IntColumn get componentTypeId => integer().nullable().references(ComponentTypes, #id)();
  TextColumn get reminderType => text()(); // odometer, date, inspection, complaint
  RealColumn get dueOdometerKm => real().nullable()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  DateTimeColumn get lastScheduledAt => dateTime().nullable()();
  IntColumn get notificationId => integer().nullable()();
}

// ============================================================
// KELOMPOK 3: AI dan Pengaturan
// ============================================================

// Tabel 21: ai_model_installs
class AiModelInstalls extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get modelName => text()();
  TextColumn get version => text()();
  TextColumn get filePath => text()();
  TextColumn get sha256 => text()();
  IntColumn get fileSizeBytes => integer().nullable()();
  TextColumn get downloadStatus => text().withDefault(const Constant('pending'))(); // pending, downloading, paused, completed, failed
  DateTimeColumn get installedAt => dateTime().nullable()();
  TextColumn get sourceUrl => text().nullable()();
  TextColumn get lastError => text().nullable()();
}

// Tabel 22: app_settings
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {key};
}
