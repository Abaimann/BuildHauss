import 'dart:math';
import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../notifications/notification_id_generator.dart';
import '../notifications/notification_service.dart';
import 'health_engine.dart';
import 'mileage_predictor.dart';

/// Information regarding a generated or scheduled maintenance reminder.
class GeneratedReminder {
  final int motorcycleId;
  final int? componentTypeId;
  final String componentName;
  final String reminderType; // 'odometer', 'date', 'inspection', 'complaint'
  final String title;
  final String message;
  final double? dueOdometerKm;
  final DateTime? dueDate;
  final bool isUrgent;
  final String
  source; // 'health_engine', 'mileage_predictor', 'odometer_staleness', 'complaint'

  const GeneratedReminder({
    required this.motorcycleId,
    this.componentTypeId,
    required this.componentName,
    required this.reminderType,
    required this.title,
    required this.message,
    this.dueOdometerKm,
    this.dueDate,
    this.isUrgent = false,
    required this.source,
  });
}

/// Engine that analyzes motorcycle data, maintenance rules, mileage predictions,
/// and component health to deterministically produce and synchronize local reminders.
class ReminderEngine {
  final AppDatabase _db;
  final NotificationService _notificationService;

  ReminderEngine({
    required AppDatabase db,
    NotificationService? notificationService,
  }) : _db = db,
       _notificationService = notificationService ?? NotificationService();

  /// Analyzes a motorcycle and returns all pending reminders based on deterministic engine criteria.
  Future<List<GeneratedReminder>> evaluateReminders(int motorcycleId) async {
    final motorcycle = await _db.getMotorcycle(motorcycleId);
    if (motorcycle == null) return [];

    final generated = <GeneratedReminder>[];

    // 1. Odometer logs & Mileage Prediction
    final odoLogs = await _db.getOdometerLogs(motorcycleId);
    final predictor = MileagePredictor(odoLogs);
    final latestOdo = odoLogs.isNotEmpty ? odoLogs.first.odometerKm : 0.0;
    final lastOdoDate = odoLogs.isNotEmpty
        ? odoLogs.first.recordedAt
        : motorcycle.createdAt;
    final avgDailyKm = predictor.kmPerDay ?? 0.0;

    // Check Odometer update reminder (staleness check)
    final odoSetting = await _db.getSetting('odometer_reminder_days');
    final maxOdoDays = int.tryParse(odoSetting ?? '30') ?? 30;
    final daysSinceOdo = DateTime.now().difference(lastOdoDate).inDays;

    if (daysSinceOdo >= maxOdoDays) {
      generated.add(
        GeneratedReminder(
          motorcycleId: motorcycleId,
          componentTypeId: null,
          componentName: 'Odometer',
          reminderType: 'odometer',
          title: 'Perbarui Odometer Motor',
          message:
              'Sudah $daysSinceOdo hari Anda tidak memperbarui kilometer ${motorcycle.nickname}. '
              'Catat angka speedometer terbaru untuk akurasi estimasi perawatan.',
          dueOdometerKm: null,
          dueDate: DateTime.now(),
          isUrgent: daysSinceOdo > maxOdoDays * 2,
          source: 'odometer_staleness',
        ),
      );
    }

    // 2. Component Health Evaluation via HealthEngine
    final componentTypes = await _db.getAllComponentTypes();
    final services = await _db.getServiceRecords(motorcycleId);
    final rules = await _db.getAllMaintenanceRules();
    final history = await _db.getAllServiceItemsForMotorcycle(motorcycleId);

    final engine = HealthEngine(
      statuses: [],
      serviceRecords: services,
      odometerLogs: odoLogs,
      rules: rules,
      componentTypes: componentTypes,
      currentOdometer: latestOdo,
      motorcycleModelId: motorcycle.modelId,
      serviceItemsWithRecords: history,
    );

    for (final compType in componentTypes) {
      final result = engine.calculateHealth(compType.id);
      if (result.isUnknown) continue;

      // Condition A: Component needs immediate replacement (overdue)
      if (result.needsReplacement ||
          (result.score != null && result.score! <= 20)) {
        generated.add(
          GeneratedReminder(
            motorcycleId: motorcycleId,
            componentTypeId: compType.id,
            componentName: compType.name,
            reminderType: 'date',
            title: 'Jadwal Servis: ${compType.name}',
            message:
                'Komponen ${compType.name} pada ${motorcycle.nickname} telah mencapai batas interval servis. '
                'Segera lakukan penggantian di bengkel.',
            dueOdometerKm: latestOdo,
            dueDate: DateTime.now(),
            isUrgent: true,
            source: 'health_engine',
          ),
        );
      }
      // Condition B: Component is approaching interval (score between 21 and 40 or inspect status)
      else if (result.needsInspection ||
          (result.score != null && result.score! <= 40)) {
        DateTime? predictedDueDate;
        double? targetOdo;

        if (result.intervalKm != null && avgDailyKm > 0) {
          final remainingKm = max(
            0.0,
            (result.intervalKm! - (result.kmSinceService ?? 0.0)),
          );
          final daysToTarget = (remainingKm / avgDailyKm)
              .clamp(1.0, 90.0)
              .round();
          predictedDueDate = DateTime.now().add(Duration(days: daysToTarget));
          targetOdo = latestOdo + remainingKm;
        } else if (result.intervalDays != null) {
          final remainingDays = max(
            1,
            (result.intervalDays! - (result.daysSinceService ?? 0)),
          );
          predictedDueDate = DateTime.now().add(Duration(days: remainingDays));
        }

        generated.add(
          GeneratedReminder(
            motorcycleId: motorcycleId,
            componentTypeId: compType.id,
            componentName: compType.name,
            reminderType: 'date',
            title: 'Pengingat Perawatan: ${compType.name}',
            message:
                'Komponen ${compType.name} pada ${motorcycle.nickname} mulai mendekati jadwal servis'
                '${predictedDueDate != null ? " (estimasi ${predictedDueDate.day}/${predictedDueDate.month})" : ""}.',
            dueOdometerKm: targetOdo,
            dueDate:
                predictedDueDate ?? DateTime.now().add(const Duration(days: 7)),
            isUrgent: false,
            source: 'mileage_predictor',
          ),
        );
      }
    }

    // 3. Unresolved Complaints Follow-up
    final complaints = await _db.getComplaints(motorcycleId);
    final openComplaints = complaints
        .where((c) => c.status == 'baru' || c.status == 'dianalisis')
        .toList();

    for (final c in openComplaints) {
      final daysOpen = DateTime.now().difference(c.openedAt).inDays;
      if (daysOpen >= 3) {
        generated.add(
          GeneratedReminder(
            motorcycleId: motorcycleId,
            componentTypeId: null,
            componentName: 'Keluhan: ${c.title}',
            reminderType: 'complaint',
            title: 'Tindak Lanjut Keluhan',
            message:
                'Keluhan "${c.title}" pada ${motorcycle.nickname} belum selesai ditangani ($daysOpen hari). '
                'Periksa kondisi motor di bengkel jika gejala berlanjut.',
            dueOdometerKm: null,
            dueDate: DateTime.now(),
            isUrgent: daysOpen > 7,
            source: 'complaint',
          ),
        );
      }
    }

    return generated;
  }

  /// Synchronizes generated reminders into SQLite [LocalReminders] table and schedules notifications.
  Future<int> syncRemindersForMotorcycle(int motorcycleId) async {
    final masterEnabledSetting = await _db.getSetting('notifications_enabled');
    final isNotificationsGloballyEnabled =
        (masterEnabledSetting ?? 'true') != 'false';

    final generatedList = await evaluateReminders(motorcycleId);
    final existingReminders = await _db.getReminders(motorcycleId);

    int syncedCount = 0;

    for (final item in generatedList) {
      // Find existing reminder matching motorcycle, componentTypeId, and reminderType
      final match = existingReminders.cast<LocalReminder?>().firstWhere(
        (r) =>
            r?.motorcycleId == item.motorcycleId &&
            r?.componentTypeId == item.componentTypeId &&
            r?.reminderType == item.reminderType,
        orElse: () => null,
      );

      if (match == null) {
        // Generate a deterministic, stable, and collision-free notification ID
        final int notifId;
        if (item.reminderType == 'odometer') {
          notifId = NotificationIdGenerator.forOdometer(item.motorcycleId);
        } else if (item.componentTypeId != null) {
          notifId = NotificationIdGenerator.forComponent(
            item.motorcycleId,
            item.componentTypeId!,
          );
        } else if (item.reminderType == 'complaint') {
          notifId = NotificationIdGenerator.forComplaint(
            item.motorcycleId,
            item.componentName.hashCode.abs() % 9999,
          );
        } else {
          notifId = NotificationIdGenerator.forManual(
            item.motorcycleId,
            item.title.hashCode.abs() % 9999,
          );
        }

        await _db.insertReminder(
          LocalRemindersCompanion.insert(
            motorcycleId: item.motorcycleId,
            componentTypeId: Value(item.componentTypeId),
            reminderType: item.reminderType,
            dueOdometerKm: Value(item.dueOdometerKm),
            dueDate: Value(item.dueDate),
            enabled: const Value(true),
            lastScheduledAt: Value(DateTime.now()),
            notificationId: Value(notifId),
          ),
        );

        if (isNotificationsGloballyEnabled && item.dueDate != null) {
          if (item.dueDate!.isAfter(DateTime.now())) {
            await _notificationService.scheduleNotification(
              id: notifId,
              title: item.title,
              body: item.message,
              scheduledDate: item.dueDate!,
            );
          } else if (item.isUrgent) {
            await _notificationService.showNotification(
              id: notifId,
              title: item.title,
              body: item.message,
            );
          }
        }
        syncedCount++;
      } else {
        // If existing and enabled, update schedule if due date has changed
        if (match.enabled) {
          await _db.updateReminder(
            LocalRemindersCompanion(
              dueOdometerKm: Value(item.dueOdometerKm),
              dueDate: Value(item.dueDate),
              lastScheduledAt: Value(DateTime.now()),
            ),
            match.id,
          );

          if (isNotificationsGloballyEnabled &&
              match.notificationId != null &&
              item.dueDate != null &&
              item.dueDate!.isAfter(DateTime.now())) {
            await _notificationService.scheduleNotification(
              id: match.notificationId!,
              title: item.title,
              body: item.message,
              scheduledDate: item.dueDate!,
            );
          }
          syncedCount++;
        }
      }
    }

    return syncedCount;
  }
}
