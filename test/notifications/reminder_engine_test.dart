import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buildhaus/core/database/app_database.dart';
import 'package:buildhaus/core/engines/reminder_engine.dart';
import 'package:buildhaus/core/notifications/notification_service.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;

void main() {
  late AppDatabase db;
  late ReminderEngine engine;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.ensureReferenceData();
    engine = ReminderEngine(db: db, notificationService: NotificationService());
  });

  tearDown(() async {
    await db.close();
  });

  group('Tahap 05 — ReminderEngine Tests', () {
    test(
      '1. Generates odometer staleness reminder when no update in 30+ days',
      () async {
        final motorId = await db.insertMotorcycle(
          MotorcyclesCompanion.insert(
            nickname: 'Vario Staleness',
            manufactureYear: 2022,
            usageProfile: const Value('campuran'),
          ),
        );

        // Record an odometer log from 35 days ago
        final oldDate = DateTime.now().subtract(const Duration(days: 35));
        await db.insertOdometerLog(
          OdometerLogsCompanion.insert(
            motorcycleId: motorId,
            odometerKm: 12000,
            recordedAt: oldDate,
          ),
        );

        final reminders = await engine.evaluateReminders(motorId);
        final odoReminder = reminders
            .where((r) => r.reminderType == 'odometer')
            .firstOrNull;

        expect(odoReminder, isNotNull);
        expect(odoReminder!.componentName, 'Odometer');
        expect(odoReminder.source, 'odometer_staleness');
        expect(odoReminder.message, contains('35 hari'));
      },
    );

    test(
      '2. Does NOT generate odometer staleness reminder when log is recent',
      () async {
        final motorId = await db.insertMotorcycle(
          MotorcyclesCompanion.insert(
            nickname: 'Beat Fresh',
            manufactureYear: 2023,
            usageProfile: const Value('campuran'),
          ),
        );

        // Record an odometer log from 5 days ago
        final recentDate = DateTime.now().subtract(const Duration(days: 5));
        await db.insertOdometerLog(
          OdometerLogsCompanion.insert(
            motorcycleId: motorId,
            odometerKm: 5000,
            recordedAt: recentDate,
          ),
        );

        final reminders = await engine.evaluateReminders(motorId);
        final odoReminder = reminders
            .where((r) => r.reminderType == 'odometer')
            .firstOrNull;

        expect(odoReminder, isNull);
      },
    );

    test(
      '3. Generates overdue component reminder when service interval is reached',
      () async {
        final motorId = await db.insertMotorcycle(
          MotorcyclesCompanion.insert(
            nickname: 'Aerox Service Overdue',
            manufactureYear: 2021,
            usageProfile: const Value('cvt'),
          ),
        );

        // Get Oli Mesin component type
        final compTypes = await db.getAllComponentTypes();
        final oilType = compTypes.firstWhere(
          (c) => c.name.toLowerCase().contains('oli'),
        );

        // Initial service 5000 km ago with replace action
        final serviceDate = DateTime.now().subtract(const Duration(days: 90));
        final recordId = await db.insertServiceRecord(
          ServiceRecordsCompanion.insert(
            motorcycleId: motorId,
            servicedAt: serviceDate,
            odometerKm: const Value(10000),
            totalCost: const Value(50000),
          ),
        );

        await db.insertServiceItem(
          ServiceItemsCompanion.insert(
            serviceRecordId: recordId,
            componentTypeId: Value(oilType.id),
            action: 'replace',
            partsCost: const Value(45000),
          ),
        );

        // Current odometer is 15000 km (+5000 km since oil change, typical interval is 2000-4000 km)
        await db.insertOdometerLog(
          OdometerLogsCompanion.insert(
            motorcycleId: motorId,
            odometerKm: 15000,
            recordedAt: DateTime.now(),
          ),
        );

        final reminders = await engine.evaluateReminders(motorId);
        final oilReminder = reminders
            .where((r) => r.componentTypeId == oilType.id)
            .firstOrNull;

        expect(oilReminder, isNotNull);
        expect(oilReminder!.isUrgent, isTrue);
        expect(oilReminder.title, contains(oilType.name));
      },
    );

    test(
      '4. Generates unresolved complaint follow-up reminder after 3+ days',
      () async {
        final motorId = await db.insertMotorcycle(
          MotorcyclesCompanion.insert(
            nickname: 'Scoopy Complaint',
            manufactureYear: 2020,
          ),
        );

        // Add a complaint from 5 days ago
        final complaintId = await db.insertComplaint(
          ComplaintsCompanion.insert(
            motorcycleId: motorId,
            title: 'Rem depan berdecit keras',
            description: 'Bunyi decit tajam setiap kali rem ditarik',
            status: const Value('dianalisis'),
            openedAt: Value(DateTime.now().subtract(const Duration(days: 5))),
          ),
        );
        expect(complaintId, greaterThan(0));

        final reminders = await engine.evaluateReminders(motorId);
        final complaintReminder = reminders
            .where((r) => r.reminderType == 'complaint')
            .firstOrNull;

        expect(complaintReminder, isNotNull);
        expect(
          complaintReminder!.componentName,
          contains('Rem depan berdecit keras'),
        );
        expect(complaintReminder.source, 'complaint');
      },
    );

    test(
      '5. SyncReminders stores reminders idempotently in SQLite LocalReminders table',
      () async {
        final motorId = await db.insertMotorcycle(
          MotorcyclesCompanion.insert(
            nickname: 'NMAX Idempotent',
            manufactureYear: 2022,
          ),
        );

        // Stale odometer trigger
        await db.insertOdometerLog(
          OdometerLogsCompanion.insert(
            motorcycleId: motorId,
            odometerKm: 20000,
            recordedAt: DateTime.now().subtract(const Duration(days: 40)),
          ),
        );

        // First sync
        final count1 = await engine.syncRemindersForMotorcycle(motorId);
        expect(count1, greaterThanOrEqualTo(1));

        final storedReminders1 = await db.getReminders(motorId);
        expect(storedReminders1.length, count1);

        // Second sync should update/maintain existing, not create duplicates
        final count2 = await engine.syncRemindersForMotorcycle(motorId);
        expect(count2, greaterThanOrEqualTo(0));
        final storedReminders2 = await db.getReminders(motorId);
        expect(storedReminders2.length, storedReminders1.length);
      },
    );

    test(
      '6. Multi-motorcycle isolation: Reminders for Motor A do not bleed into Motor B',
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
            manufactureYear: 2023,
          ),
        );

        // Motor A has stale odometer (45 days)
        await db.insertOdometerLog(
          OdometerLogsCompanion.insert(
            motorcycleId: motorA,
            odometerKm: 30000,
            recordedAt: DateTime.now().subtract(const Duration(days: 45)),
          ),
        );

        // Motor B has fresh odometer (today)
        await db.insertOdometerLog(
          OdometerLogsCompanion.insert(
            motorcycleId: motorB,
            odometerKm: 1200,
            recordedAt: DateTime.now(),
          ),
        );

        await engine.syncRemindersForMotorcycle(motorA);
        await engine.syncRemindersForMotorcycle(motorB);

        final remindersA = await db.getReminders(motorA);
        final remindersB = await db.getReminders(motorB);

        expect(remindersA.any((r) => r.reminderType == 'odometer'), isTrue);
        expect(remindersB.any((r) => r.reminderType == 'odometer'), isFalse);
      },
    );
  });
}
