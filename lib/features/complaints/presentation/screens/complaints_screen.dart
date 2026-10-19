import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';

class ComplaintsScreen extends ConsumerWidget {
  const ComplaintsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeMotor = ref.watch(activeMotorcycleProvider);

    if (activeMotor == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Keluhan')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Tambahkan motor terlebih dahulu',
                style: TextStyle(color: context.muted),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.push('/add-motor'),
                child: const Text('Tambah Motor'),
              ),
            ],
          ),
        ),
      );
    }

    final complaintsAsync = ref.watch(complaintsProvider(activeMotor.id));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: const Text('Keluhan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/complaints/new'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Riwayat keluhan motor ini.',
              style: TextStyle(color: context.muted, fontSize: 12),
            ),
          ),
          Expanded(
            child: complaintsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (complaints) {
                if (complaints.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '📝',
                          style: TextStyle(fontSize: 48, color: context.muted),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Belum ada keluhan',
                          style: TextStyle(color: context.muted),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => context.push('/complaints/new'),
                          icon: const Icon(Icons.add),
                          label: const Text('Tambah Keluhan'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: complaints.length,
                  itemBuilder: (context, i) {
                    final c = complaints[i];
                    final statusColor = _getStatusColor(c.status);

                    return GestureDetector(
                      onTap: () => context.push('/complaints/${c.id}'),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
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
                                Expanded(
                                  child: Text(
                                    c.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: context.ink,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                  child: Text(
                                    _getStatusLabel(c.status),
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: statusColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              c.description,
                              style: TextStyle(
                                color: context.muted,
                                fontSize: 11,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              Formatters.date(c.openedAt),
                              style: TextStyle(
                                color: context.muted,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/complaints/new'),
        backgroundColor: context.ink,
        foregroundColor: context.bg,
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.trim()) {
      case 'selesai':
        return BuildHausTheme.ok;
      case 'ditangani':
        return BuildHausTheme.ok;
      case 'perlu_pemeriksaan':
        return BuildHausTheme.warn;
      case 'dianalisis':
        return BuildHausTheme.warn;
      case 'dibuka_kembali':
        return BuildHausTheme.danger;
      default:
        return const Color(0xFF888888);
    }
  }

  String _getStatusLabel(String status) {
    switch (status.trim()) {
      case ' baru':
        return 'BARU';
      case 'dianalisis':
        return 'DIANALISIS';
      case 'perlu_pemeriksaan':
        return 'PERLU CEK';
      case 'ditangani':
        return 'DITANGANI';
      case 'selesai':
        return 'SELESAI';
      case 'dibuka_kembali':
        return 'DIBUKA LG';
      default:
        return status.toUpperCase();
    }
  }
}
