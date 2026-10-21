import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/ai/model_download_service.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_theme.dart';

class AiModelManagerScreen extends ConsumerStatefulWidget {
  const AiModelManagerScreen({super.key});

  @override
  ConsumerState<AiModelManagerScreen> createState() =>
      _AiModelManagerScreenState();
}

class _AiModelManagerScreenState extends ConsumerState<AiModelManagerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(modelDownloadServiceProvider).checkCurrentStatus().then((_) {
        if (mounted) setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final manifest = ref.watch(modelManifestProvider);
    final downloadService = ref.watch(modelDownloadServiceProvider);
    final state = downloadService.currentState;
    final modelInfo = ref.watch(aiModelInfoProvider);

    // Also listen to stream for reactive UI updates
    ref.listen(modelDownloadStateProvider, (_, next) {
      if (mounted) setState(() {});
    });

    final isDownloading = state.status == DownloadStatus.downloading;
    final isVerifying = state.status == DownloadStatus.verifying;
    final isPaused = state.status == DownloadStatus.paused;
    final isCompleted = state.status == DownloadStatus.completed;
    final isFailed = state.status == DownloadStatus.failed;

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
                      child: const Center(
                        child: Text('🤖', style: TextStyle(fontSize: 24)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            manifest.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: context.ink,
                            ),
                          ),
                          Text(
                            'Versi ${manifest.version} • ${manifest.quantization}',
                            style: TextStyle(
                              color: context.muted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusChip(state.status),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                _InfoRow('Ukuran', manifest.formattedSize),
                _InfoRow('Lisensi', manifest.license),
                _InfoRow('Repositori', manifest.repository),
                _InfoRow('Deskripsi', manifest.description),
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
                _InfoRow('RAM minimum', '${manifest.minRamGb} GB'),
                _InfoRow('Penyimpanan', '~${manifest.minStorageMb} MB bebas'),
                _InfoRow('Android minimum', 'API ${manifest.minAndroidApi}'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Download / Verification progress
          if (isDownloading || isVerifying || isPaused) ...[
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
                      Text(
                        isVerifying ? '🔍' : '📥',
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isVerifying
                              ? 'Memverifikasi integritas SHA-256...'
                              : isPaused
                              ? 'Download dijeda'
                              : 'Mengunduh model dari sumber resmi...',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: context.ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: isVerifying
                        ? const LinearProgressIndicator(minHeight: 8)
                        : LinearProgressIndicator(
                            value: state.progressRatio,
                            backgroundColor: context.soft,
                            color: BuildHausTheme.ok,
                            minHeight: 8,
                          ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(state.bytesDownloaded / (1024 * 1024)).toStringAsFixed(1)} MB / ${manifest.formattedSize}',
                        style: TextStyle(color: context.muted, fontSize: 11),
                      ),
                      Text(
                        '${(state.progressRatio * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: context.ink,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (isDownloading)
                        OutlinedButton(
                          onPressed: () {
                            downloadService.pauseDownload();
                            setState(() {});
                          },
                          child: const Text('Jeda'),
                        )
                      else if (isPaused)
                        ElevatedButton(
                          onPressed: () {
                            downloadService.startDownload();
                            setState(() {});
                          },
                          child: const Text('Lanjutkan'),
                        ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: isVerifying
                            ? null
                            : () async {
                                await downloadService.cancelDownload();
                                ref.invalidate(aiModelStatusProvider);
                                ref.invalidate(aiModelInfoProvider);
                                setState(() {});
                              },
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
          if (isFailed && state.errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: BuildHausTheme.dangerBg,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Row(
                children: [
                  const Text('❌', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.errorMessage!,
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
              if (model == null && !isCompleted) return const SizedBox.shrink();
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
                          'Model Terpasang & Terverifikasi',
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
                      'Model: ${model?.modelName ?? manifest.name}',
                      style: TextStyle(fontSize: 11, color: context.ink),
                    ),
                    Text(
                      'Versi: ${model?.version ?? manifest.version}',
                      style: TextStyle(fontSize: 11, color: context.muted),
                    ),
                    Text(
                      'Checksum: SHA-256 Valid',
                      style: TextStyle(fontSize: 11, color: BuildHausTheme.ok),
                    ),
                    if (model?.installedAt != null)
                      Text(
                        'Dipasang: ${model!.installedAt.toString().substring(0, 16)}',
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
          if (isCompleted) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: context.soft,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Row(
                children: [
                  const Text('ℹ️', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Model AI sudah terpasang dan siap digunakan untuk analisis keluhan secara offline.',
                      style: TextStyle(color: context.muted, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _deleteModel(context, downloadService),
              icon: Icon(Icons.delete_outline, color: BuildHausTheme.danger),
              label: Text(
                'Hapus Model',
                style: TextStyle(color: BuildHausTheme.danger),
              ),
            ),
          ] else if (!isDownloading && !isVerifying && !isPaused) ...[
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  await downloadService.startDownload();
                  ref.invalidate(aiModelStatusProvider);
                  ref.invalidate(aiModelInfoProvider);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error download: $e')),
                    );
                  }
                }
              },
              icon: const Icon(Icons.cloud_download),
              label: Text(
                isFailed ? 'Coba Unduh Ulang' : 'Unduh Model AI Offline',
              ),
            ),
          ],

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
                    const Text('🔒', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Text(
                      'Privasi & Keamanan',
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
                  '• Model AI disimpan di penyimpanan privat aplikasi\n'
                  '• Tidak ada keluhan atau data yang dikirim ke server cloud\n'
                  '• Inferensi berjalan 100% lokal pada CPU/GPU perangkat Anda\n'
                  '• Checksum SHA-256 diverifikasi ketat sebelum model diaktifkan',
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
                const Text('📋', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tanpa model AI (Fallback)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: context.ink,
                        ),
                      ),
                      Text(
                        'Analisis dasar berbasis aturan tetap aktif otomatis saat model belum diunduh.',
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

  Widget _buildStatusChip(DownloadStatus status) {
    switch (status) {
      case DownloadStatus.completed:
        return Chip(
          label: Text(
            '✓ Siap',
            style: TextStyle(fontSize: 10, color: BuildHausTheme.ok),
          ),
          backgroundColor: BuildHausTheme.okBg,
          side: BorderSide.none,
        );
      case DownloadStatus.downloading:
        return Chip(
          label: Text(
            '↓ Mengunduh',
            style: TextStyle(fontSize: 10, color: BuildHausTheme.warn),
          ),
          backgroundColor: BuildHausTheme.warnBg,
          side: BorderSide.none,
        );
      case DownloadStatus.verifying:
        return Chip(
          label: Text(
            '🔍 Verifikasi',
            style: TextStyle(fontSize: 10, color: BuildHausTheme.warn),
          ),
          backgroundColor: BuildHausTheme.warnBg,
          side: BorderSide.none,
        );
      case DownloadStatus.paused:
        return Chip(
          label: Text(
            '⏸ Dijeda',
            style: TextStyle(fontSize: 10, color: context.muted),
          ),
          backgroundColor: context.soft,
          side: BorderSide.none,
        );
      case DownloadStatus.failed:
        return Chip(
          label: Text(
            '❌ Gagal',
            style: TextStyle(fontSize: 10, color: BuildHausTheme.danger),
          ),
          backgroundColor: BuildHausTheme.dangerBg,
          side: BorderSide.none,
        );
      case DownloadStatus.idle:
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

  Future<void> _deleteModel(
    BuildContext context,
    ModelDownloadService service,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Model AI?'),
        content: const Text(
          'File model offline akan dihapus dari penyimpanan perangkat. '
          'Aplikasi akan kembali menggunakan analisis dasar berbasis aturan.',
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

    if (confirm == true && context.mounted) {
      await service.deleteModel();
      ref.invalidate(aiModelStatusProvider);
      ref.invalidate(aiModelInfoProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Model AI berhasil dihapus.')),
        );
      }
      setState(() {});
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
