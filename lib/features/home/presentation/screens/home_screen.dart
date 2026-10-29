import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/database/app_database.dart'
    show Motorcycle, MotorcycleModel;
import '../../../../core/database/sample_data_seeder.dart';
import '../../../../shared/widgets/animated_widgets.dart';
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
              FadeSlideIn(
                index: 0,
                child: _MotorSelector(motors: motors, activeMotor: activeMotor),
              ),
              const SizedBox(height: 20),

              // Bike Card
              if (activeMotor != null) ...[
                FadeSlideIn(
                  index: 1,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.03, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: _BikeCard(
                      key: ValueKey('bike_card_${activeMotor!.id}'),
                      motorcycle: activeMotor!,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Quick Actions
              FadeSlideIn(
                index: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Health Summary
              FadeSlideIn(
                index: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle('Ringkasan Kesehatan'),
                    const SizedBox(height: 10),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      child: _HealthSummary(
                        key: ValueKey('health_summary_${activeMotor?.id}'),
                        activeMotor: activeMotor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Reminder Notice
              FadeSlideIn(
                index: 4,
                child: _ReminderNotice(),
              ),
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
          return TapScale(
            onTap: () => ref
                .read(activeMotorcycleProvider.notifier)
                .setActiveMotorcycle(m),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              width: 82,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isActive
                      ? const [Color(0xFF162334), Color(0xFF0F1824)]
                      : [context.surface2, context.surface],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isActive ? const Color(0xFF00F5A0) : context.line,
                  width: isActive ? 1.6 : 1.0,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: const Color(0xFF00F5A0).withValues(alpha: 0.18),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
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
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isActive) ...[
                          const PulseLed(color: Color(0xFF00F5A0), size: 5),
                          const SizedBox(width: 4),
                        ],
                        _BrandBadge(
                          modelId: m.modelId,
                          fontSize: 9,
                          color: isActive ? const Color(0xFF00F5A0) : context.ink,
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      m.nickname.split(' ').first,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      m.manufactureYear.toString(),
                      style: TextStyle(
                        fontSize: 8.5,
                        color: context.muted,
                        fontWeight: FontWeight.w500,
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

  const _BikeCard({super.key, required this.motorcycle});

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
        return Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF131D2B),
                Color(0xFF090D14),
              ],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFF00F5A0).withValues(alpha: 0.3),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00F5A0).withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00F5A0).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(
                          color: const Color(0xFF00F5A0).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const PulseLed(color: Color(0xFF00F5A0), size: 6.5),
                          const SizedBox(width: 6),
                          const Text(
                            'MOTOR UTAMA',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF00F5A0),
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Flexible(
                      child: _BrandBadge(
                        modelId: motorcycle.modelId,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  motorcycle.nickname,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (motorcycle.plateNumber != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Text(
                      motorcycle.plateNumber!,
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.speed_rounded,
                                size: 12,
                                color: const Color(0xFF00F5A0),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'TELEMETRI ODOMETER',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white.withValues(alpha: 0.6),
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          if (odo != null)
                            TweenAnimationBuilder<double>(
                              key: ValueKey('odo_${motorcycle.id}_${odo.odometerKm}'),
                              tween: Tween<double>(
                                begin: 0,
                                end: odo.odometerKm,
                              ),
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.easeOutQuart,
                              builder: (context, animatedKm, _) {
                                final formatted = animatedKm
                                    .toStringAsFixed(0)
                                    .replaceAllMapped(
                                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                      (m) => '${m[1]},',
                                    );
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      formatted,
                                      style: const TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: -1.0,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 1.5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF00F5A0).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'km',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF00F5A0),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            )
                          else
                            const Text(
                              'Belum ada data',
                              style: TextStyle(
                                fontSize: 26,
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
                    TapScale(
                      onTap: () =>
                          context.push('/motor/${motorcycle.id}/odometer'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.edit_outlined,
                              size: 14,
                              color: Colors.white,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Update',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
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
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: color.withValues(alpha: 0.28),
                width: 1.0,
              ),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 11,
              color: context.ink,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 1),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w500,
              color: context.muted,
            ),
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
    return TapScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.surface2,
              context.surface,
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: context.line, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class _HealthSummary extends ConsumerWidget {
  final Motorcycle? activeMotor;

  const _HealthSummary({super.key, this.activeMotor});

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

        return TweenAnimationBuilder<double>(
          key: ValueKey('health_bar_${activeMotor?.id}_$avgScore'),
          tween: Tween<double>(begin: 0, end: avgScore),
          duration: const Duration(milliseconds: 550),
          curve: Curves.easeOutCubic,
          builder: (context, animatedScore, _) {
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
                            hasEvidence ? '${animatedScore.round()}' : '?',
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
                              style: TextStyle(
                                fontSize: 11,
                                color: context.muted,
                              ),
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
                      value: animatedScore / 100,
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
