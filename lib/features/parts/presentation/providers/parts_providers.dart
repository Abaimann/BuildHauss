import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/engines/budget_engine.dart';

/// Recommendation tier determining priority order
enum RecommendationTier {
  /// Priority 1A: Matched & funded in active motorcycle budget
  budgetFunded,

  /// Priority 1B: Recommended in budget plan but deferred / needs more budget
  budgetDeferred,

  /// Priority 2: Component requires health attention (replace / inspect / low score)
  healthAttention,

  /// Priority 3: General catalog sparepart
  generalCatalog,
}

/// Rich sparepart wrapper with recommendation metadata
class PrioritizedSparepart {
  final Sparepart part;
  final RecommendationTier tier;
  final String? badgeText;
  final String? reason;
  final String? componentName;
  final double? healthScore;
  final String? healthStatus;
  final BudgetRecommendation? budgetRec;

  const PrioritizedSparepart({
    required this.part,
    required this.tier,
    this.badgeText,
    this.reason,
    this.componentName,
    this.healthScore,
    this.healthStatus,
    this.budgetRec,
  });

  bool get isBudgetRecommended =>
      tier == RecommendationTier.budgetFunded ||
      tier == RecommendationTier.budgetDeferred;

  bool get isHealthRecommended => tier == RecommendationTier.healthAttention;
}

/// Summary counts for active recommendations
class SparepartRecommendationStats {
  final int budgetCount;
  final int healthCount;
  final int totalCount;
  final String? motorcycleName;
  final int? budgetAmount;

  const SparepartRecommendationStats({
    required this.budgetCount,
    required this.healthCount,
    required this.totalCount,
    this.motorcycleName,
    this.budgetAmount,
  });
}

/// Provider that returns all spareparts prioritized by active motorcycle:
/// 1. Budget Plan recommendations (Priority 1)
/// 2. Health Condition needs (Priority 2)
/// 3. General Catalog (Priority 3)
final prioritizedSparepartsProvider =
    FutureProvider<List<PrioritizedSparepart>>((ref) async {
      final db = ref.watch(databaseProvider);
      final allParts = await db.getAllSpareparts();
      final motor = ref.watch(activeMotorcycleProvider);

      if (motor == null) {
        return allParts
            .map(
              (p) => PrioritizedSparepart(
                part: p,
                tier: RecommendationTier.generalCatalog,
              ),
            )
            .toList();
      }

      // 1. Get Budget recommendations for active motorcycle
      final budgetPlan = await ref.watch(
        activeBudgetPlanProvider(motor.id).future,
      );
      final budgetAmount = budgetPlan?.budgetAmount ?? 200000;
      final budgetSummary = await ref.watch(
        budgetPlanSummaryProvider(budgetAmount).future,
      );

      // 2. Get Component health statuses
      final statuses = await ref.watch(
        componentStatusesWithNamesProvider(motor.id).future,
      );

      // Active motorcycle brand detection
      String? activeBrand;
      if (motor.modelId != null) {
        final model = await db.getMotorcycleModelById(motor.modelId!);
        if (model != null) {
          activeBrand = model.brand.toLowerCase();
        }
      }
      if (activeBrand == null) {
        final nick = motor.nickname.toLowerCase();
        if (nick.contains('vario') ||
            nick.contains('beat') ||
            nick.contains('honda') ||
            nick.contains('pcx')) {
          activeBrand = 'honda';
        } else if (nick.contains('aerox') ||
            nick.contains('nmax') ||
            nick.contains('yamaha') ||
            nick.contains('mio')) {
          activeBrand = 'yamaha';
        }
      }

      final Map<int, PrioritizedSparepart> prioritizedMap = {};

      // PRIORITY 1: Budget Recommendations
      for (final rec in budgetSummary.recommendations) {
        if (rec.matchedSparepart != null) {
          final part = rec.matchedSparepart!;
          final isFunded =
              rec.budgetStatus == 'terdanai' || rec.decision == 'selected';
          final isDeferred =
              rec.budgetStatus == 'belum_terdanai' ||
              rec.decision == 'deferred';

          // Only actual budget recommendations (funded or deferred due to budget cap)
          if (isFunded || isDeferred) {
            prioritizedMap[part.id] = PrioritizedSparepart(
              part: part,
              tier:
                  isFunded
                      ? RecommendationTier.budgetFunded
                      : RecommendationTier.budgetDeferred,
              badgeText:
                  isFunded ? 'Rekomendasi Budget' : 'Perlu Alokasi Tambahan',
              reason: rec.reason,
              componentName: rec.componentName,
              budgetRec: rec,
            );
          }
        }
      }

      // PRIORITY 2: Component Health Attention
      final criticalStatuses =
          statuses.where((s) {
            final st = s.status.estimatedStatus.toLowerCase();
            final score = s.status.score;
            return st == 'replace' ||
                st == 'inspect' ||
                (score != null && score < 70);
          }).toList();

      final categoryKeywords = <String, List<String>>{
        'oli': ['oli', 'oli_mesin'],
        'rem': ['rem', 'kampas_rem', 'minyak_rem'],
        'ban': ['ban', 'roda'],
        'busi': ['busi'],
        'filter': ['filter', 'filter_udara', 'filter_oli'],
        'cvt': ['cvt', 'transmisi'],
        'aki': ['aki', 'kelistrikan', 'baterai'],
        'knalpot': ['knalpot'],
        'gardan': ['oli_gardan', 'gardan'],
        'radiator': ['coolant', 'radiator', 'pendingin'],
        'rantai': ['rantai', 'gear'],
        'suspensi': ['shock', 'suspensi'],
      };

      for (final cs in criticalStatuses) {
        final compName = cs.componentName.toLowerCase();
        final compStatus = cs.status.estimatedStatus;
        final compScore = cs.status.score;

        for (final part in allParts) {
          if (prioritizedMap.containsKey(part.id)) continue;

          // Reject parts specifically branded for a conflicting motorcycle brand
          final pBrand = (part.brand ?? '').toLowerCase();
          final pName = part.name.toLowerCase();
          if (activeBrand != null) {
            if (activeBrand == 'honda' &&
                (pBrand.contains('yamaha') || pName.contains('yamalube'))) {
              continue;
            }
            if (activeBrand == 'yamaha' &&
                (pBrand.contains('honda') || pName.contains('ahm'))) {
              continue;
            }
          }

          // Check if category or name matches
          bool matches = false;
          final partCat = part.category.toLowerCase();
          for (final entry in categoryKeywords.entries) {
            if (compName.contains(entry.key)) {
              if (entry.value.any(
                (k) => partCat.contains(k) || pName.contains(k),
              )) {
                matches = true;
                break;
              }
            }
          }

          if (matches) {
            final isReplace =
                compStatus == 'replace' ||
                (compScore != null && compScore < 50);
            prioritizedMap[part.id] = PrioritizedSparepart(
              part: part,
              tier: RecommendationTier.healthAttention,
              badgeText: isReplace ? 'Perlu Ganti Segera' : 'Perlu Pemeriksaan',
              reason:
                  'Kondisi ${cs.componentName} ${compScore != null ? '(${compScore.round()}%)' : ''}: ${cs.status.explanation.isNotEmpty ? cs.status.explanation : compStatus}',
              componentName: cs.componentName,
              healthScore: compScore,
              healthStatus: compStatus,
            );
          }
        }
      }

      // PRIORITY 3: General Catalog
      for (final part in allParts) {
        if (!prioritizedMap.containsKey(part.id)) {
          prioritizedMap[part.id] = PrioritizedSparepart(
            part: part,
            tier: RecommendationTier.generalCatalog,
          );
        }
      }

      // Return ordered list: Budget Funded -> Budget Deferred -> Health -> General
      final result = prioritizedMap.values.toList();
      result.sort((a, b) {
        final tierComparison = a.tier.index.compareTo(b.tier.index);
        if (tierComparison != 0) return tierComparison;
        return a.part.name.compareTo(b.part.name);
      });

      return result;
    });

/// Provider for quick summary stats
final sparepartRecommendationStatsProvider =
    FutureProvider<SparepartRecommendationStats>((ref) async {
      final motor = ref.watch(activeMotorcycleProvider);
      final parts = await ref.watch(prioritizedSparepartsProvider.future);

      final budgetCount = parts.where((p) => p.isBudgetRecommended).length;
      final healthCount = parts.where((p) => p.isHealthRecommended).length;

      int? budgetAmount;
      if (motor != null) {
        final plan = await ref.watch(activeBudgetPlanProvider(motor.id).future);
        budgetAmount = plan?.budgetAmount ?? 200000;
      }

      return SparepartRecommendationStats(
        budgetCount: budgetCount,
        healthCount: healthCount,
        totalCount: parts.length,
        motorcycleName: motor?.nickname,
        budgetAmount: budgetAmount,
      );
    });
