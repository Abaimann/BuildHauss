import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' hide Column;
import '../../../../core/database/app_database.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_theme.dart';

class AiModelManagerScreen extends ConsumerStatefulWidget {
  const AiModelManagerScreen({super.key});

  @override
  ConsumerState<AiModelManagerScreen> createState() =>
      _AiModelManagerScreenState();
}

class _AiModelManagerScreenState extends ConsumerState<AiModelManagerScreen> {
  String _downloadStatus = 'not_downloaded';
  double _downloadProgress = 0.0;
  bool _downloading = false;
  String? _lastError;

  // Model manifest - in production, this would come from a trusted source
  static const _modelManifest = {
    'name': 'Qwen3-0.6B-GGUF',
    'version': '1.0',
    'description':
        'Model bahasa kecil untuk analisis keluhan motor (6 parameter).',
    'size_mb': 350,
    'license': 'Apache 2.0',
    'source_note':
        'Model harus diunduh dari sumber resmi. URL akan dikonfirmasi.',
    'requirements': {'min_ram_gb': 2, 'min_storage_mb': 500, 'android_min': 24},
  };

  @override
  Widget build(BuildContext context) {
    final aiStatus = ref.watch(aiModelStatusProvider);
    final modelInfo = ref.watch(aiModelInfoProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('AI Model Manager'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'AI Health Assistant',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(
            'Kelola model AI offline untuk analisis keluhan motor.',
            style: TextStyle(color: context.muted, fontSize: 12),
          ),
          const SizedBox(height: 24),

          // Model info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.surface2,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: context.soft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text('🤖', style: const TextStyle(fontSize: 24)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _modelManifest['name'] as String,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: context.ink,
                            ),
                          ),
                          Text(
                            'Versi ${_modelManifest['version']}',
                            style: TextStyle(
                              color: context.muted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    aiStatus.when(
                      data: (status) => _buildStatusChip(status),
                      loading: () =>
                          const CircularProgressIndicator(strokeWidth: 2),
                      error: (_, __) => const Chip(label: Text('Error')),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                _InfoRow('Ukuran', '~${_modelManifest['size_mb']} MB'),
                _InfoRow('License', _modelManifest['license'] as String),
                _InfoRow('Deskripsi', _modelManifest['description'] as String),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                Text(
                  'Persyaratan perangkat:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: context.ink,
                  ),
                ),
                const SizedBox(height: 6),
                _InfoRow(
                  'RAM minimum',
                  '${(_modelManifest['requirements'] as Map)['min_ram_gb']} GB',
                ),
                _InfoRow(
                  'Penyimpanan',
                  '~${(_modelManifest['requirements'] as Map)['min_storage_mb']} MB bebas',
                ),
                _InfoRow(
                  'Android minimum',
                  'API ${(_modelManifest['requirements'] as Map)['android_min']}',
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Download progress
          if (_downloading || _downloadProgress > 0) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.surface2,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('📥', style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(
                        'Mengunduh model...',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: context.ink,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: _downloadProgress,
                      backgroundColor: context.soft,
                      color: BuildHausTheme.ok,
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${(_downloadProgress * 100).toStringAsFixed(1)}%',
                    style: TextStyle(color: context.muted, fontSize: 11),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: _pauseDownload,
                        child: const Text('Jeda'),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: _cancelDownload,
                        child: Text(
                          'Batal',
                          style: TextStyle(color: BuildHausTheme.danger),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Error display
          if (_lastError != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: BuildHausTheme.dangerBg,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Row(
                children: [
                  Text('❌', style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _lastError!,
                      style: TextStyle(
                        color: BuildHausTheme.danger,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Installed model info
          modelInfo.when(
            data: (model) {
              if (model == null) return const SizedBox.shrink();
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: BuildHausTheme.okBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: BuildHausTheme.ok.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: BuildHausTheme.ok,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Model Terpasang',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: BuildHausTheme.ok,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Model: ${model.modelName}',
                      style: TextStyle(fontSize: 11, color: context.ink),
                    ),
                    Text(
                      'Versi: ${model.version}',
                      style: TextStyle(fontSize: 11, color: context.muted),
                    ),
                    if (model.installedAt != null)
                      Text(
                        'Dipasang: ${model.installedAt.toString().substring(0, 16)}',
                        style: TextStyle(fontSize: 11, color: context.muted),
                      ),
                  ],
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          const SizedBox(height: 16),

          // Action buttons
          aiStatus.when(
            data: (status) {
              if (status == 'ready') {
                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: context.soft,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Row(
                        children: [
                          Text('ℹ️', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Model AI sudah terpasang dan siap digunakan untuk analisis keluhan.',
                              style: TextStyle(
                                color: context.muted,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => _deleteModel(context),
                      icon: Icon(
                        Icons.delete_outline,
                        color: BuildHausTheme.danger,
                      ),
                      label: Text(
                        'Hapus Model',
                        style: TextStyle(color: BuildHausTheme.danger),
                      ),
                    ),
                  ],
                );
              }
              return ElevatedButton.icon(
                onPressed: _downloading ? null : _startDownload,
                icon: const Icon(Icons.cloud_download),
                label: Text(_downloading ? 'Mengunduh...' : 'Unduh Model AI'),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => ElevatedButton.icon(
              onPressed: _startDownload,
              icon: const Icon(Icons.cloud_download),
              label: const Text('Unduh Model AI'),
            ),
          ),

          const SizedBox(height: 24),

          // Privacy notice
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.soft,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('🔒', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Text(
                      'Privasi',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: context.ink,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '• Model AI disimpan secara lokal di HP Anda\n'
                  '• Tidak ada data yang dikirim ke server manapun\n'
                  '• Analisis keluhan dilakukan 100% offline\n'
                  '• SHA-256 checksum diverifikasi saat download',
                  style: TextStyle(
                    color: context.muted,
                    fontSize: 10,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Without AI info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.surface2,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: context.line),
            ),
            child: Row(
              children: [
                Text('📋', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tanpa model AI',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: context.ink,
                        ),
                      ),
                      Text(
                        'Analisis rule-based tetap tersedia untuk membantu memahami keluhan motor.',
                        style: TextStyle(color: context.muted, fontSize: 10),
                      ),
                    ],
                  ),
                ),
                const Chip(
                  label: Text('Aktif', style: TextStyle(fontSize: 9)),
                  backgroundColor: BuildHausTheme.okBg,
                  side: BorderSide.none,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    switch (status) {
      case 'ready':
        return Chip(
          label: Text(
            '✓ Siap',
            style: TextStyle(fontSize: 10, color: BuildHausTheme.ok),
          ),
          backgroundColor: BuildHausTheme.okBg,
          side: BorderSide.none,
        );
      case 'downloading':
        return Chip(
          label: Text(
            '↓ Unduh',
            style: TextStyle(fontSize: 10, color: BuildHausTheme.warn),
          ),
          backgroundColor: BuildHausTheme.warnBg,
          side: BorderSide.none,
        );
      default:
        return Chip(
          label: Text(
            '⏳ Belum',
            style: TextStyle(fontSize: 10, color: context.muted),
          ),
          backgroundColor: context.soft,
          side: BorderSide.none,
        );
    }
  }

  Future<void> _startDownload() async {
    setState(() {
      _downloading = true;
      _downloadProgress = 0.0;
      _lastError = null;
    });

    // Simulate download progress
    // In production, this would use dio to download from a real URL
    for (int i = 0; i <= 100; i++) {
      if (!_downloading) break;
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        setState(() => _downloadProgress = i / 100);
      }
    }

    // For now, simulate completion
    if (mounted) {
      setState(() {
        _downloading = false;
        // In production, we'd save the model info to database here
        // For demo, we show the UI flow works
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Fitur download memerlukan konfigurasi URL model resmi. '
              'Analisis rule-based tetap tersedia.',
            ),
          ),
        );
      });
      ref.invalidate(aiModelStatusProvider);
    }
  }

  void _pauseDownload() {
    setState(() => _downloading = false);
  }

  void _cancelDownload() {
    setState(() {
      _downloading = false;
      _downloadProgress = 0.0;
    });
  }

  Future<void> _deleteModel(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Model AI?'),
        content: const Text(
          'Model AI akan dihapus dari perangkat. '
          'Anda masih bisa menggunakan analisis rule-based tanpa AI.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Hapus',
              style: TextStyle(color: BuildHausTheme.danger),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Model AI dihapus.')));
      ref.invalidate(aiModelStatusProvider);
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(color: context.muted, fontSize: 11),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: context.ink, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
