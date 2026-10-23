import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/backup/backup_restore_service.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_theme.dart';

class RestoreScreen extends ConsumerStatefulWidget {
  const RestoreScreen({super.key});

  @override
  ConsumerState<RestoreScreen> createState() => _RestoreScreenState();
}

class _RestoreScreenState extends ConsumerState<RestoreScreen> {
  final _passphraseController = TextEditingController();
  final _customPathController = TextEditingController();
  File? _selectedFile;
  BackupPreviewInfo? _preview;
  bool _isLoadingPreview = false;
  bool _isRestoring = false;
  bool _isRestoreSuccess = false;
  String? _errorMessage;

  @override
  void dispose() {
    _passphraseController.dispose();
    _customPathController.dispose();
    super.dispose();
  }

  Future<void> _selectAndInspectFile(File file) async {
    setState(() {
      _selectedFile = file;
      _isLoadingPreview = true;
      _errorMessage = null;
      _preview = null;
      _isRestoreSuccess = false;
    });

    try {
      final service = ref.read(backupRestoreServiceProvider);
      final preview = await service.inspectBackupFile(file);
      setState(() {
        _preview = preview;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal membaca preview file: $e';
      });
    } finally {
      if (mounted) setState(() => _isLoadingPreview = false);
    }
  }

  Future<void> _handleRestore() async {
    if (_selectedFile == null) return;

    // Confirm dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Pemulihan Data'),
        content: const Text(
          'Seluruh data motor dan riwayat saat ini akan digantikan dengan isi file backup ini. '
          'Lanjutkan proses pemulihan?',
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
            child: const Text('Ya, Pulihkan Data'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isRestoring = true;
      _errorMessage = null;
    });

    try {
      final service = ref.read(backupRestoreServiceProvider);
      final pass = _passphraseController.text.trim();
      await service.restoreBackup(
        _selectedFile!,
        passphrase: pass.isNotEmpty ? pass : null,
      );

      // Invalidate all core providers so app reloads newly restored data
      ref.invalidate(motorcyclesProvider);
      ref.invalidate(activeMotorcycleProvider);
      ref.invalidate(databaseStatsProvider);

      setState(() {
        _isRestoreSuccess = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memulihkan data: $e';
      });
    } finally {
      if (mounted) setState(() => _isRestoring = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pulihkan Data (Restore)')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Info banner
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
                    color: Colors.purple.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.cloud_download_outlined,
                    color: Colors.purple,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pemulihan Aman & Atomik',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: context.ink,
                        ),
                      ),
                      Text(
                        'Pilih file .bhb untuk mengembalikan seluruh motor, servis, dan keluhan Anda.',
                        style: TextStyle(fontSize: 11, color: context.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // File selection section
          Text(
            'Pilih File Backup (.bhb)',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 10),
          FutureBuilder<List<File>>(
            future: ref.read(backupRestoreServiceProvider).listBackupFiles(),
            builder: (context, snapshot) {
              final files = snapshot.data ?? [];
              if (files.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: context.line),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.folder_open,
                        size: 36,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tidak ditemukan file backup di folder aplikasi.',
                        style: TextStyle(fontSize: 12, color: context.muted),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _customPathController,
                        decoration: InputDecoration(
                          hintText:
                              'Atau tempel path absolut file .bhb di sini...',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.check),
                            onPressed: () {
                              final path = _customPathController.text.trim();
                              if (path.isNotEmpty) {
                                _selectAndInspectFile(File(path));
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: files.map((f) {
                  final isSelected = _selectedFile?.path == f.path;
                  final fileName = f.path.split(Platform.pathSeparator).last;
                  final dateStr = DateFormat(
                    'dd MMM yyyy, HH:mm',
                  ).format(f.lastModifiedSync());
                  final sizeKb = (f.lengthSync() / 1024).toStringAsFixed(1);

                  return InkWell(
                    onTap: () => _selectAndInspectFile(f),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.purple.withValues(alpha: 0.1)
                            : context.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? Colors.purple : context.line,
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: isSelected ? Colors.purple : context.muted,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  fileName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                    color: context.ink,
                                  ),
                                ),
                                Text(
                                  '$dateStr • $sizeKb KB',
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
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 20),

          // Preview details
          if (_isLoadingPreview)
            const Center(child: CircularProgressIndicator())
          else if (_preview != null) ...[
            Text(
              'Ringkasan Isi Backup',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: context.line),
              ),
              child: Column(
                children: [
                  _PreviewRow(
                    'Aplikasi Sumber',
                    '${_preview!.appName} v${_preview!.appVersion}',
                  ),
                  const Divider(height: 16),
                  _PreviewRow(
                    'Tanggal Dibuat',
                    DateFormat(
                      'dd MMMM yyyy, HH:mm',
                    ).format(_preview!.createdAt),
                  ),
                  const Divider(height: 16),
                  _PreviewRow(
                    'Status Enkripsi',
                    _preview!.isEncrypted
                        ? '🔒 Terenkripsi (Perlu Passphrase)'
                        : '🔓 Standar (Tanpa Sandi)',
                  ),
                  const Divider(height: 16),
                  _PreviewRow(
                    'Jumlah Motor',
                    '${_preview!.motorcyclesCount} unit',
                  ),
                  const Divider(height: 16),
                  _PreviewRow(
                    'Log Odometer',
                    '${_preview!.odometerLogsCount} catatan',
                  ),
                  const Divider(height: 16),
                  _PreviewRow(
                    'Riwayat Servis',
                    '${_preview!.serviceRecordsCount} riwayat',
                  ),
                  const Divider(height: 16),
                  _PreviewRow(
                    'Keluhan & AI',
                    '${_preview!.complaintsCount} keluhan',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Passphrase input if encrypted
            if (_preview!.isEncrypted) ...[
              Text(
                'Kata Sandi Enkripsi (Wajib)',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _passphraseController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Masukkan kata sandi backup ini...',
                  prefixIcon: Icon(Icons.lock_outline, size: 20),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Action button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: _isRestoring ? null : _handleRestore,
                style: FilledButton.styleFrom(backgroundColor: Colors.purple),
                icon: _isRestoring
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.restore),
                label: Text(
                  _isRestoring
                      ? 'Memulihkan Data...'
                      : 'Pulihkan Data Sekarang',
                ),
              ),
            ),
          ],

          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
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
          ],

          if (_isRestoreSuccess) ...[
            const SizedBox(height: 20),
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
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: BuildHausTheme.ok,
                    size: 36,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Data Berhasil Dipulihkan!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: BuildHausTheme.ok,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Seluruh motor, riwayat servis, odometer, dan keluhan telah siap digunakan kembali.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: context.ink),
                  ),
                  const SizedBox(height: 14),
                  FilledButton(
                    onPressed: () => context.go('/home'),
                    child: const Text('Buka Beranda'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  final String label;
  final String value;
  const _PreviewRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: context.muted)),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
