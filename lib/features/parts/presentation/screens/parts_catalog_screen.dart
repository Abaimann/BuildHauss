import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/database/app_database.dart';
import '../../../../shared/widgets/buildhaus_logo.dart';

class PartsCatalogScreen extends ConsumerStatefulWidget {
  const PartsCatalogScreen({super.key});

  @override
  ConsumerState<PartsCatalogScreen> createState() => _PartsCatalogScreenState();
}

class _PartsCatalogScreenState extends ConsumerState<PartsCatalogScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'Semua';
  String _sortBy = 'name';

  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: context.bg,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [context.surface, context.bg],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(16, 60, 16, 0),
                child: Row(
                  children: [
                    const BuildHausLogoCompact(size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Katalog Sparepart',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: context.ink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari sparepart...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
            ),
          ),

          // Category Filter
          SliverToBoxAdapter(
            child: FutureBuilder<List<String>>(
              future: db.getAllSparepartCategories(),
              builder: (context, snap) {
                final categories = ['Semua', ...(snap.data ?? [])];
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: categories.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedCategory = cat),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? context.ink
                                  : context.surface2,
                              borderRadius: BorderRadius.circular(99),
                              border: Border.all(
                                color: isSelected ? context.ink : context.line,
                              ),
                            ),
                            child: Text(
                              cat,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: isSelected ? context.bg : context.ink,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Text(
                    'Sortir: ',
                    style: TextStyle(fontSize: 12, color: context.muted),
                  ),
                  ...[
                    ('name', 'Nama'),
                    ('price_low', 'Harga ⬆'),
                    ('price_high', 'Harga ⬇'),
                  ].map((s) {
                    final isSelected = _sortBy == s.$1;
                    return Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: GestureDetector(
                        onTap: () => setState(() => _sortBy = s.$1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? context.ink
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            s.$2,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected ? context.bg : context.muted,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          // Parts Grid
          FutureBuilder<List<Sparepart>>(
            future: db.searchSpareparts(
              category: _selectedCategory,
              query: _searchQuery,
            ),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              var parts = snap.data ?? [];

              // Sort
              switch (_sortBy) {
                case 'price_low':
                  parts.sort(
                    (a, b) => (a.referencePrice ?? 0).compareTo(
                      b.referencePrice ?? 0,
                    ),
                  );
                  break;
                case 'price_high':
                  parts.sort(
                    (a, b) => (b.referencePrice ?? 0).compareTo(
                      a.referencePrice ?? 0,
                    ),
                  );
                  break;
                default:
                  parts.sort((a, b) => a.name.compareTo(b.name));
                  break;
              }

              if (parts.isEmpty) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 48,
                            color: context.muted,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Sparepart tidak ditemukan',
                            style: TextStyle(color: context.muted),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.78,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _PartCard(part: parts[i]),
                    childCount: parts.length,
                  ),
                ),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _PartCard extends StatelessWidget {
  final Sparepart part;
  const _PartCard({required this.part});

  @override
  Widget build(BuildContext context) {
    final price = part.referencePrice;
    final priceText = price != null
        ? 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}'
        : 'Hubungi toko';

    return GestureDetector(
      onTap: () => _showPartDetail(context),
      child: Container(
        decoration: BoxDecoration(
          color: context.surface2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 90,
              decoration: BoxDecoration(
                color: context.surface3,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
              ),
              child: Center(
                child: Text(
                  _getPartEmoji(part.name, part.category),
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                height: 92,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: context.soft,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        part.category,
                        style: TextStyle(
                          fontSize: 9,
                          color: context.muted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      part.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: context.ink,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (part.brand != null && part.brand!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        part.brand!,
                        style: TextStyle(fontSize: 10, color: context.muted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const Spacer(),
                    Text(
                      'Est. $priceText',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: BuildHausTheme.warn,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPartEmoji(String name, String category) {
    final n = name.toLowerCase();
    if (n.contains('oli') || n.contains('oil')) return '🛢️';
    if (n.contains('rem') || n.contains('brake') || n.contains('kampas')) {
      return '🛑';
    }
    if (n.contains('rantai') || n.contains('chain')) return '⛓️';
    if (n.contains('busi') || n.contains('spark')) return '⚡';
    if (n.contains('filter')) return '🔧';
    if (n.contains('ban') || n.contains('tire')) return '🛞';
    if (n.contains('baterai') || n.contains('aki')) return '🔋';
    if (n.contains('kopling') || n.contains('clutch')) return '⚙️';
    return '🔩';
  }

  void _showPartDetail(BuildContext context) {
    final price = part.referencePrice;
    final priceText = price != null
        ? 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}'
        : 'Hubungi toko';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.line,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: 140,
                decoration: BoxDecoration(
                  color: context.surface2,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.line),
                ),
                child: Center(
                  child: Text(
                    _getPartEmoji(part.name, part.category),
                    style: const TextStyle(fontSize: 64),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: context.soft,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  part.category,
                  style: TextStyle(
                    fontSize: 11,
                    color: context.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(part.name, style: Theme.of(context).textTheme.headlineSmall),
              if (part.brand != null && part.brand!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Merek: ${part.brand}',
                  style: TextStyle(fontSize: 12, color: context.muted),
                ),
              ],
              const SizedBox(height: 12),
              if (price != null) ...[
                Text(
                  priceText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: BuildHausTheme.warn,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '* Harga referensi, bisa berbeda di toko',
                  style: TextStyle(fontSize: 10, color: context.muted),
                ),
                const SizedBox(height: 16),
              ],
              if (part.partNumber != null && part.partNumber!.isNotEmpty) ...[
                Text(
                  'Nomor Part',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: context.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  part.partNumber!,
                  style: TextStyle(fontSize: 13, color: context.muted),
                ),
                const SizedBox(height: 16),
              ],
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('"${part.name}" disimpan!')),
                    );
                  },
                  icon: const Icon(Icons.bookmark_border),
                  label: const Text('Simpan ke Wishlist'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Buka di browser...')),
                    );
                  },
                  icon: const Icon(Icons.local_offer_outlined),
                  label: const Text('Cek Toko Terdekat'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
