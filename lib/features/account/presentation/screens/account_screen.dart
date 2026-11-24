import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/sample_data_seeder.dart';
import '../../../../core/platform/native_platform_service.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/theme/app_theme.dart';
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
            pinned: true,
            toolbarHeight: 72,
            backgroundColor: context.bg,
            surfaceTintColor: Colors.transparent,
            titleSpacing: 16,
            title: Row(
              children: [
                const BuildHausLogoCompact(size: 38),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Akun',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: context.ink,
                        ),
                      ),
                      Text(
                        'Profil & Pengelolaan Garasi',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: context.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _ProfileCard(),
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
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);
  @override
  Widget build(BuildContext context) =>
      Text(title, style: Theme.of(context).textTheme.titleMedium);
}

class _ProfileCard extends ConsumerWidget {
  Future<void> _pickAndSaveAvatar(BuildContext context, WidgetRef ref) async {
    final path = await NativePlatformService.pickProfileImage();
    if (path != null && path.isNotEmpty) {
      await ref.read(authProvider.notifier).updateAvatarPath(path);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto profil berhasil diperbarui.')),
        );
      }
    }
  }

  Future<void> _onTapAvatar(
    BuildContext context,
    WidgetRef ref,
    AuthState auth,
  ) async {
    final hasStoredAvatar =
        auth.avatarPath != null && auth.avatarPath!.trim().isNotEmpty;
    if (!hasStoredAvatar) {
      await _pickAndSaveAvatar(context, ref);
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Pilih Foto dari Galeri'),
              onTap: () {
                Navigator.pop(ctx);
                _pickAndSaveAvatar(context, ref);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: BuildHausTheme.danger),
              title: Text(
                'Hapus Foto Profil',
                style: TextStyle(color: BuildHausTheme.danger),
              ),
              onTap: () async {
                Navigator.pop(ctx);
                await ref.read(authProvider.notifier).updateAvatarPath(null);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Foto profil dihapus.')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final avatarPath = auth.avatarPath;
    final hasValidAvatarFile =
        avatarPath != null &&
        avatarPath.trim().isNotEmpty &&
        File(avatarPath).existsSync();

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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () => _onTapAvatar(context, ref, auth),
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  clipBehavior: Clip.none,
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: hasValidAvatarFile
                            ? Image.file(
                                File(avatarPath),
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Center(
                                  child: Text(
                                    auth.userInitial,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: context.bg,
                                    ),
                                  ),
                                ),
                              )
                            : Center(
                                child: Text(
                                  auth.userInitial,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: context.bg,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    Positioned(
                      right: -4,
                      bottom: -4,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: context.ink,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: context.surface,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.camera_alt_rounded,
                          size: 12,
                          color: context.bg,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 72),
                child: InkWell(
                  onTap: () => _onTapAvatar(context, ref, auth),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Ubah Foto',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: context.ink2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  auth.userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: context.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  auth.userEmail.isNotEmpty
                      ? auth.userEmail
                      : 'Smart Rider • Local & Cloud AI',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
                        Icons.auto_awesome,
                        size: 12,
                        color: BuildHausTheme.ok,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'Gemini Cloud AI Active',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: BuildHausTheme.ok,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Keluar Akun',
            icon: Icon(Icons.logout_rounded, color: BuildHausTheme.danger),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Keluar dari Akun?'),
                  content: const Text(
                    'Anda akan keluar dari sesi saat ini. Data motor dan riwayat servis Anda tetap tersimpan dengan aman di perangkat ini.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('Batal', maxLines: 1),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: BuildHausTheme.danger,
                        minimumSize: const Size(0, 42),
                      ),
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('Keluar', maxLines: 1),
                      ),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  context.go('/home');
                }
              }
            },
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
            builder: (ctx, snap) => InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => context.push('/reminders'),
              child: _StatCard(
                icon: Icons.schedule,
                value: '${snap.data ?? 0}',
                label: 'Reminders',
                color: BuildHausTheme.danger,
              ),
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
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: context.ink,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: context.muted),
          ),
        ],
      ),
    );
  }
}

class _EmptyMotorsCard extends ConsumerWidget {
  final BuildContext context;
  const _EmptyMotorsCard(this.context);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/add-motor'),
              icon: const Icon(Icons.add, size: 18),
              label: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text('Tambah Motor', maxLines: 1),
              ),
              style: ElevatedButton.styleFrom(minimumSize: const Size(0, 44)),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final db = ref.read(databaseProvider);
                final createdIds = await SampleDataSeeder(
                  db,
                ).seedDiverseFiveMotorcycles();
                ref.invalidate(motorcyclesProvider);
                if (createdIds.isNotEmpty) {
                  final motors = await db.getAllMotorcycles();
                  final firstMotor = motors.cast<Motorcycle?>().firstWhere(
                    (m) => m?.id == createdIds.first,
                    orElse: () => null,
                  );
                  if (firstMotor != null) {
                    await ref
                        .read(activeMotorcycleProvider.notifier)
                        .setActiveMotorcycle(firstMotor);
                  } else {
                    ref.invalidate(activeMotorcycleProvider);
                  }
                } else {
                  ref.invalidate(activeMotorcycleProvider);
                }
              },
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text('Muat 5 Motor Beragam', maxLines: 1),
              ),
              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 44)),
            ),
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
        return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 92),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: context.ink.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              model.brand,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: context.ink,
              ),
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: FontWeight.w600, color: context.ink),
          ),
          subtitle: Text(
            'Tahun ${motorcycle.manufactureYear}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
          onTap: () => context.push('/motor/${motorcycle.id}/edit'),
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
            child: const FittedBox(
              fit: BoxFit.scaleDown,
              child: Text('Batal', maxLines: 1),
            ),
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
            child: const FittedBox(
              fit: BoxFit.scaleDown,
              child: Text('Hapus', maxLines: 1),
            ),
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
            Expanded(
              child: Text(
                'Tambah Motor Baru',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: context.muted,
                ),
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
              Expanded(
                child: Text(
                  'Tema Aplikasi',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: context.ink,
                  ),
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? context.ink : context.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? context.ink : context.line),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: isSelected ? context.bg : context.ink),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? context.bg : context.ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DataManagementSection extends ConsumerWidget {
  Future<void> _handleClearAllData(BuildContext context, WidgetRef ref) async {
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
            child: const FittedBox(
              fit: BoxFit.scaleDown,
              child: Text('Batal', maxLines: 1),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: BuildHausTheme.danger,
              minimumSize: const Size(0, 44),
            ),
            child: const FittedBox(
              fit: BoxFit.scaleDown,
              child: Text('Lanjutkan Hapus', maxLines: 1),
            ),
          ),
        ],
      ),
    );

    if (confirm1 != true || !context.mounted) return;

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
            child: const FittedBox(
              fit: BoxFit.scaleDown,
              child: Text('Batal', maxLines: 1),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: BuildHausTheme.danger,
              minimumSize: const Size(0, 44),
            ),
            child: const FittedBox(
              fit: BoxFit.scaleDown,
              child: Text('Ya, Hapus Semua', maxLines: 1),
            ),
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

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua data pengguna telah dibersihkan.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _SettingsTile(
          icon: Icons.garage_outlined,
          iconColor: BuildHausTheme.ok,
          title: 'Muat 5 Motor Beragam Jenis',
          subtitle: 'Skutik maxi, trail, sport fairing & retro + data lengkap',
          onTap: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Muat 5 Motor Beragam Jenis?'),
                content: const Text(
                  'Ini akan mendaftarkan 5 jenis motor berbeda (Honda Vario 160, '
                  'Yamaha NMAX 155, Kawasaki KLX 150, Honda CBR150R, Kawasaki W175) '
                  'lengkap dengan odometer, riwayat servis & pengeluaran, '
                  'inspeksi mandiri, rencana budget, pengingat, dan keluhan AI.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('Batal', maxLines: 1),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 44),
                    ),
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('Muat 5 Motor', maxLines: 1),
                    ),
                  ),
                ],
              ),
            );
            if (confirm == true) {
              if (!context.mounted) return;
              final container = ProviderScope.containerOf(context);
              final messenger = ScaffoldMessenger.of(context);
              final db = container.read(databaseProvider);
              final createdIds = await SampleDataSeeder(
                db,
              ).seedDiverseFiveMotorcycles(force: true);
              container.invalidate(motorcyclesProvider);
              for (final id in createdIds) {
                container.invalidate(latestOdometerProvider(id));
                container.invalidate(odometerLogsProvider(id));
                container.invalidate(componentStatusesWithNamesProvider(id));
                container.invalidate(serviceRecordsProvider(id));
                container.invalidate(motorcycleExpenseSummaryProvider(id));
                container.invalidate(complaintsProvider(id));
              }
              if (createdIds.isNotEmpty) {
                final motors = await db.getAllMotorcycles();
                final firstMotor = motors.cast<Motorcycle?>().firstWhere(
                  (m) => m?.id == createdIds.first,
                  orElse: () => null,
                );
                if (firstMotor != null) {
                  await container
                      .read(activeMotorcycleProvider.notifier)
                      .setActiveMotorcycle(firstMotor);
                }
              } else {
                container.invalidate(activeMotorcycleProvider);
              }
              messenger.showSnackBar(
                const SnackBar(
                  content: Text(
                    '5 motor beragam jenis & data lengkap berhasil dimuat!',
                  ),
                ),
              );
            }
          },
        ),
        const SizedBox(height: 8),
        _SettingsTile(
          icon: Icons.notifications_active_outlined,
          iconColor: Colors.orange.shade700,
          title: 'Pengingat Perawatan',
          subtitle: 'Jadwal servis berkala & pengingat odometer',
          onTap: () => context.push('/reminders'),
        ),
        const SizedBox(height: 8),
        _SettingsTile(
          icon: Icons.smart_toy_outlined,
          iconColor: Colors.deepPurple,
          title: 'Konfigurasi AI Gemini',
          subtitle: 'Atur API key & status asisten AI',
          onTap: () => context.push('/ai-model'),
        ),
        const SizedBox(height: 8),
        _SettingsTile(
          icon: Icons.backup_outlined,
          iconColor: Colors.blue,
          title: 'Backup Data',
          subtitle: 'Simpan semua data ke file .bhb',
          onTap: () => context.push('/backup'),
        ),
        const SizedBox(height: 8),
        _SettingsTile(
          icon: Icons.restore_outlined,
          iconColor: Colors.purple,
          title: 'Restore Data',
          subtitle: 'Pulihkan data dari file backup .bhb',
          onTap: () => context.push('/restore'),
        ),
        const SizedBox(height: 8),
        _SettingsTile(
          icon: Icons.delete_forever_outlined,
          iconColor: BuildHausTheme.danger,
          titleColor: BuildHausTheme.danger,
          title: 'Hapus Semua Data',
          subtitle: 'Reset seluruh motor dan riwayat dari perangkat',
          onTap: () => _handleClearAllData(context, ref),
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
          subtitle: 'Versi 1.2.0 — Smart AI Motorcycle Care',
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
      applicationVersion: '1.2.0',
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
  final Color? titleColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    this.titleColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: titleColor ?? context.ink,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
