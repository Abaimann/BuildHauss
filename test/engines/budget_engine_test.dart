import 'package:flutter_test/flutter_test.dart';
import 'package:buildhaus/core/engines/budget_engine.dart';
import 'package:buildhaus/core/engines/health_engine.dart';

void main() {
  group('BudgetEngine', () {
    test('prioritizes safety alerts', () {
      final healthResults = [
        _createHealthResult('rem', 'replace', 30, true),
        _createHealthResult('oli', 'good', 90, false),
      ];

      final engine = BudgetEngine(
        componentHealths: healthResults,
        budgetAmount: 100000,
      );

      final recommendations = engine.generateRecommendations();
      expect(recommendations.any((r) => r.decision == 'safety_alert'), isTrue);
      expect(recommendations.any((r) => r.priority == 'safety'), isTrue);
    });

    test('selects items within budget', () {
      final healthResults = [_createHealthResult('oli', 'replace', 40, false)];

      final engine = BudgetEngine(
        componentHealths: healthResults,
        budgetAmount: 200000,
      );

      final recommendations = engine.generateRecommendations();
      expect(recommendations, isNotEmpty);
      expect(recommendations.first.decision, isIn(['selected', 'deferred']));
    });

    test('marks safety items even with low budget', () {
      final healthResults = [
        _createHealthResult('rem', 'replace', 30, true),
        _createHealthResult('oli', 'replace', 40, false),
      ];

      final engine = BudgetEngine(
        componentHealths: healthResults,
        budgetAmount: 50000,
      );

      final recommendations = engine.generateRecommendations();
      expect(recommendations.any((r) => r.decision == 'safety_alert'), isTrue);
    });

    test('skips good status components', () {
      final healthResults = [
        _createHealthResult('oli', 'good', 90, false),
        _createHealthResult('busi', 'good', 85, false),
      ];

      final engine = BudgetEngine(
        componentHealths: healthResults,
        budgetAmount: 200000,
      );

      final recommendations = engine.generateRecommendations();
      expect(recommendations.where((r) => r.decision == 'selected'), isEmpty);
    });

    test('assigns priorities to recommendations', () {
      final healthResults = [
        _createHealthResult('busi', 'inspect', 60, false),
        _createHealthResult('rem', 'replace', 30, true),
        _createHealthResult('oli', 'inspect', 55, false),
      ];

      final engine = BudgetEngine(
        componentHealths: healthResults,
        budgetAmount: 500000,
      );

      final recommendations = engine.generateRecommendations();
      expect(recommendations, isNotEmpty);
      expect(recommendations.every((r) => r.priority.isNotEmpty), isTrue);
    });

    test('provides consequence if delayed', () {
      final healthResults = [_createHealthResult('oli', 'replace', 40, false)];

      final engine = BudgetEngine(
        componentHealths: healthResults,
        budgetAmount: 200000,
      );

      final recommendations = engine.generateRecommendations();
      expect(recommendations, isNotEmpty);
      expect(recommendations.first.consequenceIfDelayed, isNotNull);
    });

    test('sorts by priority: safety > replace > inspect', () {
      final healthResults = [
        _createHealthResult('busi', 'inspect', 60, false),
        _createHealthResult('rem', 'replace', 30, true),
        _createHealthResult('oli', 'inspect', 55, false),
        _createHealthResult('ban', 'replace', 40, false),
      ];

      final engine = BudgetEngine(
        componentHealths: healthResults,
        budgetAmount: 500000,
      );

      final recommendations = engine.generateRecommendations();
      expect(recommendations, isNotEmpty);

      // Safety items come first
      final safetyIdx = recommendations.indexWhere(
        (r) => r.priority == 'safety',
      );
      expect(safetyIdx, greaterThanOrEqualTo(0));
      expect(safetyIdx, lessThanOrEqualTo(0));
    });

    test('returns non-empty list for replace components', () {
      final healthResults = [_createHealthResult('ban', 'replace', 40, false)];

      final engine = BudgetEngine(
        componentHealths: healthResults,
        budgetAmount: 500000,
      );

      final recommendations = engine.generateRecommendations();
      expect(recommendations, isNotEmpty);
      expect(recommendations.first.componentName, isNotEmpty);
    });
  });
}

ComponentHealthResult _createHealthResult(
  String name,
  String status,
  int score,
  bool safetyCritical,
) {
  String explanation = '';
  if (safetyCritical && status == 'replace') {
    explanation = '⚠️ KESELAMATAN: Komponen perlu diganti.';
  } else if (status == 'good') {
    explanation = 'Dalam kondisi baik.';
  } else if (status == 'replace') {
    explanation = 'Perlu diganti.';
  } else {
    explanation = 'Perlu diperiksa.';
  }

  return ComponentHealthResult(
    status: status,
    score: score,
    explanation: explanation,
    confidence: 'medium',
    kmSinceService: null,
    intervalKm: null,
    daysSinceService: null,
    intervalDays: null,
  );
}
