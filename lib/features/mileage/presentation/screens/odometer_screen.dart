import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' hide Column;
import '../../../../core/database/app_database.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_theme.dart';

class OdometerScreen extends ConsumerStatefulWidget {
  final int motorcycleId;
  const OdometerScreen({super.key, required this.motorcycleId});

  @override
  ConsumerState<OdometerScreen> createState() => _OdometerScreenState();
}

class _OdometerScreenState extends ConsumerState<OdometerScreen> {
  final _odometerController = TextEditingController();
  bool _saving = false;
  OdometerLog? _latest;
  double _predictedWeekly = 0;
  double _predictedMonthly = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = ref.read(databaseProvider);
    _latest = await db.getLatestOdometer(widget.motorcycleId);
    if (_latest != null) {
      _odometerController.text = _latest!.odometerKm.toStringAsFixed(0);
    }
    await _calculatePredictions();
    if (mounted) setState(() {});
  }

  Future<void> _calculatePredictions() async {
    final db = ref.read(databaseProvider);
    final logs = await db.getOdometerLogs(widget.motorcycleId);

    if (logs.length >= 2) {
      // Sort by date ascending
      final sorted = [...logs]
        ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));

      // Calculate average daily km from the last two readings
      final latest = sorted.last;
      final prev = sorted[sorted.length - 2];
      final daysDiff = latest.recordedAt.difference(prev.recordedAt).inDays;
      if (daysDiff > 0) {
        final kmPerDay = (latest.odometerKm - prev.odometerKm) / daysDiff;
        _predictedWeekly = kmPerDay * 7;
        _predictedMonthly = kmPerDay * 30;
      }
    }
  }

  @override
  void dispose() {
    _odometerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Input Odometer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () =>
                context.push('/motor/${widget.motorcycleId}/odometer-history'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Update Odometer',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Catat kilometer motor secara rutin untuk estimasi pemakaian.',
              style: TextStyle(color: context.muted, fontSize: 12),
            ),
            const SizedBox(height: 24),

            // Current reading
            if (_latest != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.surface2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.line),
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pembacaan terakhir',
                          style: TextStyle(color: context.muted, fontSize: 10),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_latest!.odometerKm.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} km',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: context.ink,
                          ),
                        ),
                        Text(
                          _latest!.recordedAt.toString().substring(0, 10),
                          style: TextStyle(color: context.muted, fontSize: 10),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text('🔢', style: TextStyle(fontSize: 32)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Predictions
            if (_predictedWeekly > 0) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.soft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estimasi pemakaian',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: context.ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _PredBox(
                            label: 'Per minggu',
                            value: '${_predictedWeekly.toStringAsFixed(0)} km',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _PredBox(
                            label: 'Per bulan',
                            value: '${_predictedMonthly.toStringAsFixed(0)} km',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Berdasarkan 2 periode data terakhir. Semakin banyak data, semakin akurat.',
                      style: TextStyle(color: context.muted, fontSize: 10),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.soft,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Row(
                  children: [
                    Text('📊', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Data belum cukup untuk estimasi. Masukkan odometer secara rutin (minimal 2x) untuk melihat prediksi.',
                        style: TextStyle(color: context.muted, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Input
            Text(
              'Kilometer saat ini (km)',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: context.ink,
              ),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _odometerController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Contoh: 12480',
                prefixText: '',
              ),
            ),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                      'Catatan: odometer tidak boleh lebih kecil dari pembacaan terakhir.',
                      style: TextStyle(color: context.muted, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Simpan Odometer'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final text = _odometerController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Masukkan nilai odometer')));
      return;
    }

    final value = double.tryParse(text);
    if (value == null || value < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan angka yang valid')),
      );
      return;
    }

    if (_latest != null && value < _latest!.odometerKm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Odometer tidak boleh lebih kecil dari pembacaan terakhir. Gunakan koreksi jika perlu.',
          ),
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final db = ref.read(databaseProvider);

      await db.insertOdometerLog(
        OdometerLogsCompanion(
          motorcycleId: Value(widget.motorcycleId),
          odometerKm: Value(value),
          recordedAt: Value(DateTime.now()),
          source: const Value('manual'),
        ),
      );

      ref.invalidate(latestOdometerProvider(widget.motorcycleId));
      ref.invalidate(odometerLogsProvider(widget.motorcycleId));

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Odometer disimpan!')));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _PredBox extends StatelessWidget {
  final String label;
  final String value;
  const _PredBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: context.surface2,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 9, color: context.muted)),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: context.ink,
            ),
          ),
        ],
      ),
    );
  }
}
