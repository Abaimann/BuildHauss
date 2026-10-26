import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/notifications/notification_id_generator.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/theme/app_theme.dart';

class RemindersScreen extends ConsumerStatefulWidget {
  final int? motorcycleId;
  const RemindersScreen({super.key, this.motorcycleId});

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen> {
  bool _isSyncing = false;

  Future<void> _syncReminders(int motorId) async {
    setState(() => _isSyncing = true);
    try {
      final engine = ref.read(reminderEngineProvider);
      final count = await engine.syncRemindersForMotorcycle(motorId);
      ref.invalidate(remindersProvider(motorId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              count > 0
                  ? 'Berhasil menyinkronkan $count pengingat perawatan.'
                  : 'Pengingat sudah yang terbaru.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyinkronkan pengingat: $e'),
            backgroundColor: BuildHausTheme.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  void _showAddReminderDialog(BuildContext context, int motorId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _AddReminderSheet(motorId: motorId),
    ).then((_) => ref.invalidate(remindersProvider(motorId)));
  }

  @override
  Widget build(BuildContext context) {
    final motors = ref.watch(motorcyclesProvider).valueOrNull ?? [];
    final activeMotor = widget.motorcycleId != null
        ? (motors.where((m) => m.id == widget.motorcycleId).firstOrNull ??
              ref.watch(activeMotorcycleProvider))
        : ref.watch(activeMotorcycleProvider);

    if (activeMotor == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pengingat Perawatan')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Pilih sepeda motor aktif terlebih dahulu.'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      );
    }

    final remindersAsync = ref.watch(remindersProvider(activeMotor.id));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pengingat Perawatan', style: TextStyle(fontSize: 16)),
            Text(
              activeMotor.nickname,
              style: TextStyle(fontSize: 11, color: context.muted),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: _isSyncing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
            tooltip: 'Sinkronkan dengan Jadwal Servis',
            onPressed: _isSyncing ? null : () => _syncReminders(activeMotor.id),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Tambah Pengingat Manual',
            onPressed: () => _showAddReminderDialog(context, activeMotor.id),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: remindersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Terjadi kesalahan: $err')),
        data: (reminders) {
          if (reminders.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: context.surface2,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications_none_outlined,
                        size: 36,
                        color: Colors.amber,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Belum Ada Pengingat',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sinkronkan pengingat otomatis berdasarkan interval servis motor Anda atau buat pengingat baru.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: context.muted),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: () => _syncReminders(activeMotor.id),
                      icon: const Icon(Icons.sync, size: 18),
                      label: const Text('Sinkronkan Sekarang'),
                    ),
                  ],
                ),
              ),
            );
          }

          final activeCount = reminders.where((r) => r.enabled).length;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Summary card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.surface2,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.line),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.amber.shade700.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.notifications_active_outlined,
                        color: Colors.amber.shade700,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$activeCount Pengingat Aktif',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: context.ink,
                            ),
                          ),
                          Text(
                            'Total ${reminders.length} pengingat terjadwal untuk ${activeMotor.nickname}',
                            style: TextStyle(
                              fontSize: 11,
                              color: context.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Daftar Pengingat',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),

              ...reminders.map(
                (r) => _ReminderCardItem(
                  reminder: r,
                  motorId: activeMotor.id,
                  onChanged: () =>
                      ref.invalidate(remindersProvider(activeMotor.id)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ReminderCardItem extends ConsumerWidget {
  final LocalReminder reminder;
  final int motorId;
  final VoidCallback onChanged;

  const _ReminderCardItem({
    required this.reminder,
    required this.motorId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.read(databaseProvider);
    final isEnabled = reminder.enabled;

    String dateStr = '-';
    if (reminder.dueDate != null) {
      dateStr = DateFormat('dd MMM yyyy').format(reminder.dueDate!);
    }

    String odoStr = '';
    if (reminder.dueOdometerKm != null) {
      odoStr = '${reminder.dueOdometerKm!.toStringAsFixed(0)} km';
    }

    IconData icon = Icons.build_outlined;
    if (reminder.reminderType == 'odometer') {
      icon = Icons.speed;
    } else if (reminder.reminderType == 'complaint') {
      icon = Icons.chat_bubble_outline;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isEnabled
                  ? Colors.blue.withValues(alpha: 0.12)
                  : context.surface2,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isEnabled ? Colors.blue : context.muted,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _getReminderTitle(reminder.reminderType),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isEnabled ? context.ink : context.muted,
                        ),
                      ),
                    ),
                    Switch(
                      value: isEnabled,
                      onChanged: (val) async {
                        await db.setReminderEnabled(reminder.id, val);
                        onChanged();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 12,
                      color: context.muted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      dateStr,
                      style: TextStyle(fontSize: 11, color: context.muted),
                    ),
                    if (odoStr.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      Icon(Icons.speed, size: 12, color: context.muted),
                      const SizedBox(width: 4),
                      Text(
                        odoStr,
                        style: TextStyle(fontSize: 11, color: context.muted),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18),
            color: context.muted,
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Hapus Pengingat?'),
                  content: const Text(
                    'Pengingat ini akan dihapus dari jadwal.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Batal'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: FilledButton.styleFrom(
                        backgroundColor: BuildHausTheme.danger,
                      ),
                      child: const Text('Hapus'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await db.deleteReminder(reminder.id);
                onChanged();
              }
            },
          ),
        ],
      ),
    );
  }

  String _getReminderTitle(String type) {
    switch (type) {
      case 'odometer':
        return 'Pembaruan Odometer';
      case 'complaint':
        return 'Tindak Lanjut Keluhan';
      case 'inspection':
        return 'Pemeriksaan Mandiri';
      case 'date':
      default:
        return 'Jadwal Servis Berkala';
    }
  }
}

class _AddReminderSheet extends StatefulWidget {
  final int motorId;
  const _AddReminderSheet({required this.motorId});

  @override
  State<_AddReminderSheet> createState() => _AddReminderSheetState();
}

class _AddReminderSheetState extends State<_AddReminderSheet> {
  final _odoController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 14));
  String _selectedType = 'date';
  int? _selectedComponentTypeId;

  @override
  void dispose() {
    _odoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tambah Pengingat Perawatan',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),

          // Tipe pengingat
          DropdownButtonFormField<String>(
            initialValue: _selectedType,
            decoration: const InputDecoration(labelText: 'Tipe Pengingat'),
            items: const [
              DropdownMenuItem(
                value: 'date',
                child: Text('Jadwal Servis / Ganti Part'),
              ),
              DropdownMenuItem(
                value: 'odometer',
                child: Text('Pembaruan Odometer'),
              ),
              DropdownMenuItem(
                value: 'inspection',
                child: Text('Pemeriksaan Mandiri'),
              ),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _selectedType = val);
            },
          ),
          const SizedBox(height: 14),

          // Tanggal Pengingat
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today_outlined),
            title: const Text(
              'Tanggal Pengingat',
              style: TextStyle(fontSize: 13),
            ),
            subtitle: Text(
              DateFormat('dd MMMM yyyy').format(_selectedDate),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: TextButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  setState(() => _selectedDate = picked);
                }
              },
              child: const Text('Ubah'),
            ),
          ),
          const SizedBox(height: 10),

          // Target Kilometer (opsional)
          TextField(
            controller: _odoController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Target Kilometer (Opsional)',
              hintText: 'Contoh: 15000',
              suffixText: 'km',
            ),
          ),
          const SizedBox(height: 24),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              const SizedBox(width: 8),
              Consumer(
                builder: (context, ref, _) {
                  return FilledButton(
                    onPressed: () async {
                      final db = ref.read(databaseProvider);
                      final odo = double.tryParse(_odoController.text.trim());
                      final notifId = NotificationIdGenerator.forManual(
                        widget.motorId,
                        DateTime.now().millisecondsSinceEpoch % 9999,
                      );

                      await db.insertReminder(
                        LocalRemindersCompanion.insert(
                          motorcycleId: widget.motorId,
                          componentTypeId: Value(_selectedComponentTypeId),
                          reminderType: _selectedType,
                          dueOdometerKm: Value(odo),
                          dueDate: Value(_selectedDate),
                          enabled: const Value(true),
                          lastScheduledAt: Value(DateTime.now()),
                          notificationId: Value(notifId),
                        ),
                      );

                      // Schedule notification
                      final notifService = ref.read(
                        notificationServiceProvider,
                      );
                      await notifService.scheduleNotification(
                        id: notifId,
                        title: 'Pengingat Perawatan Motor',
                        body:
                            'Waktunya melakukan perawatan terjadwal motor Anda.',
                        scheduledDate: _selectedDate,
                      );

                      if (context.mounted) Navigator.pop(context);
                    },
                    child: const Text('Simpan Pengingat'),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
