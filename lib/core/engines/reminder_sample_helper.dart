import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../notifications/notification_id_generator.dart';
import '../notifications/notification_service.dart';

/// Hasil operasi pembuatan contoh pengingat beserta status pengiriman notifikasi OS.
class SampleReminderResult {
  final int insertedCount;
  final bool notificationShown;
  final bool permissionGranted;

  const SampleReminderResult({
    required this.insertedCount,
    required this.notificationShown,
    required this.permissionGranted,
  });
}

/// Helper terpusat untuk label tipe pengingat dan tombol "Contoh Pengingat"
/// yang menyiapkan pengingat sampel serta mengirim notifikasi pratinjau instan.
class ReminderSampleHelper {
  const ReminderSampleHelper._();

  static String formatReminderTypeTitle(String type) {
    switch (type) {
      case 'odometer':
        return 'Pembaruan Odometer';
      case 'complaint':
        return 'Tindak Lanjut Keluhan';
      case 'inspection':
        return 'Pemeriksaan Mandiri';
      case 'date':
      default:
        return 'Jadwal Servis Berkala';
    }
  }

  /// Menambahkan contoh pengingat perawatan untuk [motor] bila belum ada
  /// dan memicu satu notifikasi pratinjau agar pengguna dapat melihat bentuk pengingat.
  /// Mengembalikan jumlah pengingat yang ditambahkan (kompatibel dengan pemanggil lama).
  static Future<int> createSampleRemindersAndNotify({
    required AppDatabase db,
    required NotificationService notificationService,
    required Motorcycle motor,
  }) async {
    final result = await createSampleRemindersWithStatus(
      db: db,
      notificationService: notificationService,
      motor: motor,
    );
    return result.insertedCount;
  }

  /// Menambahkan contoh pengingat perawatan untuk [motor] bila belum ada,
  /// memeriksa izin notifikasi OS, mengirim pratinjau jika diizinkan,
  /// dan mengembalikan [SampleReminderResult] berisi jumlah dan status izin/kirim.
  static Future<SampleReminderResult> createSampleRemindersWithStatus({
    required AppDatabase db,
    required NotificationService notificationService,
    required Motorcycle motor,
  }) async {
    final now = DateTime.now();
    final existing = await db.getReminders(motor.id);
    final latestOdo = await db.getLatestOdometer(motor.id);
    final baseKm = latestOdo?.odometerKm ?? 5000.0;

    final components = await db.getAllComponentTypes();
    final oliId = components
        .where((c) => c.name.toLowerCase().contains('oli mesin'))
        .firstOrNull
        ?.id;

    final existingTypes = existing.map((r) => r.reminderType).toSet();
    final samples =
        <({String type, int? componentId, int days, double? dueKm, int slot})>[
          (
            type: 'date',
            componentId: oliId,
            days: 14,
            dueKm: baseKm + 1500,
            slot: 9001,
          ),
          (
            type: 'odometer',
            componentId: null,
            days: 7,
            dueKm: baseKm + 500,
            slot: 9002,
          ),
          (
            type: 'inspection',
            componentId: null,
            days: 3,
            dueKm: null,
            slot: 9003,
          ),
        ];

    int inserted = 0;
    for (final s in samples) {
      if (existingTypes.contains(s.type)) continue;
      final notifId = NotificationIdGenerator.forManual(motor.id, s.slot);
      await db.insertReminder(
        LocalRemindersCompanion.insert(
          motorcycleId: motor.id,
          componentTypeId: Value(s.componentId),
          reminderType: s.type,
          dueOdometerKm: Value(s.dueKm),
          dueDate: Value(now.add(Duration(days: s.days))),
          enabled: const Value(true),
          lastScheduledAt: Value(now),
          notificationId: Value(notifId),
        ),
      );
      inserted++;
    }

    final targetKmText = (baseKm + 1500).round();
    final notificationShown = await notificationService
        .showImmediateTestNotification(
          id: NotificationIdGenerator.forManual(motor.id, 9990),
          title: 'Contoh Pengingat • ${motor.nickname}',
          body:
              'Waktunya servis berkala & cek oli mesin ($targetKmText km). Ketuk untuk melihat daftar pengingat.',
          payload: 'motor:${motor.id}',
        );

    return SampleReminderResult(
      insertedCount: inserted,
      notificationShown: notificationShown,
      permissionGranted: notificationShown,
    );
  }
}
