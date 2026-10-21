import 'package:flutter_test/flutter_test.dart';
import 'package:buildhaus/core/database/app_database.dart';
import 'package:buildhaus/core/engines/budget_engine.dart';
import 'package:buildhaus/core/engines/self_inspection_engine.dart';

void main() {
  Motorcycle makeMotor(int id, int modelId, String name) {
    return Motorcycle(
      id: id,
      modelId: modelId,
      nickname: name,
      manufactureYear: 2022,
      plateNumber: 'B 1234 ABC',
      usageProfile: 'campuran',
      isPrimary: true,
      emoji: '🛵',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  ComponentStatusWithName makeStatus(
    int compId,
    String name,
    String status, {
    int? score,
    String? explanation,
  }) {
    return ComponentStatusWithName(
      status: ComponentStatus(
        id: compId,
        motorcycleId: 1,
        componentTypeId: compId,
        estimatedStatus: status,
        score: (score ?? 50).toDouble(),
        explanation: explanation ?? 'Status kalkulasi untuk $name',
        calculatedAt: DateTime.now(),
        ruleVersion: 'v1',
      ),
      componentName: name,
    );
  }

  InspectionFinding makeFinding({
    required String code,
    required String compName,
    required String label,
    required String risk,
    required bool isSafety,
    required String advice,
  }) {
    return InspectionFinding(
      questionCode: code,
      questionTitle: 'Inspeksi',
      category: 'umum',
      componentName: compName,
      answerLabel: label,
      riskLevel: risk,
      isSafetyCritical: isSafety,
      advice: advice,
    );
  }

  group('Tahap 03 — Smart Budget Engine Unit Tests', () {
    final testHondaModel = makeMotor(1, 101, 'Honda Vario 160');

    final hondaOilPart = const Sparepart(
      id: 1,
      name: 'Oli Mesin Honda ASM 10W-30 SL',
      partNumber: 'ASM 10W-30 SL',
      brand: 'Honda',
      category: 'oli_mesin',
      referencePrice: 65000,
      isVerified: true,
      productUrl: 'https://www.astra-honda.com',
    );

    final yamahaOilPart = const Sparepart(
      id: 2,
      name: 'Oli Mesin Yamalube Matic 10W-40',
      partNumber: 'Yamalube 10W-40',
      brand: 'Yamaha',
      category: 'oli_mesin',
      referencePrice: 70000,
      isVerified: true,
      productUrl: 'https://www.yamaha-motor.co.id',
    );

    final testFitments = [
      SparepartFitment(
        id: 1,
        sparepartId: 1,
        modelId: 101, // Honda Vario 160
        yearStart: 2022,
        verifiedAt: DateTime(2026, 1, 15),
        sourceUrl: 'https://www.astra-honda.com',
      ),
      SparepartFitment(
        id: 2,
        sparepartId: 2,
        modelId: 202, // Yamaha NMAX
        yearStart: 2020,
        verifiedAt: DateTime(2026, 1, 15),
        sourceUrl: 'https://www.yamaha-motor.co.id',
      ),
    ];

    test('1. Budget Rp0 (menghasilkan rekomendasi deferred tanpa error)', () {
      final statuses = [
        makeStatus(
          1,
          'Oli mesin',
          'replace',
          score: 30,
          explanation: 'Sudah melewati batas interval perawatan',
        ),
      ];

      final engine = BudgetEngine(
        componentHealths: [],
        budgetAmount: 0,
        activeMotorcycle: testHondaModel,
        componentStatusesWithNames: statuses,
        spareparts: [hondaOilPart],
        fitments: testFitments,
      );

      final summary = engine.calculateSummary();
      expect(summary.totalItems, equals(1));
      expect(summary.totalFundedCost, equals(0));
      expect(summary.remainingBudget, equals(0));
      expect(summary.shortfall, greaterThan(0));
      expect(summary.recommendations.first.decision, equals('deferred'));
      expect(
        summary.recommendations.first.budgetStatus,
        equals('belum_terdanai'),
      );
    });

    test('2. Budget sangat kecil (alokasi proporsional & konsisten)', () {
      final statuses = [
        makeStatus(
          1,
          'Oli mesin',
          'replace',
          score: 30,
          explanation: 'Sudah melewati batas interval perawatan',
        ),
      ];

      final engine = BudgetEngine(
        componentHealths: [],
        budgetAmount: 10000, // Rp 10.000 tidak cukup untuk oli Rp 65.000 + jasa
        activeMotorcycle: testHondaModel,
        componentStatusesWithNames: statuses,
        spareparts: [hondaOilPart],
        fitments: testFitments,
      );

      final summary = engine.calculateSummary();
      expect(summary.totalFundedCost, equals(0));
      expect(summary.remainingBudget, equals(10000));
      expect(summary.shortfall, greaterThan(0));
      expect(
        summary.recommendations.first.budgetStatus,
        equals('belum_terdanai'),
      );
    });

    test('3. Budget mencukupi seluruh perawatan (semua item terdanai)', () {
      final statuses = [
        makeStatus(
          1,
          'Oli mesin',
          'replace',
          score: 30,
          explanation: 'Sudah melewati batas interval perawatan',
        ),
      ];

      final engine = BudgetEngine(
        componentHealths: [],
        budgetAmount: 500000,
        activeMotorcycle: testHondaModel,
        componentStatusesWithNames: statuses,
        spareparts: [hondaOilPart],
        fitments: testFitments,
      );

      final summary = engine.calculateSummary();
      expect(summary.totalItems, equals(1));
      expect(summary.fundedItemsCount, equals(1));
      expect(summary.deferredItemsCount, equals(0));
      expect(summary.shortfall, equals(0));
      expect(summary.remainingBudget, equals(500000 - summary.totalFundedCost));
      expect(summary.recommendations.first.budgetStatus, equals('terdanai'));
    });

    test(
      '4. Tindakan kritis dengan biaya melebihi budget (tetap tampil terdepan & urgent)',
      () {
        final findings = [
          makeFinding(
            code: 'rem_respons',
            compName: 'Kampas rem',
            label: 'Rem terasa blong atau tidak menggigit sama sekali',
            risk: 'critical',
            isSafety: true,
            advice:
                'BAHAYA KESELAMATAN! JANGAN kendarai motor ini sampai diperiksa.',
          ),
        ];

        final statuses = [
          makeStatus(
            2,
            'Kampas rem',
            'replace',
            score: 20,
            explanation: '⚠️ KESELAMATAN: Rem tidak berfungsi',
          ),
        ];

        final engine = BudgetEngine(
          componentHealths: [],
          budgetAmount: 5000, // Budget sangat minim
          activeMotorcycle: testHondaModel,
          componentStatusesWithNames: statuses,
          inspectionFindings: findings,
        );

        final summary = engine.calculateSummary();
        expect(summary.safetyAlertCount, equals(1));
        final rec = summary.recommendations.first;
        expect(rec.priority, equals('safety'));
        expect(rec.decision, equals('safety_alert'));
        expect(rec.isSafetyCritical, isTrue);
        expect(rec.budgetStatus, equals('belum_terdanai'));
        expect(rec.reason, contains('BAHAYA KESELAMATAN'));
      },
    );

    test(
      '5. Tindakan kritis dengan biaya belum diketahui (tidak dianggap Rp0)',
      () {
        final findings = [
          makeFinding(
            code: 'kemudi_stabilitas',
            compName: 'Kemudi',
            label: 'Stang bergetar hebat atau oleng',
            risk: 'critical',
            isSafety: true,
            advice:
                'BAHAYA KESELAMATAN: Komstir atau suspensi depan bermasalah serius.',
          ),
        ];

        final statuses = [makeStatus(9, 'Kemudi', 'unknown')];

        final engine = BudgetEngine(
          componentHealths: [],
          budgetAmount: 100000,
          activeMotorcycle: testHondaModel,
          componentStatusesWithNames: statuses,
          inspectionFindings: findings,
          spareparts: [], // Biaya sparepart tidak tersedia
        );

        final recs = engine.generateRecommendations();
        expect(recs.first.isSafetyCritical, isTrue);
        expect(recs.first.action, equals('inspect'));
      },
    );

    test(
      '6. Harga sparepart null / tidak diketahui (status biaya belum tersedia)',
      () {
        final partWithoutPrice = const Sparepart(
          id: 99,
          name: 'Sparepart Khusus Tanpa Harga',
          category: 'mesin',
          brand: 'Honda',
          isVerified: false,
        );

        final statuses = [makeStatus(8, 'Knalpot', 'unknown')];

        final engine = BudgetEngine(
          componentHealths: [],
          budgetAmount: 100000,
          activeMotorcycle: testHondaModel,
          componentStatusesWithNames: statuses,
          spareparts: [partWithoutPrice],
        );

        final recs = engine.generateRecommendations();
        expect(recs.first.hasKnownCost, isFalse);
        expect(recs.first.budgetStatus, equals('biaya_belum_tersedia'));
      },
    );

    test('7 & 8. Sparepart kompatibel vs tidak kompatibel untuk model', () {
      final statuses = [makeStatus(1, 'Oli mesin', 'replace', score: 40)];

      // Honda motor should match Honda part with verified fitment
      final engineHonda = BudgetEngine(
        componentHealths: [],
        budgetAmount: 200000,
        activeMotorcycle: testHondaModel,
        componentStatusesWithNames: statuses,
        spareparts: [hondaOilPart, yamahaOilPart],
        fitments: testFitments,
      );

      final recsHonda = engineHonda.generateRecommendations();
      expect(recsHonda.first.matchedSparepart?.id, equals(hondaOilPart.id));
      expect(recsHonda.first.fitmentStatus, equals('verified'));
    });

    test(
      '9. Kompatibilitas belum terverifikasi (status reference / unverified)',
      () {
        final genericPart = const Sparepart(
          id: 50,
          name: 'Oli Mesin Universal Motor',
          category: 'oli_mesin',
          brand: 'Generic',
          referencePrice: 40000,
          isVerified: false,
        );

        final statuses = [makeStatus(1, 'Oli mesin', 'replace', score: 40)];

        final engine = BudgetEngine(
          componentHealths: [],
          budgetAmount: 200000,
          activeMotorcycle: testHondaModel,
          componentStatusesWithNames: statuses,
          spareparts: [genericPart],
          fitments: [], // No verified fitments
        );

        final recs = engine.generateRecommendations();
        expect(recs.first.matchedSparepart?.id, equals(genericPart.id));
        expect(recs.first.fitmentStatus, equals('reference'));
      },
    );

    test('10. Motor Honda tidak menggunakan fitment / part khusus Yamaha', () {
      final statuses = [makeStatus(1, 'Oli mesin', 'replace', score: 40)];

      // Only Yamaha part is provided
      final engine = BudgetEngine(
        componentHealths: [],
        budgetAmount: 200000,
        activeMotorcycle: testHondaModel, // Honda Vario 160
        componentStatusesWithNames: statuses,
        spareparts: [yamahaOilPart], // Yamaha Yamalube part
        fitments: testFitments,
      );

      final recs = engine.generateRecommendations();
      // Should NOT match Yamaha-branded part on Honda motorcycle!
      expect(recs.first.matchedSparepart, isNull);
    });

    test(
      '11. Item inspect tidak otomatis menjadi replace (evaluasi gejala rem)',
      () {
        final findings = [
          makeFinding(
            code: 'rem_respons',
            compName: 'Kampas rem',
            label: 'Kurang pakem / tuas harus ditarik dalam',
            risk: 'high',
            isSafety: true,
            advice: 'Periksa ketebalan kampas rem dan volume minyak rem.',
          ),
        ];

        final statuses = [makeStatus(2, 'Kampas rem', 'inspect', score: 55)];

        final engine = BudgetEngine(
          componentHealths: [],
          budgetAmount: 200000,
          activeMotorcycle: testHondaModel,
          componentStatusesWithNames: statuses,
          inspectionFindings: findings,
        );

        final recs = engine.generateRecommendations();
        expect(recs.first.action, equals('inspect'));
        expect(recs.first.action, isNot(equals('replace')));
        expect(
          recs.first.estimatedPartCost,
          isNull,
        ); // Belum membebankan sparepart
      },
    );

    test(
      '12. Dua komponen dengan prioritas berbeda (safety > overdue replace)',
      () {
        final findings = [
          makeFinding(
            code: 'rem_respons',
            compName: 'Kampas rem',
            label: 'Rem blong',
            risk: 'critical',
            isSafety: true,
            advice: 'Bahaya keselamatan',
          ),
        ];

        final statuses = [
          makeStatus(1, 'Oli mesin', 'replace', score: 30),
          makeStatus(2, 'Kampas rem', 'replace', score: 20),
        ];

        final engine = BudgetEngine(
          componentHealths: [],
          budgetAmount: 200000,
          activeMotorcycle: testHondaModel,
          componentStatusesWithNames: statuses,
          inspectionFindings: findings,
          spareparts: [hondaOilPart],
          fitments: testFitments,
        );

        final recs = engine.generateRecommendations();
        expect(recs.length, equals(2));
        expect(recs[0].componentName, equals('Kampas rem'));
        expect(recs[0].priority, equals('safety'));
        expect(recs[1].componentName, equals('Oli mesin'));
        expect(recs[1].priority, equals('high'));
      },
    );

    test(
      '13. Perawatan sudah melewati interval (action replace, priority high)',
      () {
        final statuses = [
          makeStatus(
            1,
            'Oli mesin',
            'replace',
            score: 25,
            explanation: 'Jadwal servis berkala telah tercapai',
          ),
        ];

        final engine = BudgetEngine(
          componentHealths: [],
          budgetAmount: 200000,
          activeMotorcycle: testHondaModel,
          componentStatusesWithNames: statuses,
          spareparts: [hondaOilPart],
          fitments: testFitments,
        );

        final recs = engine.generateRecommendations();
        expect(recs.first.action, equals('replace'));
        expect(recs.first.priority, equals('high'));
        expect(
          recs.first.estimatedPartCost,
          equals(hondaOilPart.referencePrice),
        );
      },
    );

    test(
      '14. Perawatan mendekati interval (action inspect, priority medium)',
      () {
        final statuses = [
          makeStatus(
            1,
            'Oli mesin',
            'inspect',
            score: 65,
            explanation: 'Mendekati batas interval perawatan',
          ),
        ];

        final engine = BudgetEngine(
          componentHealths: [],
          budgetAmount: 200000,
          activeMotorcycle: testHondaModel,
          componentStatusesWithNames: statuses,
          spareparts: [hondaOilPart],
          fitments: testFitments,
        );

        final recs = engine.generateRecommendations();
        expect(recs.first.action, equals('inspect'));
        expect(recs.first.priority, equals('medium'));
      },
    );

    test('22. Perhitungan total biaya tanpa double counting', () {
      final statuses = [
        makeStatus(1, 'Oli mesin', 'replace', score: 30),
        makeStatus(2, 'Kampas rem', 'inspect', score: 60),
      ];

      final engine = BudgetEngine(
        componentHealths: [],
        budgetAmount: 150000,
        activeMotorcycle: testHondaModel,
        componentStatusesWithNames: statuses,
        spareparts: [hondaOilPart],
        fitments: testFitments,
      );

      final summary = engine.calculateSummary();
      final sumItemCosts = summary.recommendations
          .where((r) => r.hasKnownCost)
          .fold<int>(0, (sum, r) => sum + r.estimatedCost);

      expect(summary.totalEstimatedCost, equals(sumItemCosts));
      expect(summary.totalFundedCost + summary.remainingBudget, equals(150000));
    });

    test('23. Tidak ada harga palsu ketika biaya tidak diketahui', () {
      final statuses = [makeStatus(8, 'Knalpot', 'unknown')];

      final engine = BudgetEngine(
        componentHealths: [],
        budgetAmount: 100000,
        activeMotorcycle: testHondaModel,
        componentStatusesWithNames: statuses,
        spareparts: [],
      );

      final recs = engine.generateRecommendations();
      expect(recs.first.hasKnownCost, isFalse);
      expect(recs.first.estimatedPartCost, isNull);
      expect(recs.first.budgetStatus, equals('biaya_belum_tersedia'));
    });

    test('24. Kondisi belum cukup data (empty statuses)', () {
      final engine = BudgetEngine(
        componentHealths: [],
        budgetAmount: 100000,
        activeMotorcycle: testHondaModel,
        componentStatusesWithNames: [], // No component status data yet
      );

      final summary = engine.calculateSummary();
      expect(summary.totalItems, equals(0));
      expect(summary.totalEstimatedCost, equals(0));
      expect(summary.remainingBudget, equals(100000));
    });
  });
}
