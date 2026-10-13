import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/providers/database_provider.dart';

class ServiceHistoryScreen extends ConsumerWidget {
  const ServiceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeMotor = ref.watch(activeMotorcycleProvider);

    if (activeMotor == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Riwayat Servis')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Tambahkan motor terlebih dahulu', style: TextStyle(color: context.muted)),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: () => context.push('/add-motor'), child: const Text('Tambah Motor')),
            ],
          ),
        ),
      );
    }

    final recordsAsync = ref.watch(serviceRecordsProvider(activeMotor.id));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/home')),
        title: const Text('Riwayat Servis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/history/add'),
          ),
        ],
      ),
      body: recordsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (records) {
          if (records.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🗂️', style: TextStyle(fontSize: 48, color: context.muted)),
                  const SizedBox(height: 12),
                  Text('Belum ada riwayat servis', style: TextStyle(color: context.muted)),
                  const SizedBox(height: 4),
                  Text('Catat servis untuk melacak perawatan motor.', style: TextStyle(color: context.muted, fontSize: 11)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/history/add'),
                    icon: const Icon(Icons.add),
                    label: const Text('Catat Servis'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            itemBuilder: (context, i) {
              final r = records[i];
              return _ServiceRecordCard(record: r, motorcycleId: activeMotor.id);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/history/add'),
        backgroundColor: context.ink,
        foregroundColor: context.bg,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ServiceRecordCard extends ConsumerWidget {
  final ServiceRecord record;
  final int motorcycleId;

  const _ServiceRecordCard({required this.record, required this.motorcycleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);

    return GestureDetector(
      onTap: () => _showDetail(context, ref),
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
                Text('🗂️', style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    record.workshopName ?? 'Servis',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: context.ink),
                  ),
                ),
                if (record.totalCost > 0)
                  Text(
                    Formatters.currency(record.totalCost),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: context.ink),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(Formatters.date(record.servicedAt), style: TextStyle(color: context.muted, fontSize: 10)),
                if (record.odometerKm != null) ...[
                  const SizedBox(width: 8),
                  Text('· ${record.odometerKm!.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} km',
                    style: TextStyle(color: context.muted, fontSize: 10)),
                ],
                if (record.workshopName != null) ...[
                  const SizedBox(width: 8),
                  Text('· ${record.workshopName}', style: TextStyle(color: context.muted, fontSize: 10)),
                ],
              ],
            ),
            if (record.notes != null && record.notes!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(record.notes!, style: TextStyle(color: context.muted, fontSize: 10), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context, WidgetRef ref) {
    final db = ref.read(databaseProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.8,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) => FutureBuilder<List<ServiceItem>>(
          future: db.getServiceItems(record.id),
          builder: (context, snap) {
            final items = snap.data ?? [];
            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Text('Detail Servis', style: Theme.of(context).textTheme.titleMedium),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        await db.deleteServiceRecord(record.id);
                        ref.invalidate(serviceRecordsProvider(motorcycleId));
                        if (context.mounted) Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _DetailRow('Tanggal', Formatters.dateTime(record.servicedAt)),
                if (record.odometerKm != null)
                  _DetailRow('Odometer', '${record.odometerKm!.toStringAsFixed(0)} km'),
                if (record.workshopName != null)
                  _DetailRow('Bengkel', record.workshopName!),
                if (record.notes != null && record.notes!.isNotEmpty)
                  _DetailRow('Catatan', record.notes!),
                _DetailRow('Total Biaya', Formatters.currency(record.totalCost)),
                const SizedBox(height: 16),
                Text('Item Servis', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                if (items.isEmpty)
                  Text('Tidak ada detail item.', style: TextStyle(color: context.muted, fontSize: 12)),
                ...items.map((item) => _ServiceItemRow(item: item)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: TextStyle(color: context.muted, fontSize: 11)),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: context.ink, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _ServiceItemRow extends StatelessWidget {
  final ServiceItem item;
  const _ServiceItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: context.soft,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(_actionIcon(item.action), style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.action.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: context.muted)),
                if (item.notes != null)
                  Text(item.notes!, style: TextStyle(fontSize: 11, color: context.ink)),
              ],
            ),
          ),
          if (item.totalCost > 0)
            Text(Formatters.currency(item.totalCost), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: context.ink)),
        ],
      ),
    );
  }

  String _actionIcon(String action) {
    switch (action) {
      case 'replace': return '🔄';
      case 'inspect': return '🔍';
      case 'clean': return '🧹';
      case 'repair': return '🔧';
      default: return '•';
    }
  }
}
