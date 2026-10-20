import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/app_database.dart';
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

// Settings provider
final settingsProvider = FutureProvider<Map<String, String>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.getAllSettings();
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
