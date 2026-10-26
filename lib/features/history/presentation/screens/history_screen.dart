import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/database/app_database.dart';
import '../../../../shared/widgets/animated_widgets.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeMotor = ref.watch(activeMotorcycleProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Servis'),
        backgroundColor: context.bg,
        surfaceTintColor: Colors.transparent,
        actions: [
          if (activeMotor != null)
            IconButton(
              onPressed: () => context.push('/history/add'),
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: context.ink,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.add, color: context.bg, size: 18),
              ),
            ),
          const SizedBox(width: 4),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: context.ink,
          labelColor: context.ink,
          unselectedLabelColor: context.muted,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 13),
          tabs: const [
            Tab(text: 'Servis'),
            Tab(text: 'Odometer'),
            Tab(text: 'Pengingat'),
          ],
        ),
      ),
      body: activeMotor == null
          ? _EmptyMotorState()
          : TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _ServiceTab(motorId: activeMotor.id),
                _OdometerTab(motorId: activeMotor.id),
                _ReminderTab(motorId: activeMotor.id),
              ],
            ),
    );
  }
}

class _EmptyMotorState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.two_wheeler, size: 64, color: context.muted),
            const SizedBox(height: 16),
            Text(
              'Pilih motor dulu',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Tambah atau pilih motor di halaman Beranda untuk melihat riwayat.',
              style: TextStyle(color: context.muted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Ke Beranda'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SERVIS TAB
// ─────────────────────────────────────────────
class _ServiceTab extends ConsumerWidget {
  final int motorId;
  const _ServiceTab({required this.motorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);

    return FutureBuilder<List<ServiceRecord>>(
      future: db.getServiceRecords(motorId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final records = snap.data ?? [];
        if (records.isEmpty) {
          return _EmptyStateWidget(
            icon: Icons.build_outlined,
            title: 'Belum ada riwayat servis',
            subtitle: 'Catat servis pertama kamu',
            onAdd: () => context.push('/history/add'),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: records.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) => FadeSlideIn(
            index: i,
            child: _ServiceCard(record: records[i]),
          ),
        );
      },
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ServiceRecord record;
  const _ServiceCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final cost = record.totalCost;
    final costText = cost > 0
        ? 'Rp ${cost.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}'
        : 'Gratis';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surface2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.line),
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
                  color: Colors.blue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.build, color: Colors.blue, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.notes ?? 'Servis',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: context.ink,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _fmtDate(record.servicedAt),
                      style: TextStyle(fontSize: 11, color: context.muted),
                    ),
                    if (record.workshopName != null &&
                        record.workshopName!.isNotEmpty)
                      Text(
                        record.workshopName!,
                        style: TextStyle(fontSize: 10, color: context.muted),
                      ),
                  ],
                ),
              ),
              Text(
                costText,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: BuildHausTheme.warn,
                ),
              ),
            ],
          ),
          if (record.odometerKm != null) ...[
            const SizedBox(height: 8),
            Text(
              '📍 ${record.odometerKm!.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} km',
              style: TextStyle(fontSize: 11, color: context.muted),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ODOMETER TAB
// ─────────────────────────────────────────────
class _OdometerTab extends ConsumerWidget {
  final int motorId;
  const _OdometerTab({required this.motorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);

    return FutureBuilder<List<OdometerLog>>(
      future: db.getOdometerLogs(motorId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final logs = snap.data ?? [];
        if (logs.isEmpty) {
          return _EmptyStateWidget(
            icon: Icons.speed,
            title: 'Belum ada data odometer',
            subtitle: 'Update odometer untuk pantau jarak tempuh',
            onAdd: () => context.push('/motor/$motorId/odometer'),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: logs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) => FadeSlideIn(
            index: i,
            child: _OdometerCard(log: logs[i]),
          ),
        );
      },
    );
  }
}

class _OdometerCard extends StatelessWidget {
  final OdometerLog log;
  const _OdometerCard({required this.log});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            decoration: BoxDecoration(
              color: BuildHausTheme.danger.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.speed, color: Colors.redAccent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${log.odometerKm.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} km',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: context.ink,
                  ),
                ),
                Text(
                  _fmtDate(log.recordedAt),
                  style: TextStyle(fontSize: 11, color: context.muted),
                ),
              ],
            ),
          ),
          Text('🛣️', style: const TextStyle(fontSize: 22)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// REMINDER TAB
// ─────────────────────────────────────────────
class _ReminderTab extends ConsumerWidget {
  final int motorId;
  const _ReminderTab({required this.motorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);

    return FutureBuilder<List<LocalReminder>>(
      future: db.getReminders(motorId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final reminders = snap.data ?? [];
        if (reminders.isEmpty) {
          return _EmptyStateWidget(
            icon: Icons.schedule,
            title: 'Belum ada pengingat',
            subtitle: 'Tambah pengingat untuk pantau servis',
            onAdd: () => context.push('/history/add'),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: reminders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) => FadeSlideIn(
            index: i,
            child: _ReminderCard(reminder: reminders[i]),
          ),
        );
      },
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final LocalReminder reminder;
  const _ReminderCard({required this.reminder});

  @override
  Widget build(BuildContext context) {
    final dueDate = reminder.dueDate;
    final now = DateTime.now();
    final daysLeft = dueDate != null ? dueDate.difference(now).inDays : 999;
    final isOverdue = daysLeft < 0;
    final isUrgent = daysLeft >= 0 && daysLeft <= 7;
    final color = isOverdue
        ? BuildHausTheme.danger
        : isUrgent
        ? BuildHausTheme.warn
        : BuildHausTheme.ok;

    String dueText = '';
    if (dueDate != null) {
      dueText = isOverdue
          ? 'Jatuh tempo ${-daysLeft} hari lalu'
          : daysLeft == 0
          ? 'Jatuh tempo hari ini!'
          : 'Jatuh tempo $daysLeft hari lagi';
    } else if (reminder.dueOdometerKm != null) {
      dueText = 'Pada ${reminder.dueOdometerKm!.toStringAsFixed(0)} km';
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surface2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isOverdue
              ? BuildHausTheme.danger.withValues(alpha: 0.3)
              : context.line,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: reminder.enabled
                  ? color.withValues(alpha: 0.12)
                  : context.soft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              reminder.enabled
                  ? Icons.schedule
                  : Icons.notifications_off_outlined,
              color: reminder.enabled ? color : context.muted,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.reminderType,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: context.ink,
                  ),
                ),
                if (dueText.isNotEmpty)
                  Text(dueText, style: TextStyle(fontSize: 11, color: color)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: reminder.enabled
                  ? color.withValues(alpha: 0.15)
                  : context.soft,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              reminder.enabled ? 'Aktif' : 'Nonaktif',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: reminder.enabled ? color : context.muted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────
class _EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onAdd;

  const _EmptyStateWidget({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 56, color: context.muted),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: context.ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: context.muted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Catat Sekarang'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(160, 44)),
            ),
          ],
        ),
      ),
    );
  }
}

String _fmtDate(DateTime dt) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
}
