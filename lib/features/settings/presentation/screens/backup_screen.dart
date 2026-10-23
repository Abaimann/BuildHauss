import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_theme.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  final _passphraseController = TextEditingController();
  bool _obscurePassphrase = true;
  bool _isCreating = false;
  File? _createdBackupFile;
  String? _errorMessage;

  @override
  void dispose() {
    _passphraseController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateBackup() async {
    setState(() {
      _isCreating = true;
      _errorMessage = null;
      _createdBackupFile = null;
    });

    try {
      final backupService = ref.read(backupRestoreServiceProvider);
      final passphrase = _passphraseController.text.trim();
      final file = await backupService.createBackup(
        passphrase: passphrase.isNotEmpty ? passphrase : null,
      );

      setState(() {
        _createdBackupFile = file;
      });

      ref.invalidate(databaseStatsProvider);
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal membuat backup: $e';
      });
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(databaseStatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Backup Data Lokal')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Info
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
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.cloud_upload_outlined,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Offline & Privat',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: context.ink,
                        ),
                      ),
                      Text(
                        'Seluruh data disimpan dalam file .bhb terenkripsi di memori HP Anda tanpa server online.',
                        style: TextStyle(fontSize: 11, color: context.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Database Statistics
          Text(
            'Data yang Akan Disimpan',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 10),
          statsAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Gagal memuat statistik: $e'),
            data: (stats) {
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: context.line),
                ),
                child: Column(
                  children: [
                    _StatRow(
                      label: 'Sepeda Motor Terdaftar',
                      value: '${stats['motorcycles'] ?? 0} unit',
                      icon: Icons.two_wheeler,
                    ),
                    const Divider(height: 16),
                    _StatRow(
                      label: 'Catatan Odometer',
                      value: '${stats['odometer_logs'] ?? 0} log',
                      icon: Icons.speed,
                    ),
                    const Divider(height: 16),
                    _StatRow(
                      label: 'Riwayat Servis & Pengeluaran',
                      value: '${stats['service_records'] ?? 0} servis',
                      icon: Icons.history,
                    ),
                    const Divider(height: 16),
                    _StatRow(
                      label: 'Keluhan & Percakapan AI',
                      value: '${stats['complaints'] ?? 0} keluhan',
                      icon: Icons.chat_bubble_outline,
                    ),
                    const Divider(height: 16),
                    _StatRow(
                      label: 'Rencana Budget & Pengingat',
                      value:
                          '${(stats['budget_plans'] ?? 0) + (stats['local_reminders'] ?? 0)} item',
                      icon: Icons.savings_outlined,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // Passphrase Protection (Optional)
          Text(
            'Proteksi Enkripsi (Opsional)',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 6),
          Text(
            'Jika Anda mengisi kata sandi, file backup akan dienkripsi dengan PBKDF2 + HMAC-SHA256.',
            style: TextStyle(fontSize: 11, color: context.muted),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _passphraseController,
            obscureText: _obscurePassphrase,
            decoration: InputDecoration(
              hintText: 'Masukkan kata sandi pengaman...',
              prefixIcon: const Icon(Icons.lock_outline, size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassphrase ? Icons.visibility_off : Icons.visibility,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscurePassphrase = !_obscurePassphrase),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Action Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: _isCreating ? null : _handleCreateBackup,
              icon: _isCreating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(
                _isCreating
                    ? 'Membuat File Backup...'
                    : 'Buat File Backup (.bhb)',
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Success result card
          if (_createdBackupFile != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: BuildHausTheme.okBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: BuildHausTheme.ok.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: BuildHausTheme.ok,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Backup Berhasil Dibuat!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: BuildHausTheme.ok,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'File: ${_createdBackupFile!.path.split(Platform.pathSeparator).last}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ukuran: ${(_createdBackupFile!.lengthSync() / 1024).toStringAsFixed(1)} KB',
                    style: TextStyle(fontSize: 11, color: context.muted),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Lokasi: ${_createdBackupFile!.path}',
                    style: TextStyle(fontSize: 10, color: context.muted),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '💡 Tip: Anda dapat menyalin file ini ke memori lain atau mentransfernya ke smartphone baru untuk memulihkan seluruh data BuildHaus.',
                    style: TextStyle(fontSize: 11, color: context.ink),
                  ),
                ],
              ),
            ),

          if (_errorMessage != null)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: BuildHausTheme.dangerBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: BuildHausTheme.danger.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                _errorMessage!,
                style: const TextStyle(
                  fontSize: 12,
                  color: BuildHausTheme.danger,
                ),
              ),
            ),

          const SizedBox(height: 20),

          // Existing Backups List
          FutureBuilder<List<File>>(
            future: ref.read(backupRestoreServiceProvider).listBackupFiles(),
            builder: (context, snapshot) {
              final files = snapshot.data ?? [];
              if (files.isEmpty) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Riwayat File Backup di Perangkat',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 10),
                  ...files.map(
                    (f) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: context.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: context.line),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.insert_drive_file_outlined,
                            size: 20,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  f.path.split(Platform.pathSeparator).last,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${DateFormat('dd MMM yyyy, HH:mm').format(f.lastModifiedSync())} • ${(f.lengthSync() / 1024).toStringAsFixed(1)} KB',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: context.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: context.muted),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 12))),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
