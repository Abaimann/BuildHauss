import 'package:flutter_test/flutter_test.dart';
import 'package:buildhaus/core/engines/health_engine.dart';
import 'package:buildhaus/core/database/app_database.dart';

void main() {
  group('HealthEngine', () {
    test('returns unknown when no rules exist', () {
      final engine = HealthEngine(
        statuses: [],
        serviceRecords: [],
        odometerLogs: [],
        rules: [],
        componentTypes: [_createComponentType(1, 'Oli mesin', true)],
        currentOdometer: 10000,
      );

      final result = engine.calculateHealth(1);
      expect(result.status, equals('unknown'));
      expect(result.score, isNull);
    });

    test('returns unknown when no service records exist', () {
      final engine = HealthEngine(
        statuses: [],
        serviceRecords: [],
        odometerLogs: [],
        rules: [_createRule(1, 1, 3000, 90)],
        componentTypes: [_createComponentType(1, 'Oli mesin', true)],
        currentOdometer: 10000,
      );

      final result = engine.calculateHealth(1);
      expect(result.status, equals('unknown'));
    });

    test('calculates good status when within interval', () {
      final engine = HealthEngine(
        statuses: [],
        serviceRecords: [
          _createServiceRecord(
            1,
            1,
            8000,
            DateTime.now().subtract(const Duration(days: 30)),
          ),
        ],
        odometerLogs: [],
        rules: [_createRule(1, 1, 3000, 90)],
        componentTypes: [_createComponentType(1, 'Oli mesin', false)],
        currentOdometer: 10000, // 2000 km since service
      );

      final result = engine.calculateHealth(1);
      expect(result.status, equals('good'));
      expect(result.score, greaterThan(50));
    });

    test('calculates inspect status when near interval end', () {
      final engine = HealthEngine(
        statuses: [],
        serviceRecords: [
          _createServiceRecord(
            1,
            1,
            7500,
            DateTime.now().subtract(const Duration(days: 60)),
          ),
        ],
        odometerLogs: [],
        rules: [_createRule(1, 1, 3000, 90)],
        componentTypes: [_createComponentType(1, 'Oli mesin', false)],
        currentOdometer: 10400, // 2900 km since service (96% of 3000)
      );

      final result = engine.calculateHealth(1);
      expect(result.status, equals('inspect'));
      expect(result.score, lessThan(70));
    });

    test('calculates replace status when past interval', () {
      final engine = HealthEngine(
        statuses: [],
        serviceRecords: [
          _createServiceRecord(
            1,
            1,
            5000,
            DateTime.now().subtract(const Duration(days: 100)),
          ),
        ],
        odometerLogs: [],
        rules: [_createRule(1, 1, 3000, 90)],
        componentTypes: [_createComponentType(1, 'Oli mesin', false)],
        currentOdometer: 10000, // 5000 km since service
      );

      final result = engine.calculateHealth(1);
      expect(result.status, equals('replace'));
      expect(result.score, lessThan(50));
    });

    test('marks safety-critical components with warning', () {
      final engine = HealthEngine(
        statuses: [],
        serviceRecords: [
          _createServiceRecord(
            1,
            1,
            5000,
            DateTime.now().subtract(const Duration(days: 100)),
          ),
        ],
        odometerLogs: [],
        rules: [_createRule(1, 1, 3000, 90)],
        componentTypes: [
          _createComponentType(1, 'Rem', true),
        ], // safety critical
        currentOdometer: 10000,
      );

      final result = engine.calculateHealth(1);
      expect(result.status, equals('replace'));
      expect(result.explanation, contains('KESELAMATAN'));
    });

    test('calculates overall score as average', () {
      final engine = HealthEngine(
        statuses: [],
        serviceRecords: [
          _createServiceRecord(
            1,
            1,
            9000,
            DateTime.now().subtract(const Duration(days: 14)),
          ),
        ],
        odometerLogs: [],
        rules: [_createRule(1, 1, 3000, 90)],
        componentTypes: [_createComponentType(1, 'Oli mesin', false)],
        currentOdometer: 10000,
      );

      final overallScore = engine.calculateOverallScore();
      expect(overallScore, isNotNull);
      expect(overallScore, greaterThan(0));
      expect(overallScore, lessThanOrEqualTo(100));
    });

    test('handles heavy usage profile (jarak jauh)', () {
      final engine = HealthEngine(
        statuses: [],
        serviceRecords: [
          _createServiceRecord(
            1,
            1,
            8000,
            DateTime.now().subtract(const Duration(days: 20)),
          ),
        ],
        odometerLogs: [],
        rules: [_createRule(1, 1, 3000, 90)],
        componentTypes: [_createComponentType(1, 'Oli mesin', false)],
        currentOdometer: 10200, // 2200 km since service
        usageProfile: 'jarak_jauh',
      );

      // With 80% multiplier for jarak jauh: effective interval = 2400 km
      // 2200 / 2400 = 91.7% -> should trigger inspect or replace
      final result = engine.calculateHealth(1);
      expect(result.status, isIn(['inspect', 'replace']));
    });

    // ============================================================
    // TAHAP 02: EXTENDED HEALTH ENGINE TESTS (8 - 16)
    // ============================================================

    test('8. Komponen dengan aturan valid', () {
      final engine = HealthEngine(
        statuses: [],
        serviceRecords: [
          _createServiceRecord(
            1,
            1,
            10000,
            DateTime.now().subtract(const Duration(days: 15)),
          ),
        ],
        odometerLogs: [],
        rules: [_createRule(1, 1, 3000, 90)],
        componentTypes: [_createComponentType(1, 'Oli mesin', false)],
        currentOdometer: 11000, // 1000 km since service (33% of 3000)
      );

      final result = engine.calculateHealth(1);
      expect(result.status, equals('good'));
      expect(result.score, greaterThanOrEqualTo(70));
      expect(result.explanation, contains('Dalam kondisi baik'));
    });

    test('9. Komponen tanpa aturan menghasilkan status unknown', () {
      final engine = HealthEngine(
        statuses: [],
        serviceRecords: [_createServiceRecord(1, 1, 10000, DateTime.now())],
        odometerLogs: [],
        rules: [], // no rules
        componentTypes: [_createComponentType(1, 'Komponen Kustom', false)],
        currentOdometer: 10500,
      );

      final result = engine.calculateHealth(1);
      expect(result.status, equals('unknown'));
      expect(result.score, isNull);
    });

    test('10. Aturan spesifik model berbeda (Honda vs Yamaha)', () {
      final rules = [
        _createRule(1, 1, 3000, 90, modelId: 101), // Honda Vario 160: 3000 km
        _createRule(2, 1, 4000, 120, modelId: 202), // Yamaha NMAX: 4000 km
      ];
      final comp = _createComponentType(1, 'Oli mesin', false);

      final engineHonda = HealthEngine(
        statuses: [],
        serviceRecords: [_createServiceRecord(1, 1, 10000, DateTime.now())],
        odometerLogs: [],
        rules: rules,
        componentTypes: [comp],
        currentOdometer:
            13200, // 3200 km since service -> for Honda (3000km) this is replace
        motorcycleModelId: 101,
      );
      expect(engineHonda.calculateHealth(1).status, equals('replace'));

      final engineYamaha = HealthEngine(
        statuses: [],
        serviceRecords: [_createServiceRecord(2, 2, 10000, DateTime.now())],
        odometerLogs: [],
        rules: rules,
        componentTypes: [comp],
        currentOdometer:
            13200, // 3200 km since service -> for Yamaha (4000km) this is still inspect
        motorcycleModelId: 202,
      );
      expect(engineYamaha.calculateHealth(1).status, equals('inspect'));
    });

    test(
      '11. Penggantian oli hanya mengubah status oli (component isolation)',
      () {
        final oliType = _createComponentType(1, 'Oli mesin', false);
        final remType = _createComponentType(2, 'Kampas rem', true);

        final serviceRecord = _createServiceRecord(1, 1, 10000, DateTime.now());
        final serviceItemsWithRecords = [
          ServiceItemWithRecord(
            item: _createServiceItem(
              1,
              1,
              1,
              'replace',
            ), // ONLY replace oli mesin
            record: serviceRecord,
          ),
        ];

        final engine = HealthEngine(
          statuses: [],
          serviceRecords: [serviceRecord],
          odometerLogs: [],
          rules: [_createRule(1, 1, 3000, 90), _createRule(2, 2, 8000, 365)],
          componentTypes: [oliType, remType],
          currentOdometer: 10500,
          serviceItemsWithRecords: serviceItemsWithRecords,
        );

        final oliResult = engine.calculateHealth(1);
        final remResult = engine.calculateHealth(2);

        // Oli was serviced recently -> good
        expect(oliResult.status, equals('good'));
        // Rem was never replaced in history -> unknown (not reset by oli replacement)
        expect(remResult.status, equals('unknown'));
      },
    );

    test(
      '12. Tindakan inspect tidak mereset usia/interval penggantian komponen',
      () {
        final comp = _createComponentType(1, 'Oli mesin', false);
        final oldReplaceRecord = _createServiceRecord(
          1,
          1,
          10000,
          DateTime.now().subtract(const Duration(days: 90)),
        );
        final recentInspectRecord = _createServiceRecord(
          2,
          1,
          13200, // inspected at 13200 km
          DateTime.now().subtract(const Duration(days: 5)),
        );

        final serviceItems = [
          ServiceItemWithRecord(
            item: _createServiceItem(1, 1, 1, 'replace'),
            record: oldReplaceRecord,
          ),
          ServiceItemWithRecord(
            item: _createServiceItem(2, 2, 1, 'inspect'), // inspect action
            record: recentInspectRecord,
          ),
        ];

        final engine = HealthEngine(
          statuses: [],
          serviceRecords: [oldReplaceRecord, recentInspectRecord],
          odometerLogs: [],
          rules: [_createRule(1, 1, 3000, 90)],
          componentTypes: [comp],
          currentOdometer: 13300, // 3300 km since last replace!
          serviceItemsWithRecords: serviceItems,
        );

        final result = engine.calculateHealth(1);
        // Because inspection does NOT reset replacement cycle, status must be replace (> 3000 km)
        expect(result.status, equals('replace'));
      },
    );

    test('13. Interval kilometer dan interval waktu', () {
      final comp = _createComponentType(1, 'Aki', true);
      // Serviced 750 days ago (interval is 730 days) but low km
      final record = _createServiceRecord(
        1,
        1,
        5000,
        DateTime.now().subtract(const Duration(days: 750)),
      );

      final engine = HealthEngine(
        statuses: [],
        serviceRecords: [record],
        odometerLogs: [],
        rules: [_createRule(1, 1, 0, 730)], // time based
        componentTypes: [comp],
        currentOdometer: 5200,
      );

      final result = engine.calculateHealth(1);
      expect(result.status, equals('inspect'));
      expect(result.daysSinceService, greaterThanOrEqualTo(730));
    });

    test('14. Status mendekati batas (ratio >= 0.7 triggers inspect)', () {
      final comp = _createComponentType(1, 'Oli mesin', false);
      final record = _createServiceRecord(1, 1, 10000, DateTime.now());

      final engine = HealthEngine(
        statuses: [],
        serviceRecords: [record],
        odometerLogs: [],
        rules: [_createRule(1, 1, 3000, 90)],
        componentTypes: [comp],
        currentOdometer: 12300, // 2300 km / 3000 km = 76.6%
      );

      final result = engine.calculateHealth(1);
      expect(result.status, equals('inspect'));
    });

    test('15. Status melewati batas (ratio >= 1.0 triggers replace)', () {
      final comp = _createComponentType(1, 'Oli mesin', false);
      final record = _createServiceRecord(1, 1, 10000, DateTime.now());

      final engine = HealthEngine(
        statuses: [],
        serviceRecords: [record],
        odometerLogs: [],
        rules: [_createRule(1, 1, 3000, 90)],
        componentTypes: [comp],
        currentOdometer: 13500, // 3500 km / 3000 km = 116.6%
      );

      final result = engine.calculateHealth(1);
      expect(result.status, equals('replace'));
    });

    test('16. Perubahan motor aktif tidak mencampur hasil perhitungan', () {
      final comp = _createComponentType(1, 'Oli mesin', false);
      final rules = [_createRule(1, 1, 3000, 90)];

      final motor1Record = _createServiceRecord(1, 1, 10000, DateTime.now());
      final motor2Record = _createServiceRecord(2, 2, 50000, DateTime.now());

      final engine1 = HealthEngine(
        statuses: [],
        serviceRecords: [motor1Record],
        odometerLogs: [],
        rules: rules,
        componentTypes: [comp],
        currentOdometer: 10500, // 500 km since service -> good
      );

      final engine2 = HealthEngine(
        statuses: [],
        serviceRecords: [motor2Record],
        odometerLogs: [],
        rules: rules,
        componentTypes: [comp],
        currentOdometer: 54000, // 4000 km since service -> replace
      );

      expect(engine1.calculateHealth(1).status, equals('good'));
      expect(engine2.calculateHealth(1).status, equals('replace'));
    });

    test(
      '17. Keluhan aktif menurunkan status komponen menjadi inspect dan menurunkan skor',
      () {
        final cvtComp = _createComponentType(7, 'CVT', false);
        final oliComp = _createComponentType(1, 'Oli mesin', false);
        final rules = [
          _createRule(1, 1, 3000, 90),
          _createRule(2, 7, 8000, 365),
        ];

        final activeComplaint = Complaint(
          id: 1,
          motorcycleId: 1,
          title: 'Tarikan awal gredek',
          description: 'Saat gas awal dari berhenti terasa getar gredek',
          status: 'dianalisis',
          odometerKm: 10500,
          openedAt: DateTime.now(),
          updatedAt: DateTime.now(),
          closedAt: null,
          resolvedByServiceId: null,
        );

        final engine = HealthEngine(
          statuses: [],
          serviceRecords: [_createServiceRecord(1, 1, 10000, DateTime.now())],
          odometerLogs: [],
          rules: rules,
          componentTypes: [oliComp, cvtComp],
          currentOdometer: 10500,
          complaints: [activeComplaint],
        );

        final cvtResult = engine.calculateHealth(7);
        final oliResult = engine.calculateHealth(1);

        expect(cvtResult.status, equals('inspect'));
        expect(cvtResult.score, lessThanOrEqualTo(65));
        expect(cvtResult.explanation, contains('Keluhan aktif'));
        expect(oliResult.status, equals('good'));
      },
    );

    test('18. Keluhan kritis keselamatan langsung memicu status replace', () {
      final remComp = _createComponentType(2, 'Kampas rem', true);
      final rules = [_createRule(1, 2, 8000, 365)];

      final criticalComplaint = Complaint(
        id: 2,
        motorcycleId: 1,
        title: 'Rem blong',
        description: 'Rem blong saat turunan tidak pakem sama sekali',
        status: 'dianalisis',
        odometerKm: 10500,
        openedAt: DateTime.now(),
        updatedAt: DateTime.now(),
        closedAt: null,
        resolvedByServiceId: null,
      );

      final engine = HealthEngine(
        statuses: [],
        serviceRecords: [_createServiceRecord(1, 1, 10000, DateTime.now())],
        odometerLogs: [],
        rules: rules,
        componentTypes: [remComp],
        currentOdometer: 10500,
        complaints: [criticalComplaint],
      );

      final remResult = engine.calculateHealth(2);
      expect(remResult.status, equals('replace'));
      expect(remResult.score, lessThanOrEqualTo(40));
      expect(remResult.explanation, contains('KELUHAN KRITIS'));
    });
  });
}

ComponentType _createComponentType(int id, String name, bool safetyCritical) {
  return ComponentType(
    id: id,
    name: name,
    category: 'test',
    safetyCritical: safetyCritical,
    appliesTo: null,
  );
}

MaintenanceRule _createRule(
  int id,
  int componentTypeId,
  double intervalKm,
  int intervalDays, {
  int? modelId,
}) {
  return MaintenanceRule(
    id: id,
    modelId: modelId,
    componentTypeId: componentTypeId,
    intervalKm: intervalKm,
    intervalDays: intervalDays,
    severeUseRule: null,
    sourceUrl: null,
    ruleVersion: 'v1',
    verifiedAt: null,
  );
}

ServiceItem _createServiceItem(
  int id,
  int serviceRecordId,
  int componentTypeId,
  String action,
) {
  return ServiceItem(
    id: id,
    serviceRecordId: serviceRecordId,
    componentTypeId: componentTypeId,
    action: action,
    partsCost: 0,
    laborCost: 0,
    totalCost: 0,
  );
}

ServiceRecord _createServiceRecord(
  int id,
  int motorcycleId,
  double odometer,
  DateTime date,
) {
  return ServiceRecord(
    id: id,
    motorcycleId: motorcycleId,
    servicedAt: date,
    odometerKm: odometer,
    workshopName: 'Test Workshop',
    notes: null,
    totalCost: 0,
    createdAt: date,
  );
}
