import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' hide Column;
import '../../../../core/database/app_database.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/engines/mileage_predictor.dart';

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
  MileagePredictor? _predictor;

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
    final logs = await db.getOdometerLogs(widget.motorcycleId);
    _predictor = MileagePredictor(logs);
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _odometerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final predictor = _predictor;
    final isLearning = predictor?.isLearningPhase ?? true;
    final periods = predictor?.validMonthlyPeriodsCount ?? 0;
    final kmWeek = predictor?.kmPerWeek ?? 0.0;
    final kmMonth = predictor?.kmPerMonth ?? 0.0;
    final kmDay = predictor?.kmPerDay;

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
              'Catat kilometer motor aktual secara berkala untuk estimasi pemakaian.',
              style: TextStyle(color: context.muted, fontSize: 12),
            ),
            const SizedBox(height: 20),

            // Current Actual Reading Card
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
                        Row(
                          children: [
                            Text(
                              'ODOMETER AKTUAL TERAKHIR',
                              style: TextStyle(
                                color: context.muted,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
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
                          'Dicatat pada ${_latest!.recordedAt.toString().substring(0, 10)}',
                          style: TextStyle(color: context.muted, fontSize: 10),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Text('🔢', style: TextStyle(fontSize: 32)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Learning Phase / Estimation Section
            if (isLearning) ...[
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
                        const Text('📊', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Text(
                          'Masa Pembelajaran ($periods/3 Periode Bulanan)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: context.ink,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      predictor?.learningStatusMessage ??
                          'Data penggunaan belum cukup. Masukkan pembaruan odometer secara rutin.',
                      style: TextStyle(
                        color: context.muted,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                    if (kmDay != null && kmDay > 0) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _PredBox(
                              label: 'Estimasi awal / hari',
                              value: '${kmDay.toStringAsFixed(1)} km',
                              sublabel: '(Masih kalibrasi)',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _PredBox(
                              label: 'Estimasi awal / bulan',
                              value: '${kmMonth.toStringAsFixed(0)} km',
                              sublabel: '(Akurasi berkembang)',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.soft,
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
                        const Text('✅', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 8),
                        Text(
                          'Estimasi Pemakaian Terkalibrasi',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: context.ink,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: BuildHausTheme.okBg,
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            '3 PERIODE TERPENUHI',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: BuildHausTheme.ok,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _PredBox(
                            label: 'Rata-rata per minggu',
                            value: '${kmWeek.toStringAsFixed(0)} km',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _PredBox(
                            label: 'Rata-rata per bulan',
                            value: '${kmMonth.toStringAsFixed(0)} km',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Estimasi dihitung dari bobot pembacaan aktual terbaru.',
                      style: TextStyle(color: context.muted, fontSize: 10),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Input Form
            Text(
              'Kilometer Aktual Baru (km)',
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
              decoration: const InputDecoration(hintText: 'Contoh: 12480'),
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
                  const Text('ℹ️', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Masukkan angka odometer yang terbaca pada speedometer motor.',
                      style: TextStyle(color: context.muted, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Simpan Odometer'),
              ),
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
            'Nilai kilometer lebih kecil dari catatan terakhir. Pastikan angka sesuai speedometer.',
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

      // Recalculate component statuses and predictions dynamically
      await db.recalculateComponentStatuses(widget.motorcycleId);

      ref.invalidate(latestOdometerProvider(widget.motorcycleId));
      ref.invalidate(odometerLogsProvider(widget.motorcycleId));
      ref.invalidate(mileagePredictorProvider(widget.motorcycleId));
      ref.invalidate(componentStatusesProvider(widget.motorcycleId));
      ref.invalidate(componentStatusesWithNamesProvider(widget.motorcycleId));
      ref.invalidate(budgetPlanSummaryProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Odometer berhasil disimpan!')),
        );
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
  final String? sublabel;

  const _PredBox({required this.label, required this.value, this.sublabel});

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
          if (sublabel != null)
            Text(
              sublabel!,
              style: TextStyle(fontSize: 8, color: context.muted),
            ),
        ],
      ),
    );
  }
}
