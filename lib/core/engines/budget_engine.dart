import '../database/app_database.dart';
import 'health_engine.dart';

/// Budget service advisor engine.
/// Recommends service priorities based on:
/// - Safety critical components
/// - Health engine results
/// - User's budget
/// - Component costs
/// 
/// Priority order:
/// 1. Safety-critical components needing attention
/// 2. High-urgency components (within 20% of service interval)
/// 3. Medium-urgency components
/// 4. Low-urgency / deferred items
class BudgetEngine {
  final List<ComponentHealthResult> _componentHealths;
  final int _budgetAmount;
  final Map<String, int> _componentCostEstimates;

  BudgetEngine({
    required List<ComponentHealthResult> componentHealths,
    required int budgetAmount,
    Map<String, int>? componentCostEstimates,
  })  : _componentHealths = componentHealths,
        _budgetAmount = budgetAmount,
        _componentCostEstimates = componentCostEstimates ?? _defaultCosts;

  static const _defaultCosts = {
    'oli_mesin': 75000,
    'kampas_rem': 120000,
    'aki': 250000,
    'ban': 350000,
    'filter_udara': 65000,
    'busi': 45000,
    'cvt': 200000,
    'knalpot': 500000,
  };

  /// Generate prioritized recommendations within budget
  List<BudgetRecommendation> generateRecommendations() {
    final results = <BudgetRecommendation>[];
    var remainingBudget = _budgetAmount;

    // Sort by priority: safety > replace > inspect
    final sorted = [..._componentHealths]..sort((a, b) {
      final aP = _priority(a);
      final bP = _priority(b);
      return aP.compareTo(bP);
    });

    for (final health in sorted) {
      final componentName = _getComponentName(health);
      final cost = _componentCostEstimates[componentName] ?? 100000;
      final decision = _determineDecision(health, remainingBudget);

      if (decision == 'safety_alert') {
        results.add(BudgetRecommendation(
          componentName: componentName,
          priority: 'safety',
          decision: decision,
          estimatedCost: cost,
          reason: '⚠️ Komponen keselamatan memerlukan perhatian segera.',
          consequenceIfDelayed: 'Risiko kecelakaan jika ditunda.',
          requiresInspection: true,
        ));
      } else if (decision == 'selected') {
        if (remainingBudget >= cost) {
          results.add(BudgetRecommendation(
            componentName: componentName,
            priority: health.score != null && health.score! < 50 ? 'high' : 'medium',
            decision: decision,
            estimatedCost: cost,
            reason: 'Dalam anggaran dan perlu perhatian.',
            consequenceIfDelayed: 'Kondisi bisa memburuk jika ditunda.',
            requiresInspection: health.needsInspection,
          ));
          remainingBudget -= cost;
        } else {
          results.add(BudgetRecommendation(
            componentName: componentName,
            priority: 'medium',
            decision: 'deferred',
            estimatedCost: cost,
            reason: 'Diperlukan tapi budget tidak mencukupi.',
            consequenceIfDelayed: 'Butuh tabungan tambahan.',
            requiresInspection: true,
          ));
        }
      }
      // Skip items that are 'good' status
    }

    return results;
  }

  int _priority(ComponentHealthResult health) {
    if (health.needsReplacement && health.status == 'replace') return 0;
    if (health.needsInspection) return 1;
    if (health.score != null && health.score! < 50) return 2;
    return 3;
  }

  String _determineDecision(ComponentHealthResult health, int remainingBudget) {
    if (health.status == 'replace' || health.status == 'inspect') {
      if (health.needsReplacement) {
        // Safety critical check
        if (health.explanation.contains('KESELAMATAN')) {
          return 'safety_alert';
        }
      }
      return remainingBudget > 0 ? 'selected' : 'deferred';
    }
    return 'skip';
  }

  String _getComponentName(ComponentHealthResult health) {
    // This would normally look up the component type name
    return health.explanation.split(' ').first.toLowerCase();
  }
}

class BudgetRecommendation {
  final String componentName;
  final String priority; // 'safety', 'high', 'medium', 'low'
  final String decision; // 'selected', 'deferred', 'safety_alert', 'inspect'
  final int estimatedCost;
  final String reason;
  final String? consequenceIfDelayed;
  final bool requiresInspection;

  BudgetRecommendation({
    required this.componentName,
    required this.priority,
    required this.decision,
    required this.estimatedCost,
    required this.reason,
    this.consequenceIfDelayed,
    this.requiresInspection = false,
  });
}
