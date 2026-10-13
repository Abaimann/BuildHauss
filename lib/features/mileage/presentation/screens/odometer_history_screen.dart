import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';

class OdometerHistoryScreen extends ConsumerWidget {
  final int motorcycleId;
  const OdometerHistoryScreen({super.key, required this.motorcycleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(odometerLogsProvider(motorcycleId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        title: const Text('Riwayat Odometer'),
      ),
      body: logsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (logs) {
          if (logs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('📊', style: TextStyle(fontSize: 48, color: context.muted)),
                  const SizedBox(height: 12),
                  Text('Belum ada data odometer', style: TextStyle(color: context.muted)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.push('/motor/$motorcycleId/odometer'),
                    child: const Text('Input Odometer'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: logs.length,
            itemBuilder: (context, i) {
              final log = logs[i];
              final prev = i < logs.length - 1 ? logs[i + 1] : null;
              double? diff;
              if (prev != null) {
                diff = log.odometerKm - prev.odometerKm;
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.surface2,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: context.line),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: context.soft,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(child: Text('🔢', style: const TextStyle(fontSize: 18))),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${log.odometerKm.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} km',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: context.ink),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            Formatters.dateTime(log.recordedAt),
                            style: TextStyle(color: context.muted, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    if (diff != null && diff > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: context.soft,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          '+${diff.toStringAsFixed(0)} km',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: context.ink),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/motor/$motorcycleId/odometer'),
        backgroundColor: context.ink,
        foregroundColor: context.bg,
        child: const Icon(Icons.add),
      ),
    );
  }
}
