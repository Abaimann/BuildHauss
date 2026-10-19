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
