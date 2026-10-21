import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buildhaus/core/database/app_database.dart';
import 'package:buildhaus/core/engines/budget_engine.dart';
import 'package:buildhaus/core/engines/self_inspection_engine.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async => db.close());

  Future<Motorcycle> addMotor({
    int? modelId,
    String name = 'Motor Uji Tahap 03',
    double initialOdo = 10000,
  }) async {
    final models = await db.getAllMotorcycleModels();
    final selected = models.firstWhere(
      (m) => m.id == (modelId ?? models.first.id),
    );
    final id = await db.createMotorcycle(
      motorcycle: MotorcyclesCompanion.insert(
        nickname: name,
        modelId: Value(selected.id),
        manufactureYear: selected.yearStart,
      ),
      initialOdometerKm: initialOdo,
    );
    return (await db.getMotorcycle(id))!;
  }

  group('Tahap 03 — Database & End-to-End Budget Tests', () {
    test(
      '15. Rekomendasi berubah setelah servis dicatat (wear reset removes recommendation)',
      () async {
        final motor = await addMotor(initialOdo: 10000);

        // Record old service at 6,000 km (interval oil is 3,000 km -> at 10,000 km it's overdue by 4,000 km)
        await db.createServiceWithItems(
          record: ServiceRecordsCompanion.insert(
            motorcycleId: motor.id,
            servicedAt: DateTime.now().subtract(const Duration(days: 60)),
            workshopName: const Value('Bengkel Lama'),
          ),
          items: [
            ServiceItemsCompanion.insert(
              serviceRecordId: 0,
              componentTypeId: const Value(1), // Oli mesin
              action: 'replace',
              partsCost: const Value(65000),
              laborCost: const Value(15000),
              totalCost: const Value(80000),
            ),
          ],
          odometerKm: 6000,
        );

        // Current odo is 10,000 -> elapsed is 4,000 km > 3,000 km rule
        await db.recalculateComponentStatuses(motor.id);
        final statusesBefore = await db.getComponentStatusesWithNames(motor.id);

        final engineBefore = BudgetEngine(
          componentHealths: [],
          budgetAmount: 200000,
          activeMotorcycle: motor,
          componentStatusesWithNames: statusesBefore,
        );

        final recsBefore = engineBefore.generateRecommendations();
        expect(
          recsBefore.any(
            (r) => r.componentName == 'Oli mesin' && r.action == 'replace',
          ),
          isTrue,
        );

        // Now record a new service replacement at 10,000 km
        await db.createServiceWithItems(
          record: ServiceRecordsCompanion.insert(
            motorcycleId: motor.id,
            servicedAt: DateTime.now(),
            workshopName: const Value('Bengkel Baru'),
          ),
          items: [
            ServiceItemsCompanion.insert(
              serviceRecordId: 0,
              componentTypeId: const Value(1), // Oli mesin
              action: 'replace',
              partsCost: const Value(65000),
              laborCost: const Value(15000),
              totalCost: const Value(80000),
            ),
          ],
          odometerKm: 10000,
        );

        final statusesAfter = await db.getComponentStatusesWithNames(motor.id);
        final engineAfter = BudgetEngine(
          componentHealths: [],
          budgetAmount: 200000,
          activeMotorcycle: motor,
          componentStatusesWithNames: statusesAfter,
        );

        final recsAfter = engineAfter.generateRecommendations();
        // Oil is fresh (0 km since replacement) -> no longer recommended for replacement!
        expect(
          recsAfter.any(
            (r) => r.componentName == 'Oli mesin' && r.action == 'replace',
          ),
          isFalse,
        );
      },
    );

    test(
      '16. Rekomendasi berubah setelah update kilometer (crossing interval triggers action)',
      () async {
        final motor = await addMotor(initialOdo: 10000);

        // Replace oil at 10,000 km
        await db.createServiceWithItems(
          record: ServiceRecordsCompanion.insert(
            motorcycleId: motor.id,
            servicedAt: DateTime.now(),
          ),
          items: [
            ServiceItemsCompanion.insert(
              serviceRecordId: 0,
              componentTypeId: const Value(1), // Oli mesin
              action: 'replace',
              partsCost: const Value(65000),
              laborCost: const Value(15000),
              totalCost: const Value(80000),
            ),
          ],
          odometerKm: 10000,
        );

        // Check right after service: 0 km elapsed -> good status
        await db.recalculateComponentStatuses(motor.id);
        var statuses = await db.getComponentStatusesWithNames(motor.id);
        var engine = BudgetEngine(
          componentHealths: [],
          budgetAmount: 200000,
          activeMotorcycle: motor,
          componentStatusesWithNames: statuses,
        );
        expect(
          engine.generateRecommendations().any(
            (r) => r.componentName == 'Oli mesin' && r.action == 'replace',
          ),
          isFalse,
        );

        // User logs new odometer 4,000 km later (14,000 km)
        await db
            .into(db.odometerLogs)
            .insert(
              OdometerLogsCompanion.insert(
                motorcycleId: motor.id,
                odometerKm: 14000,
                recordedAt: DateTime.now(),
                source: const Value('manual'),
              ),
            );

        await db.recalculateComponentStatuses(motor.id);
        statuses = await db.getComponentStatusesWithNames(motor.id);
        engine = BudgetEngine(
          componentHealths: [],
          budgetAmount: 200000,
          activeMotorcycle: motor,
          componentStatusesWithNames: statuses,
        );

        // Now oil is overdue -> replace recommendation triggered!
        final recs = engine.generateRecommendations();
        expect(
          recs.any(
            (r) => r.componentName == 'Oli mesin' && r.action == 'replace',
          ),
          isTrue,
        );
      },
    );

    test(
      '17. Rekomendasi berubah setelah pemeriksaan mandiri (safety alert integration)',
      () async {
        final motor = await addMotor();

        await db.recalculateComponentStatuses(motor.id);
        var statuses = await db.getComponentStatusesWithNames(motor.id);

        var engine = BudgetEngine(
          componentHealths: [],
          budgetAmount: 200000,
          activeMotorcycle: motor,
          componentStatusesWithNames: statuses,
        );
        expect(
          engine.generateRecommendations().any((r) => r.priority == 'safety'),
          isFalse,
        );

        // User completes self-inspection noting severe brake failure
        await db.saveCompleteSelfInspection(
          motorcycleId: motor.id,
          riskLevel: 'critical',
          answers: {'rem_respons': 'blong'},
        );

        statuses = await db.getComponentStatusesWithNames(motor.id);
        final latestInspection = await db.getLatestSelfInspection(motor.id);
        final answers = await db.getInspectionAnswers(latestInspection!.id);
        final answerMap = {for (var a in answers) a.questionCode: a.answer};
        final findings = SelfInspectionEngine.evaluate(answerMap).allFindings;

        engine = BudgetEngine(
          componentHealths: [],
          budgetAmount: 200000,
          activeMotorcycle: motor,
          componentStatusesWithNames: statuses,
          inspectionFindings: findings,
        );

        final recs = engine.generateRecommendations();
        expect(
          recs.any(
            (r) => r.componentName == 'Kampas rem' && r.priority == 'safety',
          ),
          isTrue,
        );
      },
    );

    test(
      '18. Perubahan motor aktif tidak mencampur rekomendasi (multi-motor isolation)',
      () async {
        final motorA = await addMotor(name: 'Motor A');
        final motorB = await addMotor(name: 'Motor B');

        // Motor A has critical brake issue
        await db.saveCompleteSelfInspection(
          motorcycleId: motorA.id,
          riskLevel: 'critical',
          answers: {'rem_respons': 'blong'},
        );

        await db.recalculateComponentStatuses(motorA.id);
        await db.recalculateComponentStatuses(motorB.id);

        final statusesA = await db.getComponentStatusesWithNames(motorA.id);
        final statusesB = await db.getComponentStatusesWithNames(motorB.id);

        final inspectionA = await db.getLatestSelfInspection(motorA.id);
        final answersA = await db.getInspectionAnswers(inspectionA!.id);
        final findingsA = SelfInspectionEngine.evaluate({
          for (var a in answersA) a.questionCode: a.answer,
        }).allFindings;

        final engineA = BudgetEngine(
          componentHealths: [],
          budgetAmount: 100000,
          activeMotorcycle: motorA,
          componentStatusesWithNames: statusesA,
          inspectionFindings: findingsA,
        );

        final engineB = BudgetEngine(
          componentHealths: [],
          budgetAmount: 100000,
          activeMotorcycle: motorB,
          componentStatusesWithNames: statusesB,
          inspectionFindings: [], // Motor B has no inspection findings
        );

        expect(
          engineA.generateRecommendations().any((r) => r.priority == 'safety'),
          isTrue,
        );
        expect(
          engineB.generateRecommendations().any((r) => r.priority == 'safety'),
          isFalse,
        );
      },
    );

    test(
      '19 & 20. Penyimpanan budget plan dan recommendation snapshot di SQLite',
      () async {
        final motor = await addMotor();

        final recsToSave = [
          BudgetRecommendation(
            componentName: 'Oli mesin',
            componentTypeId: 1,
            priority: 'high',
            decision: 'selected',
            estimatedCost: 80000,
            estimatedPartCost: 65000,
            estimatedLaborCost: 15000,
            action: 'replace',
            reason: 'Jadwal servis tercapai',
          ),
          BudgetRecommendation(
            componentName: 'Kampas rem',
            componentTypeId: 2,
            priority: 'safety',
            decision: 'safety_alert',
            estimatedCost: 30000,
            estimatedPartCost: null,
            estimatedLaborCost: 30000,
            action: 'inspect',
            reason: 'Pemeriksaan rem',
            isSafetyCritical: true,
          ),
        ];

        final planId = await db.saveCompleteBudgetPlan(
          motorcycleId: motor.id,
          budgetAmount: 250000,
          period: 'bulanan',
          recommendations: recsToSave,
          notes: 'Snapshot uji tahap 03',
        );

        expect(planId, greaterThan(0));

        // Verify budget_plans row
        final history = await db.getBudgetPlanHistory(motor.id);
        expect(history.length, equals(1));
        expect(history.first.budgetAmount, equals(250000));
        expect(history.first.notes, equals('Snapshot uji tahap 03'));

        // Verify service_recommendations row
        final rec = await db.getLatestRecommendation(planId);
        expect(rec, isNotNull);
        expect(rec!.budgetPlanId, equals(planId));
        expect(rec.estimatedTotal, equals(110000)); // 80000 + 30000

        // Verify recommendation_items rows
        final items = await db.getRecommendationItems(rec.id);
        expect(items.length, equals(2));
        expect(
          items.any((i) => i.componentTypeId == 1 && i.decision == 'selected'),
          isTrue,
        );
        expect(
          items.any(
            (i) => i.componentTypeId == 2 && i.decision == 'safety_alert',
          ),
          isTrue,
        );
      },
    );

    test(
      '21. Rollback ketika penyimpanan gagal (transaksi terisolasi)',
      () async {
        await addMotor();

        // Attempt saving with invalid foreign key (non-existent motorcycleId)
        expect(
          () async => await db.saveCompleteBudgetPlan(
            motorcycleId:
                999999, // Non-existent motorcycle ID triggers FK violation
            budgetAmount: 100000,
            period: 'bulanan',
            recommendations: [],
          ),
          throwsA(isA<Exception>()),
        );

        // Verify no dangling budget plans exist
        final allPlans = await db.select(db.budgetPlans).get();
        expect(allPlans.where((p) => p.motorcycleId == 999999), isEmpty);
      },
    );
  });
}
