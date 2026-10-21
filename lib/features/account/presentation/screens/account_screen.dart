import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/database/app_database.dart';
import '../../../../shared/widgets/buildhaus_logo.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final motorsAsync = ref.watch(motorcyclesProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
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
                    const BuildHausLogo(size: 44),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      onPressed: () => _showSettingsBottomSheet(context, ref),
                    ),
                  ],
                ),
              ),
            ),
            title: const Text('Akun'),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _ProfileCard(),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => context.push('/ai-model'),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: context.surface2,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.purple.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.purple.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.smart_toy_outlined,
                            color: Colors.purple,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI Offline Qwen3 (378 MB)',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: context.ink,
                                ),
                              ),
                              Text(
                                'Kelola & unduh model AI untuk asisten offline',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: context.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: Colors.purple,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _QuickStatsSection(),
                const SizedBox(height: 24),
                _SectionTitle('Motor Saya'),
                const SizedBox(height: 10),
                motorsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error: $e'),
                  data: (motors) {
                    if (motors.isEmpty) return _EmptyMotorsCard(context);
                    return Column(
                      children: [
                        ...motors.map((m) => _MotorListTile(motorcycle: m)),
                        const SizedBox(height: 8),
                        _AddMotorTile(context),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                _SectionTitle('Tampilan'),
                const SizedBox(height: 10),
                _ThemeSection(),
                const SizedBox(height: 24),
                _SectionTitle('Data'),
                const SizedBox(height: 10),
                _DataManagementSection(),
                const SizedBox(height: 24),
                _SectionTitle('Tentang'),
                const SizedBox(height: 10),
                _AboutSection(),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => _SettingsSheet(parentRef: ref),
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

class _ProfileCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [context.surface2, context.surface],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.line),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  context.ink.withValues(alpha: 0.8),
                  context.ink.withValues(alpha: 0.5),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Center(
              child: Text('🏍️', style: TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rider BuildHaus',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: context.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pengguna Offline',
                  style: TextStyle(fontSize: 12, color: context.muted),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: BuildHausTheme.ok.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.offline_bolt,
                        size: 12,
                        color: BuildHausTheme.ok,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Offline Mode',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: BuildHausTheme.ok,
                        ),
                      ),
                    ],
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

class _QuickStatsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);

    return Row(
      children: [
        Expanded(
          child: FutureBuilder<int>(
            future: db.getTotalServiceRecordsCount(),
            builder: (ctx, snap) => _StatCard(
              icon: Icons.build,
              value: '${snap.data ?? 0}',
              label: 'Servis',
              color: Colors.blue,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FutureBuilder<double>(
            future: db.getTotalMaintenanceCost(),
            builder: (ctx, snap) {
              final val = snap.data ?? 0.0;
              return _StatCard(
                icon: Icons.payments_outlined,
                value: val > 0
                    ? 'Rp ${(val / 1000000).toStringAsFixed(1)}jt'
                    : 'Rp 0',
                label: 'Total Biaya',
                color: BuildHausTheme.warn,
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FutureBuilder<int>(
            future: db.getUpcomingRemindersCount(),
            builder: (ctx, snap) => _StatCard(
              icon: Icons.schedule,
              value: '${snap.data ?? 0}',
              label: 'Reminders',
              color: BuildHausTheme.danger,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.surface2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.line),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: context.ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 10, color: context.muted)),
        ],
      ),
    );
  }
}

class _EmptyMotorsCard extends StatelessWidget {
  final BuildContext context;
  const _EmptyMotorsCard(this.context);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.surface2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.line),
      ),
      child: Column(
        children: [
          Icon(Icons.two_wheeler, size: 40, color: context.muted),
          const SizedBox(height: 12),
          Text(
            'Belum ada motor',
            style: TextStyle(fontWeight: FontWeight.bold, color: context.ink),
          ),
          const SizedBox(height: 4),
          Text(
            'Tambah motor untuk mulai merawat',
            style: TextStyle(fontSize: 12, color: context.muted),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.push('/add-motor'),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Tambah Motor'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(0, 44)),
          ),
        ],
      ),
    );
  }
}

class _MotorBrandLabel extends ConsumerWidget {
  final int? modelId;
  const _MotorBrandLabel({required this.modelId});

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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: context.ink.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            model.brand,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: context.ink,
            ),
          ),
        );
      },
    );
  }
}

class _MotorListTile extends ConsumerWidget {
  final Motorcycle motorcycle;
  const _MotorListTile({required this.motorcycle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeMotor = ref.watch(activeMotorcycleProvider);
    final isActive = activeMotor?.id == motorcycle.id;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: context.surface2,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive
                ? BuildHausTheme.ok.withValues(alpha: 0.4)
                : context.line,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          leading: _MotorBrandLabel(modelId: motorcycle.modelId),
          title: Text(
            motorcycle.nickname,
            style: TextStyle(fontWeight: FontWeight.w600, color: context.ink),
          ),
          subtitle: Text(
            'Tahun ${motorcycle.manufactureYear}',
            style: TextStyle(fontSize: 11, color: context.muted),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isActive)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: BuildHausTheme.ok.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    'Aktif',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: BuildHausTheme.ok,
                    ),
                  ),
                ),
              IconButton(
                icon: Icon(Icons.more_vert, color: context.muted, size: 18),
                onPressed: () => _showMotorOptions(context, ref),
              ),
            ],
          ),
          onTap: () => context.push('/edit-motor/${motorcycle.id}'),
        ),
      ),
    );
  }

  void _showMotorOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.check_circle_outline),
              title: const Text('Jadikan Motor Utama'),
              onTap: () {
                ref
                    .read(activeMotorcycleProvider.notifier)
                    .setActiveMotorcycle(motorcycle);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit Motor'),
              onTap: () {
                Navigator.pop(ctx);
                context.push('/motor/${motorcycle.id}/edit');
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: BuildHausTheme.danger),
              title: Text(
                'Hapus Motor',
                style: TextStyle(color: BuildHausTheme.danger),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDelete(context, ref);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Motor?'),
        content: Text(
          'Motor "${motorcycle.nickname}" dan semua datanya akan dihapus. Tindakan ini tidak bisa dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final db = ref.read(databaseProvider);
              await db.deleteMotorcycle(motorcycle.id);
              ref.invalidate(motorcyclesProvider);
              ref.invalidate(activeMotorcycleProvider);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: BuildHausTheme.danger,
              minimumSize: const Size(0, 44),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

class _AddMotorTile extends StatelessWidget {
  final BuildContext context;
  const _AddMotorTile(this.context);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/add-motor'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.line),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.soft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.add, color: context.muted, size: 20),
            ),
            const SizedBox(width: 14),
            Text(
              'Tambah Motor Baru',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: context.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

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
                child: _ThemeChoiceChip(
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
                child: _ThemeChoiceChip(
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
                child: _ThemeChoiceChip(
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
    );
  }
}

class _ThemeChoiceChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeChoiceChip({
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

class _DataManagementSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SettingsTile(
          icon: Icons.smart_toy_outlined,
          iconColor: Colors.amber.shade700,
          title: 'Model AI Offline',
          subtitle: 'Unduh & kelola model Qwen3 0.6B (378 MB)',
          onTap: () => context.push('/ai-model'),
        ),
        const SizedBox(height: 8),
        _SettingsTile(
          icon: Icons.backup_outlined,
          iconColor: Colors.blue,
          title: 'Backup Data',
          subtitle: 'Simpan semua data ke file',
          onTap: () => context.push('/backup'),
        ),
        const SizedBox(height: 8),
        _SettingsTile(
          icon: Icons.restore_outlined,
          iconColor: Colors.purple,
          title: 'Restore Data',
          subtitle: 'Pulihkan data dari file backup',
          onTap: () => context.push('/restore'),
        ),
      ],
    );
  }
}

class _AboutSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SettingsTile(
          icon: Icons.info_outline,
          iconColor: context.ink2,
          title: 'Tentang BuildHaus',
          subtitle: 'Versi 1.0.0 — Offline-first motorcycle care',
          onTap: () => _showAbout(context),
        ),
        const SizedBox(height: 8),
        _SettingsTile(
          icon: Icons.code,
          iconColor: Colors.teal,
          title: 'Lisensi & Sumber',
          subtitle: 'Lihat lisensi dan kredit library',
          onTap: () => context.push('/licenses'),
        ),
      ],
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'BuildHaus',
      applicationVersion: '1.0.0',
      applicationLegalese:
          '© 2026 BuildHaus\nOffline-first motorcycle maintenance assistant.',
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            const BuildHausLogoCompact(size: 48),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Rawat motor dengan lebih terencana.\nSemua data tersimpan offline di HP kamu.',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: context.ink,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: context.muted),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: context.muted),
          ],
        ),
      ),
    );
  }
}

class _SettingsSheet extends ConsumerWidget {
  final WidgetRef parentRef;
  const _SettingsSheet({required this.parentRef});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: context.line,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Pengaturan', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            Container(
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
                          color: Colors.indigo.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          themeMode == ThemeMode.dark
                              ? Icons.dark_mode
                              : Icons.light_mode,
                          color: Colors.indigo,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tema Tampilan',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: context.ink,
                              ),
                            ),
                            Text(
                              themeMode == ThemeMode.dark
                                  ? 'Mode Gelap aktif'
                                  : (themeMode == ThemeMode.light
                                        ? 'Mode Terang aktif'
                                        : 'Mengikuti tema sistem HP'),
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
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _ThemeChoiceChip(
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
                        child: _ThemeChoiceChip(
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
                        child: _ThemeChoiceChip(
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
            const SizedBox(height: 12),
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                Navigator.pop(context);
                context.push('/ai-model');
              },
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
                        color: Colors.amber.shade700.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.smart_toy_outlined,
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
                            'Kelola Model AI Offline',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: context.ink,
                            ),
                          ),
                          Text(
                            'Unduh & kelola model Qwen3 0.6B',
                            style: TextStyle(
                              fontSize: 11,
                              color: context.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: context.muted, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
