import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/ai/gemini_ai_runtime.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_theme.dart';

class AiModelManagerScreen extends ConsumerStatefulWidget {
  const AiModelManagerScreen({super.key});

  @override
  ConsumerState<AiModelManagerScreen> createState() =>
      _AiModelManagerScreenState();
}

class _AiModelManagerScreenState extends ConsumerState<AiModelManagerScreen> {
  final _apiKeyController = TextEditingController();
  bool _obscureKey = true;
  bool _isSaving = false;
  bool _isTesting = false;
  String? _testMessage;
  bool? _testSuccess;
  bool _hasKey = false;

  @override
  void initState() {
    super.initState();
    _loadApiKey();
  }

  Future<void> _loadApiKey() async {
    final GeminiAiRuntime runtime = ref.read(geminiAiRuntimeProvider);
    final key = await runtime.getApiKey();
    if (!mounted) return;
    setState(() {
      if (key != null && key.isNotEmpty) {
        _apiKeyController.text = key;
        _hasKey = true;
      } else {
        _hasKey = false;
      }
    });
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _saveApiKey() async {
    final trimmed = _apiKeyController.text.trim();
    if (trimmed.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan API Key terlebih dahulu.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final GeminiAiRuntime runtime = ref.read(geminiAiRuntimeProvider);
      await runtime.saveApiKey(trimmed);
      ref.invalidate(aiModelStatusProvider);
      ref.invalidate(geminiApiKeyProvider);
      if (!mounted) return;
      setState(() {
        _hasKey = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('API Key Gemini 2.5 Flash berhasil disimpan!'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _testConnection() async {
    setState(() {
      _isTesting = true;
      _testMessage = null;
      _testSuccess = null;
    });
    try {
      final GeminiAiRuntime runtime = ref.read(geminiAiRuntimeProvider);
      final (ok, msg) = await runtime.testConnection(
        overrideApiKey: _apiKeyController.text,
      );
      if (!mounted) return;
      setState(() {
        _testSuccess = ok;
        _testMessage = msg;
      });
    } finally {
      if (mounted) {
        setState(() => _isTesting = false);
      }
    }
  }

  Future<void> _clearApiKey() async {
    final GeminiAiRuntime runtime = ref.read(geminiAiRuntimeProvider);
    await runtime.clearApiKey();
    _apiKeyController.clear();
    ref.invalidate(aiModelStatusProvider);
    ref.invalidate(geminiApiKeyProvider);
    if (!mounted) return;
    setState(() {
      _hasKey = false;
      _testMessage = null;
      _testSuccess = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('API Key berhasil dihapus.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Konfigurasi AI (Gemini 2.5 Flash)'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Google Gemini 2.5 Flash',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(
            'Asisten AI Online Cloud — Cerdas, Cepat, dan Hemat Memori (0 MB).',
            style: TextStyle(color: context.muted, fontSize: 12),
          ),
          const SizedBox(height: 24),

          // Card 1: Info Model Cloud
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
                        child: Text('✨', style: TextStyle(fontSize: 24)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gemini 2.5 Flash (Cloud API)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: context.ink,
                            ),
                          ),
                          Text(
                            'Model ID: ${GeminiAiRuntime.modelId} • Google Generative AI',
                            style: TextStyle(
                              color: context.muted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _hasKey
                        ? Chip(
                            label: Text(
                              '✓ Aktif',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: BuildHausTheme.ok,
                              ),
                            ),
                            backgroundColor: BuildHausTheme.okBg,
                            side: BorderSide.none,
                          )
                        : Chip(
                            label: Text(
                              '🔑 Perlu API Key',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: BuildHausTheme.warn,
                              ),
                            ),
                            backgroundColor: BuildHausTheme.warnBg,
                            side: BorderSide.none,
                          ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                const _InfoRow(
                  'Penyimpanan',
                  '0 MB (Online API — Tanpa Download Model)',
                ),
                const _InfoRow(
                  'Penggunaan RAM',
                  'Sangat Ringan (Inferensi di Cloud)',
                ),
                const _InfoRow(
                  'Konteks Motor',
                  'Terintegrasi dengan data SQLite motor Anda',
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Card 2: Konfigurasi Gemini API Key
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
                Text(
                  '🔑 Gemini API Key',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: context.ink,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Masukkan API Key dari Google AI Studio (aistudio.google.com) untuk mengaktifkan analisis Gemini 2.5 Flash.',
                  style: TextStyle(
                    color: context.muted,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _apiKeyController,
                  obscureText: _obscureKey,
                  decoration: InputDecoration(
                    hintText: 'AIzaSy...',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: _obscureKey
                              ? 'Tampilkan API Key'
                              : 'Sembunyikan API Key',
                          icon: Icon(
                            _obscureKey
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 18,
                          ),
                          onPressed: () {
                            setState(() => _obscureKey = !_obscureKey);
                          },
                        ),
                        IconButton(
                          tooltip: 'Bersihkan teks',
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            setState(() {
                              _apiKeyController.clear();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      onPressed: _isSaving ? null : _saveApiKey,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_outlined, size: 16),
                      label: const Text('Simpan API Key'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _isTesting ? null : _testConnection,
                      icon: _isTesting
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.wifi_tethering, size: 16),
                      label: const Text('Tes Koneksi'),
                    ),
                    if (_hasKey)
                      TextButton.icon(
                        onPressed: _clearApiKey,
                        icon: Icon(
                          Icons.delete_outline,
                          size: 16,
                          color: BuildHausTheme.danger,
                        ),
                        label: Text(
                          'Hapus API Key',
                          style: TextStyle(color: BuildHausTheme.danger),
                        ),
                      ),
                  ],
                ),
                if (_testMessage != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _testSuccess == true
                          ? BuildHausTheme.okBg
                          : BuildHausTheme.dangerBg,
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(
                        color: (_testSuccess == true
                                ? BuildHausTheme.ok
                                : BuildHausTheme.danger)
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          _testSuccess == true
                              ? Icons.check_circle_outline
                              : Icons.error_outline,
                          size: 18,
                          color: _testSuccess == true
                              ? BuildHausTheme.ok
                              : BuildHausTheme.danger,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _testMessage!,
                            style: TextStyle(
                              fontSize: 12,
                              color: _testSuccess == true
                                  ? BuildHausTheme.ok
                                  : BuildHausTheme.danger,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Card 3: Keunggulan Mode Online & Fallback
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.soft,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('💡', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Text(
                      'Keunggulan Mode Online & Fallback Otomatis',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: context.ink,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '• Menghemat ~378 MB ruang penyimpanan internal dan beban RAM berat karena tidak perlu mengunduh model GGUF lokal.\n'
                  '• Riwayat motor, servis, odometer, dan percakapan tetap tersimpan aman di database SQLite perangkat Anda.\n'
                  '• Fallback Otomatis: Jika perangkat sedang tidak memiliki koneksi internet atau API Key belum diatur, asisten tetap bekerja menggunakan Analisis Dasar berbasis aturan.',
                  style: TextStyle(
                    color: context.muted,
                    fontSize: 11,
                    height: 1.5,
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
            width: 110,
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
