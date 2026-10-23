import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/app_providers.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/theme/app_theme.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _odometerDays = '30';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final db = ref.read(databaseProvider);
    final notifVal = await db.getSetting('notifications_enabled');
    final odoVal = await db.getSetting('odometer_reminder_days');

    setState(() {
      _notificationsEnabled = (notifVal ?? 'true') != 'false';
      _odometerDays = odoVal ?? '30';
      _isLoading = false;
    });
  }

  Future<void> _updateNotifications(bool enabled) async {
    setState(() => _notificationsEnabled = enabled);
    final db = ref.read(databaseProvider);
    await db.setSetting('notifications_enabled', enabled ? 'true' : 'false');

    if (!enabled) {
      final notifService = ref.read(notificationServiceProvider);
      await notifService.cancelAll();
    } else {
      final activeMotor = ref.read(activeMotorcycleProvider);
      if (activeMotor != null) {
        final engine = ref.read(reminderEngineProvider);
        await engine.syncRemindersForMotorcycle(activeMotor.id);
      }
    }
  }

  Future<void> _updateOdometerDays(String days) async {
    setState(() => _odometerDays = days);
    final db = ref.read(databaseProvider);
    await db.setSetting('odometer_reminder_days', days);
  }

  Future<void> _handleClearAllData() async {
    final confirm1 = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Semua Data Pengguna?'),
        content: const Text(
          'Tindakan ini akan menghapus permanen seluruh motor, riwayat servis, odometer, '
          'dan keluhan Anda dari perangkat ini.\n\n'
          'Pastikan Anda telah membuat file backup terlebih dahulu.',
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
            child: const Text('Lanjutkan Hapus'),
          ),
        ],
      ),
    );

    if (confirm1 != true) return;

    if (!mounted) return;

    final confirm2 = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Terakhir'),
        content: const Text(
          'Apakah Anda benar-benar yakin? Data yang dihapus tidak dapat dipulihkan tanpa file backup.',
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
            child: const Text('Ya, Hapus Semua'),
          ),
        ],
      ),
    );

    if (confirm2 != true) return;

    final db = ref.read(databaseProvider);
    await db.clearAllUserData();

    ref.invalidate(motorcyclesProvider);
    ref.invalidate(activeMotorcycleProvider);
    ref.invalidate(databaseStatsProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua data pengguna telah dibersihkan.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final statsAsync = ref.watch(databaseStatsProvider);
    final aiStatus = ref.watch(aiModelStatusProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Section: Tampilan
                _SectionTitle('Tampilan'),
                const SizedBox(height: 10),
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
                          Icon(
                            themeMode == ThemeMode.dark
                                ? Icons.dark_mode
                                : Icons.light_mode,
                            size: 20,
                            color: themeMode == ThemeMode.dark
                                ? Colors.indigo
                                : Colors.amber.shade700,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Tema Aplikasi',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: context.ink,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _ChoiceChip(
                              label: 'Terang',
                              icon: Icons.light_mode_outlined,
                              isSelected: themeMode == ThemeMode.light,
                              onTap: () => ref
                                  .read(themeModeProvider.notifier)
                                  .setTheme(ThemeMode.light),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _ChoiceChip(
                              label: 'Gelap',
                              icon: Icons.dark_mode_outlined,
                              isSelected: themeMode == ThemeMode.dark,
                              onTap: () => ref
                                  .read(themeModeProvider.notifier)
                                  .setTheme(ThemeMode.dark),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _ChoiceChip(
                              label: 'Sistem',
                              icon: Icons.phone_android_outlined,
                              isSelected: themeMode == ThemeMode.system,
                              onTap: () => ref
                                  .read(themeModeProvider.notifier)
                                  .setTheme(ThemeMode.system),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Section: Notifikasi & Pengingat
                _SectionTitle('Notifikasi & Pengingat'),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.line),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.notifications_active_outlined,
                            color: Colors.blue,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Notifikasi Pengingat Servis',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: context.ink,
                                  ),
                                ),
                                Text(
                                  'Jadwalkan notifikasi perawatan dan ganti oli',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: context.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _notificationsEnabled,
                            onChanged: _updateNotifications,
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        children: [
                          const Icon(Icons.speed, color: Colors.teal, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pengingat Update Odometer',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: context.ink,
                                  ),
                                ),
                                Text(
                                  'Ingatkan catat kilometer jika tidak diperbarui',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: context.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DropdownButton<String>(
                            value: _odometerDays,
                            underline: const SizedBox.shrink(),
                            items: const [
                              DropdownMenuItem(
                                value: '14',
                                child: Text('14 Hari'),
                              ),
                              DropdownMenuItem(
                                value: '30',
                                child: Text('30 Hari'),
                              ),
                              DropdownMenuItem(
                                value: '60',
                                child: Text('60 Hari'),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) _updateOdometerDays(val);
                            },
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.list_alt,
                          color: Colors.amber,
                        ),
                        title: const Text(
                          'Kelola Daftar Pengingat',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: const Text(
                          'Lihat atau tambahkan jadwal pengingat manual',
                          style: TextStyle(fontSize: 11),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/reminders'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Section: Data & Backup
                _SectionTitle('Cadangan & Pemulihan Data (Offline)'),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.line),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.cloud_upload_outlined,
                          color: Colors.blue,
                        ),
                        title: const Text(
                          'Backup Data ke File (.bhb)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: const Text(
                          'Simpan seluruh riwayat dan motor ke file lokal',
                          style: TextStyle(fontSize: 11),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/backup'),
                      ),
                      const Divider(height: 16),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.cloud_download_outlined,
                          color: Colors.purple,
                        ),
                        title: const Text(
                          'Pulihkan Data (Restore)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: const Text(
                          'Kembalikan data motor dari file cadangan',
                          style: TextStyle(fontSize: 11),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/restore'),
                      ),
                      const Divider(height: 16),
                      statsAsync.when(
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (stats) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Icon(
                                Icons.storage_outlined,
                                size: 16,
                                color: context.muted,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${stats['motorcycles'] ?? 0} motor • ${stats['service_records'] ?? 0} servis • ${stats['odometer_logs'] ?? 0} log km',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: context.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(height: 20),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.delete_forever_outlined,
                          color: BuildHausTheme.danger,
                        ),
                        title: const Text(
                          'Hapus Semua Data Pengguna',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: BuildHausTheme.danger,
                          ),
                        ),
                        subtitle: const Text(
                          'Reset seluruh motor dan riwayat dari perangkat',
                          style: TextStyle(fontSize: 11),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: BuildHausTheme.danger,
                        ),
                        onTap: _handleClearAllData,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Section: AI Model
                _SectionTitle('Model AI Asisten'),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.line),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.smart_toy_outlined,
                      color: Colors.amber,
                    ),
                    title: const Text(
                      'AI Model Manager (Qwen3 0.6B)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      aiStatus.valueOrNull == 'ready'
                          ? 'Model offline terpasang dan aktif'
                          : 'Belum diunduh (378 MB)',
                      style: TextStyle(
                        fontSize: 11,
                        color: aiStatus.valueOrNull == 'ready'
                            ? BuildHausTheme.ok
                            : context.muted,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/ai-model'),
                  ),
                ),
                const SizedBox(height: 24),

                // Section: Tentang & Lisensi
                _SectionTitle('Tentang & Lisensi'),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.line),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.info_outline,
                          color: Colors.teal,
                        ),
                        title: const Text(
                          'Tentang BuildHaus',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: const Text(
                          'Versi 1.0.0 — Offline-First Motorcycle Care',
                          style: TextStyle(fontSize: 11),
                        ),
                      ),
                      const Divider(height: 16),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.code, color: Colors.blueGrey),
                        title: const Text(
                          'Lisensi Pihak Ketiga & Katalog',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: const Text(
                          'Informasi lisensi open source dan sumber suku cadang',
                          style: TextStyle(fontSize: 11),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/licenses'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
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
    return Text(title, style: Theme.of(context).textTheme.titleSmall);
  }
}

class _ChoiceChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChoiceChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? context.ink : context.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? context.ink : context.line),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: isSelected ? context.bg : context.ink),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? context.bg : context.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
