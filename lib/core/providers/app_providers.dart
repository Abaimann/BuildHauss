import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/app_database.dart';
import '../../core/engines/mileage_predictor.dart';
import '../../core/engines/budget_engine.dart';
import '../../core/engines/self_inspection_engine.dart';
import '../ai/ai_chat_service.dart';
import '../ai/ai_context_retriever.dart';
import '../ai/gemini_ai_runtime.dart';
import '../ai/model_download_service.dart';
import '../ai/model_manifest.dart';
import '../ai/offline_ai_runtime.dart';
import '../backup/backup_restore_service.dart';
import '../engines/reminder_engine.dart';
import '../notifications/notification_service.dart';
import 'database_provider.dart';

// Auth & Onboarding state
class AuthState {
  final bool isLoading;
  final bool isLoggedIn;
  final bool isOnboardingCompleted;
  final String userName;
  final String userEmail;
  final String userInitial;

  const AuthState({
    this.isLoading = true,
    this.isLoggedIn = false,
    this.isOnboardingCompleted = false,
    this.userName = 'Rider BuildHaus',
    this.userEmail = '',
    this.userInitial = 'BH',
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isLoggedIn,
    bool? isOnboardingCompleted,
    String? userName,
    String? userEmail,
    String? userInitial,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isOnboardingCompleted:
          isOnboardingCompleted ?? this.isOnboardingCompleted,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userInitial: userInitial ?? this.userInitial,
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;

  AuthNotifier(this.ref) : super(const AuthState()) {
    _load();
  }

  static String _computeInitials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'BH';
    if (parts.length == 1) {
      return parts.first
          .substring(0, parts.first.length.clamp(1, 2))
          .toUpperCase();
    }
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

  Future<void> _load() async {
    final db = ref.read(databaseProvider);
    final loggedInVal = await db.getSetting('auth_logged_in');
    final onboardingVal = await db.getSetting('onboarding_completed');
    final userName = await db.getSetting('user_name') ?? 'Rider BuildHaus';
    final userEmail = await db.getSetting('user_email') ?? '';
    final userInitial =
        await db.getSetting('user_initial') ?? _computeInitials(userName);
    final motors = await db.getAllMotorcycles();

    if (loggedInVal == 'true') {
      state = AuthState(
        isLoading: false,
        isLoggedIn: true,
        isOnboardingCompleted:
            (onboardingVal == 'true') || motors.isNotEmpty,
        userName: userName,
        userEmail: userEmail,
        userInitial: userInitial,
      );
    } else if (loggedInVal == null && motors.isNotEmpty) {
      // Existing installation or pre-seeded data
      state = AuthState(
        isLoading: false,
        isLoggedIn: true,
        isOnboardingCompleted: true,
        userName: userName,
        userEmail: userEmail,
        userInitial: userInitial,
      );
    } else {
      state = AuthState(
        isLoading: false,
        isLoggedIn: false,
        isOnboardingCompleted: false,
        userName: userName,
        userEmail: userEmail,
        userInitial: userInitial,
      );
    }
  }

  Future<List<Map<String, dynamic>>> _getRegisteredUsers() async {
    final db = ref.read(databaseProvider);
    final raw = await db.getSetting('registered_users_json');
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map>()
          .map((m) => Map<String, dynamic>.from(m))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final cleanName = name.trim();
    final cleanEmail = email.trim().toLowerCase();
    if (cleanName.isEmpty) return 'Nama lengkap wajib diisi.';
    if (cleanEmail.isEmpty) return 'Email atau nomor HP wajib diisi.';
    if (password.length < 4) return 'Kata sandi minimal 4 karakter.';

    final db = ref.read(databaseProvider);
    final users = await _getRegisteredUsers();
    final existingIdx = users.indexWhere(
      (u) => (u['email']?.toString().toLowerCase() ?? '') == cleanEmail,
    );
    if (existingIdx >= 0) {
      return 'Email/akun ini sudah terdaftar. Silakan masuk melalui tab Masuk.';
    }

    final initial = _computeInitials(cleanName);
    users.add({
      'name': cleanName,
      'email': cleanEmail,
      'password': password,
      'initial': initial,
      'createdAt': DateTime.now().toIso8601String(),
    });

    await db.setSetting('registered_users_json', jsonEncode(users));
    await db.setSetting('auth_logged_in', 'true');
    await db.setSetting('user_name', cleanName);
    await db.setSetting('user_email', cleanEmail);
    await db.setSetting('user_initial', initial);
    await db.setSetting('onboarding_completed', 'false');

    state = AuthState(
      isLoading: false,
      isLoggedIn: true,
      isOnboardingCompleted: false,
      userName: cleanName,
      userEmail: cleanEmail,
      userInitial: initial,
    );
    return null;
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty) return 'Masukkan email atau nomor HP Anda.';
    if (password.isEmpty) return 'Masukkan kata sandi Anda.';

    final db = ref.read(databaseProvider);
    final users = await _getRegisteredUsers();
    final matched = users.where(
      (u) => (u['email']?.toString().toLowerCase() ?? '') == cleanEmail,
    );

    if (matched.isEmpty) {
      return 'Akun belum terdaftar. Silakan buat akun di tab Daftar Akun.';
    }

    final account = matched.first;
    if (account['password']?.toString() != password) {
      return 'Kata sandi yang Anda masukkan salah.';
    }

    final name = account['name']?.toString() ?? 'Rider BuildHaus';
    final initial =
        account['initial']?.toString() ?? _computeInitials(name);
    final motors = await db.getAllMotorcycles();
    final hasMotors = motors.isNotEmpty;

    await db.setSetting('auth_logged_in', 'true');
    await db.setSetting('user_name', name);
    await db.setSetting('user_email', cleanEmail);
    await db.setSetting('user_initial', initial);
    await db.setSetting('onboarding_completed', hasMotors ? 'true' : 'false');

    state = AuthState(
      isLoading: false,
      isLoggedIn: true,
      isOnboardingCompleted: hasMotors,
      userName: name,
      userEmail: cleanEmail,
      userInitial: initial,
    );
    return null;
  }

  Future<void> completeOnboarding() async {
    final db = ref.read(databaseProvider);
    await db.setSetting('onboarding_completed', 'true');
    state = state.copyWith(isOnboardingCompleted: true);
  }

  Future<void> logout() async {
    final db = ref.read(databaseProvider);
    await db.setSetting('auth_logged_in', 'false');
    state = state.copyWith(isLoggedIn: false);
  }

  Future<void> refresh() => _load();
}

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

// Gemini AI runtime provider
final geminiAiRuntimeProvider = Provider<GeminiAiRuntime>((ref) {
  final db = ref.watch(databaseProvider);
  final runtime = GeminiAiRuntime(db: db);
  ref.onDispose(() => runtime.dispose());
  return runtime;
});

// Gemini API key provider
final geminiApiKeyProvider = FutureProvider<String?>((ref) async {
  final runtime = ref.watch(geminiAiRuntimeProvider);
  return runtime.getApiKey();
});

// Offline AI runtime provider
final offlineAiRuntimeProvider = Provider<OfflineAiRuntime>((ref) {
  return ref.watch(geminiAiRuntimeProvider);
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
  final runtime = ref.watch(geminiAiRuntimeProvider);
  if (await runtime.hasApiKey()) return 'ready';
  final db = ref.watch(databaseProvider);
  final model = await db.getInstalledModel();
  if (model != null) return 'ready';
  return 'not_configured';
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
