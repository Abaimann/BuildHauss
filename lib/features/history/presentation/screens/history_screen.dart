import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/engines/reminder_sample_helper.dart';
import '../../../../core/utils/formatters.dart';
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
        title: const Text(
          'Riwayat Servis',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.two_wheeler, size: 64, color: context.muted),
            const SizedBox(height: 16),
            Text(
              'Pilih motor dulu',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
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
              child: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text('Ke Beranda', maxLines: 1),
              ),
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
    final recordsAsync = ref.watch(serviceRecordsProvider(motorId));
    final expenseAsync = ref.watch(motorcycleExpenseSummaryProvider(motorId));

    return recordsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Gagal memuat riwayat: $e')),
      data: (records) {
        final summary =
            expenseAsync.value ??
            const MotorcycleExpenseSummary(
              totalAllCost: 0,
              totalMonthCost: 0,
              totalPartsCost: 0,
              totalLaborCost: 0,
              recordCount: 0,
            );

        if (records.isEmpty) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _ExpenseSummaryCard(motorId: motorId, summary: summary),
              ),
              Expanded(
                child: _EmptyStateWidget(
                  icon: Icons.build_outlined,
                  title: 'Belum ada riwayat servis',
                  subtitle: 'Catat servis atau pengeluaran pertama kamu',
                  onAdd: () => context.push('/history/add'),
                ),
              ),
            ],
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: records.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            if (i == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: _ExpenseSummaryCard(motorId: motorId, summary: summary),
              );
            }
            return FadeSlideIn(
              index: i - 1,
              child: _ServiceCard(record: records[i - 1]),
            );
          },
        );
      },
    );
  }
}

class _ExpenseSummaryCard extends StatelessWidget {
  final int motorId;
  final MotorcycleExpenseSummary summary;

  const _ExpenseSummaryCard({required this.motorId, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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
              Icon(
                Icons.payments_outlined,
                color: BuildHausTheme.warn,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Ringkasan Biaya Perawatan',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: context.ink,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 132),
                child: TextButton.icon(
                  key: const ValueKey('history_add_expense_button'),
                  onPressed: () => context.push('/motor/$motorId/expense/add'),
                  icon: const Icon(Icons.receipt_long_outlined, size: 15),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('+ Pengeluaran', maxLines: 1),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    minimumSize: const Size(0, 32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ExpenseStatChip(
                  label: 'Total Semua',
                  value: Formatters.currency(summary.totalAllCost),
                  color: BuildHausTheme.warn,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ExpenseStatChip(
                  label: 'Bulan Ini',
                  value: Formatters.currency(summary.totalMonthCost),
                  color: BuildHausTheme.ok,
                ),
              ),
            ],
          ),
          if (summary.totalPartsCost > 0 || summary.totalLaborCost > 0) ...[
            const SizedBox(height: 8),
            Text(
              'Part: ${Formatters.currency(summary.totalPartsCost)}  •  Jasa: ${Formatters.currency(summary.totalLaborCost)}',
              style: TextStyle(fontSize: 11, color: context.muted),
            ),
          ],
        ],
      ),
    );
  }
}

class _ExpenseStatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _ExpenseStatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: context.soft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 10, color: context.muted)),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (record.workshopName != null &&
                        record.workshopName!.isNotEmpty)
                      Text(
                        record.workshopName!,
                        style: TextStyle(fontSize: 10, color: context.muted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 115),
                child: Text(
                  costText,
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: BuildHausTheme.warn,
                  ),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _fmtDate(log.recordedAt),
                  style: TextStyle(fontSize: 11, color: context.muted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Text('🛣️', style: TextStyle(fontSize: 22)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// REMINDER TAB
// ─────────────────────────────────────────────
class _ReminderTab extends ConsumerStatefulWidget {
  final int motorId;
  const _ReminderTab({required this.motorId});

  @override
  ConsumerState<_ReminderTab> createState() => _ReminderTabState();
}

class _ReminderTabState extends ConsumerState<_ReminderTab> {
  bool _isSendingSample = false;

  Future<void> _onSampleReminderTap() async {
    if (_isSendingSample) return;
    setState(() => _isSendingSample = true);
    try {
      final db = ref.read(databaseProvider);
      final motor = await db.getMotorcycle(widget.motorId);
      if (motor == null) return;
      final notifService = ref.read(notificationServiceProvider);
      final result =
          await ReminderSampleHelper.createSampleRemindersWithStatus(
        db: db,
        notificationService: notifService,
        motor: motor,
      );
      ref.invalidate(remindersProvider(widget.motorId));
      if (!mounted) return;
      if (result.notificationShown) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text(
                'Notifikasi pengingat telah dikirim ke bar notifikasi HP Anda!',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
      } else {
        await _showNotificationPermissionDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text('Gagal mengirim contoh pengingat: $e'),
              backgroundColor: BuildHausTheme.danger,
              behavior: SnackBarBehavior.floating,
            ),
          );
      }
    } finally {
      if (mounted) setState(() => _isSendingSample = false);
    }
  }

  Future<void> _showNotificationPermissionDialog() {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(
              Icons.notifications_off_outlined,
              color: BuildHausTheme.warn,
              size: 22,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Izin Notifikasi Belum Aktif',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: const SingleChildScrollView(
          child: Text(
            'Izin notifikasi HP (Android 13+) belum diaktifkan atau belum diberikan, sehingga notifikasi pengingat belum dapat ditampilkan.\n\n'
            'Silakan aktifkan melalui:\n'
            'Pengaturan HP > Aplikasi > BuildHaus > Notifikasi > Izinkan Notifikasi.',
            style: TextStyle(fontSize: 13, height: 1.45),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Mengerti'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _onSampleReminderTap();
            },
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildTopActionRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            key: const ValueKey('history_sample_reminder_button'),
            onPressed: _isSendingSample ? null : _onSampleReminderTap,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 44),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            icon: const Icon(
              Icons.notifications_active_outlined,
              size: 16,
            ),
            label: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                _isSendingSample ? 'Mengirim...' : 'Cek Notif di HP Saya',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 108),
          child: TextButton.icon(
            onPressed: () => context.push('/motor/${widget.motorId}/reminders'),
            style: TextButton.styleFrom(
              minimumSize: const Size(0, 44),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: const Icon(Icons.tune_rounded, size: 16),
            label: const FittedBox(
              fit: BoxFit.scaleDown,
              child: Text('Kelola', maxLines: 1),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final remindersAsync = ref.watch(remindersProvider(widget.motorId));

    return remindersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Gagal memuat pengingat: $err')),
      data: (reminders) {
        if (reminders.isEmpty) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _buildTopActionRow(context),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.schedule, size: 56, color: context.muted),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada pengingat',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: context.ink,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tambah pengingat atau ketuk "Cek Notif di HP Saya" di atas untuk tes notifikasi & contoh jadwal servis.',
                          style: TextStyle(fontSize: 12, color: context.muted),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => context.push(
                            '/motor/${widget.motorId}/reminder/add',
                          ),
                          icon: const Icon(Icons.add, size: 18),
                          label: const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text('Tambah Pengingat', maxLines: 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: reminders.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            if (i == 0) {
              return _buildTopActionRow(context);
            }
            return FadeSlideIn(
              index: i - 1,
              child: _ReminderCard(reminder: reminders[i - 1]),
            );
          },
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
      dueText = 'Pada ${Formatters.formatOdometer(reminder.dueOdometerKm!)} km';
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
                  ReminderSampleHelper.formatReminderTypeTitle(
                    reminder.reminderType,
                  ),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: context.ink,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (dueText.isNotEmpty)
                  Text(
                    dueText,
                    style: TextStyle(fontSize: 11, color: color),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
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
              textAlign: TextAlign.center,
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
              label: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text('Catat Sekarang', maxLines: 1),
              ),
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
