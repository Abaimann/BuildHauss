import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/app_database.dart';
import '../../core/engines/mileage_predictor.dart';
import '../../core/engines/budget_engine.dart';
import '../../core/engines/self_inspection_engine.dart';
import '../ai/ai_chat_service.dart';
import '../ai/ai_context_retriever.dart';
import '../ai/model_download_service.dart';
import '../ai/model_manifest.dart';
import '../ai/offline_ai_runtime.dart';
import '../backup/backup_restore_service.dart';
import '../engines/reminder_engine.dart';
import '../notifications/notification_service.dart';
import 'database_provider.dart';

// Theme provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((
  ref,
) {
  return ThemeModeNotifier(ref);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final Ref ref;

  ThemeModeNotifier(this.ref) : super(ThemeMode.dark) {
    _load();
  }

  Future<void> _load() async {
    final db = ref.read(databaseProvider);
    final val = await db.getSetting('theme_mode');
    if (val == 'light') {
      state = ThemeMode.light;
    } else if (val == 'system') {
      state = ThemeMode.system;
    } else {
      state = ThemeMode.dark;
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    final db = ref.read(databaseProvider);
    String val = 'dark';
    if (mode == ThemeMode.light) val = 'light';
    if (mode == ThemeMode.system) val = 'system';
    await db.setSetting('theme_mode', val);
  }
}

// Active motorcycle provider
final activeMotorcycleProvider =
    StateNotifierProvider<ActiveMotorcycleNotifier, Motorcycle?>((ref) {
      return ActiveMotorcycleNotifier(ref);
    });

class ActiveMotorcycleNotifier extends StateNotifier<Motorcycle?> {
  final Ref ref;

  ActiveMotorcycleNotifier(this.ref) : super(null) {
    _load();
  }

  Future<void> _load() async {
    final db = ref.read(databaseProvider);
    final idStr = await db.getSetting('active_motorcycle_id');
    if (idStr != null && idStr.isNotEmpty) {
      final id = int.tryParse(idStr);
      if (id != null) {
        state = await db.getMotorcycle(id);
      }
    }
    // Fallback to primary motor
    if (state == null) {
      final motors = await db.getAllMotorcycles();
      if (motors.isNotEmpty) {
        state = motors.first;
        await db.setSetting('active_motorcycle_id', state!.id.toString());
      }
    }
  }

  Future<void> setActiveMotorcycle(Motorcycle m) async {
    state = m;
    final db = ref.read(databaseProvider);
    await db.setSetting('active_motorcycle_id', m.id.toString());
  }

  Future<void> refresh() async {
    final db = ref.read(databaseProvider);
    final previousId = state?.id;
    state = previousId == null ? null : await db.getMotorcycle(previousId);
    if (state == null) await _load();
  }
}

// Motorcycles list provider
final motorcyclesProvider = StreamProvider<List<Motorcycle>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllMotorcycles();
});

// Odometer provider
final odometerLogsProvider = FutureProvider.family<List<OdometerLog>, int>((
  ref,
  motorcycleId,
) {
  final db = ref.watch(databaseProvider);
  return db.getOdometerLogs(motorcycleId);
});

final latestOdometerProvider = FutureProvider.family<OdometerLog?, int>((
  ref,
  motorcycleId,
) {
  final db = ref.watch(databaseProvider);
  return db.getLatestOdometer(motorcycleId);
});

// Component statuses provider
final componentStatusesProvider =
    FutureProvider.family<List<ComponentStatus>, int>((ref, motorcycleId) {
      final db = ref.watch(databaseProvider);
      return db.getComponentStatuses(motorcycleId);
    });

// Service records provider
final serviceRecordsProvider = FutureProvider.family<List<ServiceRecord>, int>((
  ref,
  motorcycleId,
) {
  final db = ref.watch(databaseProvider);
  return db.getServiceRecords(motorcycleId);
});

// Complaints provider
final complaintsProvider = FutureProvider.family<List<Complaint>, int>((
  ref,
  motorcycleId,
) {
  final db = ref.watch(databaseProvider);
  return db.getComplaints(motorcycleId);
});

// Budget plan provider
final activeBudgetPlanProvider = FutureProvider.family<BudgetPlan?, int>((
  ref,
  motorcycleId,
) {
  final db = ref.watch(databaseProvider);
  return db.getActiveBudgetPlan(motorcycleId);
});

// Mileage predictor provider
final mileagePredictorProvider = FutureProvider.family<MileagePredictor, int>((
  ref,
  motorcycleId,
) async {
  final db = ref.watch(databaseProvider);
  final logs = await db.getOdometerLogs(motorcycleId);
  return MileagePredictor(logs);
});

// Self inspection provider
final latestSelfInspectionProvider =
    FutureProvider.family<SelfInspection?, int>((ref, motorcycleId) {
      final db = ref.watch(databaseProvider);
      return db.getLatestSelfInspection(motorcycleId);
    });

// Component statuses with names provider
final componentStatusesWithNamesProvider =
    FutureProvider.family<List<ComponentStatusWithName>, int>((
      ref,
      motorcycleId,
    ) {
      final db = ref.watch(databaseProvider);
      return db.getComponentStatusesWithNames(motorcycleId);
    });

// Settings provider
final settingsProvider = FutureProvider<Map<String, String>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.getAllSettings();
});

// AI model manifest provider
final modelManifestProvider = Provider<ModelManifest>((ref) {
  return ModelManifest.defaultManifest;
});

// AI model download service provider
final modelDownloadServiceProvider = Provider<ModelDownloadService>((ref) {
  final db = ref.watch(databaseProvider);
  final manifest = ref.watch(modelManifestProvider);
  final service = ModelDownloadService(db: db, manifest: manifest);
  ref.onDispose(() => service.dispose());
  return service;
});

// AI download state stream provider
final modelDownloadStateProvider = StreamProvider<ModelDownloadState>((ref) {
  final service = ref.watch(modelDownloadServiceProvider);
  return service.stateStream;
});

// Offline AI runtime provider
final offlineAiRuntimeProvider = Provider<OfflineAiRuntime>((ref) {
  final runtime = AndroidOfflineAiRuntime();
  ref.onDispose(() => runtime.dispose());
  return runtime;
});

// AI context retriever provider
final aiContextRetrieverProvider = Provider<AiContextRetriever>((ref) {
  final db = ref.watch(databaseProvider);
  return AiContextRetriever(db: db);
});

// AI chat service provider
final aiChatServiceProvider = Provider<AiChatService>((ref) {
  final db = ref.watch(databaseProvider);
  final runtime = ref.watch(offlineAiRuntimeProvider);
  final downloadService = ref.watch(modelDownloadServiceProvider);
  final contextRetriever = ref.watch(aiContextRetrieverProvider);
  return AiChatService(
    db: db,
    runtime: runtime,
    downloadService: downloadService,
    contextRetriever: contextRetriever,
  );
});

// AI model status
final aiModelStatusProvider = FutureProvider<String>((ref) async {
  final db = ref.watch(databaseProvider);
  final model = await db.getInstalledModel();
  if (model != null) return 'ready';
  final pending = await db.getPendingModel();
  if (pending != null) return pending.downloadStatus;
  return 'not_downloaded';
});

// AI model info
final aiModelInfoProvider = FutureProvider<AiModelInstall?>((ref) {
  final db = ref.watch(databaseProvider);
  return db.getInstalledModel();
});

// Component types provider
final componentTypesProvider = FutureProvider<List<ComponentType>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.getAllComponentTypes();
});

// Motorcycle models provider
final motorcycleModelsProvider = FutureProvider<List<MotorcycleModel>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.getAllMotorcycleModels();
});

// Spareparts by category
final sparepartsByCategoryProvider =
    FutureProvider.family<List<Sparepart>, String>((ref, category) {
      final db = ref.watch(databaseProvider);
      return db.getSparepartsByCategory(category);
    });

// All spareparts provider
final allSparepartsProvider = FutureProvider<List<Sparepart>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.getAllSpareparts();
});

// All sparepart fitments provider
final allSparepartFitmentsProvider =
    FutureProvider<List<SparepartFitment>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.getAllSparepartFitments();
});

// Dynamic Smart Budget Plan Summary provider
final budgetPlanSummaryProvider = FutureProvider.family<BudgetPlanSummary, int>(
  (ref, budgetAmount) async {
    final motor = ref.watch(activeMotorcycleProvider);
    if (motor == null) {
      return BudgetPlanSummary(
        budgetAmount: budgetAmount,
        totalEstimatedCost: 0,
        totalFundedCost: 0,
        remainingBudget: budgetAmount,
        shortfall: 0,
        totalItems: 0,
        fundedItemsCount: 0,
        deferredItemsCount: 0,
        safetyAlertCount: 0,
        recommendations: [],
      );
    }

    final db = ref.watch(databaseProvider);
    final statuses = await ref.watch(
      componentStatusesWithNamesProvider(motor.id).future,
    );
    final latestOdo = await ref.watch(latestOdometerProvider(motor.id).future);
    final latestInspection = await ref.watch(
      latestSelfInspectionProvider(motor.id).future,
    );
    final complaints = await ref.watch(complaintsProvider(motor.id).future);
    final serviceRecords = await ref.watch(
      serviceRecordsProvider(motor.id).future,
    );

    List<InspectionFinding> findings = [];
    if (latestInspection != null) {
      final answers = await db.getInspectionAnswers(latestInspection.id);
      final answerMap = {for (var a in answers) a.questionCode: a.answer};
      final eval = SelfInspectionEngine.evaluate(answerMap);
      findings = eval.allFindings;
    }

    final rules = await db.getAllMaintenanceRules();
    final spareparts = await db.getAllSpareparts();
    final fitments = await db.getAllSparepartFitments();

    final engine = BudgetEngine(
      componentHealths: [],
      budgetAmount: budgetAmount,
      activeMotorcycle: motor,
      componentStatusesWithNames: statuses,
      maintenanceRules: rules,
      currentOdometer: latestOdo?.odometerKm,
      serviceRecords: serviceRecords,
      inspectionFindings: findings,
      complaints: complaints,
      spareparts: spareparts,
      fitments: fitments,
    );

    return engine.calculateSummary();
  },
);

// Budget plan history provider
final budgetPlanHistoryProvider = FutureProvider.family<List<BudgetPlan>, int>((
  ref,
  motorcycleId,
) {
  final db = ref.watch(databaseProvider);
  return db.getBudgetPlanHistory(motorcycleId);
});

// Notification service provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final service = NotificationService();
  service.initialize();
  return service;
});

// Reminder engine provider
final reminderEngineProvider = Provider<ReminderEngine>((ref) {
  final db = ref.watch(databaseProvider);
  final notif = ref.watch(notificationServiceProvider);
  return ReminderEngine(db: db, notificationService: notif);
});

// Reminders for a motorcycle provider
final remindersProvider = FutureProvider.family<List<LocalReminder>, int>((
  ref,
  motorcycleId,
) {
  final db = ref.watch(databaseProvider);
  return db.getReminders(motorcycleId);
});

// Backup restore service provider
final backupRestoreServiceProvider = Provider<BackupRestoreService>((ref) {
  final db = ref.watch(databaseProvider);
  return BackupRestoreService(db: db);
});

// Database stats provider
final databaseStatsProvider = FutureProvider<Map<String, int>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.getDatabaseStats();
});
