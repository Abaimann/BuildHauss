import '../database/app_database.dart';

/// Health engine calculates component health status based on:
/// - Last service record (replace action resets the component cycle)
/// - Maintenance rules (interval_km, interval_days)
/// - Odometer readings
/// - Usage profile
///
/// Returns estimated status, score (0-100), and explanation.
/// Status can be: 'good', 'inspect', 'replace', 'unknown'
class HealthEngine {
  final List<ComponentStatus> statuses;
  final List<ServiceRecord> _serviceRecords;
  final List<OdometerLog> odometerLogs;
  final List<MaintenanceRule> _rules;
  final List<ComponentType> _componentTypes;
  final double? _currentOdometer;
  final String _usageProfile;

  HealthEngine({
    required this.statuses,
    required List<ServiceRecord> serviceRecords,
    required this.odometerLogs,
    required List<MaintenanceRule> rules,
    required List<ComponentType> componentTypes,
    double? currentOdometer,
    String usageProfile = 'campuran',
  }) : _serviceRecords = serviceRecords,
       _rules = rules,
       _componentTypes = componentTypes,
       _currentOdometer = currentOdometer,
       _usageProfile = usageProfile;

  /// Calculate health for a specific component type.
  ComponentHealthResult calculateHealth(int componentTypeId) {
    // Find applicable rules
    final rules = _rules
        .where((r) => r.componentTypeId == componentTypeId)
        .toList();
    if (rules.isEmpty) {
      return ComponentHealthResult(
        status: 'unknown',
        score: null,
        explanation: 'Belum ada data aturan untuk komponen ini.',
        confidence: null,
      );
    }

    // Find last replacement/inspection for this component
    final relevantServices = _serviceRecords
        .where((s) => s.odometerKm != null)
        .toList();
    if (relevantServices.isEmpty) {
      return ComponentHealthResult(
        status: 'unknown',
        score: null,
        explanation: 'Belum ada data servis. Periksa komponen secara visuelle.',
        confidence: null,
      );
    }

    // Sort by date descending
    relevantServices.sort((a, b) => b.servicedAt.compareTo(a.servicedAt));
    final latestService = relevantServices.first;
    final latestOdo = latestService.odometerKm!;

    // Calculate km since last service
    final kmSinceService = (_currentOdometer ?? latestOdo) - latestOdo;

    // Use the most specific rule (model-specific over generic)
    final rule = rules.firstWhere(
      (r) => r.modelId != null,
      orElse: () => rules.first,
    );

    final intervalKm = rule.intervalKm;
    final intervalDays = rule.intervalDays;

    // Calculate days since service
    final daysSinceService = DateTime.now()
        .difference(latestService.servicedAt)
        .inDays;

    if (intervalKm == null && intervalDays == null) {
      return ComponentHealthResult(
        status: 'unknown',
        score: null,
        explanation: 'Tidak ada interval yang tervalidasi untuk komponen ini.',
        confidence: 'low',
      );
    }

    // Determine status
    String status;
    int score;
    String explanation;

    if (intervalKm != null) {
      final usageMultiplier = _usageProfile == 'jarak_jauh' ? 0.8 : 1.0;
      final effectiveInterval = intervalKm * usageMultiplier;
      final ratio = kmSinceService / effectiveInterval;

      if (ratio >= 1.0) {
        status = 'replace';
        score = ((1 - (ratio - 1).clamp(0, 0.5)) * 40).round();
        explanation =
            'Sudah ${kmSinceService.toStringAsFixed(0)} km sejak servis. Interval rekomendasi ${effectiveInterval.toStringAsFixed(0)} km.';
      } else if (ratio >= 0.7) {
        status = 'inspect';
        score = ((1 - ratio) * 30 + 60).round();
        explanation =
            '${kmSinceService.toStringAsFixed(0)} km dari ${effectiveInterval.toStringAsFixed(0)} km. Segera periksa.';
      } else {
        status = 'good';
        score = ((1 - ratio) * 40 + 60).round().clamp(0, 100);
        explanation =
            'Dalam kondisi baik. Sudah ${kmSinceService.toStringAsFixed(0)} km dari ${effectiveInterval.toStringAsFixed(0)} km.';
      }
    } else {
      // Time-based only
      if (intervalDays != null && daysSinceService >= intervalDays) {
        status = 'inspect';
        score = 55;
        explanation =
            'Perlu diperiksa. Sudah $daysSinceService hari sejak servis terakhir.';
      } else {
        status = 'good';
        score = 75;
        explanation = 'Dalam kondisi baik.';
      }
    }

    // Safety override
    final component = _componentTypes
        .where((c) => c.id == componentTypeId)
        .firstOrNull;
    if (component?.safetyCritical == true && score < 50) {
      status = 'replace';
      explanation = '⚠️ Komponen KESELAMATAN. $explanation';
    }

    return ComponentHealthResult(
      status: status,
      score: score.clamp(0, 100),
      explanation: explanation,
      confidence: _serviceRecords.length >= 3 ? 'high' : 'medium',
      kmSinceService: kmSinceService,
      intervalKm: intervalKm,
      daysSinceService: daysSinceService,
      intervalDays: intervalDays,
    );
  }

  /// Calculate overall health score as average of component scores
  double? calculateOverallScore() {
    final results = _componentTypes
        .map((ct) => calculateHealth(ct.id))
        .toList();
    final validScores = results
        .where((r) => r.score != null)
        .map((r) => r.score!)
        .toList();
    if (validScores.isEmpty) return null;
    return validScores.reduce((a, b) => a + b) / validScores.length;
  }
}

class ComponentHealthResult {
  final String status; // 'good', 'inspect', 'replace', 'unknown'
  final int? score; // 0-100
  final String explanation;
  final String? confidence; // 'low', 'medium', 'high'
  final double? kmSinceService;
  final double? intervalKm;
  final int? daysSinceService;
  final int? intervalDays;

  ComponentHealthResult({
    required this.status,
    this.score,
    required this.explanation,
    this.confidence,
    this.kmSinceService,
    this.intervalKm,
    this.daysSinceService,
    this.intervalDays,
  });

  bool get needsInspection => status == 'inspect';
  bool get needsReplacement => status == 'replace';
  bool get isUnknown => status == 'unknown';
}
