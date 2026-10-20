import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/providers/database_provider.dart';

class SparepartsScreen extends ConsumerStatefulWidget {
  const SparepartsScreen({super.key});

  @override
  ConsumerState<SparepartsScreen> createState() => _SparepartsScreenState();
}

class _SparepartsScreenState extends ConsumerState<SparepartsScreen> {
  String? _selectedCategory;

  final _categories = [
    {'key': 'oli_mesin', 'name': 'Oli mesin', 'icon': '🛢️'},
    {'key': 'kampas_rem', 'name': 'Kampas rem', 'icon': '🛑'},
    {'key': 'aki', 'name': 'Aki', 'icon': '🔋'},
    {'key': 'ban', 'name': 'Ban', 'icon': '🛞'},
    {'key': 'filter_udara', 'name': 'Filter udara', 'icon': '🌬️'},
    {'key': 'busi', 'name': 'Busi', 'icon': '⚡'},
    {'key': 'cvt', 'name': 'CVT', 'icon': '⚙️'},
    {'key': 'knalpot', 'name': 'Knalpot', 'icon': '💨'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: const Text('Sparepart & Kondisi'),
        actions: [
          TextButton.icon(
            onPressed: () => context.go('/budget'),
            icon: const Icon(Icons.account_balance_wallet_outlined, size: 18),
            label: const Text('Budget'),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pilih kategori',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Katalog referensi. Kecocokan dan harga perlu diverifikasi.',
                  style: TextStyle(color: context.muted, fontSize: 11),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.3,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, i) {
                final cat = _categories[i];
                final isSelected = _selectedCategory == cat['key'];
                return GestureDetector(
                  onTap: () => setState(
                    () => _selectedCategory = isSelected ? null : cat['key'],
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.surface2,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? context.ink : context.line,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          cat['icon']!,
                          style: const TextStyle(fontSize: 24),
                        ),
                        Text(
                          cat['name']!,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: context.ink,
                          ),
                        ),
                        if (isSelected)
                          Text(
                            'Dipilih',
                            style: TextStyle(fontSize: 9, color: context.muted),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Parts list
          if (_selectedCategory != null) _buildPartsList(context, ref),
        ],
      ),
    );
  }

  Widget _buildPartsList(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);

    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(top: BorderSide(color: context.line)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  _categories.firstWhere(
                    (c) => c['key'] == _selectedCategory,
                  )['icon']!,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  _categories.firstWhere(
                    (c) => c['key'] == _selectedCategory,
                  )['name']!,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => setState(() => _selectedCategory = null),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Sparepart>>(
              future: db.getSparepartsByCategory(_selectedCategory!),
              builder: (context, snap) {
                final parts = snap.data ?? [];
                if (parts.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '📦',
                          style: TextStyle(fontSize: 32, color: context.muted),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Belum ada data sparepart untuk kategori ini.',
                          style: TextStyle(color: context.muted, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Data untuk kategori ini belum tersedia.',
                          style: TextStyle(color: context.muted, fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: parts.length,
                  itemBuilder: (context, i) {
                    final p = parts[i];
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
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: context.soft,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                _categories.firstWhere(
                                  (c) => c['key'] == _selectedCategory,
                                )['icon']!,
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                    color: context.ink,
                                  ),
                                ),
                                if (p.partNumber != null)
                                  Text(
                                    'Kode referensi: ${p.partNumber}',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: context.muted,
                                    ),
                                  ),
                                if (!p.isVerified)
                                  Text(
                                    'Belum diverifikasi; kecocokan tidak dijamin',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: context.muted,
                                    ),
                                  ),
                                if (p.productUrl != null)
                                  GestureDetector(
                                    onTap: () {
                                      /* open URL */
                                    },
                                    child: Text(
                                      'Lihat sumber resmi',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                p.referencePrice != null
                                    ? Formatters.currency(p.referencePrice)
                                    : 'Harga ref.',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  color: context.ink,
                                ),
                              ),
                              if (p.isVerified)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: BuildHausTheme.okBg,
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                  child: Text(
                                    '✓ Terverifikasi',
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: BuildHausTheme.ok,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
