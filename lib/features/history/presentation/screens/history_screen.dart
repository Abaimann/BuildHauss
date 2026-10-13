import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/database/app_database.dart';
import '../../../../shared/widgets/buildhaus_logo.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> with SingleTickerProviderStateMixin {
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
      resizeToAvoidBottomInset: true,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 90,
            floating: true,
            pinned: true,
            backgroundColor: context.bg,
            surfaceTintColor: Colors.transparent,
            actions: activeMotor != null
                ? [
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: context.ink,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.add, color: context.bg, size: 20),
                      ),
                      onPressed: () => context.push('/history/add'),
                    ),
                    const SizedBox(width: 8),
                  ]
                : null,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [context.surface, context.bg],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(16, 56, 16, 0),
                child: Row(
                  children: [
                    const BuildHausLogoCompact(size: 36),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text('Riwayat Servis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: context.ink)),
                    ),
                    if (activeMotor != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: context.soft, borderRadius: BorderRadius.circular(99)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(activeMotor.emoji, style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 4),
                            Text(activeMotor.nickname.split(' ').first, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: context.ink)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: context.ink,
              labelColor: context.ink,
              unselectedLabelColor: context.muted,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              unselectedLabelStyle: const TextStyle(fontSize: 13),
              tabs: const [
                Tab(text: 'Servis'),
                Tab(text: 'Odometer'),
                Tab(text: 'Pengingat'),
              ],
            ),
          ),
        ],
        body: activeMotor == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.two_wheeler, size: 48, color: context.muted),
                    const SizedBox(height: 12),
                    Text('Pilih motor untuk melihat riwayat', style: TextStyle(color: context.muted)),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: () => context.go('/'), child: const Text('Ke Beranda')),
                  ],
                ),
              )
            : TabBarView(
                controller: _tabController,
                children: [
                  _ServiceHistoryTab(motorcycle: activeMotor),
                  _OdometerHistoryTab(motorcycle: activeMotor),
                  _RemindersTab(motorcycle: activeMotor),
                ],
              ),
      ),
    );
  }
}

class _ServiceHistoryTab extends ConsumerWidget {
  final Motorcycle motorcycle;
  const _ServiceHistoryTab({required this.motorcycle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);

    return FutureBuilder<List<ServiceRecord>>(
      future: db.getServiceRecords(motorcycle.id),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final records = snap.data ?? [];
        if (records.isEmpty) {
          return _EmptyState(
            icon: Icons.build_outlined,
            title: 'Belum ada riwayat servis',
            subtitle: 'Catat servis untuk melihat histori',
            onAdd: () => context.push('/history/add'),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: records.length,
          itemBuilder: (context, i) => _ServiceRecordTile(record: records[i]),
        );
      },
    );
  }
}

class _ServiceRecordTile extends StatelessWidget {
  final ServiceRecord record;
  const _ServiceRecordTile({required this.record});

  @override
  Widget build(BuildContext context) {
    final totalCost = record.totalCost;
    final costText = totalCost > 0 ? 'Rp ${totalCost.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}' : 'Gratis';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
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
                  decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.build, color: Colors.blue, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.notes ?? 'Servis',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: context.ink),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(_formatDate(record.servicedAt), style: TextStyle(fontSize: 11, color: context.muted)),
                      if (record.workshopName != null && record.workshopName!.isNotEmpty)
                        Text(record.workshopName!, style: TextStyle(fontSize: 10, color: context.muted)),
                    ],
                  ),
                ),
                Text(costText, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: BuildHausTheme.warn)),
              ],
            ),
            if (record.odometerKm != null) ...[
              const SizedBox(height: 8),
              Text(
                'Odometer: ${record.odometerKm!.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} km',
                style: TextStyle(fontSize: 10, color: context.muted),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}

class _OdometerHistoryTab extends ConsumerWidget {
  final Motorcycle motorcycle;
  const _OdometerHistoryTab({required this.motorcycle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);

    return FutureBuilder<List<OdometerLog>>(
      future: db.getOdometerLogs(motorcycle.id),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final logs = snap.data ?? [];
        if (logs.isEmpty) {
          return _EmptyState(
            icon: Icons.speed,
            title: 'Belum ada riwayat odometer',
            subtitle: 'Update odometer untuk pantau jarak',
            onAdd: () => context.push('/motor/${motorcycle.id}/odometer'),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: logs.length,
          itemBuilder: (context, i) {
            final log = logs[i];
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
                      decoration: BoxDecoration(color: BuildHausTheme.danger.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.speed, color: Colors.redAccent, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${log.odometerKm.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} km',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: context.ink),
                          ),
                          Text(_formatDate(log.recordedAt), style: TextStyle(fontSize: 11, color: context.muted)),
                        ],
                      ),
                    ),
                    Text('🛣️', style: const TextStyle(fontSize: 20)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}

class _RemindersTab extends ConsumerWidget {
  final Motorcycle motorcycle;
  const _RemindersTab({required this.motorcycle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);

    return FutureBuilder<List<LocalReminder>>(
      future: db.getReminders(motorcycle.id),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final reminders = snap.data ?? [];
        if (reminders.isEmpty) {
          return _EmptyState(
            icon: Icons.schedule,
            title: 'Belum ada pengingat',
            subtitle: 'Tambah pengingat untuk pantau servis',
            onAdd: () => context.push('/history/add'),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reminders.length,
          itemBuilder: (context, i) {
            final r = reminders[i];
            final dueDate = r.dueDate;
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
                      decoration: BoxDecoration(
                        color: r.enabled ? BuildHausTheme.ok.withValues(alpha: 0.12) : context.soft,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        r.enabled ? Icons.schedule : Icons.notifications_off_outlined,
                        color: r.enabled ? BuildHausTheme.ok : context.muted,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.reminderType,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: context.ink),
                          ),
                          if (dueDate != null) Text(_formatDate(dueDate), style: TextStyle(fontSize: 11, color: context.muted)),
                          if (r.dueOdometerKm != null) Text('Pada ${r.dueOdometerKm!.toStringAsFixed(0)} km', style: TextStyle(fontSize: 11, color: context.muted)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: r.enabled ? BuildHausTheme.ok.withValues(alpha: 0.15) : context.soft,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        r.enabled ? 'Aktif' : 'Nonaktif',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: r.enabled ? BuildHausTheme.ok : context.muted),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onAdd;

  const _EmptyState({required this.icon, required this.title, required this.subtitle, required this.onAdd});

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
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: context.ink)),
            const SizedBox(height: 6),
            Text(subtitle, style: TextStyle(fontSize: 12, color: context.muted), textAlign: TextAlign.center),
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
