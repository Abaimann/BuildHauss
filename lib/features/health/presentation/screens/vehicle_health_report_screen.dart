import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/engines/motorcycle_specs.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/buildhaus_logo.dart';

/// Kartu Sertifikat & Laporan Ringkas Kondisi Motor.
///
/// Dirancang untuk transparansi kondisi kendaraan saat ingin dijual kembali,
/// diserahkan ke mekanik bengkel, atau diarsipkan oleh pemilik.
class VehicleHealthReportScreen extends ConsumerWidget {
  final int? motorcycleId;

  const VehicleHealthReportScreen({super.key, this.motorcycleId});

  String _fmtDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  String _buildPlainTextReport({
    required Motorcycle motor,
    required MotorcycleModel? model,
    required double? latestOdoKm,
    required List<ComponentStatusWithName> statuses,
    required MotorcycleExpenseSummary expense,
    required SelfInspection? inspection,
  }) {
    final validScores = statuses
        .where((s) => s.status.score != null)
        .map((s) => s.status.score!)
        .toList();
    final avgScore = validScores.isNotEmpty
        ? (validScores.reduce((a, b) => a + b) / validScores.length).round()
        : null;

    final ageCategory = MotorcycleSpecs.ageCategoryLabel(motor.manufactureYear);
    final fuelSystem = MotorcycleSpecs.fuelSystemLabel(
      model,
      manufactureYear: motor.manufactureYear,
    );
    final transmission = MotorcycleSpecs.transmissionLabel(model);
    final cooling = MotorcycleSpecs.coolingLabel(model);

    final buf = StringBuffer()
      ..writeln('========================================')
      ..writeln('LAPORAN KONDISI MOTOR — BUILDHAUS')
      ..writeln('Tanggal Cetak: ${_fmtDate(DateTime.now())}')
      ..writeln('========================================')
      ..writeln('Unit       : ${motor.nickname} (${motor.manufactureYear})')
      ..writeln('Kategori   : $ageCategory');
    if (model != null) {
      buf.writeln(
        'Model      : ${model.brand} ${model.model} ${model.variant ?? ''}'
            .trimRight(),
      );
    }
    buf.writeln('Spesifikasi: $transmission | $fuelSystem | $cooling');
    if (motor.plateNumber != null && motor.plateNumber!.isNotEmpty) {
      buf.writeln('Plat Nomor : ${motor.plateNumber}');
    }
    buf
      ..writeln(
        'Odometer   : ${latestOdoKm != null ? Formatters.km(latestOdoKm) : '-'}',
      )
      ..writeln('Skor Unit  : ${avgScore != null ? '$avgScore/100' : 'Belum cukup data'}')
      ..writeln(
        'Riwayat    : ${expense.recordCount} kunjungan/transaksi (Total ${Formatters.currency(expense.totalAllCost)})',
      )
      ..writeln(
        'Cek Fisik  : ${inspection != null ? '${_fmtDate(inspection.inspectedAt)} (${inspection.riskLevel?.toUpperCase() ?? 'NORMAL'})' : 'Belum pernah uji mandiri'}',
      )
      ..writeln('')
      ..writeln('STATUS KOMPONEN (${statuses.length} terpantau):');

    for (final item in statuses) {
      final sc = item.status.score != null
          ? '${item.status.score!.round()}%'
          : '-';
      final st = switch (item.status.estimatedStatus) {
        'good' => 'NORMAL',
        'inspect' => 'PERIKSA',
        'replace' => 'GANTI',
        _ => 'BELUM ADA DATA',
      };
      buf.writeln('- ${item.componentName}: [$st | $sc]');
    }
    buf.writeln('========================================');
    return buf.toString();
  }

  static const _downloadsChannel = MethodChannel(
    'com.buildhaus.buildhaus/downloads',
  );

  Future<void> _exportTextFile(
    BuildContext context,
    String reportText,
    String nickname,
  ) async {
    try {
      final safeName = nickname.toLowerCase().replaceAll(
        RegExp(r'[^a-z0-9]+'),
        '_',
      );
      final ts = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'laporan_${safeName}_$ts.txt';

      String? savedPath;
      if (Platform.isAndroid) {
        try {
          savedPath = await _downloadsChannel.invokeMethod<String>(
            'saveToDownloads',
            {
              'fileName': fileName,
              'content': reportText,
              'mimeType': 'text/plain',
            },
          );
        } on MissingPluginException {
          // Fallback saat pengujian headless/unit test di luar Android runtime.
          savedPath = null;
        }
      }

      if (savedPath == null) {
        final dir =
            (await getDownloadsDirectory()) ??
            await getApplicationDocumentsDirectory();
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
        final file = File(p.join(dir.path, fileName));
        await file.writeAsString(reportText);
        savedPath = file.path;
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Laporan disimpan ke: $savedPath')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan berkas: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    final activeMotor = ref.watch(activeMotorcycleProvider);
    final targetFuture = motorcycleId != null
        ? ref.watch(motorcyclesByIdProvider(motorcycleId!).future)
        : Future.value(activeMotor);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/health');
            }
          },
        ),
        title: const Text('Laporan Kondisi Motor'),
      ),
      body: FutureBuilder<Motorcycle?>(
        future: targetFuture,
        builder: (context, motorSnap) {
          if (motorSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final motor = motorSnap.data;
          if (motor == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.two_wheeler, size: 56, color: context.muted),
                    const SizedBox(height: 12),
                    const Text('Pilih motor terlebih dahulu.'),
                  ],
                ),
              ),
            );
          }

          final modelFuture = motor.modelId != null
              ? db.getMotorcycleModelById(motor.modelId!)
              : Future<MotorcycleModel?>.value(null);
          final statusesAsync = ref.watch(
            componentStatusesWithNamesProvider(motor.id),
          );
          final odoAsync = ref.watch(latestOdometerProvider(motor.id));
          final expenseAsync = ref.watch(
            motorcycleExpenseSummaryProvider(motor.id),
          );
          final inspectionAsync = ref.watch(
            latestSelfInspectionProvider(motor.id),
          );

          return FutureBuilder<MotorcycleModel?>(
            future: modelFuture,
            builder: (context, modelSnap) {
              final model = modelSnap.data;
              final statuses = statusesAsync.value ?? [];
              final latestOdo = odoAsync.value;
              final expense =
                  expenseAsync.value ??
                  const MotorcycleExpenseSummary(
                    totalAllCost: 0,
                    totalMonthCost: 0,
                    totalPartsCost: 0,
                    totalLaborCost: 0,
                    recordCount: 0,
                  );
              final inspection = inspectionAsync.value;

              final validScores = statuses
                  .where((s) => s.status.score != null)
                  .map((s) => s.status.score!)
                  .toList();
              final avgScore = validScores.isNotEmpty
                  ? (validScores.reduce((a, b) => a + b) / validScores.length)
                  : null;
              final scoreColor = avgScore == null
                  ? context.muted
                  : avgScore >= 75
                  ? BuildHausTheme.ok
                  : avgScore >= 50
                  ? BuildHausTheme.warn
                  : BuildHausTheme.danger;

              final reportText = _buildPlainTextReport(
                motor: motor,
                model: model,
                latestOdoKm: latestOdo?.odometerKm,
                statuses: statuses,
                expense: expense,
                inspection: inspection,
              );

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Header Sertifikat Kondisi
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF131D2B), Color(0xFF090D14)],
                      ),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: scoreColor.withValues(alpha: 0.45),
                        width: 1.3,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const BuildHausLogoCompact(size: 36),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'SERTIFIKAT KONDISI MOTOR',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.1,
                                      color: Color(0xFF00F5A0),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    motor.nickname,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: scoreColor.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: scoreColor.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    avgScore != null
                                        ? '${avgScore.round()}'
                                        : '?',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: scoreColor,
                                    ),
                                  ),
                                  Text(
                                    'SKOR',
                                    style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      color: scoreColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (model != null)
                              _ReportBadge(
                                '${model.brand} ${model.model} (${motor.manufactureYear})',
                              )
                            else
                              _ReportBadge('Tahun ${motor.manufactureYear}'),
                            _ReportBadge(
                              MotorcycleSpecs.ageCategoryLabel(
                                motor.manufactureYear,
                              ),
                            ),
                            if (motor.plateNumber != null &&
                                motor.plateNumber!.isNotEmpty)
                              _ReportBadge(motor.plateNumber!),
                            _ReportBadge(
                              MotorcycleSpecs.fuelSystemLabel(
                                model,
                                manufactureYear: motor.manufactureYear,
                              ),
                            ),
                            _ReportBadge(
                              MotorcycleSpecs.transmissionLabel(model),
                            ),
                            _ReportBadge(MotorcycleSpecs.coolingLabel(model)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: Colors.white12),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _ReportMetric(
                                label: 'Odometer Terkini',
                                value: latestOdo != null
                                    ? Formatters.km(latestOdo.odometerKm)
                                    : '-',
                              ),
                            ),
                            Expanded(
                              child: _ReportMetric(
                                label: 'Total Servis',
                                value: '${expense.recordCount} catatan',
                              ),
                            ),
                            Expanded(
                              child: _ReportMetric(
                                label: 'Investasi Rawat',
                                value: Formatters.currency(expense.totalAllCost),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tombol Aksi Ekspor / Salin
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          key: const ValueKey('copy_report_button'),
                          onPressed: () async {
                            await Clipboard.setData(
                              ClipboardData(text: reportText),
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Laporan kondisi motor disalin ke clipboard!',
                                  ),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.copy_rounded, size: 18),
                          label: const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Salin Teks',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          key: const ValueKey('save_report_file_button'),
                          onPressed: () => _exportTextFile(
                            context,
                            reportText,
                            motor.nickname,
                          ),
                          icon: const Icon(Icons.save_alt_rounded, size: 18),
                          label: const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Simpan .TXT',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  Text(
                    'Rincian Komponen Terpantau (${statuses.length})',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  ...statuses.map((item) {
                    final sc = item.status.score;
                    final col = sc == null
                        ? context.muted
                        : sc >= 75
                        ? BuildHausTheme.ok
                        : sc >= 50
                        ? BuildHausTheme.warn
                        : BuildHausTheme.danger;
                    final stLabel = switch (item.status.estimatedStatus) {
                      'good' => 'NORMAL',
                      'inspect' => 'PERIKSA',
                      'replace' => 'GANTI',
                      _ => 'BELUM ADA DATA',
                    };
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.surface2,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: context.line),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.componentName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: context.ink,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.status.explanation,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: context.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: col.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              sc != null ? '$stLabel · ${sc.round()}%' : stLabel,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: col,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _ReportBadge extends StatelessWidget {
  final String text;
  const _ReportBadge(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: Colors.white70,
        ),
      ),
    );
  }
}

class _ReportMetric extends StatelessWidget {
  final String label;
  final String value;
  const _ReportMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.white54),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
