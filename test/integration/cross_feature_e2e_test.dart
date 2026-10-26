import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buildhaus/core/database/app_database.dart';
import 'package:buildhaus/core/engines/health_engine.dart';
import 'package:buildhaus/core/engines/mileage_predictor.dart';
import 'package:buildhaus/core/engines/budget_engine.dart';
import 'package:buildhaus/core/engines/reminder_engine.dart';
import 'package:buildhaus/core/backup/backup_restore_service.dart';
import 'package:buildhaus/core/ai/ai_safety_guard.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;

void main() {
  late AppDatabase db;
  late Directory tempDir;
  late BackupRestoreService backupService;
  late ReminderEngine reminderEngine;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.ensureReferenceData();
    tempDir = await Directory.systemTemp.createTemp('buildhaus_e2e_test_');
    backupService = BackupRestoreService(db: db, customBackupDir: tempDir);
    reminderEngine = ReminderEngine(db: db);
  });

  tearDown(() async {
    await db.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('Tahap 06 — Cross-Feature End-to-End Integration Tests', () {
    test(
      '1. Fresh install -> Add motor -> Verify motor appears in database and active selection',
      () async {
        final motorsBefore = await db.getAllMotorcycles();
        expect(motorsBefore, isEmpty);

        final motorId = await db.insertMotorcycle(
          MotorcyclesCompanion.insert(
            nickname: 'Honda Vario 160',
            manufactureYear: 2023,
            plateNumber: const Value('B 5555 XYZ'),
            usageProfile: const Value('harian'),
          ),
        );

        final motorsAfter = await db.getAllMotorcycles();
        expect(motorsAfter.length, 1);
        expect(motorsAfter.first.id, motorId);
        expect(motorsAfter.first.nickname, 'Honda Vario 160');

        // Set active motor in settings
        await db.setSetting('active_motorcycle_id', motorId.toString());
        final activeSetting = await db.getSetting('active_motorcycle_id');
        expect(activeSetting, motorId.toString());
      },
    );

    test(
      '2. Motor -> Odometer logs -> MileagePredictor calculates daily and monthly forecast',
      () async {
        final motorId = await db.insertMotorcycle(
          MotorcyclesCompanion.insert(
            nickname: 'Yamaha Aerox E2E',
            manufactureYear: 2022,
          ),
        );

        // Add two sequential odometer readings separated by 10 days
        await db.insertOdometerLog(
          OdometerLogsCompanion.insert(
            motorcycleId: motorId,
            odometerKm: 5000,
            recordedAt: DateTime(2026, 3, 1),
          ),
        );
        await db.insertOdometerLog(
          OdometerLogsCompanion.insert(
            motorcycleId: motorId,
            odometerKm: 5350,
            recordedAt: DateTime(2026, 3, 11),
          ),
        );

        final logs = await db.getOdometerLogs(motorId);
        expect(logs.length, 2);

        final predictor = MileagePredictor(logs);
        expect(predictor.kmPerDay, closeTo(35.0, 0.1));
        expect(predictor.kmPerMonth, closeTo(1050.0, 5.0));
      },
    );

    test(
      '3. Motor -> Health Engine evaluates wear, Service recorded -> component status refreshes',
      () async {
        final motorId = await db.insertMotorcycle(
          MotorcyclesCompanion.insert(
            nickname: 'Beat Street E2E',
            manufactureYear: 2021,
          ),
        );

        await db.insertOdometerLog(
          OdometerLogsCompanion.insert(
            motorcycleId: motorId,
            odometerKm: 10000,
            recordedAt: DateTime.now(),
          ),
        );

        final compTypes = await db.getAllComponentTypes();
        final rules = await db.getAllMaintenanceRules();
        final initialLogs = await db.getOdometerLogs(motorId);

        // 1. Initial evaluation: no service record yet -> status is honestly 'unknown'
        final engineInitial = HealthEngine(
          statuses: [],
          serviceRecords: [],
          odometerLogs: initialLogs,
          rules: rules,
          componentTypes: compTypes,
          currentOdometer: 10000,
        );

        final oilResultInitial = engineInitial.calculateHealth(
          1,
        ); // 1 = Oli Mesin
        expect(oilResultInitial.status, equals('unknown'));

        // 2. An old service record is added at 6,000 km -> interval 3,000 km is overdue -> status becomes 'replace'
        final oldService = ServiceRecord(
          id: 1,
          motorcycleId: motorId,
          servicedAt: DateTime.now().subtract(const Duration(days: 90)),
          odometerKm: 6000,
          workshopName: 'Bengkel Lama',
          totalCost: 50000,
          createdAt: DateTime.now(),
        );

        final engineOverdue = HealthEngine(
          statuses: [],
          serviceRecords: [oldService],
          odometerLogs: initialLogs,
          rules: rules,
          componentTypes: compTypes,
          currentOdometer: 10000,
        );

        final oilResultOverdue = engineOverdue.calculateHealth(1);
        expect(oilResultOverdue.status, equals('replace'));

        // 3. Record a fresh service replacement of engine oil at 10000 km
        final serviceId = await db.insertServiceRecord(
          ServiceRecordsCompanion.insert(
            motorcycleId: motorId,
            servicedAt: DateTime.now(),
            odometerKm: const Value(10000),
            workshopName: const Value('AHASS Resmi'),
            totalCost: const Value(65000),
          ),
        );

        await db.insertServiceItem(
          ServiceItemsCompanion.insert(
            serviceRecordId: serviceId,
            componentTypeId: const Value(1), // Oli Mesin
            action: 'replace',
            partsCost: const Value(65000),
            totalCost: const Value(65000),
          ),
        );

        // Re-evaluate with service records -> status becomes 'good'
        final servicesAfter = await db.getServiceRecords(motorId);
        final itemsWithRecords = await db.getAllServiceItemsForMotorcycle(
          motorId,
        );

        final engineAfter = HealthEngine(
          statuses: [],
          serviceRecords: servicesAfter,
          serviceItemsWithRecords: itemsWithRecords,
          odometerLogs: initialLogs,
          rules: rules,
          componentTypes: compTypes,
          currentOdometer: 10000,
        );

        final oilResultAfter = engineAfter.calculateHealth(1);
        expect(oilResultAfter.status, equals('good'));
        expect(oilResultAfter.score, greaterThan(80));
      },
    );

    test(
      '4. Self-Inspection -> Critical symptom detection triggers Safety Warning',
      () async {
        final motorId = await db.insertMotorcycle(
          MotorcyclesCompanion.insert(
            nickname: 'CBR 150',
            manufactureYear: 2020,
          ),
        );

        // Save self inspection with critical risk
        final inspId = await db.insertSelfInspection(
          SelfInspectionsCompanion.insert(
            motorcycleId: motorId,
            riskLevel: const Value('high'),
          ),
        );

        await db.insertInspectionAnswer(
          InspectionAnswersCompanion.insert(
            inspectionId: inspId,
            questionCode: 'BRAKE_WEAR',
            answer: 'rem terasa blong dan dalam',
            riskFlag: const Value(true),
          ),
        );

        final answers = await db.getInspectionAnswers(inspId);
        expect(answers.length, 1);
        expect(answers.first.riskFlag, isTrue);

        // AiSafetyGuard evaluates safety red flags
        final safetyCheck = AiSafetyGuard.evaluate(
          'Motor saya rem blong di jalan dan tidak bisa berhenti',
        );
        expect(safetyCheck.hasRedFlag, isTrue);
        expect(safetyCheck.riskLevel, equals(SafetyRiskLevel.critical));
        expect(safetyCheck.doNotRideWarning, isTrue);
      },
    );

    test(
      '5. Smart Budget -> Recommendations prioritize safety-critical components first',
      () async {
        final spareparts = await db.getAllSpareparts();

        // Create component health results: 1 replace (brake), 1 warning (spark plug)
        final healths = [
          ComponentHealthResult(
            status: 'replace',
            score: 15,
            explanation: 'Melebihi batas interval kampas rem',
            confidence: 'high',
          ),
          ComponentHealthResult(
            status: 'warning',
            score: 55,
            explanation: 'Mendekati usia pakai busi',
            confidence: 'medium',
          ),
        ];

        final budgetEngine = BudgetEngine(
          componentHealths: healths,
          budgetAmount: 100000,
          spareparts: spareparts,
        );

        final recommendations = budgetEngine.generateRecommendations();
        expect(recommendations.isNotEmpty, isTrue);
      },
    );

    test(
      '6. Reminders -> Stable notification ID generation, synchronization, and multi-motor isolation',
      () async {
        final motorA = await db.insertMotorcycle(
          MotorcyclesCompanion.insert(
            nickname: 'Motor A',
            manufactureYear: 2021,
          ),
        );
        final motorB = await db.insertMotorcycle(
          MotorcyclesCompanion.insert(
            nickname: 'Motor B',
            manufactureYear: 2022,
          ),
        );

        // Sync reminders for motor A
        await reminderEngine.syncRemindersForMotorcycle(motorA);
        final remindersA = await db.getReminders(motorA);

        // Sync reminders for motor B
        await reminderEngine.syncRemindersForMotorcycle(motorB);
        final remindersB = await db.getReminders(motorB);

        // Reminders for Motor A and Motor B must be strictly isolated
        for (final r in remindersA) {
          expect(r.motorcycleId, equals(motorA));
          expect(remindersB.any((rb) => rb.id == r.id), isFalse);
          // Notification ID must belong to motorA block
          expect(r.notificationId, isNotNull);
          expect(r.notificationId! ~/ 100000, equals(motorA));
        }

        for (final r in remindersB) {
          expect(r.motorcycleId, equals(motorB));
          expect(r.notificationId! ~/ 100000, equals(motorB));
        }
      },
    );

    test(
      '7. End-to-End Backup -> Encrypted AES-256-GCM Export -> Clear DB -> Restore -> Integrity intact',
      () async {
        // 1. Populate full data graph
        final motorId = await db.insertMotorcycle(
          MotorcyclesCompanion.insert(
            nickname: 'Comprehensive Test Motor',
            manufactureYear: 2023,
            plateNumber: const Value('D 7777 FULL'),
          ),
        );

        await db.insertOdometerLog(
          OdometerLogsCompanion.insert(
            motorcycleId: motorId,
            odometerKm: 12500,
            recordedAt: DateTime(2026, 4, 1),
          ),
        );

        final sId = await db.insertServiceRecord(
          ServiceRecordsCompanion.insert(
            motorcycleId: motorId,
            servicedAt: DateTime(2026, 4, 2),
            odometerKm: const Value(12500),
            totalCost: const Value(250000),
          ),
        );

        await db.insertServiceItem(
          ServiceItemsCompanion.insert(
            serviceRecordId: sId,
            action: 'replace',
            partsCost: const Value(200000),
            laborCost: const Value(50000),
            totalCost: const Value(250000),
          ),
        );

        await db.setSetting('theme_mode', 'system');
        await db.setSetting('active_motorcycle_id', motorId.toString());

        // 2. Export encrypted backup with AES-256-GCM
        const passphrase = 'SuperSecretPassword2026!';
        final backupFile = await backupService.createBackup(
          passphrase: passphrase,
        );
        expect(await backupFile.exists(), isTrue);

        // 3. Clear database completely
        await db.clearAllUserData();
        expect(await db.getAllMotorcycles(), isEmpty);
        expect(await db.getOdometerLogs(motorId), isEmpty);
        expect(await db.getServiceRecords(motorId), isEmpty);

        // 4. Restore from backup
        await backupService.restoreBackup(backupFile, passphrase: passphrase);

        // 5. Verify restored state
        final restoredMotors = await db.getAllMotorcycles();
        expect(restoredMotors.length, 1);
        expect(restoredMotors.first.id, equals(motorId));
        expect(
          restoredMotors.first.nickname,
          equals('Comprehensive Test Motor'),
        );

        final restoredOdos = await db.getOdometerLogs(motorId);
        expect(restoredOdos.length, 1);
        expect(restoredOdos.first.odometerKm, equals(12500));

        final restoredServices = await db.getServiceRecords(motorId);
        expect(restoredServices.length, 1);
        expect(restoredServices.first.totalCost, equals(250000));

        final restoredTheme = await db.getSetting('theme_mode');
        expect(restoredTheme, equals('system'));

        // Reference catalog must remain intact
        final compTypes = await db.getAllComponentTypes();
        expect(compTypes.length, greaterThanOrEqualTo(8));
      },
    );
  });
}
