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

// State Manajemen Autentikasi & Alur Onboarding Pengguna
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

// Provider preferensi tema tampilan (Gelap / Terang / Mengikuti Sistem)
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

// Provider motor aktif yang sedang dipilih pengguna
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
    // Jika belum ada motor yang tersimpan aktif, gunakan motor pertama sebagai default
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

// Provider daftar seluruh motor yang terdaftar di database
final motorcyclesProvider = StreamProvider<List<Motorcycle>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllMotorcycles();
});

// Provider riwayat dan pembacaan odometer
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

// Provider status kesehatan 14 komponen motor
final componentStatusesProvider =
    FutureProvider.family<List<ComponentStatus>, int>((ref, motorcycleId) {
      final db = ref.watch(databaseProvider);
      return db.getComponentStatuses(motorcycleId);
    });

// Provider riwayat servis berkala
final serviceRecordsProvider = FutureProvider.family<List<ServiceRecord>, int>((
  ref,
  motorcycleId,
) {
  final db = ref.watch(databaseProvider);
  return db.getServiceRecords(motorcycleId);
});

// Provider riwayat keluhan motor
final complaintsProvider = FutureProvider.family<List<Complaint>, int>((
  ref,
  motorcycleId,
) {
  final db = ref.watch(databaseProvider);
  return db.getComplaints(motorcycleId);
});

// Provider rencana anggaran servis (Budget Plan)
final activeBudgetPlanProvider = FutureProvider.family<BudgetPlan?, int>((
  ref,
  motorcycleId,
) {
  final db = ref.watch(databaseProvider);
  return db.getActiveBudgetPlan(motorcycleId);
});

// Provider mesin prediksi jarak tempuh harian (Mileage Predictor Engine)
final mileagePredictorProvider = FutureProvider.family<MileagePredictor, int>((
  ref,
  motorcycleId,
) async {
  final db = ref.watch(databaseProvider);
  final logs = await db.getOdometerLogs(motorcycleId);
  return MileagePredictor(logs);
});

// Provider inspeksi mandiri visual
final latestSelfInspectionProvider =
    FutureProvider.family<SelfInspection?, int>((ref, motorcycleId) {
      final db = ref.watch(databaseProvider);
      return db.getLatestSelfInspection(motorcycleId);
    });

// Provider status komponen lengkap dengan nama dan detail tipe
final componentStatusesWithNamesProvider =
    FutureProvider.family<List<ComponentStatusWithName>, int>((
      ref,
      motorcycleId,
    ) {
      final db = ref.watch(databaseProvider);
      return db.getComponentStatusesWithNames(motorcycleId);
    });

// Provider pengaturan aplikasi (Key-Value)
final settingsProvider = FutureProvider<Map<String, String>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.getAllSettings();
});

// Provider manifes metadata model AI
final modelManifestProvider = Provider<ModelManifest>((ref) {
  return ModelManifest.defaultManifest;
});

// Provider layanan pengunduhan model AI lokal
final modelDownloadServiceProvider = Provider<ModelDownloadService>((ref) {
  final db = ref.watch(databaseProvider);
  final manifest = ref.watch(modelManifestProvider);
  final service = ModelDownloadService(db: db, manifest: manifest);
  ref.onDispose(() => service.dispose());
  return service;
});

// Provider aliran status progres unduhan model AI
final modelDownloadStateProvider = StreamProvider<ModelDownloadState>((ref) {
  final service = ref.watch(modelDownloadServiceProvider);
  return service.stateStream;
});

// Provider runtime Gemini AI (Google Cloud Generative AI)
final geminiAiRuntimeProvider = Provider<GeminiAiRuntime>((ref) {
  final db = ref.watch(databaseProvider);
  final runtime = GeminiAiRuntime(db: db);
  ref.onDispose(() => runtime.dispose());
  return runtime;
});

// Provider API Key Google Gemini
final geminiApiKeyProvider = FutureProvider<String?>((ref) async {
  final runtime = ref.watch(geminiAiRuntimeProvider);
  return runtime.getApiKey();
});

// Provider runtime Offline AI
final offlineAiRuntimeProvider = Provider<OfflineAiRuntime>((ref) {
  return ref.watch(geminiAiRuntimeProvider);
});

// Provider pengambil konteks telemetri motor untuk AI (RAG / Context Retriever)
final aiContextRetrieverProvider = Provider<AiContextRetriever>((ref) {
  final db = ref.watch(databaseProvider);
  return AiContextRetriever(db: db);
});

// Provider layanan obrolan cerdas asisten AI (AiChatService)
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

// Provider status kesiapan runtime AI (ready / not_configured)
final aiModelStatusProvider = FutureProvider<String>((ref) async {
  final runtime = ref.watch(geminiAiRuntimeProvider);
  if (await runtime.hasApiKey()) return 'ready';
  final db = ref.watch(databaseProvider);
  final model = await db.getInstalledModel();
  if (model != null) return 'ready';
  return 'not_configured';
});

// Provider informasi instalasi model AI
final aiModelInfoProvider = FutureProvider<AiModelInstall?>((ref) {
  final db = ref.watch(databaseProvider);
  return db.getInstalledModel();
});

// Provider master data tipe komponen motor
final componentTypesProvider = FutureProvider<List<ComponentType>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.getAllComponentTypes();
});

// Provider master katalog model sepeda motor
final motorcycleModelsProvider = FutureProvider<List<MotorcycleModel>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.getAllMotorcycleModels();
});

// Provider katalog suku cadang berdasarkan kategori komponen
final sparepartsByCategoryProvider =
    FutureProvider.family<List<Sparepart>, String>((ref, category) {
      final db = ref.watch(databaseProvider);
      return db.getSparepartsByCategory(category);
    });

// Provider seluruh katalog suku cadang
final allSparepartsProvider = FutureProvider<List<Sparepart>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.getAllSpareparts();
});

// Provider kecocokan suku cadang dengan model motor (fitments)
final allSparepartFitmentsProvider =
    FutureProvider<List<SparepartFitment>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.getAllSparepartFitments();
});

// Provider ringkasan rencana anggaran servis pintar (Dynamic Smart Budget Plan)
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

// Provider riwayat rencana anggaran servis (Budget Plan History)
final budgetPlanHistoryProvider = FutureProvider.family<List<BudgetPlan>, int>((
  ref,
  motorcycleId,
) {
  final db = ref.watch(databaseProvider);
  return db.getBudgetPlanHistory(motorcycleId);
});

// Provider layanan notifikasi sistem lokal
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final service = NotificationService();
  service.initialize();
  return service;
});

// Provider mesin pengingat jadwal servis (Reminder Engine)
final reminderEngineProvider = Provider<ReminderEngine>((ref) {
  final db = ref.watch(databaseProvider);
  final notif = ref.watch(notificationServiceProvider);
  return ReminderEngine(db: db, notificationService: notif);
});

// Provider daftar pengingat jadwal untuk sepeda motor tertentu
final remindersProvider = FutureProvider.family<List<LocalReminder>, int>((
  ref,
  motorcycleId,
) {
  final db = ref.watch(databaseProvider);
  return db.getReminders(motorcycleId);
});

// Provider layanan backup dan restore database (JSON export/import)
final backupRestoreServiceProvider = Provider<BackupRestoreService>((ref) {
  final db = ref.watch(databaseProvider);
  return BackupRestoreService(db: db);
});

// Provider statistik jumlah data database lokal (hitung baris tabel)
final databaseStatsProvider = FutureProvider<Map<String, int>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.getDatabaseStats();
});
