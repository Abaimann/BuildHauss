import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buildhaus/core/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.ensureReferenceData();
  });

  tearDown(() async {
    await db.close();
  });

  group('Tahap 05 — Settings & Database Stats Tests', () {
    test('1. Sets and retrieves app settings in SQLite', () async {
      await db.setSetting('theme_mode', 'dark');
      await db.setSetting('notifications_enabled', 'false');
      await db.setSetting('odometer_reminder_days', '14');

      final theme = await db.getSetting('theme_mode');
      final notif = await db.getSetting('notifications_enabled');
      final odoDays = await db.getSetting('odometer_reminder_days');

      expect(theme, 'dark');
      expect(notif, 'false');
      expect(odoDays, '14');
    });

    test('2. getDatabaseStats accurately computes table row counts', () async {
      // Initially, reference tables have records, user tables are empty
      var stats = await db.getDatabaseStats();
      expect(stats['motorcycles'], 0);
      expect(stats['odometer_logs'], 0);
      expect(stats['service_records'], 0);

      // Add a motorcycle and logs
      final motorId = await db.insertMotorcycle(
        MotorcyclesCompanion.insert(
          nickname: 'Stats Motor',
          manufactureYear: 2022,
        ),
      );

      await db.insertOdometerLog(
        OdometerLogsCompanion.insert(
          motorcycleId: motorId,
          odometerKm: 5000,
          recordedAt: DateTime.now(),
        ),
      );

      await db.insertComplaint(
        ComplaintsCompanion.insert(
          motorcycleId: motorId,
          title: 'Bunyi aneh',
          description: 'Bunyi di area transmisi',
        ),
      );

      stats = await db.getDatabaseStats();
      expect(stats['motorcycles'], 1);
      expect(stats['odometer_logs'], 1);
      expect(stats['complaints'], 1);
    });

    test(
      '3. clearAllUserData wipes user tables but preserves master reference data',
      () async {
        // 1. Seed user data
        final motorId = await db.insertMotorcycle(
          MotorcyclesCompanion.insert(
            nickname: 'Wipe Target',
            manufactureYear: 2021,
          ),
        );

        await db.insertOdometerLog(
          OdometerLogsCompanion.insert(
            motorcycleId: motorId,
            odometerKm: 12000,
            recordedAt: DateTime.now(),
          ),
        );

        await db.insertReminder(
          LocalRemindersCompanion.insert(
            motorcycleId: motorId,
            reminderType: 'odometer',
          ),
        );

        // Verify user data exists
        expect((await db.getAllMotorcycles()).length, 1);
        expect((await db.getOdometerLogs(motorId)).length, 1);

        // 2. Clear all user data
        await db.clearAllUserData();

        // Verify user data is wiped
        expect(await db.getAllMotorcycles(), isEmpty);
        expect(await db.select(db.odometerLogs).get(), isEmpty);
        expect(await db.select(db.localReminders).get(), isEmpty);

        // 3. Verify master reference data remains 100% intact
        final compTypes = await db.getAllComponentTypes();
        expect(compTypes, isNotEmpty);

        final spareparts = await db.select(db.spareparts).get();
        expect(spareparts, isNotEmpty);

        final rules = await db.getAllMaintenanceRules();
        expect(rules, isNotEmpty);
      },
    );
  });
}
