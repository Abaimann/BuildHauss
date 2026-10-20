import 'dart:io';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:buildhaus/core/database/app_database.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('buildhaus_migration_test_');
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('Database Migration v1 to v4 verification with real SQLite files', () {
    test('Migrate v1 to v4: backfills master data and relaxes odometer constraint', () async {
      final dbFile = File(p.join(tempDir.path, 'v1_test.db'));

      // 1. Setup a real SQLite file simulating v1 schema
      {
        final rawDb = NativeDatabase(dbFile);
        final setupDb = AppDatabase(rawDb);
        final m = Migrator(setupDb);
        await m.createAll();

        // Simulate v1 state: user_version = 1, seed only componentTypes & defaultSettings
        await setupDb.customStatement('PRAGMA user_version = 1;');
        // Recreate odometer_logs with the legacy UNIQUE(motorcycle_id, recorded_at) constraint
        await setupDb.customStatement('DROP TABLE odometer_logs;');
        await setupDb.customStatement('''
          CREATE TABLE odometer_logs (
            id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
            motorcycle_id INTEGER NOT NULL REFERENCES motorcycles (id),
            odometer_km REAL NOT NULL,
            recorded_at INTEGER NOT NULL,
            source TEXT NOT NULL DEFAULT 'manual',
            note TEXT,
            UNIQUE(motorcycle_id, recorded_at)
          );
        ''');

        // Insert legacy user motorcycle
        final now = DateTime(2026, 1, 15, 8, 30);
        await setupDb.customStatement(
          "INSERT INTO motorcycles (id, nickname, manufacture_year, is_primary) VALUES (1, 'Vespa Antik', 2021, 1);",
        );
        await setupDb.customStatement(
          "INSERT INTO odometer_logs (id, motorcycle_id, odometer_km, recorded_at, source) VALUES (1, 1, 5000, ${now.millisecondsSinceEpoch ~/ 1000}, 'manual');",
        );

        // Verify that under v1, inserting second log at exact same second violates UNIQUE constraint
        expect(
          () => setupDb.customStatement(
            "INSERT INTO odometer_logs (id, motorcycle_id, odometer_km, recorded_at, source) VALUES (2, 1, 5050, ${now.millisecondsSinceEpoch ~/ 1000}, 'service');",
          ),
          throwsA(isA<Exception>()),
        );

        await setupDb.close();
      }

      // 2. Open the existing database with v4 AppDatabase. Drift automatically triggers onUpgrade(from: 1, to: 4)
      {
        final upgradedDb = AppDatabase(NativeDatabase(dbFile));

        // Verify user data is preserved
        final motorcycles = await upgradedDb.getAllMotorcycles();
        expect(motorcycles.length, 1);
        expect(motorcycles.first.nickname, 'Vespa Antik');

        final initialLogs = await upgradedDb.getOdometerLogs(1);
        expect(initialLogs.length, 1);
        expect(initialLogs.first.odometerKm, 5000);

        // Verify master data backfilled (v3 requirement)
        final models = await upgradedDb.getAllMotorcycleModels();
        expect(models, isNotEmpty);
        final parts = await upgradedDb.select(upgradedDb.spareparts).get();
        expect(parts, isNotEmpty);
        final rules = await upgradedDb
            .select(upgradedDb.maintenanceRules)
            .get();
        expect(rules, isNotEmpty);

        // Verify v4 alteration: inserting second log at exact same timestamp now SUCCEEDS
        final sameTime = DateTime(2026, 1, 15, 8, 30);
        await upgradedDb
            .into(upgradedDb.odometerLogs)
            .insert(
              OdometerLogsCompanion.insert(
                motorcycleId: 1,
                odometerKm: 5050,
                recordedAt: sameTime,
                source: const Value('service'),
              ),
            );

        final updatedLogs = await upgradedDb.getOdometerLogs(1);
        expect(updatedLogs.length, 2);
        expect(
          updatedLogs.map((l) => l.odometerKm),
          containsAll([5000.0, 5050.0]),
        );

        await upgradedDb.close();
      }
    });

    test(
      'Migrate v2 to v4: preserves existing data and migrates odometer table',
      () async {
        final dbFile = File(p.join(tempDir.path, 'v2_test.db'));

        // 1. Setup a real SQLite file simulating v2
        {
          final rawDb = NativeDatabase(dbFile);
          final setupDb = AppDatabase(rawDb);
          final m = Migrator(setupDb);
          await m.createAll();
          await setupDb.ensureReferenceData();

          await setupDb.customStatement('PRAGMA user_version = 2;');
          await setupDb.customStatement('DROP TABLE odometer_logs;');
          await setupDb.customStatement('''
          CREATE TABLE odometer_logs (
            id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
            motorcycle_id INTEGER NOT NULL REFERENCES motorcycles (id),
            odometer_km REAL NOT NULL,
            recorded_at INTEGER NOT NULL,
            source TEXT NOT NULL DEFAULT 'manual',
            note TEXT,
            UNIQUE(motorcycle_id, recorded_at)
          );
        ''');

          // Add user motorcycle and odometer log
          final testTime = DateTime(2026, 2, 10, 14, 0);
          await setupDb.customStatement(
            "INSERT INTO motorcycles (id, nickname, manufacture_year, is_primary) VALUES (10, 'Beat Pop', 2020, 1);",
          );
          await setupDb.customStatement(
            "INSERT INTO odometer_logs (id, motorcycle_id, odometer_km, recorded_at, source) VALUES (1, 10, 15000, ${testTime.millisecondsSinceEpoch ~/ 1000}, 'manual');",
          );

          await setupDb.close();
        }

        // 2. Upgrade to v4
        {
          final upgradedDb = AppDatabase(NativeDatabase(dbFile));

          final motor = await upgradedDb.getMotorcycle(10);
          expect(motor, isNotNull);
          expect(motor!.nickname, 'Beat Pop');

          // Second log at identical timestamp succeeds
          final testTime = DateTime(2026, 2, 10, 14, 0);
          await upgradedDb
              .into(upgradedDb.odometerLogs)
              .insert(
                OdometerLogsCompanion.insert(
                  motorcycleId: 10,
                  odometerKm: 15100,
                  recordedAt: testTime,
                  source: const Value('service'),
                ),
              );

          final logs = await upgradedDb.getOdometerLogs(10);
          expect(logs.length, 2);

          await upgradedDb.close();
        }
      },
    );

    test(
      'Migrate v3 to v4: migrates odometerLogs table without duplicating reference data',
      () async {
        final dbFile = File(p.join(tempDir.path, 'v3_test.db'));

        int modelsCountBefore = 0;
        int partsCountBefore = 0;

        // 1. Setup a real SQLite file simulating v3
        {
          final rawDb = NativeDatabase(dbFile);
          final setupDb = AppDatabase(rawDb);
          final m = Migrator(setupDb);
          await m.createAll();
          await setupDb.ensureReferenceData();

          await setupDb.customStatement('PRAGMA user_version = 3;');
          await setupDb.customStatement('DROP TABLE odometer_logs;');
          await setupDb.customStatement('''
          CREATE TABLE odometer_logs (
            id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
            motorcycle_id INTEGER NOT NULL REFERENCES motorcycles (id),
            odometer_km REAL NOT NULL,
            recorded_at INTEGER NOT NULL,
            source TEXT NOT NULL DEFAULT 'manual',
            note TEXT,
            UNIQUE(motorcycle_id, recorded_at)
          );
        ''');

          modelsCountBefore = (await setupDb.getAllMotorcycleModels()).length;
          partsCountBefore =
              (await setupDb.select(setupDb.spareparts).get()).length;

          final models = await setupDb.getAllMotorcycleModels();
          final selectedModel = models.first;

          final motorId = await setupDb.createMotorcycle(
            motorcycle: MotorcyclesCompanion.insert(
              nickname: 'Vario 160 Hitam',
              modelId: Value(selectedModel.id),
              manufactureYear: selectedModel.yearStart,
            ),
            initialOdometerKm: 3200,
          );
          expect(motorId, isPositive);

          await setupDb.close();
        }

        // 2. Open with v4 AppDatabase
        {
          final v4Db = AppDatabase(NativeDatabase(dbFile));

          // Master records must not be duplicated
          final modelsCountAfter = (await v4Db.getAllMotorcycleModels()).length;
          final partsCountAfter =
              (await v4Db.select(v4Db.spareparts).get()).length;
          expect(modelsCountAfter, modelsCountBefore);
          expect(partsCountAfter, partsCountBefore);

          // User motorcycle and log must be intact
          final motors = await v4Db.getAllMotorcycles();
          expect(motors.length, 1);
          expect(motors.first.nickname, 'Vario 160 Hitam');

          final logs = await v4Db.getOdometerLogs(motors.first.id);
          expect(logs.length, 1);
          expect(logs.first.odometerKm, 3200);

          // Inserting second log at the exact same second now succeeds
          await v4Db
              .into(v4Db.odometerLogs)
              .insert(
                OdometerLogsCompanion.insert(
                  motorcycleId: motors.first.id,
                  odometerKm: 3250,
                  recordedAt: logs.first.recordedAt,
                  source: const Value('service'),
                ),
              );

          final updatedLogs = await v4Db.getOdometerLogs(motors.first.id);
          expect(updatedLogs.length, 2);

          await v4Db.close();
        }
      },
    );
  });
}
