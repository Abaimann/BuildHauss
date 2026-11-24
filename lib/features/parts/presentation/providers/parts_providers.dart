import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/engines/budget_engine.dart';
import '../../../../core/engines/motorcycle_specs.dart';

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
  final bool fitsBudget;
  final int urgencyRank;
  final bool isVerifiedFitment;

  const PrioritizedSparepart({
    required this.part,
    required this.tier,
    this.badgeText,
    this.reason,
    this.componentName,
    this.healthScore,
    this.healthStatus,
    this.budgetRec,
    this.fitsBudget = false,
    this.urgencyRank = 99,
    this.isVerifiedFitment = false,
  });

  bool get isBudgetRecommended =>
      tier == RecommendationTier.budgetFunded ||
      tier == RecommendationTier.budgetDeferred;

  bool get isHealthRecommended => tier == RecommendationTier.healthAttention;

  /// Urutan prioritas terpadu:
  /// Tier 0 (`budgetFunded`): safety/critical -> replace -> inspect -> harga -> nama
  /// Tier 1 (`budgetDeferred`): safety/critical -> replace -> inspect -> harga -> nama
  /// Tier 2 (`healthAttention`): replace -> inspect -> masuk budget -> fitment -> harga -> nama
  /// Tier 3 (`generalCatalog`): masuk budget (`<= budgetAmount`) -> fitment terverifikasi -> OEM -> harga -> nama
  static int compareByPriority(PrioritizedSparepart a, PrioritizedSparepart b) {
    final tierCmp = a.tier.index.compareTo(b.tier.index);
    if (tierCmp != 0) return tierCmp;

    const maxPrice = 1 << 30;
    final priceA = a.part.referencePrice ?? maxPrice;
    final priceB = b.part.referencePrice ?? maxPrice;

    switch (a.tier) {
      case RecommendationTier.budgetFunded:
      case RecommendationTier.budgetDeferred:
        final urgCmp = a.urgencyRank.compareTo(b.urgencyRank);
        if (urgCmp != 0) return urgCmp;
        final priceCmp = priceA.compareTo(priceB);
        if (priceCmp != 0) return priceCmp;
        return a.part.name.compareTo(b.part.name);

      case RecommendationTier.healthAttention:
        final urgCmp = a.urgencyRank.compareTo(b.urgencyRank);
        if (urgCmp != 0) return urgCmp;
        if (a.fitsBudget != b.fitsBudget) return a.fitsBudget ? -1 : 1;
        if (a.isVerifiedFitment != b.isVerifiedFitment) {
          return a.isVerifiedFitment ? -1 : 1;
        }
        final priceCmp = priceA.compareTo(priceB);
        if (priceCmp != 0) return priceCmp;
        return a.part.name.compareTo(b.part.name);

      case RecommendationTier.generalCatalog:
        if (a.fitsBudget != b.fitsBudget) return a.fitsBudget ? -1 : 1;
        if (a.isVerifiedFitment != b.isVerifiedFitment) {
          return a.isVerifiedFitment ? -1 : 1;
        }
        if (a.part.isVerified != b.part.isVerified) {
          return a.part.isVerified ? -1 : 1;
        }
        final priceCmp = priceA.compareTo(priceB);
        if (priceCmp != 0) return priceCmp;
        return a.part.name.compareTo(b.part.name);
    }
  }
}

/// Memvalidasi kompatibilitas [part] terhadap [model] motor aktif
/// (merek pabrikan, jenis transmisi matic/manual, sistem pendingin, 2-tak/4-tak,
/// serta kecocokan eksplisit tabel fitment bila tersedia).
bool isSparepartCompatibleWithMotorcycle({
  required Sparepart part,
  MotorcycleModel? model,
  Map<int, Set<int>>? fitmentModelsByPartId,
}) {
  if (model == null) return true;

  final activeBrand = model.brand.trim().toLowerCase();
  final pBrand = (part.brand ?? '').trim().toLowerCase();
  final pName = part.name.toLowerCase();
  final pCat = part.category.toLowerCase().trim();
  final pNum = (part.partNumber ?? '').toLowerCase().trim();

  // 1. Jika part punya daftar model fitment terverifikasi, wajib cocok dengan model aktif.
  final allowedModelIds = fitmentModelsByPartId?[part.id];
  if (allowedModelIds != null &&
      allowedModelIds.isNotEmpty &&
      !allowedModelIds.contains(model.id)) {
    return false;
  }

  // 2. Tolak part yang bermerek / ditujukan khusus pabrikan lain.
  final isHondaPart =
      pBrand.contains('honda') ||
      pBrand == 'ahm' ||
      pName.contains('honda') ||
      RegExp(r'\b(ahm|aoil)\b').hasMatch(pName) ||
      pNum.contains('ahm') ||
      pNum.startsWith('hn-');
  final isYamahaPart =
      pBrand.contains('yamaha') ||
      pBrand.contains('yamalube') ||
      pName.contains('yamaha') ||
      pName.contains('yamalube') ||
      pNum.contains('yamalube') ||
      pNum.startsWith('ym-');
  final isSuzukiPart =
      pBrand.contains('suzuki') ||
      pName.contains('suzuki') ||
      RegExp(r'\b(sgo|sgp)\b').hasMatch(pName) ||
      pNum.contains('sgo') ||
      pNum.contains('sgp');
  final isKawasakiPart =
      pBrand.contains('kawasaki') ||
      pName.contains('kawasaki') ||
      RegExp(r'\b(kgo|kgp)\b').hasMatch(pName) ||
      pNum.contains('kgo') ||
      pNum.contains('kgp') ||
      pNum.startsWith('kaw-');

  if (activeBrand.contains('honda')) {
    if (isYamahaPart || isSuzukiPart || isKawasakiPart) return false;
  } else if (activeBrand.contains('yamaha')) {
    if (isHondaPart || isSuzukiPart || isKawasakiPart) return false;
  } else if (activeBrand.contains('kawasaki')) {
    if (isHondaPart || isYamahaPart || isSuzukiPart) return false;
    if (pName.contains('beat') ||
        pName.contains('vario') ||
        pName.contains('scoopy') ||
        pName.contains('nmax') ||
        pName.contains('aerox') ||
        pName.contains('mio')) {
      return false;
    }
  } else if (activeBrand.contains('suzuki')) {
    if (isHondaPart || isYamahaPart || isKawasakiPart) return false;
  }

  // 3. Tolak part yang tidak kompatibel dengan tipe transmisi (Matic vs Manual).
  final isMatic = MotorcycleSpecs.isMaticOrNull(model);
  if (isMatic == false) {
    if (pCat == 'cvt' ||
        pCat == 'vbelt' ||
        pCat == 'oli_gardan' ||
        pName.contains('cvt') ||
        pName.contains('v-belt') ||
        pName.contains('vbelt') ||
        pName.contains('vanbelt') ||
        pName.contains('roller') ||
        pName.contains('pulley') ||
        pName.contains('oli gardan') ||
        pName.contains('gear oil') ||
        pName.contains('scooter') ||
        pName.contains('matic') ||
        pName.contains('vario') ||
        pName.contains('beat') ||
        pName.contains('scoopy') ||
        pName.contains('nmax') ||
        pName.contains('aerox') ||
        pName.contains('mio') ||
        pName.contains('pcx') ||
        pName.contains('adv')) {
      return false;
    }
  } else if (isMatic == true) {
    final isCvtPulley =
        pName.contains('pulley') ||
        pName.contains('cvt') ||
        pName.contains('kampas ganda');
    if (pCat == 'rantai' ||
        (pCat == 'kopling' && !isCvtPulley) ||
        pName.contains('rantai') ||
        RegExp(r'\bgir\b').hasMatch(pName) ||
        pName.contains('gear depan') ||
        pName.contains('gear belakang') ||
        pName.contains('chain') ||
        pName.contains('kampas kopling') ||
        pName.contains('plat kopling') ||
        pName.contains('kopling manual') ||
        pName.contains('motor bebek') ||
        pName.contains('supra') ||
        pName.contains('vixion') ||
        pName.contains('ninja') ||
        pName.contains('klx') ||
        pName.contains('rx-king')) {
      return false;
    }
  }

  // 4. Tolak coolant untuk motor berpendingin udara.
  final isLiquid = MotorcycleSpecs.isLiquidCooledOrNull(model);
  if (isLiquid == false &&
      (pCat == 'coolant' ||
          pName.contains('coolant') ||
          pName.contains('radiator'))) {
    return false;
  }

  // 5. Tolak oli samping / 2-Tak untuk motor 4-Tak.
  if (!MotorcycleSpecs.is2Stroke(model) &&
      (RegExp(r'\b2t\b').hasMatch(pName) ||
          pName.contains('2-tak') ||
          pName.contains('2 tak') ||
          pName.contains('oli samping'))) {
    return false;
  }

  return true;
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
        final result = allParts
            .map(
              (p) => PrioritizedSparepart(
                part: p,
                tier: RecommendationTier.generalCatalog,
              ),
            )
            .toList()
          ..sort(PrioritizedSparepart.compareByPriority);
        return result;
      }

      // 1. Get Budget recommendations for active motorcycle
      final budgetPlan = await ref.watch(
        activeBudgetPlanProvider(motor.id).future,
      );
      final budgetAmount = budgetPlan?.budgetAmount ?? 200000;
      final budgetSummary = await ref.watch(
        budgetPlanSummaryProvider(
          BudgetSummaryKey(
            motorcycleId: motor.id,
            budgetAmount: budgetAmount,
          ),
        ).future,
      );

      // 2. Get Component health statuses & fitments
      final statuses = await ref.watch(
        componentStatusesWithNamesProvider(motor.id).future,
      );
      final allFitments = await db.getAllSparepartFitments();
      final fitmentModelsByPartId = <int, Set<int>>{};
      for (final f in allFitments) {
        if (f.modelId != null) {
          fitmentModelsByPartId
              .putIfAbsent(f.sparepartId, () => <int>{})
              .add(f.modelId!);
        }
      }

      // Ambil model motor aktif langsung dari modelId (bukan menebak dari nickname).
      final MotorcycleModel? activeModel = motor.modelId != null
          ? await db.getMotorcycleModelById(motor.modelId!)
          : null;

      bool isCompatible(Sparepart part) => isSparepartCompatibleWithMotorcycle(
        part: part,
        model: activeModel,
        fitmentModelsByPartId: fitmentModelsByPartId,
      );

      bool isVerifiedForModel(Sparepart part) =>
          activeModel != null &&
          (fitmentModelsByPartId[part.id]?.contains(activeModel.id) ?? false);

      bool fitsWithinBudget(Sparepart part) =>
          part.referencePrice != null && part.referencePrice! <= budgetAmount;

      final Map<int, PrioritizedSparepart> prioritizedMap = {};

      // PRIORITY 0 & 1: Budget Recommendations (Funded -> Deferred)
      for (final rec in budgetSummary.recommendations) {
        final part = rec.matchedSparepart;
        if (part == null || !isCompatible(part)) continue;

        final isFunded =
            rec.budgetStatus == 'terdanai' || rec.decision == 'selected';
        final isDeferred =
            rec.budgetStatus == 'belum_terdanai' ||
            rec.decision == 'deferred' ||
            (rec.isSafetyCritical && !isFunded);

        if (!isFunded && !isDeferred) continue;

        final urgencyRank = rec.isSafetyCritical || rec.priority == 'safety'
            ? 0
            : (rec.action == 'replace' || rec.priority == 'high')
            ? 1
            : rec.action == 'repair'
            ? 2
            : rec.action == 'inspect' || rec.priority == 'medium'
            ? 3
            : 4;

        prioritizedMap[part.id] = PrioritizedSparepart(
          part: part,
          tier: isFunded
              ? RecommendationTier.budgetFunded
              : RecommendationTier.budgetDeferred,
          badgeText: isFunded
              ? 'Rekomendasi Budget'
              : 'Perlu Alokasi Tambahan',
          reason: rec.reason,
          componentName: rec.componentName,
          budgetRec: rec,
          fitsBudget: isFunded || fitsWithinBudget(part),
          urgencyRank: urgencyRank,
          isVerifiedFitment: isVerifiedForModel(part),
        );
      }

      // PRIORITY 2: Component Health Attention
      final criticalStatuses = statuses.where((s) {
        final st = s.status.estimatedStatus.toLowerCase();
        final score = s.status.score;
        return st == 'replace' ||
            st == 'inspect' ||
            (score != null && score < 70);
      }).toList()
        ..sort((a, b) {
          int rankOf(ComponentStatusWithName item) {
            final exp = item.status.explanation;
            final st = item.status.estimatedStatus.toLowerCase();
            final sc = item.status.score;
            if (exp.contains('KESELAMATAN') || exp.contains('KELUHAN KRITIS')) {
              return 0;
            }
            if (st == 'replace' || (sc != null && sc < 50)) return 1;
            return 2;
          }

          final rCmp = rankOf(a).compareTo(rankOf(b));
          if (rCmp != 0) return rCmp;
          return (a.status.score ?? 100).compareTo(b.status.score ?? 100);
        });

      bool doesComponentMatchPart(String compName, Sparepart part) {
        final partCat = part.category.toLowerCase().trim();
        if (compName.contains('oli gardan')) {
          return partCat == 'oli_gardan';
        }
        if (compName.contains('filter oli')) {
          return partCat == 'filter_oli';
        }
        if (compName.contains('filter udara')) {
          return partCat == 'filter_udara' || partCat == 'filter';
        }
        if (compName.contains('oli mesin') || compName == 'oli') {
          return partCat == 'oli' || partCat == 'oli_mesin';
        }
        if (compName.contains('minyak rem')) {
          return partCat == 'minyak_rem';
        }
        if (compName.contains('rem')) {
          return partCat == 'kampas_rem' || partCat == 'rem';
        }
        if (compName.contains('ban')) {
          return partCat == 'ban';
        }
        if (compName.contains('busi')) {
          return partCat == 'busi';
        }
        if (compName.contains('cvt')) {
          return partCat == 'cvt' || partCat == 'vbelt';
        }
        if (compName.contains('aki')) {
          return partCat == 'aki';
        }
        if (compName.contains('knalpot')) {
          return partCat == 'knalpot';
        }
        if (compName.contains('radiator') || compName.contains('coolant')) {
          return partCat == 'coolant';
        }
        if (compName.contains('rantai')) {
          return partCat == 'rantai';
        }
        if (compName.contains('suspensi') || compName.contains('shock')) {
          return partCat == 'shock' ||
              partCat == 'shockbreaker' ||
              partCat == 'suspensi';
        }
        return false;
      }

      for (final cs in criticalStatuses) {
        final compName = cs.componentName.toLowerCase();
        final compStatus = cs.status.estimatedStatus.toLowerCase();
        final compScore = cs.status.score;
        final isSafety =
            cs.status.explanation.contains('KESELAMATAN') ||
            cs.status.explanation.contains('KELUHAN KRITIS');
        final isReplace =
            isSafety ||
            compStatus == 'replace' ||
            (compScore != null && compScore < 50);
        final urgencyRank = isSafety ? 0 : (isReplace ? 1 : 2);

        for (final part in allParts) {
          if (prioritizedMap.containsKey(part.id)) continue;
          if (!isCompatible(part)) continue;

          if (doesComponentMatchPart(compName, part)) {
            prioritizedMap[part.id] = PrioritizedSparepart(
              part: part,
              tier: RecommendationTier.healthAttention,
              badgeText: isReplace ? 'Perlu Ganti Segera' : 'Perlu Pemeriksaan',
              reason:
                  'Kondisi ${cs.componentName} ${compScore != null ? '(${compScore.round()}%)' : ''}: ${cs.status.explanation.isNotEmpty ? cs.status.explanation : compStatus}',
              componentName: cs.componentName,
              healthScore: compScore,
              healthStatus: compStatus,
              fitsBudget: fitsWithinBudget(part),
              urgencyRank: urgencyRank,
              isVerifiedFitment: isVerifiedForModel(part),
            );
          }
        }
      }

      // PRIORITY 3: General Catalog (hanya part kompatibel, utamakan masuk anggaran)
      for (final part in allParts) {
        if (prioritizedMap.containsKey(part.id)) continue;
        if (!isCompatible(part)) continue;

        prioritizedMap[part.id] = PrioritizedSparepart(
          part: part,
          tier: RecommendationTier.generalCatalog,
          fitsBudget: fitsWithinBudget(part),
          isVerifiedFitment: isVerifiedForModel(part),
        );
      }

      // Return ordered list: Budget Funded -> Budget Deferred -> Health -> General
      final result = prioritizedMap.values.toList()
        ..sort(PrioritizedSparepart.compareByPriority);

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
