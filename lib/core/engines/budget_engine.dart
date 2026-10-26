import '../database/app_database.dart';
import 'health_engine.dart';
import 'self_inspection_engine.dart';

/// Smart Budget & Service Advisor Engine for BuildHaus.
///
/// Deterministically calculates and prioritizes service recommendations based on:
/// 1. Safety-critical issues (Self-inspection alerts, severe brake/fuel/tyre hazards).
/// 2. Urgent inspections (Unresolved user complaints, abnormal noises/leaks).
/// 3. Overdue maintenance (Passed scheduled mileage or calendar intervals).
/// 4. Approaching maintenance (Near interval thresholds, e.g. ratio >= 0.7).
/// 5. Routine / preventive care.
///
/// Features:
/// - Clear distinction between Inspection (`inspect`), Repair (`repair`), and Replacement (`replace`).
/// - Strict sparepart compatibility (Honda parts are never recommended for Yamaha, and vice versa).
/// - Transparent cost breakdown (spareparts, labor, and total) without fabricating prices.
/// - Honest handling of unknown costs (items with unknown cost are not treated as Rp0 and not faked as funded).
/// - Budget allocation preventing double-counting, calculating remaining budget and shortfall.
/// - Practical savings planning for non-urgent deferred items.
class BudgetEngine {
  final List<ComponentHealthResult> _componentHealths;
  final int _budgetAmount;
  final Map<String, int> _componentCostEstimates;

  // Extended context for full dynamic calculation
  final Motorcycle? activeMotorcycle;
  final List<ComponentStatusWithName>? componentStatusesWithNames;
  final List<MaintenanceRule>? maintenanceRules;
  final double? currentOdometer;
  final double? estimatedOdometer;
  final List<ServiceRecord>? serviceRecords;
  final List<ServiceItemWithRecord>? serviceItems;
  final List<InspectionFinding>? inspectionFindings;
  final List<Complaint>? complaints;
  final List<Sparepart>? spareparts;
  final List<SparepartFitment>? fitments;

  BudgetEngine({
    required List<ComponentHealthResult> componentHealths,
    required int budgetAmount,
    Map<String, int>? componentCostEstimates,
    this.activeMotorcycle,
    this.componentStatusesWithNames,
    this.maintenanceRules,
    this.currentOdometer,
    this.estimatedOdometer,
    this.serviceRecords,
    this.serviceItems,
    this.inspectionFindings,
    this.complaints,
    this.spareparts,
    this.fitments,
  }) : _componentHealths = componentHealths,
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

  static const Map<String, int> _standardLaborCosts = {
    'oli_mesin': 15000,
    'kampas_rem': 30000,
    'ban': 25000,
    'busi': 10000,
    'filter_udara': 10000,
    'cvt': 45000,
    'aki': 15000,
    'knalpot': 35000,
  };

  static const int _standardInspectionFee = 25000;

  /// Generate prioritized recommendations within budget
  List<BudgetRecommendation> generateRecommendations() {
    // If rich context is provided, use the dynamic multi-factor evaluation
    if (componentStatusesWithNames != null &&
        componentStatusesWithNames!.isNotEmpty) {
      return _generateDynamicRecommendations();
    }

    // Fallback: Legacy generation for backward compatibility with existing tests
    return _generateLegacyRecommendations();
  }

  /// Calculates a complete budget summary including allocation and savings plan
  BudgetPlanSummary calculateSummary() {
    final recommendations = generateRecommendations();

    int totalEstimatedCost = 0;
    int totalFundedCost = 0;
    int remainingBudget = _budgetAmount;
    int shortfall = 0;
    int fundedCount = 0;
    int deferredCount = 0;
    int safetyCount = 0;

    for (final item in recommendations) {
      if (item.isSafetyCritical) safetyCount++;

      if (item.hasKnownCost && item.estimatedCost > 0) {
        totalEstimatedCost += item.estimatedCost;

        if (item.budgetStatus == 'terdanai') {
          totalFundedCost += item.estimatedCost;
          fundedCount++;
        } else if (item.budgetStatus == 'belum_terdanai') {
          deferredCount++;
          shortfall += item.estimatedCost;
        }
      } else {
        deferredCount++;
      }
    }

    remainingBudget = (_budgetAmount - totalFundedCost).clamp(0, _budgetAmount);

    SavingsPlan? savingsPlan;
    if (shortfall > 0) {
      final nonSafetyShortfall = recommendations
          .where(
            (r) =>
                !r.isSafetyCritical &&
                r.budgetStatus == 'belum_terdanai' &&
                r.hasKnownCost,
          )
          .fold<int>(0, (sum, r) => sum + r.estimatedCost);

      final targetAmount = nonSafetyShortfall > 0
          ? nonSafetyShortfall
          : shortfall;
      savingsPlan = SavingsPlan(
        totalShortfall: targetAmount,
        weeklyTarget: (targetAmount / 4).ceil(),
        monthlyTarget: (targetAmount / 2).ceil(),
        advice: safetyCount > 0
            ? '⚠️ Perhatian: Tindakan keselamatan mendesak tidak disarankan untuk ditunda.'
            : 'Sisihkan sekitar Rp ${(targetAmount / 4).ceil()} per minggu selama 4 minggu untuk melengkapi perawatan.',
      );
    }

    return BudgetPlanSummary(
      budgetAmount: _budgetAmount,
      totalEstimatedCost: totalEstimatedCost,
      totalFundedCost: totalFundedCost,
      remainingBudget: remainingBudget,
      shortfall: shortfall,
      totalItems: recommendations.length,
      fundedItemsCount: fundedCount,
      deferredItemsCount: deferredCount,
      safetyAlertCount: safetyCount,
      recommendations: recommendations,
      savingsPlan: savingsPlan,
    );
  }

  /// Dynamic generator incorporating active motorcycle, complaints, inspections, rules, and catalog fitments
  List<BudgetRecommendation> _generateDynamicRecommendations() {
    final candidates = <_RecommendationCandidate>[];
    final statuses = componentStatusesWithNames ?? [];
    final activeModelId = activeMotorcycle?.modelId;
    final activeBrand = activeMotorcycle != null
        ? _extractBrandFromModel(activeMotorcycle!)
        : null;

    for (final item in statuses) {
      final compName = item.componentName;
      final compKey = _normalizeKey(compName);
      final compId = item.status.componentTypeId;
      final status = item.status.estimatedStatus;

      // 1. Check for self-inspection finding on this component
      final finding = inspectionFindings
          ?.where(
            (f) => f.componentName.toLowerCase() == compName.toLowerCase(),
          )
          .firstOrNull;

      // 2. Check for unresolved complaints
      final compComplaint = complaints
          ?.where(
            (c) =>
                c.closedAt == null &&
                (c.title.toLowerCase().contains(compName.toLowerCase()) ||
                    c.description.toLowerCase().contains(
                      compName.toLowerCase(),
                    )),
          )
          .firstOrNull;

      // Determine matching sparepart and fitment
      final matchedPartInfo = _findBestSparepartForComponent(
        componentName: compName,
        activeModelId: activeModelId,
        activeBrand: activeBrand,
      );

      // Skenario A: Safety Critical Alert from Self-Inspection
      if (finding != null && finding.isSafetyCritical) {
        candidates.add(
          _RecommendationCandidate(
            componentName: compName,
            componentTypeId: compId,
            priorityRank: 0,
            priority: 'safety',
            action: 'inspect', // Urgent Inspection, not automatic replace!
            reason:
                '⚠️ KESELAMATAN: ${finding.advice} (${finding.answerLabel})',
            consequenceIfDelayed:
                'Risiko kecelakaan fatal jika motor tetap dikendarai sebelum diperiksa.',
            requiresInspection: true,
            isSafetyCritical: true,
            evidence: 'Temuan pemeriksaan mandiri: ${finding.answerLabel}',
            estimatedPartCost: null, // Don't charge part until inspected
            estimatedLaborCost: _standardInspectionFee,
            matchedSparepart: matchedPartInfo.part,
            fitmentStatus: matchedPartInfo.fitmentStatus,
            sourceUrl: finding.isSafetyCritical
                ? 'Panduan Keselamatan Berkendara'
                : null,
          ),
        );
        continue;
      }

      // Skenario B: Urgent inspection from complaints or high-risk finding
      if (finding != null && finding.riskLevel == 'high') {
        candidates.add(
          _RecommendationCandidate(
            componentName: compName,
            componentTypeId: compId,
            priorityRank: 1,
            priority: 'high',
            action: 'inspect',
            reason:
                '⚠️ Perhatian: Ditemukan indikasi masalah: ${finding.advice}',
            consequenceIfDelayed:
                'Kondisi komponen dapat memburuk dan memicu kerusakan komponen lain.',
            requiresInspection: true,
            isSafetyCritical: false,
            evidence: 'Pemeriksaan mandiri: ${finding.answerLabel}',
            estimatedPartCost: null,
            estimatedLaborCost: _standardInspectionFee,
            matchedSparepart: matchedPartInfo.part,
            fitmentStatus: matchedPartInfo.fitmentStatus,
          ),
        );
        continue;
      }

      if (compComplaint != null) {
        candidates.add(
          _RecommendationCandidate(
            componentName: compName,
            componentTypeId: compId,
            priorityRank: 1,
            priority: 'high',
            action: 'inspect',
            reason:
                'Keluhan aktif: "${compComplaint.title}". Memerlukan pengecekan di bengkel.',
            consequenceIfDelayed:
                'Gejala kerusakan yang dibiarkan berisiko memperparah kerusakan mekanis.',
            requiresInspection: true,
            isSafetyCritical: false,
            evidence:
                'Keluhan pengguna tercatat pada ${compComplaint.openedAt.day}/${compComplaint.openedAt.month}',
            estimatedPartCost: null,
            estimatedLaborCost: _standardInspectionFee,
            matchedSparepart: matchedPartInfo.part,
            fitmentStatus: matchedPartInfo.fitmentStatus,
          ),
        );
        continue;
      }

      // Skenario C: Overdue Scheduled Replacement (status == 'replace')
      if (status == 'replace') {
        final partCost = matchedPartInfo.part?.referencePrice;
        final laborCost = _standardLaborCosts[compKey] ?? 20000;

        candidates.add(
          _RecommendationCandidate(
            componentName: compName,
            componentTypeId: compId,
            priorityRank: 2,
            priority: 'high',
            action: 'replace',
            reason:
                'Jadwal servis berkala telah tercapai. ${item.status.explanation}',
            consequenceIfDelayed:
                'Mempercepat keausan komponen internal dan menurunkan efisiensi motor.',
            requiresInspection: false,
            isSafetyCritical: false,
            evidence: 'Status jadwal: Telah melewati batas interval perawatan',
            estimatedPartCost: partCost,
            estimatedLaborCost: laborCost,
            matchedSparepart: matchedPartInfo.part,
            fitmentStatus: matchedPartInfo.fitmentStatus,
            sourceUrl: matchedPartInfo.part?.productUrl,
          ),
        );
        continue;
      }

      // Skenario D: Approaching Maintenance Interval (status == 'inspect')
      if (status == 'inspect') {
        final laborCost =
            _standardLaborCosts[compKey] ?? _standardInspectionFee;

        candidates.add(
          _RecommendationCandidate(
            componentName: compName,
            componentTypeId: compId,
            priorityRank: 3,
            priority: 'medium',
            action: 'inspect',
            reason:
                'Jadwal pemeriksaan berkala mulai mendekat. ${item.status.explanation}',
            consequenceIfDelayed:
                'Dapat dipantau dan dijadwalkan pada kunjungan bengkel berikutnya.',
            requiresInspection: true,
            isSafetyCritical: false,
            evidence: 'Status jadwal: Mendekati interval perawatan',
            estimatedPartCost: null,
            estimatedLaborCost: laborCost,
            matchedSparepart: matchedPartInfo.part,
            fitmentStatus: matchedPartInfo.fitmentStatus,
          ),
        );
        continue;
      }

      // Skenario E: Unknown status with no recorded service
      if (status == 'unknown') {
        candidates.add(
          _RecommendationCandidate(
            componentName: compName,
            componentTypeId: compId,
            priorityRank: 4,
            priority: 'low',
            action: 'inspect',
            reason:
                'Belum ada catatan riwayat perawatan untuk ${item.componentName}. Lakukan pemeriksaan visual.',
            consequenceIfDelayed: 'Kondisi fisik belum diketahui secara pasti.',
            requiresInspection: true,
            isSafetyCritical: false,
            evidence: 'Riwayat servis belum tersedia',
            estimatedPartCost: null,
            estimatedLaborCost: null, // Unknown cost
            matchedSparepart: matchedPartInfo.part,
            fitmentStatus: matchedPartInfo.fitmentStatus,
          ),
        );
      }
    }

    // Sort candidates deterministically: PriorityRank asc, then componentName
    candidates.sort((a, b) {
      final pComp = a.priorityRank.compareTo(b.priorityRank);
      if (pComp != 0) return pComp;
      return a.componentName.compareTo(b.componentName);
    });

    // Allocate budget
    final results = <BudgetRecommendation>[];
    int remainingBudget = _budgetAmount;

    for (final c in candidates) {
      final totalCost = c.totalCost;
      final hasKnownCost = totalCost != null && totalCost > 0;

      String decision;
      String budgetStatus;

      if (!hasKnownCost) {
        decision = c.isSafetyCritical ? 'safety_alert' : 'unknown_cost';
        budgetStatus = 'biaya_belum_tersedia';
      } else if (c.isSafetyCritical) {
        decision = 'safety_alert';
        if (remainingBudget >= totalCost) {
          budgetStatus = 'terdanai';
          remainingBudget -= totalCost;
        } else {
          budgetStatus = 'belum_terdanai';
        }
      } else {
        if (remainingBudget >= totalCost) {
          decision = 'selected';
          budgetStatus = 'terdanai';
          remainingBudget -= totalCost;
        } else {
          decision = 'deferred';
          budgetStatus = 'belum_terdanai';
        }
      }

      results.add(
        BudgetRecommendation(
          componentName: c.componentName,
          componentTypeId: c.componentTypeId,
          priority: c.priority,
          decision: decision,
          estimatedCost: totalCost ?? 0,
          estimatedPartCost: c.estimatedPartCost,
          estimatedLaborCost: c.estimatedLaborCost,
          hasKnownCost: hasKnownCost,
          action: c.action,
          reason: c.reason,
          consequenceIfDelayed: c.consequenceIfDelayed,
          requiresInspection: c.requiresInspection,
          evidence: c.evidence,
          isSafetyCritical: c.isSafetyCritical,
          budgetStatus: budgetStatus,
          matchedSparepart: c.matchedSparepart,
          fitmentStatus: c.fitmentStatus,
          sourceUrl: c.sourceUrl,
        ),
      );
    }

    return results;
  }

  /// Legacy recommendation generator for backward compatibility
  List<BudgetRecommendation> _generateLegacyRecommendations() {
    final results = <BudgetRecommendation>[];
    var remainingBudget = _budgetAmount;

    // Sort by priority: safety > replace > inspect
    final sorted = [..._componentHealths]
      ..sort((a, b) {
        final aP = _priority(a);
        final bP = _priority(b);
        return aP.compareTo(bP);
      });

    for (final health in sorted) {
      final componentName = _getComponentName(health);
      final cost = _componentCostEstimates[componentName] ?? 100000;
      final decision = _determineDecision(health, remainingBudget);

      if (decision == 'safety_alert') {
        results.add(
          BudgetRecommendation(
            componentName: componentName,
            priority: 'safety',
            decision: decision,
            estimatedCost: cost,
            estimatedPartCost: cost,
            estimatedLaborCost: 0,
            hasKnownCost: true,
            action: 'inspect',
            reason: '⚠️ Komponen keselamatan memerlukan perhatian segera.',
            consequenceIfDelayed: 'Risiko kecelakaan jika ditunda.',
            requiresInspection: true,
            isSafetyCritical: true,
            budgetStatus: remainingBudget >= cost
                ? 'terdanai'
                : 'belum_terdanai',
          ),
        );
        if (remainingBudget >= cost) remainingBudget -= cost;
      } else if (decision == 'selected') {
        if (remainingBudget >= cost) {
          results.add(
            BudgetRecommendation(
              componentName: componentName,
              priority: health.score != null && health.score! < 50
                  ? 'high'
                  : 'medium',
              decision: decision,
              estimatedCost: cost,
              estimatedPartCost: cost,
              estimatedLaborCost: 0,
              hasKnownCost: true,
              action: health.needsReplacement ? 'replace' : 'inspect',
              reason: 'Dalam anggaran dan perlu perhatian.',
              consequenceIfDelayed: 'Kondisi bisa memburuk jika ditunda.',
              requiresInspection: health.needsInspection,
              budgetStatus: 'terdanai',
            ),
          );
          remainingBudget -= cost;
        } else {
          results.add(
            BudgetRecommendation(
              componentName: componentName,
              priority: 'medium',
              decision: 'deferred',
              estimatedCost: cost,
              estimatedPartCost: cost,
              estimatedLaborCost: 0,
              hasKnownCost: true,
              action: health.needsReplacement ? 'replace' : 'inspect',
              reason: 'Diperlukan tapi budget tidak mencukupi.',
              consequenceIfDelayed: 'Butuh tabungan tambahan.',
              requiresInspection: true,
              budgetStatus: 'belum_terdanai',
            ),
          );
        }
      }
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
        if (health.explanation.contains('KESELAMATAN')) {
          return 'safety_alert';
        }
      }
      return remainingBudget > 0 ? 'selected' : 'deferred';
    }
    return 'skip';
  }

  String _getComponentName(ComponentHealthResult health) {
    return health.explanation.split(' ').first.toLowerCase();
  }

  String _normalizeKey(String name) {
    return name.toLowerCase().replaceAll('&', 'dan').replaceAll(' ', '_');
  }

  String? _extractBrandFromModel(Motorcycle m) {
    return m.nickname.toLowerCase();
  }

  _MatchedPart _findBestSparepartForComponent({
    required String componentName,
    int? activeModelId,
    String? activeBrand,
  }) {
    if (spareparts == null || spareparts!.isEmpty) {
      return _MatchedPart(null, 'unverified');
    }

    final compKey = _normalizeKey(componentName);

    // Map component to sparepart category keywords
    final categoryKeywords = <String, List<String>>{
      'oli_mesin': ['oli', 'oli_mesin'],
      'kampas_rem': ['rem', 'kampas_rem'],
      'ban': ['ban', 'roda'],
      'busi': ['busi'],
      'filter_udara': ['filter', 'filter_udara'],
      'cvt': ['cvt', 'transmisi'],
      'aki': ['aki', 'kelistrikan'],
      'knalpot': ['knalpot'],
      'oli_gardan': ['oli_gardan', 'gardan', 'oli'],
      'minyak_rem': ['minyak_rem', 'rem'],
      'radiator_coolant': ['coolant', 'radiator', 'pendingin'],
      'rantai_dan_gir': ['rantai', 'gear'],
      'rantai_&_gir': ['rantai', 'gear'],
      'suspensi': ['shock', 'suspensi'],
      'filter_oli': ['filter_oli', 'filter'],
    };

    final targetCategories = categoryKeywords[compKey] ?? [compKey];

    // Candidate parts matching category
    final candidateParts = spareparts!.where((p) {
      final pCat = p.category.toLowerCase();
      return targetCategories.any((cat) => pCat.contains(cat));
    }).toList();

    if (candidateParts.isEmpty) {
      return _MatchedPart(null, 'unverified');
    }

    // 1. Try to find a verified fitment matching activeModelId
    if (activeModelId != null && fitments != null && fitments!.isNotEmpty) {
      for (final part in candidateParts) {
        final matchFit = fitments!
            .where(
              (f) => f.sparepartId == part.id && f.modelId == activeModelId,
            )
            .firstOrNull;

        if (matchFit != null) {
          final isVerified =
              matchFit.verifiedAt != null &&
              (matchFit.sourceUrl?.startsWith('https') ?? false);
          return _MatchedPart(part, isVerified ? 'verified' : 'reference');
        }
      }
    }

    // 2. Reject parts specifically branded for another motorcycle
    // (e.g. Do not recommend Yamalube or Yamaha parts if active motorcycle is Honda)
    final filteredByBrand = candidateParts.where((part) {
      final pBrand = (part.brand ?? '').toLowerCase();
      final pName = part.name.toLowerCase();

      if (activeBrand != null) {
        if (activeBrand.contains('honda')) {
          if (pBrand.contains('yamaha') || pName.contains('yamaha')) {
            return false;
          }
          if (pBrand.contains('suzuki') || pName.contains('suzuki')) {
            return false;
          }
          if (pBrand.contains('kawasaki') || pName.contains('kawasaki')) {
            return false;
          }
        } else if (activeBrand.contains('yamaha')) {
          if (pBrand.contains('honda') || pName.contains('honda')) {
            return false;
          }
          if (pBrand.contains('suzuki') || pName.contains('suzuki')) {
            return false;
          }
          if (pBrand.contains('kawasaki') || pName.contains('kawasaki')) {
            return false;
          }
        }
      }
      return true;
    }).toList();

    if (filteredByBrand.isEmpty) {
      return _MatchedPart(null, 'unverified');
    }

    // 3. Fallback to first compatible or universal part as reference
    final selected = filteredByBrand.first;
    return _MatchedPart(selected, 'reference');
  }
}

class _RecommendationCandidate {
  final String componentName;
  final int? componentTypeId;
  final int
  priorityRank; // 0: safety, 1: urgent inspect, 2: overdue replace, 3: approaching inspect, 4: routine
  final String priority;
  final String action;
  final String reason;
  final String? consequenceIfDelayed;
  final bool requiresInspection;
  final bool isSafetyCritical;
  final String? evidence;
  final int? estimatedPartCost;
  final int? estimatedLaborCost;
  final Sparepart? matchedSparepart;
  final String fitmentStatus;
  final String? sourceUrl;

  _RecommendationCandidate({
    required this.componentName,
    this.componentTypeId,
    required this.priorityRank,
    required this.priority,
    required this.action,
    required this.reason,
    this.consequenceIfDelayed,
    required this.requiresInspection,
    required this.isSafetyCritical,
    this.evidence,
    this.estimatedPartCost,
    this.estimatedLaborCost,
    this.matchedSparepart,
    required this.fitmentStatus,
    this.sourceUrl,
  });

  int? get totalCost {
    if (estimatedPartCost == null && estimatedLaborCost == null) return null;
    return (estimatedPartCost ?? 0) + (estimatedLaborCost ?? 0);
  }
}

class _MatchedPart {
  final Sparepart? part;
  final String fitmentStatus;
  _MatchedPart(this.part, this.fitmentStatus);
}

/// Item recommendation produced by BudgetEngine
class BudgetRecommendation {
  final String componentName;
  final int? componentTypeId;
  final String priority; // 'safety', 'high', 'medium', 'low'
  final String
  decision; // 'selected', 'deferred', 'safety_alert', 'unknown_cost'
  final int estimatedCost; // total of parts + labor (0 if unknown)
  final int? estimatedPartCost;
  final int? estimatedLaborCost;
  final bool hasKnownCost;
  final String action; // 'inspect', 'clean', 'repair', 'replace'
  final String reason;
  final String? consequenceIfDelayed;
  final bool requiresInspection;
  final String? evidence;
  final bool isSafetyCritical;
  final String
  budgetStatus; // 'terdanai', 'belum_terdanai', 'biaya_belum_tersedia'
  final Sparepart? matchedSparepart;
  final String? fitmentStatus; // 'verified', 'reference', 'unverified'
  final String? sourceUrl;

  BudgetRecommendation({
    required this.componentName,
    this.componentTypeId,
    required this.priority,
    required this.decision,
    required this.estimatedCost,
    this.estimatedPartCost,
    this.estimatedLaborCost,
    this.hasKnownCost = true,
    this.action = 'inspect',
    required this.reason,
    this.consequenceIfDelayed,
    this.requiresInspection = false,
    this.evidence,
    this.isSafetyCritical = false,
    this.budgetStatus = 'terdanai',
    this.matchedSparepart,
    this.fitmentStatus,
    this.sourceUrl,
  });
}

/// Complete budget plan summary with funding metrics and savings guidance
class BudgetPlanSummary {
  final int budgetAmount;
  final int totalEstimatedCost;
  final int totalFundedCost;
  final int remainingBudget;
  final int shortfall;
  final int totalItems;
  final int fundedItemsCount;
  final int deferredItemsCount;
  final int safetyAlertCount;
  final List<BudgetRecommendation> recommendations;
  final SavingsPlan? savingsPlan;

  BudgetPlanSummary({
    required this.budgetAmount,
    required this.totalEstimatedCost,
    required this.totalFundedCost,
    required this.remainingBudget,
    required this.shortfall,
    required this.totalItems,
    required this.fundedItemsCount,
    required this.deferredItemsCount,
    required this.safetyAlertCount,
    required this.recommendations,
    this.savingsPlan,
  });
}

/// Savings plan recommendation when user budget has shortfall
class SavingsPlan {
  final int totalShortfall;
  final int weeklyTarget;
  final int monthlyTarget;
  final String advice;

  SavingsPlan({
    required this.totalShortfall,
    required this.weeklyTarget,
    required this.monthlyTarget,
    required this.advice,
  });
}
