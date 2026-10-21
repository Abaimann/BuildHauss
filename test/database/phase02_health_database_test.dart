import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buildhaus/core/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async => db.close());

  Future<int> addMotor({
    int? modelId,
    String name = 'Motor Uji Tahap 02',
  }) async {
    final models = await db.getAllMotorcycleModels();
    final selected = models.firstWhere(
      (m) => m.id == (modelId ?? models.first.id),
    );
    return db.createMotorcycle(
      motorcycle: MotorcyclesCompanion.insert(
        nickname: name,
        modelId: Value(selected.id),
        manufactureYear: selected.yearStart,
      ),
      initialOdometerKm: 10000,
    );
  }

  group('Tahap 02 — Database & Health Engine Integration Tests', () {
    test(
      '21. Penyimpanan riwayat pemeriksaan mandiri (Self-Inspection Persistence)',
      () async {
        final motorId = await addMotor();

        final answers = {
          'rem_bunyi': 'gesekan_ringan',
          'ban_kondisi': 'menipis',
          'kebocoran_cairan': 'bersih',
        };

        final inspectionId = await db.saveCompleteSelfInspection(
          motorcycleId: motorId,
          riskLevel: 'medium',
          answers: answers,
          notes: 'Pemeriksaan mandiri sebelum touring',
        );

        expect(inspectionId, greaterThan(0));

        final latest = await db.getLatestSelfInspection(motorId);
        expect(latest, isNotNull);
        expect(latest!.id, equals(inspectionId));
        expect(latest.notes, equals('Pemeriksaan mandiri sebelum touring'));

        final savedAnswers = await db.getInspectionAnswers(inspectionId);
        expect(savedAnswers.length, equals(3));
        expect(
          savedAnswers.firstWhere((a) => a.questionCode == 'rem_bunyi').answer,
          equals('gesekan_ringan'),
        );
        expect(
          savedAnswers
              .firstWhere((a) => a.questionCode == 'ban_kondisi')
              .answer,
          equals('menipis'),
        );
        expect(
          savedAnswers
              .firstWhere((a) => a.questionCode == 'kebocoran_cairan')
              .answer,
          equals('bersih'),
        );

        final history = await db.getSelfInspections(motorId);
        expect(history.length, equals(1));
      },
    );

    test(
      '22. Pembaruan dinamis status komponen setelah pemeriksaan mandiri',
      () async {
        final motorId = await addMotor();

        // Initially recalculate component statuses
        await db.recalculateComponentStatuses(motorId);
        final initialStatuses = await db.getComponentStatuses(motorId);
        expect(initialStatuses, isNotEmpty);
        final initialRem = initialStatuses.firstWhere(
          (s) => s.componentTypeId == 2, // Kampas rem
        );
        expect(initialRem.explanation.contains('KESELAMATAN'), isFalse);

        // Save an inspection indicating critical brake failure
        await db.saveCompleteSelfInspection(
          motorcycleId: motorId,
          riskLevel: 'critical',
          answers: {'rem_respons': 'blong'},
        );

        // Verify that recalculateComponentStatuses updated the Kampas rem status to replace & safety alert
        final updatedStatuses = await db.getComponentStatuses(motorId);
        final updatedRem = updatedStatuses.firstWhere(
          (s) => s.componentTypeId == 2, // Kampas rem
        );
        expect(updatedRem.estimatedStatus, equals('replace'));
        expect(updatedRem.explanation.contains('KESELAMATAN'), isTrue);
        expect(updatedRem.explanation.contains('BAHAYA KESELAMATAN'), isTrue);
      },
    );

    test('23. Rekalkulasi kesehatan setelah servis dicatat', () async {
      final motorId = await addMotor();
      final now = DateTime.now();

      // Record a service item replacing oil and brake pads at 10,000 km
      final serviceId = await db.createServiceWithItems(
        record: ServiceRecordsCompanion.insert(
          motorcycleId: motorId,
          servicedAt: now,
          workshopName: const Value('Bengkel Resmi'),
        ),
        items: [
          ServiceItemsCompanion.insert(
            serviceRecordId: 0,
            componentTypeId: const Value(1), // Oli mesin
            action: 'replace',
            partsCost: const Value(80000),
            laborCost: const Value(20000),
            totalCost: const Value(100000),
          ),
          ServiceItemsCompanion.insert(
            serviceRecordId: 0,
            componentTypeId: const Value(2), // Kampas rem
            action: 'replace',
            partsCost: const Value(40000),
            laborCost: const Value(10000),
            totalCost: const Value(50000),
          ),
        ],
        odometerKm: 10000,
      );

      expect(serviceId, greaterThan(0));

      // After service replacement at current odometer (10,000 km), progress is 0% -> status is good
      final statuses = await db.getComponentStatuses(motorId);
      final oliStatus = statuses.firstWhere((s) => s.componentTypeId == 1);
      final remStatus = statuses.firstWhere((s) => s.componentTypeId == 2);

      expect(oliStatus.estimatedStatus, equals('good'));
      expect(remStatus.estimatedStatus, equals('good'));
      expect(oliStatus.score, equals(100.0));
      expect(remStatus.score, equals(100.0));
    });

    test(
      '24. Pembacaan odometer pada tanggal dan jam yang sama di database',
      () async {
        final motorId = await addMotor();
        final sameTimestamp = DateTime(2026, 10, 21, 14, 30, 0);

        // Insert two readings with identical timestamps
        final logId1 = await db
            .into(db.odometerLogs)
            .insert(
              OdometerLogsCompanion.insert(
                motorcycleId: motorId,
                odometerKm: 10500,
                recordedAt: sameTimestamp,
                note: const Value('Pagi hari'),
              ),
            );

        final logId2 = await db
            .into(db.odometerLogs)
            .insert(
              OdometerLogsCompanion.insert(
                motorcycleId: motorId,
                odometerKm: 10550,
                recordedAt: sameTimestamp,
                note: const Value('Sore hari setelah dicek ulang'),
              ),
            );

        expect(logId1, isNot(equals(logId2)));

        final allLogs = await db.getOdometerLogs(motorId);
        final sameTimestampLogs = allLogs
            .where((l) => l.recordedAt.isAtSameMomentAs(sameTimestamp))
            .toList();

        expect(sameTimestampLogs.length, equals(2));
        expect(
          sameTimestampLogs.map((l) => l.odometerKm),
          containsAll([10500, 10550]),
        );
      },
    );

    test('25. Isolasi multi-motor pada komponen dan hasil inspeksi', () async {
      final motor1 = await addMotor(name: 'Vario Merah');
      final motor2 = await addMotor(name: 'NMAX Biru');

      // Add self-inspection ONLY for motor1 with severe brake fault
      await db.saveCompleteSelfInspection(
        motorcycleId: motor1,
        riskLevel: 'critical',
        answers: {'rem_respons': 'blong'},
      );

      // Check Motor 1: inspection exists and Kampas rem is flagged
      final m1Inspections = await db.getSelfInspections(motor1);
      expect(m1Inspections.length, equals(1));
      final m1Statuses = await db.getComponentStatuses(motor1);
      final m1Rem = m1Statuses.firstWhere((s) => s.componentTypeId == 2);
      expect(m1Rem.estimatedStatus, equals('replace'));
      expect(m1Rem.explanation.contains('KESELAMATAN'), isTrue);

      // Check Motor 2: ZERO inspections, and Kampas rem is NOT affected
      await db.recalculateComponentStatuses(motor2);
      final m2Inspections = await db.getSelfInspections(motor2);
      expect(m2Inspections, isEmpty);
      final m2Statuses = await db.getComponentStatuses(motor2);
      final m2Rem = m2Statuses.firstWhere((s) => s.componentTypeId == 2);
      expect(m2Rem.explanation.contains('KESELAMATAN'), isFalse);
      expect(m2Rem.estimatedStatus, isNot(equals('replace')));
    });
  });
}
