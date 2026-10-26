import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/database/app_database.dart';
import '../../../../shared/widgets/buildhaus_logo.dart';
import '../../../../core/utils/formatters.dart';

class HealthScreen extends ConsumerWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeMotor = ref.watch(activeMotorcycleProvider);

    if (activeMotor == null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.two_wheeler, size: 64, color: context.muted),
                const SizedBox(height: 16),
                Text(
                  'Pilih Motor Dulu',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Pilih motor untuk melihat estimasi kesehatan',
                  style: TextStyle(color: context.muted),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('Ke Beranda'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: context.bg,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [context.surface, context.bg],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(16, 60, 16, 0),
                child: Row(
                  children: [
                    const BuildHausLogoCompact(size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Kesehatan Motor',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: context.ink,
                            ),
                          ),
                          Text(
                            activeMotor.nickname,
                            style: TextStyle(
                              fontSize: 12,
                              color: context.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: context.soft,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: _HealthBrandLabel(modelId: activeMotor.modelId),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _HealthScoreCard(motorcycle: activeMotor),
                const SizedBox(height: 16),
                _MileagePredictionHealthCard(motorcycle: activeMotor),
                const SizedBox(height: 16),
                _SelfInspectionBanner(motorcycle: activeMotor),
                const SizedBox(height: 16),
                _AIRecommendationCard(motorcycle: activeMotor),
                const SizedBox(height: 24),
                _SectionTitle('Status Komponen'),
                const SizedBox(height: 10),
                _ComponentStatusSection(motorcycle: activeMotor),
                const SizedBox(height: 24),
                _SectionTitle('Pengingat Servis'),
                const SizedBox(height: 10),
                _RemindersSection(motorcycle: activeMotor),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);
  @override
  Widget build(BuildContext context) =>
      Text(title, style: Theme.of(context).textTheme.titleMedium);
}

class _HealthBrandLabel extends ConsumerWidget {
  final int? modelId;
  const _HealthBrandLabel({required this.modelId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (modelId == null) return const SizedBox.shrink();
    final db = ref.watch(databaseProvider);
    return FutureBuilder<MotorcycleModel?>(
      future: db.getMotorcycleModelById(modelId!),
      builder: (context, snap) {
        final model = snap.data;
        if (model == null) return const SizedBox.shrink();
        return Text(
          model.brand,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        );
      },
    );
  }
}

class _HealthScoreCard extends ConsumerWidget {
  final Motorcycle motorcycle;
  const _HealthScoreCard({required this.motorcycle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusesAsync = ref.watch(
      componentStatusesWithNamesProvider(motorcycle.id),
    );

    return statusesAsync.when(
      loading: () => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: context.surface2,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (data) {
        final scores = data
            .where((d) => d.status.score != null)
            .map((d) => d.status.score!)
            .toList();
        final hasEvidence = scores.isNotEmpty;
        final avgScore = hasEvidence
            ? scores.reduce((a, b) => a + b) / scores.length
            : 0.0;

        final color = !hasEvidence
            ? context.muted
            : avgScore >= 75
            ? BuildHausTheme.ok
            : avgScore >= 50
            ? BuildHausTheme.warn
            : BuildHausTheme.danger;

        final statusText = !hasEvidence
            ? 'Belum cukup data'
            : avgScore >= 85
            ? 'Sangat Baik'
            : avgScore >= 70
            ? 'Baik'
            : avgScore >= 50
            ? 'Cukup'
            : avgScore >= 30
            ? 'Perlu Perhatian'
            : 'Perlu Penanganan';

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.15),
                color.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 56,
                            height: 56,
                            child: CircularProgressIndicator(
                              value: hasEvidence ? avgScore / 100 : null,
                              strokeWidth: 6,
                              backgroundColor: context.soft,
                              color: color,
                            ),
                          ),
                          Text(
                            hasEvidence ? '${avgScore.round()}' : '?',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Skor Kesehatan',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: context.ink,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              statusText.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: color,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            !hasEvidence
                                ? 'Status belum dapat dipastikan dari data tersedia'
                                : 'Estimasi berdasarkan riwayat dan interval, bukan pengukuran keausan fisik.',
                            style: TextStyle(
                              fontSize: 11,
                              color: context.muted,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (data.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${data.length} komponen dipantau',
                        style: TextStyle(fontSize: 11, color: context.muted),
                      ),
                      Text(
                        'Profil: ${motorcycle.usageProfile.replaceAll('_', ' ')}',
                        style: TextStyle(fontSize: 11, color: context.muted),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MileagePredictionHealthCard extends ConsumerWidget {
  final Motorcycle motorcycle;
  const _MileagePredictionHealthCard({required this.motorcycle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final predictorAsync = ref.watch(mileagePredictorProvider(motorcycle.id));

    return predictorAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (predictor) {
        final isLearning = predictor.isLearningPhase;
        final periods = predictor.validMonthlyPeriodsCount;
        final kmWeek = predictor.kmPerWeek;
        final kmMonth = predictor.kmPerMonth;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.surface2,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isLearning
                          ? context.soft
                          : BuildHausTheme.ok.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        isLearning ? '⏳' : '📈',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isLearning
                              ? 'Masa Pembelajaran Odometer'
                              : 'Estimasi Penggunaan Terkalibrasi',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: context.ink,
                          ),
                        ),
                        Text(
                          isLearning
                              ? 'Periode $periods/3 bulan terpantau'
                              : 'Akurasi tinggi dari 3+ periode bulanan',
                          style: TextStyle(fontSize: 10, color: context.muted),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        context.push('/motor/${motorcycle.id}/odometer'),
                    child: const Text('Update Odo'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (isLearning) ...[
                Text(
                  predictor.learningStatusMessage,
                  style: TextStyle(
                    fontSize: 11,
                    color: context.muted,
                    height: 1.4,
                  ),
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: context.soft,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rata-rata/minggu',
                              style: TextStyle(
                                fontSize: 9,
                                color: context.muted,
                              ),
                            ),
                            Text(
                              '${kmWeek.toStringAsFixed(0)} km',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: context.ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: context.soft,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rata-rata/bulan',
                              style: TextStyle(
                                fontSize: 9,
                                color: context.muted,
                              ),
                            ),
                            Text(
                              '${kmMonth.toStringAsFixed(0)} km',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: context.ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _SelfInspectionBanner extends ConsumerWidget {
  final Motorcycle motorcycle;
  const _SelfInspectionBanner({required this.motorcycle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inspectionAsync = ref.watch(
      latestSelfInspectionProvider(motorcycle.id),
    );

    return inspectionAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (inspection) {
        final hasInspection = inspection != null;
        final isHighRisk = inspection?.riskLevel == 'high';
        final isMediumRisk = inspection?.riskLevel == 'medium';

        final cardColor = isHighRisk
            ? BuildHausTheme.danger
            : isMediumRisk
            ? BuildHausTheme.warn
            : context.line;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isHighRisk ? BuildHausTheme.dangerBg : context.surface2,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHighRisk
                  ? BuildHausTheme.danger.withValues(alpha: 0.5)
                  : cardColor,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    isHighRisk
                        ? '🚨'
                        : isMediumRisk
                        ? '⚠️'
                        : '📋',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isHighRisk
                              ? 'Peringatan Pemeriksaan Mandiri'
                              : 'Pemeriksaan Mandiri Motor',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: isHighRisk
                                ? BuildHausTheme.danger
                                : context.ink,
                          ),
                        ),
                        Text(
                          hasInspection
                              ? 'Terakhir: ${inspection.inspectedAt.toString().substring(0, 10)} (${inspection.riskLevel?.toUpperCase() ?? 'NORMAL'})'
                              : 'Amati kondisi fisik rem, ban, oli, dan kemudi secara berkala',
                          style: TextStyle(
                            fontSize: 10,
                            color: isHighRisk
                                ? BuildHausTheme.danger
                                : context.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () =>
                        context.push('/motor/${motorcycle.id}/inspection'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      minimumSize: const Size(0, 36),
                    ),
                    child: Text(hasInspection ? 'Uji Ulang' : 'Mulai Cek'),
                  ),
                ],
              ),
              if (isHighRisk) ...[
                const SizedBox(height: 8),
                Text(
                  '⚠️ Terdapat indikasi masalah penting pada motor Anda. Utamakan keselamatan dan periksakan ke bengkel sebelum digunakan jarak jauh.',
                  style: TextStyle(
                    fontSize: 11,
                    color: BuildHausTheme.danger,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _AIRecommendationCard extends ConsumerWidget {
  final Motorcycle motorcycle;
  const _AIRecommendationCard({required this.motorcycle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);

    return FutureBuilder<String>(
      future: _getAIRecommendation(db, motorcycle.id),
      builder: (context, snap) {
        final recommendation = snap.data ?? 'Memuat rekomendasi...';
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.surface2,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.indigo.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text('🤖', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'AI Rekomendasi',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: context.ink,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.indigo.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: const Text(
                      'OFFLINE',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                recommendation,
                style: TextStyle(
                  fontSize: 12,
                  color: context.muted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => context.push('/ai-chat'),
                  icon: const Icon(Icons.auto_awesome, size: 16),
                  label: const Text('Detail Lengkap'),
                  style: TextButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String> _getAIRecommendation(AppDatabase db, int motorId) async {
    final statuses = await db.getComponentStatusesWithNames(motorId);
    final reminders = await db.getUpcomingReminders(motorId);

    final urgent = statuses.where((s) => (s.status.score ?? 100) < 50).toList();
    final warns = statuses
        .where(
          (s) => (s.status.score ?? 100) >= 50 && (s.status.score ?? 100) < 75,
        )
        .toList();

    if (urgent.isNotEmpty) {
      return '⚠️ ${urgent.first.componentName} dalam kondisi kritis. Disarankan untuk segera ditangani di bengkel.';
    }
    if (warns.isNotEmpty) {
      return '🔧 ${warns.map((w) => w.componentName).join(', ')} perlu perhatian. Periksa di layanan servis terdekat.';
    }
    if (reminders.isNotEmpty) {
      return '📅 ${reminders.length} pengingat servis menunggu. Cek jadwal untuk detail.';
    }
    return '✅ Motor dalam kondisi baik. Lakukan pengecekan rutin setiap 1.000 km untuk memastikan semua komponen prima.';
  }
}

class _ComponentStatusSection extends ConsumerWidget {
  final Motorcycle motorcycle;
  const _ComponentStatusSection({required this.motorcycle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusesAsync = ref.watch(
      componentStatusesWithNamesProvider(motorcycle.id),
    );

    return statusesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text('Error: $e'),
      data: (data) {
        if (data.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.surface2,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.line),
            ),
            child: Column(
              children: [
                Icon(Icons.build_outlined, size: 40, color: context.muted),
                const SizedBox(height: 12),
                Text(
                  'Belum ada data komponen',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: context.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Catat servis untuk melihat status',
                  style: TextStyle(fontSize: 12, color: context.muted),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => context.push('/history/add'),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Catat Servis'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 44),
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            ...data.map((d) => _ComponentTile(data: d, motorcycle: motorcycle)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => context.push('/history/add'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: context.line),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      color: context.muted,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Catat Servis Baru',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: context.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ComponentTile extends ConsumerWidget {
  final ComponentStatusWithName data;
  final Motorcycle motorcycle;
  const _ComponentTile({required this.data, required this.motorcycle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final score = data.status.score;
    final color = score == null
        ? context.muted
        : score >= 75
        ? BuildHausTheme.ok
        : score >= 50
        ? BuildHausTheme.warn
        : BuildHausTheme.danger;

    String displayLabel;
    switch (data.status.estimatedStatus) {
      case 'good':
        displayLabel = 'NORMAL';
        break;
      case 'inspect':
        displayLabel = 'PERIKSA';
        break;
      case 'replace':
        displayLabel = 'GANTI';
        break;
      default:
        displayLabel = 'BELUM CUKUP DATA';
    }

    final isSafetyIssue = data.status.explanation.contains('KESELAMATAN');

    final allParts = ref.watch(allSparepartsProvider).value ?? [];
    final allFitments = ref.watch(allSparepartFitmentsProvider).value ?? [];
    final matchedParts = _getMatchingParts(
      componentName: data.componentName,
      allSpareparts: allParts,
      fitments: allFitments,
      modelId: motorcycle.modelId,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _showComponentPartsModal(
          context,
          data,
          matchedParts,
          motorcycle,
        ),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.surface2,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSafetyIssue
                  ? BuildHausTheme.danger.withValues(alpha: 0.4)
                  : context.line,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        _getEmoji(data.componentName),
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              data.componentName,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: context.ink,
                              ),
                            ),
                            if (isSafetyIssue) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: BuildHausTheme.dangerBg,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'SAFETY',
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: BuildHausTheme.danger,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (data.status.explanation.isNotEmpty)
                          Text(
                            data.status.explanation,
                            style: TextStyle(fontSize: 10, color: context.muted),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        score == null ? '—' : '${score.round()}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: color,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          displayLabel,
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (matchedParts.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: context.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: context.line.withValues(alpha: 0.7),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.build_circle_outlined,
                        size: 13,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${matchedParts.first.name} · ${Formatters.currency(matchedParts.first.referencePrice ?? 0)}',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: context.ink,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: context.soft,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${matchedParts.length} part',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: context.muted,
                          ),
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.chevron_right,
                        size: 14,
                        color: context.muted,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showComponentPartsModal(
    BuildContext context,
    ComponentStatusWithName data,
    List<Sparepart> matchedParts,
    Motorcycle motorcycle,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: context.muted.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: context.soft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            _getEmoji(data.componentName),
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.componentName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Motor: ${motorcycle.nickname}',
                              style: TextStyle(
                                fontSize: 11,
                                color: context.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (data.status.score != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: context.soft,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Skor: ${data.status.score!.round()}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.surface2,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      data.status.explanation,
                      style: TextStyle(fontSize: 12, color: context.ink),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pilihan Sparepart (${matchedParts.length})',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          context.go('/parts');
                        },
                        child: const Text('Buka Katalog ➔'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (matchedParts.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'Belum ada sparepart terdaftar untuk komponen ini di katalog lokal.',
                          style: TextStyle(color: context.muted, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    ...matchedParts.map(
                      (part) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: context.surface2,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: part.isVerified
                                ? BuildHausTheme.ok.withValues(alpha: 0.3)
                                : context.line,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          part.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (part.isVerified) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                            vertical: 1,
                                          ),
                                          decoration: BoxDecoration(
                                            color: BuildHausTheme.ok.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            'OEM RESMI',
                                            style: TextStyle(
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                              color: BuildHausTheme.ok,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${part.brand ?? 'Aftermarket'} · Part #${part.partNumber ?? '-'}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: context.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              Formatters.currency(part.referencePrice ?? 0),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.push('/history/add');
                    },
                    icon: const Icon(Icons.add_task, size: 18),
                    label: const Text('Catat Servis Komponen Ini'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<Sparepart> _getMatchingParts({
    required String componentName,
    required List<Sparepart> allSpareparts,
    required List<SparepartFitment> fitments,
    int? modelId,
  }) {
    final n = componentName.toLowerCase();
    List<String> targetCategories;
    List<String> nameKeywords;

    if (n.contains('minyak rem')) {
      targetCategories = ['minyak_rem'];
      nameKeywords = ['minyak rem', 'brake fluid', 'dot 3', 'dot 4'];
    } else if (n.contains('oli gardan')) {
      targetCategories = ['oli_gardan'];
      nameKeywords = ['oli gardan', 'gear oil', 'final gear'];
    } else if (n.contains('filter oli')) {
      targetCategories = ['filter_oli'];
      nameKeywords = ['filter oli', 'oil filter'];
    } else if (n.contains('filter udara') || n.contains('filter')) {
      targetCategories = ['filter'];
      nameKeywords = ['filter udara', 'air filter'];
    } else if (n.contains('oli') || n.contains('mesin')) {
      targetCategories = ['oli'];
      nameKeywords = ['oli', 'engine oil', '10w-40', '10w-30'];
    } else if (n.contains('kampas rem') || n.contains('rem')) {
      targetCategories = ['rem'];
      nameKeywords = ['kampas rem', 'brake pad', 'brake shoe', 'dispad'];
    } else if (n.contains('ban')) {
      targetCategories = ['ban'];
      nameKeywords = ['ban', 'tire', 'tubeless'];
    } else if (n.contains('busi')) {
      targetCategories = ['busi'];
      nameKeywords = ['busi', 'spark plug'];
    } else if (n.contains('cvt')) {
      targetCategories = ['cvt'];
      nameKeywords = ['cvt', 'v-belt', 'roller', 'vanbelt'];
    } else if (n.contains('aki')) {
      targetCategories = ['aki'];
      nameKeywords = ['aki', 'battery', 'accu'];
    } else if (n.contains('coolant') || n.contains('radiator')) {
      targetCategories = ['coolant'];
      nameKeywords = ['coolant', 'radiator'];
    } else if (n.contains('rantai')) {
      targetCategories = ['rantai'];
      nameKeywords = ['rantai', 'gir', 'gear', 'chain'];
    } else if (n.contains('suspensi') || n.contains('shock')) {
      targetCategories = ['shock'];
      nameKeywords = ['shock', 'suspensi', 'absorber'];
    } else if (n.contains('knalpot')) {
      targetCategories = ['knalpot'];
      nameKeywords = ['knalpot', 'exhaust', 'muffler'];
    } else {
      targetCategories = [];
      nameKeywords = [n];
    }

    // First, strictly match by defined category
    var candidates = allSpareparts.where((p) {
      final cat = p.category.toLowerCase();
      return targetCategories.contains(cat);
    }).toList();

    // If no exact category match found, fallback to name keywords
    if (candidates.isEmpty) {
      candidates = allSpareparts.where((p) {
        final name = p.name.toLowerCase();
        return nameKeywords.any((k) => name.contains(k));
      }).toList();
    }

    if (modelId != null && fitments.isNotEmpty) {
      final verifiedPartIds = fitments
          .where((f) => f.modelId == modelId)
          .map((f) => f.sparepartId)
          .toSet();
      candidates.sort((a, b) {
        final aVerified = verifiedPartIds.contains(a.id);
        final bVerified = verifiedPartIds.contains(b.id);
        if (aVerified && !bVerified) return -1;
        if (!aVerified && bVerified) return 1;
        return (a.referencePrice ?? 0).compareTo(b.referencePrice ?? 0);
      });
    }

    return candidates;
  }

  String _getEmoji(String name) {
    final n = name.toLowerCase();
    if (n.contains('minyak rem')) return '💧';
    if (n.contains('oli gardan')) return '⚙️';
    if (n.contains('filter oli')) return '🧴';
    if (n.contains('filter udara') || n.contains('filter')) return '🌬️';
    if (n.contains('oli') || n.contains('mesin')) return '🛢️';
    if (n.contains('rem') || n.contains('pengereman')) return '🛑';
    if (n.contains('rantai')) return '⛓️';
    if (n.contains('ban') || n.contains('roda')) return '🛞';
    if (n.contains('aki') || n.contains('kelistrikan')) return '🔋';
    if (n.contains('busi')) return '⚡';
    if (n.contains('cvt') || n.contains('transmisi')) return '⚙️';
    if (n.contains('coolant') || n.contains('radiator')) return '🧊';
    if (n.contains('suspensi') || n.contains('shock')) return '🛵';
    if (n.contains('knalpot')) return '💨';
    return '🔩';
  }
}

class _RemindersSection extends ConsumerWidget {
  final Motorcycle motorcycle;
  const _RemindersSection({required this.motorcycle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);

    return FutureBuilder<List<UpcomingReminder>>(
      future: db.getUpcomingReminders(motorcycle.id),
      builder: (context, snap) {
        final reminders = snap.data ?? [];

        if (reminders.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.surface2,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.line),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: BuildHausTheme.ok,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tidak ada pengingat servis mendesak',
                    style: TextStyle(color: context.muted, fontSize: 12),
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: reminders
              .take(3)
              .map((r) => _ReminderTile(reminder: r))
              .toList(),
        );
      },
    );
  }
}

class _ReminderTile extends StatelessWidget {
  final UpcomingReminder reminder;
  const _ReminderTile({required this.reminder});

  @override
  Widget build(BuildContext context) {
    final dueDate = reminder.reminder.dueDate;
    final now = DateTime.now();
    final daysLeft = dueDate != null ? dueDate.difference(now).inDays : 999;
    final isOverdue = daysLeft < 0;
    final isUrgent = daysLeft >= 0 && daysLeft <= 7;

    final color = isOverdue
        ? BuildHausTheme.danger
        : isUrgent
        ? BuildHausTheme.warn
        : BuildHausTheme.ok;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.surface2,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isOverdue
                ? BuildHausTheme.danger.withValues(alpha: 0.3)
                : isUrgent
                ? BuildHausTheme.warn.withValues(alpha: 0.3)
                : context.line,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  isOverdue ? '⚠️' : '📅',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder.componentName,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: context.ink,
                    ),
                  ),
                  if (dueDate != null)
                    Text(
                      isOverdue
                          ? 'Jatuh tempo ${-daysLeft} hari lalu'
                          : daysLeft == 0
                          ? 'Jatuh tempo hari ini!'
                          : 'Jatuh tempo $daysLeft hari lagi',
                      style: TextStyle(fontSize: 10, color: color),
                    )
                  else if (reminder.reminder.dueOdometerKm != null)
                    Text(
                      'Pada ${reminder.reminder.dueOdometerKm!.toStringAsFixed(0)} km',
                      style: TextStyle(fontSize: 10, color: color),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
