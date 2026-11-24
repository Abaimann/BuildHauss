import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
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
  final String? avatarPath;

  const AuthState({
    this.isLoading = true,
    this.isLoggedIn = false,
    this.isOnboardingCompleted = false,
    this.userName = 'Rider BuildHaus',
    this.userEmail = '',
    this.userInitial = 'BH',
    this.avatarPath,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isLoggedIn,
    bool? isOnboardingCompleted,
    String? userName,
    String? userEmail,
    String? userInitial,
    String? avatarPath,
    bool clearAvatarPath = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isOnboardingCompleted:
          isOnboardingCompleted ?? this.isOnboardingCompleted,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userInitial: userInitial ?? this.userInitial,
      avatarPath: clearAvatarPath ? null : (avatarPath ?? this.avatarPath),
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;

  static final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  AuthNotifier(this.ref) : super(const AuthState()) {
    _load();
  }

  /// Memvalidasi format email wajib isi.
  static String? validateEmail(String? value) {
    final clean = (value ?? '').trim();
    if (clean.isEmpty) {
      return 'Email wajib diisi.';
    }
    if (!_emailRegex.hasMatch(clean)) {
      return 'Format email tidak valid. Contoh: rider@email.com';
    }
    return null;
  }

  /// Memvalidasi kekuatan kata sandi untuk pendaftaran akun baru.
  static String? validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) {
      return 'Kata sandi wajib diisi.';
    }
    if (password.contains(RegExp(r'\s'))) {
      return 'Kata sandi tidak boleh mengandung spasi.';
    }
    if (password.length < 8) {
      return 'Kata sandi minimal 8 karakter.';
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Kata sandi harus mengandung minimal 1 huruf kapital.';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Kata sandi harus mengandung minimal 1 angka.';
    }
    return null;
  }

  static String? _normalizeAvatarPath(String? path) {
    if (path == null || path.trim().isEmpty) return null;
    return path;
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
    final avatarPath = _normalizeAvatarPath(
      await db.getSetting('user_avatar_path'),
    );
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
        avatarPath: avatarPath,
      );
    } else {
      state = AuthState(
        isLoading: false,
        isLoggedIn: false,
        isOnboardingCompleted: false,
        userName: userName,
        userEmail: userEmail,
        userInitial: userInitial,
        avatarPath: avatarPath,
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

  static String _generateSalt() {
    final rng = Random.secure();
    final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
    return base64UrlEncode(bytes);
  }

  static String _hashPassword(String password, String salt) {
    final bytes = utf8.encode('$salt:$password');
    return sha256.convert(bytes).toString();
  }

  /// Memperbarui path foto profil pengguna aktif dan menyinkronkannya ke DB.
  Future<void> updateAvatarPath(String? path) async {
    final db = ref.read(databaseProvider);
    final cleanPath = _normalizeAvatarPath(path);
    await db.setSetting('user_avatar_path', cleanPath ?? '');

    final currentEmail = state.userEmail.trim().toLowerCase();
    if (currentEmail.isNotEmpty) {
      final users = await _getRegisteredUsers();
      final idx = users.indexWhere(
        (u) => (u['email']?.toString().toLowerCase() ?? '') == currentEmail,
      );
      if (idx >= 0) {
        if (cleanPath == null) {
          users[idx].remove('avatarPath');
        } else {
          users[idx]['avatarPath'] = cleanPath;
        }
        await db.setSetting('registered_users_json', jsonEncode(users));
      }
    }

    state = state.copyWith(
      avatarPath: cleanPath,
      clearAvatarPath: cleanPath == null,
    );
  }

  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final cleanName = name.trim();
    final cleanEmail = email.trim().toLowerCase();
    if (cleanName.isEmpty) return 'Nama lengkap wajib diisi.';
    final emailError = validateEmail(cleanEmail);
    if (emailError != null) return emailError;
    final passwordError = validatePassword(password);
    if (passwordError != null) return passwordError;

    final db = ref.read(databaseProvider);
    final users = await _getRegisteredUsers();
    final existingIdx = users.indexWhere(
      (u) => (u['email']?.toString().toLowerCase() ?? '') == cleanEmail,
    );
    if (existingIdx >= 0) {
      return 'Email ini sudah terdaftar. Silakan masuk melalui tab Masuk.';
    }

    final initial = _computeInitials(cleanName);
    final salt = _generateSalt();
    final passwordHash = _hashPassword(password, salt);
    users.add({
      'name': cleanName,
      'email': cleanEmail,
      'passwordSalt': salt,
      'passwordHash': passwordHash,
      'initial': initial,
      'createdAt': DateTime.now().toIso8601String(),
    });

    await db.setSetting('registered_users_json', jsonEncode(users));
    await db.setSetting('auth_logged_in', 'true');
    await db.setSetting('user_name', cleanName);
    await db.setSetting('user_email', cleanEmail);
    await db.setSetting('user_initial', initial);
    await db.setSetting('user_avatar_path', '');
    await db.setSetting('onboarding_completed', 'false');

    state = AuthState(
      isLoading: false,
      isLoggedIn: true,
      isOnboardingCompleted: false,
      userName: cleanName,
      userEmail: cleanEmail,
      userInitial: initial,
      avatarPath: null,
    );
    return null;
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final emailError = validateEmail(cleanEmail);
    if (emailError != null) return emailError;
    if (password.isEmpty) return 'Masukkan kata sandi Anda.';

    final db = ref.read(databaseProvider);
    final users = await _getRegisteredUsers();
    final matchedIdx = users.indexWhere(
      (u) => (u['email']?.toString().toLowerCase() ?? '') == cleanEmail,
    );

    if (matchedIdx < 0) {
      return 'Akun belum terdaftar. Silakan buat akun di tab Daftar Akun.';
    }

    final account = users[matchedIdx];
    final storedHash = account['passwordHash']?.toString();
    final storedSalt = account['passwordSalt']?.toString();
    final legacyPlain = account['password']?.toString();

    bool verified = false;
    if (storedHash != null && storedSalt != null) {
      verified = _hashPassword(password, storedSalt) == storedHash;
    } else if (legacyPlain != null) {
      verified = legacyPlain == password;
      // Upgrade akun lama yang masih plaintext ke hash SHA-256 + salt
      if (verified) {
        final salt = _generateSalt();
        account['passwordSalt'] = salt;
        account['passwordHash'] = _hashPassword(password, salt);
        account.remove('password');
        await db.setSetting('registered_users_json', jsonEncode(users));
      }
    }

    if (!verified) {
      return 'Kata sandi yang Anda masukkan salah.';
    }

    final name = account['name']?.toString() ?? 'Rider BuildHaus';
    final initial =
        account['initial']?.toString() ?? _computeInitials(name);
    final avatarPath = _normalizeAvatarPath(account['avatarPath']?.toString());
    final motors = await db.getAllMotorcycles();
    final hasMotors = motors.isNotEmpty;

    await db.setSetting('auth_logged_in', 'true');
    await db.setSetting('user_name', name);
    await db.setSetting('user_email', cleanEmail);
    await db.setSetting('user_initial', initial);
    await db.setSetting('user_avatar_path', avatarPath ?? '');
    await db.setSetting('onboarding_completed', hasMotors ? 'true' : 'false');

    state = AuthState(
      isLoading: false,
      isLoggedIn: true,
      isOnboardingCompleted: hasMotors,
      userName: name,
      userEmail: cleanEmail,
      userInitial: initial,
      avatarPath: avatarPath,
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

// Provider preferensi tema tampilan (Gelap / Terang)
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
    } else {
      state = ThemeMode.dark;
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    final effectiveMode = mode == ThemeMode.system ? ThemeMode.dark : mode;
    state = effectiveMode;
    final db = ref.read(databaseProvider);
    final val = effectiveMode == ThemeMode.light ? 'light' : 'dark';
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
    Motorcycle? resolved;
    if (idStr != null && idStr.isNotEmpty) {
      final id = int.tryParse(idStr);
      if (id != null) {
        resolved = await db.getMotorcycle(id);
      }
    }
    if (!mounted || state != null) return;
    if (resolved != null) {
      state = resolved;
      return;
    }
    // Jika belum ada motor yang tersimpan aktif, gunakan motor pertama sebagai default
    final motors = await db.getAllMotorcycles();
    if (!mounted || state != null) return;
    if (motors.isNotEmpty) {
      state = motors.first;
      await db.setSetting('active_motorcycle_id', state!.id.toString());
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

// Provider satu motor berdasarkan id. Mengembalikan null bila id tidak ada,
// sehingga pemanggil tidak pernah diam-diam memakai motor lain.
final motorcyclesByIdProvider = FutureProvider.family<Motorcycle?, int>((
  ref,
  motorcycleId,
) {
  final db = ref.watch(databaseProvider);
  return db.getMotorcycle(motorcycleId);
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

/// Kunci cache untuk [budgetPlanSummaryProvider].
///
/// Angka budget saja tidak cukup sebagai kunci: dua motor dengan budget yang
/// sama akan berbagi entri cache yang sama sehingga rekomendasi motor kedua
/// bisa menampilkan data motor pertama. Kunci ini menggabungkan id motor dan
/// jumlah budget sehingga setiap kombinasi motor+budget punya cache sendiri.
@immutable
class BudgetSummaryKey {
  final int? motorcycleId;
  final int budgetAmount;

  const BudgetSummaryKey({required this.motorcycleId, required this.budgetAmount});

  @override
  bool operator ==(Object other) =>
      other is BudgetSummaryKey &&
      other.motorcycleId == motorcycleId &&
      other.budgetAmount == budgetAmount;

  @override
  int get hashCode => Object.hash(motorcycleId, budgetAmount);
}

// Provider ringkasan rencana anggaran servis pintar (Dynamic Smart Budget Plan)
final budgetPlanSummaryProvider =
    FutureProvider.family<BudgetPlanSummary, BudgetSummaryKey>((
      ref,
      key,
    ) async {
      final budgetAmount = key.budgetAmount;

      // Motor yang diminta secara eksplisit menang; bila null, pakai motor aktif.
      final activeMotor = ref.watch(activeMotorcycleProvider);
      final motor = key.motorcycleId == null
          ? activeMotor
          : await ref.watch(
              motorcyclesByIdProvider(key.motorcycleId!).future,
            );

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
      final activeModel = motor.modelId != null
          ? await db.getMotorcycleModelById(motor.modelId!)
          : null;

      final engine = BudgetEngine(
        componentHealths: [],
        budgetAmount: budgetAmount,
        activeMotorcycle: motor,
        activeMotorcycleModel: activeModel,
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
    });

// Provider ringkasan biaya perawatan & pengeluaran motor
final motorcycleExpenseSummaryProvider =
    FutureProvider.family<MotorcycleExpenseSummary, int>((ref, motorcycleId) {
      final db = ref.watch(databaseProvider);
      return db.getMotorcycleExpenseSummary(motorcycleId);
    });

// Provider detail model motor berdasarkan modelId
final motorcycleModelByIdProvider =
    FutureProvider.family<MotorcycleModel?, int?>((ref, modelId) async {
      if (modelId == null) return null;
      final db = ref.watch(databaseProvider);
      return db.getMotorcycleModelById(modelId);
    });

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
