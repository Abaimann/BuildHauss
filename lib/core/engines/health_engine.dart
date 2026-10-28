import '../database/app_database.dart';
import 'self_inspection_engine.dart';

/// Health calculation engine for BuildHaus.
///
/// Features:
/// - Evaluates component health deterministically using verified maintenance rules.
/// - Distinguishes model-specific rules from generic fallback rules (Honda rules are never applied to Yamaha).
/// - Ensures component isolation: Servicing Component A does NOT reset the interval cycle of Component B.
/// - Distinguishes service actions: 'replace' resets the cycle, whereas 'inspect' documents inspection without resetting mileage interval.
/// - Incorporates calendar days elapsed, usage profiles (e.g. jarak jauh), and self-inspection findings.
/// - Provides transparent, honest explanations without claiming to measure physical wear directly.
class HealthEngine {
  final List<ComponentStatus> statuses;
  final List<ServiceRecord> _serviceRecords;
  final List<OdometerLog> odometerLogs;
  final List<MaintenanceRule> _rules;
  final List<ComponentType> _componentTypes;
  final double? _currentOdometer;
  final String _usageProfile;
  final List<ServiceItemWithRecord>? _serviceItemsWithRecords;
  final int? _motorcycleModelId;
  final List<InspectionFinding>? _inspectionFindings;
  final List<Complaint>? complaints;

  HealthEngine({
    required this.statuses,
    required List<ServiceRecord> serviceRecords,
    required this.odometerLogs,
    required List<MaintenanceRule> rules,
    required List<ComponentType> componentTypes,
    double? currentOdometer,
    String usageProfile = 'campuran',
    List<ServiceItemWithRecord>? serviceItemsWithRecords,
    int? motorcycleModelId,
    List<InspectionFinding>? inspectionFindings,
    this.complaints,
  }) : _serviceRecords = serviceRecords,
       _rules = rules,
       _componentTypes = componentTypes,
       _currentOdometer = currentOdometer,
       _usageProfile = usageProfile,
       _serviceItemsWithRecords = serviceItemsWithRecords,
       _motorcycleModelId = motorcycleModelId,
       _inspectionFindings = inspectionFindings;

  /// Calculate health for a specific component type.
  ComponentHealthResult calculateHealth(int componentTypeId) {
    // 1. Find applicable rules for this component type
    final matchingRules = _rules
        .where((r) => r.componentTypeId == componentTypeId)
        .toList();

    if (matchingRules.isEmpty) {
      return ComponentHealthResult(
        status: 'unknown',
        score: null,
        explanation: 'Belum ada data aturan perawatan untuk komponen ini.',
        confidence: null,
      );
    }

    // Prioritize model-specific rule over generic rule.
    // If active model is set, reject rules with a different modelId.
    MaintenanceRule? selectedRule;
    if (_motorcycleModelId != null) {
      selectedRule = matchingRules
          .where((r) => r.modelId == _motorcycleModelId)
          .firstOrNull;
    }

    // Fall back to generic rule (modelId == null)
    selectedRule ??= matchingRules.where((r) => r.modelId == null).firstOrNull;

    // If still not found (e.g. test environment without modelId set, or fallback)
    selectedRule ??= matchingRules.firstWhere(
      (r) => r.modelId != null,
      orElse: () => matchingRules.first,
    );

    final intervalKm = selectedRule.intervalKm;
    final intervalDays = selectedRule.intervalDays;

    if (intervalKm == null && intervalDays == null) {
      return ComponentHealthResult(
        status: 'unknown',
        score: null,
        explanation: 'Tidak ada interval kilometer atau hari yang tervalidasi.',
        confidence: 'low',
      );
    }

    // 2. Component isolation in service history:
    // Determine the baseline service event that reset this specific component's cycle.
    DateTime? baselineServiceDate;
    double? baselineServiceOdo;
    DateTime? lastInspectionDate;

    if (_serviceItemsWithRecords != null &&
        _serviceItemsWithRecords.isNotEmpty) {
      // Isolate by componentTypeId
      final componentHistory =
          _serviceItemsWithRecords
              .where((entry) => entry.item.componentTypeId == componentTypeId)
              .toList()
            ..sort(
              (a, b) => b.record.servicedAt.compareTo(a.record.servicedAt),
            );

      if (componentHistory.isEmpty) {
        return _buildUnknownResult(
          componentTypeId: componentTypeId,
          intervalKm: intervalKm,
          intervalDays: intervalDays,
        );
      }

      // Check for 'replace' action (which resets the wear cycle)
      final replacements = componentHistory
          .where((entry) => entry.item.action == 'replace')
          .toList();

      if (replacements.isNotEmpty) {
        final lastReplace = replacements.first;
        baselineServiceDate = lastReplace.record.servicedAt;
        baselineServiceOdo = lastReplace.record.odometerKm;
      } else {
        // Only inspect or clean was performed; baseline defaults to first recorded service or initial odo
        final firstRecord = componentHistory.last;
        baselineServiceDate = firstRecord.record.servicedAt;
        baselineServiceOdo = firstRecord.record.odometerKm;
      }

      // Track most recent inspection
      final inspections = componentHistory
          .where((entry) => entry.item.action == 'inspect')
          .toList();
      if (inspections.isNotEmpty) {
        lastInspectionDate = inspections.first.record.servicedAt;
      }
    } else {
      // Fallback to legacy _serviceRecords for tests and backward compatibility
      final relevantServices = _serviceRecords
          .where((s) => s.odometerKm != null)
          .toList();

      if (relevantServices.isEmpty) {
        return _buildUnknownResult(
          componentTypeId: componentTypeId,
          intervalKm: intervalKm,
          intervalDays: intervalDays,
        );
      }

      relevantServices.sort((a, b) => b.servicedAt.compareTo(a.servicedAt));
      final latest = relevantServices.first;
      baselineServiceDate = latest.servicedAt;
      baselineServiceOdo = latest.odometerKm;
    }

    if (baselineServiceOdo == null) {
      return _buildUnknownResult(
        componentTypeId: componentTypeId,
        intervalKm: intervalKm,
        intervalDays: intervalDays,
      );
    }

    // 3. Compute elapsed usage since service
    final currentOdo = _currentOdometer ?? baselineServiceOdo;
    final kmSinceService = (currentOdo - baselineServiceOdo).clamp(
      0.0,
      double.infinity,
    );
    final daysSinceService = DateTime.now()
        .difference(baselineServiceDate)
        .inDays;

    // Apply usage multiplier (e.g. jarak jauh reduces effective interval by 20%)
    final usageMultiplier = _usageProfile == 'jarak_jauh' ? 0.8 : 1.0;

    String status = 'good';
    int score = 80;
    String explanation = '';

    if (intervalKm != null && intervalKm > 0) {
      final effectiveIntervalKm = intervalKm * usageMultiplier;
      final kmRatio = kmSinceService / effectiveIntervalKm;

      if (kmRatio >= 1.0) {
        status = 'replace';
        score = ((1 - (kmRatio - 1).clamp(0, 0.5)) * 40).round();
        explanation =
            'Sudah ${kmSinceService.toStringAsFixed(0)} km sejak servis. Interval rekomendasi ${effectiveIntervalKm.toStringAsFixed(0)} km.';
      } else if (kmRatio >= 0.7) {
        status = 'inspect';
        score = ((1 - kmRatio) * 30 + 60).round();
        explanation =
            '${kmSinceService.toStringAsFixed(0)} km dari ${effectiveIntervalKm.toStringAsFixed(0)} km. Jadwal perawatan mulai mendekat.';
      } else {
        status = 'good';
        score = ((1 - kmRatio) * 40 + 60).round().clamp(0, 100);
        explanation =
            'Dalam kondisi baik. Sudah ${kmSinceService.toStringAsFixed(0)} km dari ${effectiveIntervalKm.toStringAsFixed(0)} km.';
      }
    } else if (intervalDays != null && intervalDays > 0) {
      if (daysSinceService >= intervalDays) {
        status = 'inspect';
        score = 55;
        explanation =
            'Perlu diperiksa. Sudah $daysSinceService hari sejak servis terakhir.';
      } else {
        status = 'good';
        score = 75;
        explanation =
            'Dalam kondisi baik. Belum mencapai batas hari pemakaian.';
      }
    }

    // 4. Integrate Self-Inspection Findings
    final component = _componentTypes
        .where((c) => c.id == componentTypeId)
        .firstOrNull;

    if (_inspectionFindings != null && component != null) {
      final finding = _inspectionFindings
          .where(
            (f) =>
                f.componentName.toLowerCase() == component.name.toLowerCase(),
          )
          .firstOrNull;

      if (finding != null) {
        if (finding.isSafetyCritical) {
          status = 'replace';
          score = (score.clamp(0, 40));
          explanation =
              '⚠️ KESELAMATAN: ${finding.advice} (${finding.answerLabel})';
        } else if (finding.riskLevel == 'high') {
          status = 'replace';
          score = (score.clamp(0, 45));
          explanation =
              '⚠️ Perhatian: Ditemukan indikasi masalah pada pemeriksaan mandiri: ${finding.advice}';
        } else if (finding.riskLevel == 'medium' && status == 'good') {
          status = 'inspect';
          score = (score.clamp(50, 65));
          explanation = 'Pemeriksaan mandiri mencatat: ${finding.advice}';
        }
      }
    }

    // 4b. Integrate Active User Complaints from AI Chat / Complaint Log
    if (component != null) {
      final activeComplaint = findMatchingActiveComplaint(
        component.name,
        complaints,
      );
      if (activeComplaint != null) {
        if (isCriticalComplaint(activeComplaint)) {
          status = 'replace';
          score = score.clamp(0, 40);
          explanation =
              '⚠️ KELUHAN KRITIS: "${activeComplaint.title}". Segera periksa komponen ini di bengkel.';
        } else if (status == 'good') {
          status = 'inspect';
          score = score.clamp(50, 65);
          explanation =
              'Keluhan aktif: "${activeComplaint.title}". Disarankan pengecekan fisik.';
        } else if (status == 'inspect' &&
            !explanation.contains('Keluhan aktif')) {
          score = (score - 5).clamp(45, 65);
          explanation =
              '$explanation (Keluhan aktif: "${activeComplaint.title}")';
        }
      }
    }

    // 5. Safety Override
    if (component?.safetyCritical == true && score < 50) {
      status = 'replace';
      if (!explanation.contains('KESELAMATAN')) {
        explanation = '⚠️ KESELAMATAN: Komponen perlu diganti. $explanation';
      }
    }

    return ComponentHealthResult(
      status: status,
      score: score.clamp(0, 100),
      explanation: explanation,
      confidence: (_serviceRecords.length >= 3) ? 'high' : 'medium',
      kmSinceService: kmSinceService,
      intervalKm: intervalKm,
      daysSinceService: daysSinceService,
      intervalDays: intervalDays,
      lastInspectionDate: lastInspectionDate,
    );
  }

  ComponentHealthResult _buildUnknownResult({
    required int componentTypeId,
    double? intervalKm,
    int? intervalDays,
  }) {
    final component = _componentTypes
        .where((c) => c.id == componentTypeId)
        .firstOrNull;
    final name = component?.name ?? 'komponen';

    // Check if there is an active self-inspection finding or complaint even without prior service records
    if (component != null) {
      final finding = _inspectionFindings
          ?.where(
            (f) =>
                f.componentName.toLowerCase() == component.name.toLowerCase(),
          )
          .firstOrNull;
      if (finding != null) {
        if (finding.isSafetyCritical || finding.riskLevel == 'high') {
          return ComponentHealthResult(
            status: 'replace',
            score: 40,
            explanation:
                '⚠️ KESELAMATAN: ${finding.advice} (${finding.answerLabel})',
            confidence: 'medium',
            intervalKm: intervalKm,
            intervalDays: intervalDays,
          );
        } else if (finding.riskLevel == 'medium') {
          return ComponentHealthResult(
            status: 'inspect',
            score: 60,
            explanation: 'Pemeriksaan mandiri mencatat: ${finding.advice}',
            confidence: 'medium',
            intervalKm: intervalKm,
            intervalDays: intervalDays,
          );
        }
      }

      final activeComplaint = findMatchingActiveComplaint(
        component.name,
        complaints,
      );
      if (activeComplaint != null) {
        final critical = isCriticalComplaint(activeComplaint);
        return ComponentHealthResult(
          status: critical ? 'replace' : 'inspect',
          score: critical ? 40 : 60,
          explanation: critical
              ? '⚠️ KELUHAN KRITIS: "${activeComplaint.title}". Segera periksa komponen ini di bengkel.'
              : 'Keluhan aktif: "${activeComplaint.title}". Perlu pengecekan fisik.',
          confidence: 'medium',
          intervalKm: intervalKm,
          intervalDays: intervalDays,
        );
      }
    }

    return ComponentHealthResult(
      status: 'unknown',
      score: null,
      explanation:
          'Belum ada data servis untuk $name. Periksa komponen secara visual.',
      confidence: null,
      intervalKm: intervalKm,
      intervalDays: intervalDays,
    );
  }

  /// Matches an open user complaint to a specific component name using symptom & component keywords.
  static Complaint? findMatchingActiveComplaint(
    String componentName,
    List<Complaint>? complaints,
  ) {
    if (complaints == null || complaints.isEmpty) return null;
    final compLower = componentName.toLowerCase().trim();

    for (final c in complaints) {
      final st = c.status.trim().toLowerCase();
      if (c.closedAt != null || st == 'selesai' || st == 'ditangani') {
        continue;
      }

      final text = '${c.title} ${c.description}'.toLowerCase();
      if (text.contains(compLower)) return c;

      if (compLower == 'oli mesin') {
        if ((text.contains('oli') &&
                !text.contains('oli gardan') &&
                !text.contains('filter oli')) ||
            text.contains('mesin panas') ||
            text.contains('overheat') ||
            text.contains('pelumas')) {
          return c;
        }
      } else if (compLower == 'kampas rem') {
        if ((text.contains('rem') && !text.contains('minyak rem')) ||
            text.contains('berdecit') ||
            text.contains('cakram') ||
            text.contains('tidak pakem')) {
          return c;
        }
      } else if (compLower == 'minyak rem') {
        if (text.contains('minyak rem') ||
            text.contains('rem blong') ||
            text.contains('rem ambles') ||
            text.contains('rem ngelos')) {
          return c;
        }
      } else if (compLower == 'aki') {
        if (text.contains('aki') ||
            text.contains('accu') ||
            text.contains('starter') ||
            text.contains('kelistrikan') ||
            text.contains('lampu redup') ||
            text.contains('mati total')) {
          return c;
        }
      } else if (compLower == 'ban') {
        if (text.contains('ban') ||
            text.contains('kempes') ||
            text.contains('botak') ||
            text.contains('oleng') ||
            text.contains('licin')) {
          return c;
        }
      } else if (compLower == 'filter udara') {
        if (text.contains('filter udara') ||
            text.contains('saringan udara') ||
            text.contains('boros bensin')) {
          return c;
        }
      } else if (compLower == 'busi') {
        if (text.contains('busi') ||
            text.contains('pengapian') ||
            text.contains('brebet') ||
            text.contains('mogok') ||
            text.contains('susah hidup')) {
          return c;
        }
      } else if (compLower == 'cvt') {
        if (text.contains('cvt') ||
            text.contains('gredek') ||
            text.contains('v-belt') ||
            text.contains('vbelt') ||
            text.contains('roller') ||
            text.contains('kampas ganda') ||
            text.contains('tarikan awal') ||
            text.contains('tarikan berat')) {
          return c;
        }
      } else if (compLower == 'knalpot') {
        if (text.contains('knalpot') ||
            text.contains('asap') ||
            text.contains('nembak')) {
          return c;
        }
      } else if (compLower == 'oli gardan') {
        if (text.contains('gardan') || text.contains('gearbox')) {
          return c;
        }
      } else if (compLower == 'radiator coolant') {
        if (text.contains('radiator') ||
            text.contains('coolant') ||
            text.contains('overheat')) {
          return c;
        }
      } else if (compLower.contains('rantai')) {
        if (text.contains('rantai') ||
            text.contains('gir') ||
            text.contains('gear')) {
          return c;
        }
      } else if (compLower == 'suspensi') {
        if (text.contains('suspensi') ||
            text.contains('shock') ||
            text.contains('jedug')) {
          return c;
        }
      } else if (compLower == 'filter oli') {
        if (text.contains('filter oli') || text.contains('saringan oli')) {
          return c;
        }
      }
    }
    return null;
  }

  /// Checks whether a complaint describes a critical safety hazard.
  static bool isCriticalComplaint(Complaint complaint) {
    final text = '${complaint.title} ${complaint.description}'.toLowerCase();
    const criticalKeywords = [
      'rem blong',
      'rem tidak fungsi',
      'rem hilang',
      'oli bocor',
      'oli kering',
      'oli habis',
      'ban pecah',
      'bensin bocor',
      'bahan bakar bocor',
      'mati mendadak',
    ];
    for (final kw in criticalKeywords) {
      if (text.contains(kw)) return true;
    }
    return false;
  }

  /// Calculate overall health score as average of valid component scores.
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

/// Result of a single component health calculation.
class ComponentHealthResult {
  final String status; // 'good', 'inspect', 'replace', 'unknown'
  final int? score; // 0-100 progress metric
  final String explanation;
  final String? confidence; // 'low', 'medium', 'high'
  final double? kmSinceService;
  final double? intervalKm;
  final int? daysSinceService;
  final int? intervalDays;
  final DateTime? lastInspectionDate;

  ComponentHealthResult({
    required this.status,
    this.score,
    required this.explanation,
    this.confidence,
    this.kmSinceService,
    this.intervalKm,
    this.daysSinceService,
    this.intervalDays,
    this.lastInspectionDate,
  });

  bool get needsInspection => status == 'inspect';
  bool get needsReplacement => status == 'replace';
  bool get isUnknown => status == 'unknown';

  /// Human-readable label for UI matching Bagian C
  String get displayStatus {
    switch (status) {
      case 'good':
        return 'Normal';
      case 'inspect':
        return 'Perlu Pemeriksaan';
      case 'replace':
        return 'Perlu Penanganan';
      default:
        return 'Data Belum Cukup';
    }
  }
}
