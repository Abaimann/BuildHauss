import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/database/app_database.dart'
    show Motorcycle, MotorcycleModel;
import '../../../../core/database/sample_data_seeder.dart';
import '../../../../shared/widgets/buildhaus_logo.dart';

// Helper widget to show brand name instead of emoji
class _BrandBadge extends ConsumerWidget {
  final int? modelId;
  final double fontSize;
  final Color? color;

  const _BrandBadge({required this.modelId, this.fontSize = 20, this.color});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (modelId == null) return const SizedBox.shrink();
    final db = ref.watch(databaseProvider);
    return FutureBuilder<MotorcycleModel?>(
      future: db.getMotorcycleModelById(modelId!),
      builder: (context, snap) {
        final model = snap.data;
        if (model == null) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: context.ink.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            model.brand,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: color ?? context.ink,
            ),
          ),
        );
      },
    );
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final motorsAsync = ref.watch(motorcyclesProvider);
    final activeMotor = ref.watch(activeMotorcycleProvider);

    return Scaffold(
      body: motorsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (motors) {
          if (motors.isEmpty) {
            return _buildEmptyState(context, ref);
          }
          return _HomeContent(motors: motors, activeMotor: activeMotor);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const BuildHausLogoCompact(size: 80),
            const SizedBox(height: 32),
            Text(
              'Selamat Datang di BuildHaus',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Rawat motor dengan lebih terencana.\nSemua data tersimpan offline di HP kamu.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.push('/add-motor'),
                icon: const Icon(Icons.add),
                label: const Text('Tambah Motor Pertama'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final db = ref.read(databaseProvider);
                  await SampleDataSeeder(db).seedRealisticSampleMotorcycles();
                  ref.invalidate(motorcyclesProvider);
                  ref.invalidate(activeMotorcycleProvider);
                },
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Muat 3 Data Motor Contoh'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeContent extends ConsumerWidget {
  final List<Motorcycle> motors;
  final Motorcycle? activeMotor;

  const _HomeContent({required this.motors, this.activeMotor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        // App Bar with Logo
        SliverAppBar(
          expandedHeight: 120,
          floating: true,
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
              padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
              child: Row(
                children: [
                  const BuildHausLogo(size: 44),
                  const Spacer(),
                  _GreetingChip(context),
                ],
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_outline),
              onPressed: () => context.go('/account'),
            ),
            const SizedBox(width: 8),
          ],
        ),

        // Content
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Motor Selector
              _MotorSelector(motors: motors, activeMotor: activeMotor),
              const SizedBox(height: 20),

              // Bike Card
              if (activeMotor != null) ...[
                _BikeCard(motorcycle: activeMotor!),
                const SizedBox(height: 24),
              ],

              // Quick Actions
              _SectionTitle('Aksi Cepat'),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.favorite_outline,
                      label: 'Kesehatan',
                      subtitle: 'Monitor kondisi',
                      color: BuildHausTheme.ok,
                      onTap: () => context.go('/health'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.smart_toy_outlined,
                      label: 'Konsultasi AI',
                      subtitle: 'Analisis keluhan',
                      color: Colors.purple,
                      onTap: () => context.push('/ai-chat'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'Atur Budget',
                      subtitle: 'Prioritas servis',
                      color: BuildHausTheme.warn,
                      onTap: () => context.go('/budget'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.build_outlined,
                      label: 'Cari Sparepart',
                      subtitle: 'Katalog resmi',
                      color: Colors.blue,
                      onTap: () => context.go('/parts'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Health Summary
              _SectionTitle('Ringkasan Kesehatan'),
              const SizedBox(height: 10),
              _HealthSummary(activeMotor: activeMotor),
              const SizedBox(height: 24),

              // Reminder Notice
              _ReminderNotice(),
              const SizedBox(height: 20),

              // Bottom padding for nav bar
              const SizedBox(height: 20),
            ]),
          ),
        ),
      ],
    );
  }
}

class _GreetingChip extends StatelessWidget {
  final BuildContext context;
  const _GreetingChip(this.context);

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting;
    String emoji;
    if (hour < 12) {
      greeting = 'Pagi';
      emoji = '☀️';
    } else if (hour < 15) {
      greeting = 'Siang';
      emoji = '🌤️';
    } else if (hour < 18) {
      greeting = 'Sore';
      emoji = '🌅';
    } else {
      greeting = 'Malam';
      emoji = '🌙';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: context.surface2,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: context.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            greeting,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: context.ink,
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
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleMedium);
  }
}

class _MotorSelector extends ConsumerWidget {
  final List<Motorcycle> motors;
  final Motorcycle? activeMotor;

  const _MotorSelector({required this.motors, this.activeMotor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: motors.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final m = motors[i];
          final isActive = activeMotor?.id == m.id;
          return GestureDetector(
            onTap: () => ref
                .read(activeMotorcycleProvider.notifier)
                .setActiveMotorcycle(m),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 76,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isActive ? context.ink : context.surface2,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isActive ? context.ink : context.line,
                  width: isActive ? 2 : 1,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: FittedBox(
                fit: BoxFit.contain,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _BrandBadge(
                      modelId: m.modelId,
                      fontSize: 10,
                      color: isActive ? context.bg : context.ink,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      m.nickname.split(' ').first,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isActive ? context.bg : context.ink,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      m.manufactureYear.toString(),
                      style: TextStyle(
                        fontSize: 8,
                        color: isActive
                            ? context.bg.withValues(alpha: 0.6)
                            : context.muted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BikeCard extends ConsumerWidget {
  final Motorcycle motorcycle;

  const _BikeCard({required this.motorcycle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final odoAsync = ref.watch(latestOdometerProvider(motorcycle.id));

    return odoAsync.when(
      loading: () => Container(
        height: 140,
        decoration: BoxDecoration(
          color: context.surface2,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (odo) {
        final odoText = odo != null
            ? '${odo.odometerKm.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} km'
            : 'Belum ada data';

        return Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1a2a1a), Color(0xFF0f1a0f)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: BuildHausTheme.ok.withValues(alpha: 0.2)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: BuildHausTheme.ok.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            size: 12,
                            color: Color(0xFF3da96e),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'MOTOR UTAMA',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF3da96e),
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Flexible(
                      child: _BrandBadge(
                        modelId: motorcycle.modelId,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  motorcycle.nickname,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (motorcycle.plateNumber != null)
                  Text(
                    motorcycle.plateNumber!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Odometer',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            odoText,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () =>
                          context.push('/motor/${motorcycle.id}/odometer'),
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('Update'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white.withValues(alpha: 0.7),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _CardWrapper(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 14),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 10,
              color: context.ink,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 9, color: context.muted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _CardWrapper extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const _CardWrapper({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.surface2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.line),
        ),
        child: child,
      ),
    );
  }
}

class _HealthSummary extends ConsumerWidget {
  final Motorcycle? activeMotor;

  const _HealthSummary({this.activeMotor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (activeMotor == null) return const SizedBox.shrink();

    final statusesAsync = ref.watch(
      componentStatusesWithNamesProvider(activeMotor!.id),
    );

    return statusesAsync.when(
      loading: () => Container(
        height: 100,
        decoration: BoxDecoration(
          color: context.surface2,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (statuses) {
        if (statuses.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.surface2,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.line),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: context.muted, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Belum ada data kesehatan. Catat servis untuk melihat status komponen.',
                    style: TextStyle(color: context.muted, fontSize: 12),
                  ),
                ),
              ],
            ),
          );
        }

        final validScores = statuses
            .where((s) => s.status.score != null)
            .map((s) => s.status.score!)
            .toList();
        final hasEvidence = validScores.isNotEmpty;
        final avgScore = hasEvidence
            ? validScores.reduce((a, b) => a + b) / validScores.length
            : 0.0;

        final statusColor = !hasEvidence
            ? context.muted
            : avgScore >= 75
            ? BuildHausTheme.ok
            : avgScore >= 50
            ? BuildHausTheme.warn
            : BuildHausTheme.danger;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.surface2,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.line),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        hasEvidence ? '${avgScore.round()}' : '?',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Skor Kesehatan',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: context.ink,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          !hasEvidence
                              ? 'Belum cukup data riwayat servis'
                              : avgScore >= 75
                              ? 'Baik — semua komponen prima'
                              : avgScore >= 50
                              ? 'Perlu perhatian — beberapa komponen perlu dicek'
                              : 'Perlu segera ditangani',
                          style: TextStyle(fontSize: 11, color: context.muted),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/health'),
                    child: const Text('Detail'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: avgScore / 100,
                  backgroundColor: context.soft,
                  color: statusColor,
                  minHeight: 8,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ReminderNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: BuildHausTheme.warnBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BuildHausTheme.warn.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: BuildHausTheme.warn.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text('🔔', style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pengingat',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: BuildHausTheme.warn,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Periksa kampas rem secara berkala untuk keselamatan.',
                  style: TextStyle(
                    fontSize: 11,
                    color: context.muted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
