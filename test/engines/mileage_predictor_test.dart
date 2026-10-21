import 'package:flutter_test/flutter_test.dart';
import 'package:buildhaus/core/engines/mileage_predictor.dart';
import 'package:buildhaus/core/database/app_database.dart';

void main() {
  group('MileagePredictor', () {
    test('returns null for empty logs', () {
      final predictor = MileagePredictor([]);
      expect(predictor.kmPerDay, isNull);
      expect(predictor.hasEnoughData, isFalse);
    });

    test('returns null for single log', () {
      final logs = [_createOdometerLog(10000, DateTime(2026, 1, 1))];
      final predictor = MileagePredictor(logs);
      expect(predictor.kmPerDay, isNull);
      expect(predictor.hasEnoughData, isFalse);
    });

    test('calculates km/day for two logs', () {
      final logs = [
        _createOdometerLog(10000, DateTime(2026, 1, 1)),
        _createOdometerLog(10070, DateTime(2026, 1, 8)), // 70 km in 7 days
      ];
      final predictor = MileagePredictor(logs);
      expect(predictor.kmPerDay, closeTo(10.0, 0.1));
      expect(predictor.hasEnoughData, isTrue);
    });

    test('calculates weighted average for multiple logs', () {
      final logs = [
        _createOdometerLog(10000, DateTime(2026, 1, 1)),
        _createOdometerLog(
          10050,
          DateTime(2026, 1, 8),
        ), // 50 km / 7 days = 7.14 km/day
        _createOdometerLog(
          10120,
          DateTime(2026, 1, 22),
        ), // 70 km / 14 days = 5 km/day
      ];
      final predictor = MileagePredictor(logs);
      // Weighted by recency: later intervals get more weight
      expect(predictor.kmPerDay, isNotNull);
      expect(predictor.kmPerDay, greaterThan(0));
    });

    test('calculates weekly estimate', () {
      final logs = [
        _createOdometerLog(10000, DateTime(2026, 1, 1)),
        _createOdometerLog(
          10100,
          DateTime(2026, 1, 8),
        ), // 100 km / 7 days = ~14.3 km/day
      ];
      final predictor = MileagePredictor(logs);
      expect(predictor.kmPerWeek, closeTo(100.0, 1.0));
    });

    test('calculates monthly estimate', () {
      final logs = [
        _createOdometerLog(10000, DateTime(2026, 1, 1)),
        _createOdometerLog(
          10070,
          DateTime(2026, 1, 8),
        ), // 70 km / 7 days = 10 km/day
      ];
      final predictor = MileagePredictor(logs);
      expect(predictor.kmPerMonth, closeTo(300.0, 1.0));
    });

    test('handles negative distance gracefully', () {
      final logs = [
        _createOdometerLog(10000, DateTime(2026, 1, 1)),
        _createOdometerLog(9000, DateTime(2026, 1, 8)), // odometer reset
      ];
      final predictor = MileagePredictor(logs);
      // Should not crash, may return null or handle gracefully
      expect(predictor.kmPerDay ?? 0.0, greaterThanOrEqualTo(0.0));
    });

    test('confidence is low for 2 logs', () {
      final logs = [
        _createOdometerLog(10000, DateTime(2026, 1, 1)),
        _createOdometerLog(10050, DateTime(2026, 1, 8)),
      ];
      final predictor = MileagePredictor(logs);
      expect(predictor.confidence, isIn(['low', 'medium']));
    });

    test('confidence is medium for 3-4 logs', () {
      final logs = [
        _createOdometerLog(10000, DateTime(2026, 1, 1)),
        _createOdometerLog(10050, DateTime(2026, 1, 8)),
        _createOdometerLog(10100, DateTime(2026, 1, 15)),
      ];
      final predictor = MileagePredictor(logs);
      expect(predictor.confidence, equals('medium'));
    });

    test('confidence is high for 5+ logs', () {
      final logs = List.generate(
        5,
        (i) =>
            _createOdometerLog(10000.0 + i * 50, DateTime(2026, 1, 1 + i * 7)),
      );
      final predictor = MileagePredictor(logs);
      expect(predictor.confidence, equals('high'));
    });

    test('predictDateForOdometer works correctly', () {
      final logs = [
        _createOdometerLog(10000, DateTime(2026, 1, 1)),
        _createOdometerLog(
          10100,
          DateTime(2026, 1, 8),
        ), // 100 km / 7 days = ~14.3 km/day
      ];
      final predictor = MileagePredictor(logs);
      final predictedDate = predictor.predictDateForOdometer(
        10100,
        101400,
      ); // 1300 km remaining

      expect(predictedDate, isNotNull);
      // ~1300 / 14.3 = ~91 days from Jan 8
      expect(
        predictedDate!.difference(DateTime(2026, 1, 8)).inDays,
        greaterThan(80),
      );
    });

    test('predictDateForOdometer returns now if already past target', () {
      final logs = [
        _createOdometerLog(10000, DateTime(2026, 1, 1)),
        _createOdometerLog(10100, DateTime(2026, 1, 8)),
      ];
      final predictor = MileagePredictor(logs);
      final predictedDate = predictor.predictDateForOdometer(10100, 9000);

      expect(predictedDate, isNotNull);
      // When target already passed, should return now or very recent (within 2 seconds)
      expect(
        DateTime.now().difference(predictedDate!).inSeconds.abs() <= 2,
        isTrue,
      );
    });

    // ============================================================
    // TAHAP 02: 3-MONTHLY PERIODS & RECALIBRATION TESTS
    // ============================================================

    test('1. Data belum mencapai tiga periode (learning phase active)', () {
      // 3 readings on same week / 1 month span
      final logs = [
        _createOdometerLog(10000, DateTime(2026, 1, 1)),
        _createOdometerLog(10050, DateTime(2026, 1, 8)),
        _createOdometerLog(10100, DateTime(2026, 1, 15)),
      ];
      final predictor = MileagePredictor(logs);
      expect(predictor.validMonthlyPeriodsCount, lessThan(3));
      expect(predictor.isLearningPhase, isTrue);
      expect(predictor.hasCompletedThreeMonthlyPeriods, isFalse);
      expect(predictor.learningStatusMessage, contains('periode bulanan'));
    });

    test('2. Tepat tiga periode valid (learning phase complete)', () {
      // Readings spanning across 3 distinct monthly checkpoints (~90 days)
      final logs = [
        _createOdometerLog(10000, DateTime(2026, 1, 1)),
        _createOdometerLog(10300, DateTime(2026, 1, 31)), // +30 days (period 1)
        _createOdometerLog(10650, DateTime(2026, 3, 2)), // +30 days (period 2)
        _createOdometerLog(11000, DateTime(2026, 4, 1)), // +30 days (period 3)
      ];
      final predictor = MileagePredictor(logs);
      expect(predictor.validMonthlyPeriodsCount, equals(3));
      expect(predictor.hasCompletedThreeMonthlyPeriods, isTrue);
      expect(predictor.isLearningPhase, isFalse);
      expect(predictor.learningStatusMessage, contains('selesai'));
      expect(predictor.kmPerDay, isNotNull);
      expect(predictor.kmPerDay!, greaterThan(0));
    });

    test('3. Pembacaan pada tanggal dan detik yang sama', () {
      final now = DateTime(2026, 1, 1, 10, 0, 0);
      final logs = [
        _createOdometerLog(10000, now),
        _createOdometerLog(10020, now), // same second
        _createOdometerLog(10100, now.add(const Duration(days: 7))),
      ];
      final predictor = MileagePredictor(logs);
      expect(predictor.kmPerDay, isNotNull);
      expect(predictor.kmPerDay!, closeTo(11.42, 0.5));
    });

    test('4. Data kilometer menurun (rollback/typo handled gracefully)', () {
      final logs = [
        _createOdometerLog(10000, DateTime(2026, 1, 1)),
        _createOdometerLog(10100, DateTime(2026, 1, 10)),
        _createOdometerLog(9500, DateTime(2026, 1, 20)), // decreased
        _createOdometerLog(10200, DateTime(2026, 1, 30)),
      ];
      final predictor = MileagePredictor(logs);
      expect(predictor.kmPerDay, isNotNull);
      expect(predictor.kmPerDay!, greaterThanOrEqualTo(0));
    });

    test('5. Koreksi odometer aktual', () {
      final logs = [
        _createOdometerLog(10000, DateTime(2026, 1, 1)),
        _createOdometerLog(10500, DateTime(2026, 2, 1)),
      ];
      final predictor = MileagePredictor(logs);
      expect(predictor.latestActualOdometer, equals(10500.0));
      expect(predictor.baselineReading?.odometerKm, equals(10000.0));
    });

    test('6. Motor dengan pemakaian rendah (low usage)', () {
      // Driven only 20 km over 40 days (~0.5 km/day)
      final logs = [
        _createOdometerLog(5000, DateTime(2026, 1, 1)),
        _createOdometerLog(5020, DateTime(2026, 2, 10)),
      ];
      final predictor = MileagePredictor(logs);
      expect(predictor.kmPerDay, closeTo(0.5, 0.05));
      expect(predictor.kmPerWeek, closeTo(3.5, 0.5));
    });

    test(
      '7. Estimasi setelah pembacaan baru (recalibration with recency weight)',
      () {
        final logsInitial = [
          _createOdometerLog(10000, DateTime(2026, 1, 1)),
          _createOdometerLog(10070, DateTime(2026, 1, 8)), // 10 km/day
        ];
        final p1 = MileagePredictor(logsInitial);

        // User suddenly rides 40 km/day in the latest interval
        final logsUpdated = [
          ...logsInitial,
          _createOdometerLog(
            10350,
            DateTime(2026, 1, 15),
          ), // 280 km in 7 days = 40 km/day
        ];
        final p2 = MileagePredictor(logsUpdated);

        expect(p2.kmPerDay!, greaterThan(p1.kmPerDay!));
        expect(
          p2.estimateOdometerAt(DateTime(2026, 1, 22)),
          greaterThan(10350),
        );
      },
    );
  });
}

OdometerLog _createOdometerLog(double km, DateTime date) {
  return OdometerLog(
    id: 1,
    motorcycleId: 1,
    odometerKm: km,
    recordedAt: date,
    source: 'manual',
    note: null,
  );
}
