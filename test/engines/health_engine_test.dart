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
  int intervalDays,
) {
  return MaintenanceRule(
    id: id,
    modelId: null,
    componentTypeId: componentTypeId,
    intervalKm: intervalKm,
    intervalDays: intervalDays,
    severeUseRule: null,
    sourceUrl: null,
    ruleVersion: 'v1',
    verifiedAt: null,
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
