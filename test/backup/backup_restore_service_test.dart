import 'dart:convert';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buildhaus/core/database/app_database.dart';
import 'package:buildhaus/core/backup/backup_restore_service.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;

void main() {
  late AppDatabase db;
  late Directory tempDir;
  late BackupRestoreService service;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.ensureReferenceData();
    tempDir = await Directory.systemTemp.createTemp('buildhaus_backup_test_');
    service = BackupRestoreService(db: db, customBackupDir: tempDir);
  });

  tearDown(() async {
    await db.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('Tahap 05 — BackupRestoreService Tests', () {
    test(
      '1. Creates valid unencrypted .bhb backup with SHA-256 checksum',
      () async {
        final motorId = await db.insertMotorcycle(
          MotorcyclesCompanion.insert(
            nickname: 'Vario Backup Test',
            manufactureYear: 2022,
            plateNumber: const Value('B 1234 ABC'),
            usageProfile: const Value('campuran'),
          ),
        );

        await db.insertOdometerLog(
          OdometerLogsCompanion.insert(
            motorcycleId: motorId,
            odometerKm: 14500,
            recordedAt: DateTime(2026, 3, 15),
            note: const Value('Catatan rutin'),
          ),
        );

        final file = await service.createBackup();
        expect(await file.exists(), isTrue);
        expect(file.path.endsWith('.bhb'), isTrue);

        final jsonStr = await file.readAsString();
        final envelope = jsonDecode(jsonStr) as Map<String, dynamic>;

        expect(envelope['app'], 'BuildHaus');
        expect(envelope['schema_version'], 4);
        expect(envelope['is_encrypted'], isFalse);
        expect(envelope['checksum_sha256'], isNotNull);

        final data = envelope['data'] as Map<String, dynamic>;
        final motors = data['motorcycles'] as List;
        expect(motors.length, 1);
        expect(motors.first['nickname'], 'Vario Backup Test');

        final odos = data['odometer_logs'] as List;
        expect(odos.length, 1);
        expect(odos.first['odometer_km'], 14500.0);
      },
    );

    test(
      '2. Creates encrypted .bhb backup with PBKDF2 HMAC-SHA256 and salt',
      () async {
        await db.insertMotorcycle(
          MotorcyclesCompanion.insert(
            nickname: 'Beat Encrypted',
            manufactureYear: 2023,
          ),
        );

        const passphrase = 'RahasiaSuperKuat2026!';
        final file = await service.createBackup(passphrase: passphrase);

        final jsonStr = await file.readAsString();
        final envelope = jsonDecode(jsonStr) as Map<String, dynamic>;

        expect(envelope['is_encrypted'], isTrue);
        expect(envelope['salt'], isNotNull);
        expect(envelope['auth_tag'], isNotNull);
        expect(envelope['payload'], isNotNull);
        expect(
          envelope.containsKey('data'),
          isFalse,
        ); // raw plaintext data must NOT be exposed
      },
    );

    test(
      '3. inspectBackupFile provides non-destructive preview metadata',
      () async {
        final motorId = await db.insertMotorcycle(
          MotorcyclesCompanion.insert(
            nickname: 'Preview Motor',
            manufactureYear: 2020,
          ),
        );

        await db.insertOdometerLog(
          OdometerLogsCompanion.insert(
            motorcycleId: motorId,
            odometerKm: 32000,
            recordedAt: DateTime.now(),
          ),
        );

        final file = await service.createBackup();
        final preview = await service.inspectBackupFile(file);

        expect(preview.appName, 'BuildHaus');
        expect(preview.schemaVersion, 4);
        expect(preview.motorcyclesCount, 1);
        expect(preview.odometerLogsCount, 1);
        expect(preview.isEncrypted, isFalse);
      },
    );

    test(
      '4. Atomic restore recovers all records preserving foreign keys',
      () async {
        // 1. Populate original database
        final motorId = await db.insertMotorcycle(
          MotorcyclesCompanion.insert(
            nickname: 'Original Aerox',
            manufactureYear: 2021,
            plateNumber: const Value('D 4567 XYZ'),
          ),
        );

        final odoDate = DateTime(2026, 2, 10);
        await db.insertOdometerLog(
          OdometerLogsCompanion.insert(
            motorcycleId: motorId,
            odometerKm: 8500,
            recordedAt: odoDate,
          ),
        );

        final serviceDate = DateTime(2026, 2, 12);
        final sRecordId = await db.insertServiceRecord(
          ServiceRecordsCompanion.insert(
            motorcycleId: motorId,
            servicedAt: serviceDate,
            odometerKm: const Value(8500),
            workshopName: const Value('Bengkel Resmi'),
            totalCost: const Value(120000),
          ),
        );

        await db.insertServiceItem(
          ServiceItemsCompanion.insert(
            serviceRecordId: sRecordId,
            action: 'replace',
            partsCost: const Value(75000),
            laborCost: const Value(45000),
            totalCost: const Value(120000),
          ),
        );

        // Create backup
        final file = await service.createBackup();

        // 2. Wipe or alter database state
        await db.delete(db.serviceItems).go();
        await db.delete(db.serviceRecords).go();
        await db.delete(db.odometerLogs).go();
        await db.delete(db.motorcycles).go();

        expect(await db.getAllMotorcycles(), isEmpty);

        // 3. Restore from backup
        await service.restoreBackup(file);

        // 4. Verify restored state
        final restoredMotors = await db.getAllMotorcycles();
        expect(restoredMotors.length, 1);
        expect(restoredMotors.first.id, motorId);
        expect(restoredMotors.first.nickname, 'Original Aerox');

        final restoredOdos = await db.getOdometerLogs(motorId);
        expect(restoredOdos.length, 1);
        expect(restoredOdos.first.odometerKm, 8500);

        final restoredServices = await db.getServiceRecords(motorId);
        expect(restoredServices.length, 1);
        expect(restoredServices.first.workshopName, 'Bengkel Resmi');
        expect(restoredServices.first.totalCost, 120000);
      },
    );

    test('5. Restores encrypted backup with correct passphrase', () async {
      final motorId = await db.insertMotorcycle(
        MotorcyclesCompanion.insert(
          nickname: 'Encrypted Scoopy',
          manufactureYear: 2024,
        ),
      );

      const passphrase = 'KunciKriptoAman123!';
      final file = await service.createBackup(passphrase: passphrase);

      // Clear database
      await db.delete(db.motorcycles).go();
      expect(await db.getAllMotorcycles(), isEmpty);

      // Restore with correct passphrase
      await service.restoreBackup(file, passphrase: passphrase);

      final restored = await db.getAllMotorcycles();
      expect(restored.length, 1);
      expect(restored.first.id, motorId);
      expect(restored.first.nickname, 'Encrypted Scoopy');
    });

    test('6. Rejects encrypted backup when passphrase is wrong', () async {
      await db.insertMotorcycle(
        MotorcyclesCompanion.insert(
          nickname: 'Secret PCX',
          manufactureYear: 2023,
        ),
      );

      final file = await service.createBackup(passphrase: 'KataSandiBenar');

      // Attempt restore with wrong passphrase
      expect(
        () async =>
            await service.restoreBackup(file, passphrase: 'KataSandiSalah'),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('Kata sandi salah atau data rusak'),
          ),
        ),
      );
    });

    test('7. Rejects corrupted or tampered backup file', () async {
      await db.insertMotorcycle(
        MotorcyclesCompanion.insert(
          nickname: 'Tamper Target',
          manufactureYear: 2022,
        ),
      );

      final file = await service.createBackup();

      // Tamper file content (modify raw JSON without updating checksum)
      final content = await file.readAsString();
      final envelope = jsonDecode(content) as Map<String, dynamic>;
      (envelope['data'] as Map<String, dynamic>)['motorcycles'] = [
        {'id': 999, 'nickname': 'Hacked Motor', 'manufacture_year': 2025},
      ];
      await file.writeAsString(jsonEncode(envelope));

      // Attempt restore
      expect(
        () async => await service.restoreBackup(file),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('Checksum integritas data tidak cocok'),
          ),
        ),
      );
    });
  });
}
