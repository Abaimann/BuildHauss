import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/database/app_database.dart';
import '../../../../shared/widgets/buildhaus_logo.dart';

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
                  'Pilih motor untuk melihat kesehatan',
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
            expandedHeight: 100,
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
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: context.ink),
                          ),
                          Text(activeMotor.nickname, style: TextStyle(fontSize: 12, color: context.muted)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: context.soft, borderRadius: BorderRadius.circular(99)),
                      child: Text(activeMotor.emoji, style: const TextStyle(fontSize: 20)),
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
                const SizedBox(height: 20),
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
  Widget build(BuildContext context) => Text(title, style: Theme.of(context).textTheme.titleMedium);
}

class _HealthScoreCard extends ConsumerWidget {
  final Motorcycle motorcycle;
  const _HealthScoreCard({required this.motorcycle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);

    return FutureBuilder<List<ComponentStatusWithName>>(
      future: db.getComponentStatusesWithNames(motorcycle.id),
      builder: (context, snap) {
        final data = snap.data ?? [];
        final scores = data.map((d) => d.status.score ?? 0.0).toList();
        final avgScore = scores.isEmpty ? 0.0 : scores.reduce((a, b) => a + b) / scores.length;

        final color = avgScore >= 75
            ? BuildHausTheme.ok
            : avgScore >= 50
                ? BuildHausTheme.warn
                : BuildHausTheme.danger;

        final statusText = avgScore >= 85
            ? 'Sangat Baik'
            : avgScore >= 70
                ? 'Baik'
                : avgScore >= 50
                    ? 'Cukup'
                    : avgScore >= 30
                        ? 'Buruk'
                        : 'Sangat Buruk';

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.05)],
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
                      child: Stack(alignment: Alignment.center, children: [
                        SizedBox(
                          width: 56,
                          height: 56,
                          child: CircularProgressIndicator(
                            value: avgScore / 100,
                            strokeWidth: 6,
                            backgroundColor: context.soft,
                            color: color,
                          ),
                        ),
                        Text(
                          avgScore > 0 ? '${avgScore.round()}' : '?',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
                        ),
                      ]),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Skor Kesehatan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: context.ink)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(99)),
                            child: Text(statusText.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color, letterSpacing: 0.5)),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            avgScore >= 75 ? 'Kondisi motor prima!' : avgScore >= 50 ? 'Perlu perhatian lebih' : 'Perlu servis segera',
                            style: TextStyle(fontSize: 12, color: context.muted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (data.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text('${data.length} komponen dipantau', style: TextStyle(fontSize: 11, color: context.muted)),
                ],
              ],
            ),
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
                    decoration: BoxDecoration(color: Colors.indigo.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                    child: const Center(child: Text('🤖', style: TextStyle(fontSize: 18))),
                  ),
                  const SizedBox(width: 12),
                  Text('AI Rekomendasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: context.ink)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.indigo.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(99)),
                    child: const Text('OFFLINE', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.indigo)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(recommendation, style: TextStyle(fontSize: 12, color: context.muted, height: 1.5)),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => context.push('/ai-chat'),
                  icon: const Icon(Icons.auto_awesome, size: 16),
                  label: const Text('Detail Lengkap'),
                  style: TextButton.styleFrom(textStyle: const TextStyle(fontSize: 12)),
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
    final warns = statuses.where((s) => (s.status.score ?? 100) >= 50 && (s.status.score ?? 100) < 75).toList();

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
    final db = ref.watch(databaseProvider);

    return FutureBuilder<List<ComponentStatusWithName>>(
      future: db.getComponentStatusesWithNames(motorcycle.id),
      builder: (context, snap) {
        final data = snap.data ?? [];

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
                Text('Belum ada data komponen', style: TextStyle(fontWeight: FontWeight.bold, color: context.ink)),
                const SizedBox(height: 4),
                Text('Catat servis untuk melihat status', style: TextStyle(fontSize: 12, color: context.muted)),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => context.push('/history/add'),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Catat Servis'),
                  style: ElevatedButton.styleFrom(minimumSize: const Size(0, 44)),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            ...data.map((d) => _ComponentTile(data: d)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => context.push('/history/add'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: context.line),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline, color: context.muted, size: 20),
                    const SizedBox(width: 12),
                    Text('Catat Servis Baru', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: context.muted)),
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

class _ComponentTile extends StatelessWidget {
  final ComponentStatusWithName data;
  const _ComponentTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final score = data.status.score ?? 0;
    final color = score >= 75
        ? BuildHausTheme.ok
        : score >= 50
            ? BuildHausTheme.warn
            : BuildHausTheme.danger;
    final statusLabel = data.status.estimatedStatus;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.surface2,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.line),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
              child: Center(child: Text(_getEmoji(data.componentName), style: const TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data.componentName, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: context.ink)),
                  if (data.status.explanation.isNotEmpty)
                    Text(data.status.explanation, style: TextStyle(fontSize: 10, color: context.muted), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${score.round()}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(99)),
                  child: Text(statusLabel, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: color)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getEmoji(String name) {
    final n = name.toLowerCase();
    if (n.contains('rem') || n.contains('pengereman')) return '🛑';
    if (n.contains('oli') || n.contains('mesin')) return '🛢️';
    if (n.contains('rantai')) return '⛓️';
    if (n.contains('ban') || n.contains('roda')) return '🛞';
    if (n.contains('aki') || n.contains('kelistrikan')) return '🔋';
    if (n.contains('filter') || n.contains('udara')) return '🔧';
    if (n.contains('busi')) return '⚡';
    if (n.contains('cvt') || n.contains('transmisi')) return '⚙️';
    if (n.contains('knalpot')) return '🔩';
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
                Icon(Icons.check_circle_outline, color: BuildHausTheme.ok, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Tidak ada pengingat servis mendatang', style: TextStyle(color: context.muted, fontSize: 12)),
                ),
              ],
            ),
          );
        }

        return Column(
          children: reminders.take(3).map((r) => _ReminderTile(reminder: r)).toList(),
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
          border: Border.all(color: isOverdue ? BuildHausTheme.danger.withValues(alpha: 0.3) : isUrgent ? BuildHausTheme.warn.withValues(alpha: 0.3) : context.line),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
              child: Center(child: Text(isOverdue ? '⚠️' : '📅', style: const TextStyle(fontSize: 18))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(reminder.componentName, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: context.ink)),
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
