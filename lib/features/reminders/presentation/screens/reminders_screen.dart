import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/engines/reminder_sample_helper.dart';
import '../../../../core/notifications/notification_id_generator.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';

class RemindersScreen extends ConsumerStatefulWidget {
  final int? motorcycleId;

  /// When true, the "add reminder" sheet is opened automatically once the
  /// screen has loaded. Used by the `/motor/:id/reminder/add` route so the
  /// user lands directly on the form instead of the reminder list.
  final bool openAddSheetOnOpen;

  const RemindersScreen({
    super.key,
    this.motorcycleId,
    this.openAddSheetOnOpen = false,
  });

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen> {
  bool _isSyncing = false;
  bool _isSendingSample = false;
  bool _didAutoOpenAddSheet = false;

  Future<void> _triggerSampleReminder(Motorcycle motor) async {
    setState(() => _isSendingSample = true);
    try {
      final db = ref.read(databaseProvider);
      final notifService = ref.read(notificationServiceProvider);
      final result =
          await ReminderSampleHelper.createSampleRemindersWithStatus(
        db: db,
        notificationService: notifService,
        motor: motor,
      );
      ref.invalidate(remindersProvider(motor.id));
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
        await _showNotificationPermissionDialog(motor);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text('Gagal membuat contoh pengingat: $e'),
              backgroundColor: BuildHausTheme.danger,
              behavior: SnackBarBehavior.floating,
            ),
          );
      }
    } finally {
      if (mounted) setState(() => _isSendingSample = false);
    }
  }

  Future<void> _showNotificationPermissionDialog(Motorcycle motor) {
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
              _triggerSampleReminder(motor);
            },
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

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

  /// Menentukan motor yang ditampilkan pada layar ini.
  ///
  /// Bila `motorcycleId` diberikan, motor dengan id tersebut dipakai dan tidak
  /// ada fallback ke motor aktif. Ini mencegah tampilnya pengingat motor lain
  /// ketika id yang diminta tidak valid.
  Motorcycle? _resolveMotor(List<Motorcycle> motors) {
    final requestedId = widget.motorcycleId;
    if (requestedId == null) {
      return ref.watch(activeMotorcycleProvider);
    }
    return motors.where((m) => m.id == requestedId).firstOrNull;
  }

  Widget _buildTestNotifButton(Motorcycle motor) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        key: const ValueKey('sample_reminder_button'),
        onPressed: _isSendingSample ? null : () => _triggerSampleReminder(motor),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 44),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        ),
        icon: const Icon(Icons.notifications_active_outlined, size: 17),
        label: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            _isSendingSample ? 'Mengirim...' : 'Cek Notif di HP Saya',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final motors = ref.watch(motorcyclesProvider).valueOrNull ?? [];

    // Resolve the target motorcycle. When an explicit id is supplied but does
    // not resolve, fall back to the active motorcycle only when the id was
    // never provided; an explicitly requested but unknown id must not silently
    // display another motorcycle's reminders.
    final activeMotor = _resolveMotor(motors);

    if (activeMotor == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Pengingat Perawatan',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Pilih sepeda motor aktif terlebih dahulu.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => context.pop(),
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('Kembali', maxLines: 1),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Auto-open the add sheet once, after the first frame, when this route was
    // opened specifically to create a reminder.
    if (widget.openAddSheetOnOpen && !_didAutoOpenAddSheet) {
      _didAutoOpenAddSheet = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showAddReminderDialog(context, activeMotor.id);
      });
    }

    final remindersAsync = ref.watch(remindersProvider(activeMotor.id));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pengingat Perawatan',
              style: TextStyle(fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              activeMotor.nickname,
              style: TextStyle(fontSize: 11, color: context.muted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
          const SizedBox(width: 4),
        ],
      ),
      body: remindersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Terjadi kesalahan: $err')),
        data: (reminders) {
          if (reminders.isEmpty) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
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
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.amber.shade700.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.notifications_active_outlined,
                              color: Colors.amber.shade700,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tes Notifikasi di HP',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: context.ink,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Coba kirim contoh pengingat ke bar notifikasi HP Anda.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: context.muted,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildTestNotifButton(activeMotor),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
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
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sinkronkan pengingat otomatis berdasarkan interval servis motor Anda atau ketuk tombol di atas untuk tes notifikasi.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: context.muted),
                      ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: () => _syncReminders(activeMotor.id),
                        icon: const Icon(Icons.sync, size: 18),
                        label: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('Sinkronkan Sekarang', maxLines: 1),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
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
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Total ${reminders.length} pengingat terjadwal untuk ${activeMotor.nickname}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: context.muted,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTestNotifButton(activeMotor),
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
      odoStr = '${Formatters.formatOdometer(reminder.dueOdometerKm!)} km';
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
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Switch(
                      value: isEnabled,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onChanged: (val) async {
                        await db.setReminderEnabled(reminder.id, val);
                        onChanged();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 12,
                          color: context.muted,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            dateStr,
                            style: TextStyle(
                              fontSize: 11,
                              color: context.muted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (odoStr.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.speed, size: 12, color: context.muted),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              odoStr,
                              style: TextStyle(
                                fontSize: 11,
                                color: context.muted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            padding: const EdgeInsets.all(6),
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
    return ReminderSampleHelper.formatReminderTypeTitle(type);
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
      child: SingleChildScrollView(
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
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Tipe Pengingat'),
              items: const [
                DropdownMenuItem(
                  value: 'date',
                  child: Text(
                    'Jadwal Servis / Ganti Part',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DropdownMenuItem(
                  value: 'odometer',
                  child: Text(
                    'Pembaruan Odometer',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DropdownMenuItem(
                  value: 'inspection',
                  child: Text(
                    'Pemeriksaan Mandiri',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                DateFormat('dd MMMM yyyy').format(_selectedDate),
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: TextButton(
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
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
              inputFormatters: const [OdometerTextInputFormatter()],
              decoration: const InputDecoration(
                labelText: 'Target Kilometer (Opsional)',
                hintText: 'Contoh: 15.000',
                suffixText: 'km',
              ),
            ),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('Batal', maxLines: 1),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Consumer(
                    builder: (context, ref, _) {
                      return FilledButton(
                        onPressed: () async {
                          final db = ref.read(databaseProvider);
                          final odo = Formatters.parseOdometerDouble(
                            _odoController.text,
                          );
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
                        child: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('Simpan Pengingat', maxLines: 1),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
