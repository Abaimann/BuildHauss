import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/animated_widgets.dart';
import '../../../../shared/widgets/buildhaus_logo.dart';
import '../../domain/sparepart_image_helper.dart';
import '../providers/parts_providers.dart';

String _formatPartCategoryLabel(String raw) {
  switch (raw) {
    case 'Semua':
    case 'Rekomendasi Budget':
    case 'Perhatian Kesehatan':
      return raw;
  }
  const exactMap = {
    'oli': 'Oli Mesin',
    'oli_mesin': 'Oli Mesin',
    'oli_gardan': 'Oli Gardan',
    'minyak_rem': 'Minyak Rem',
    'filter': 'Filter Udara',
    'filter_oli': 'Filter Oli',
    'filter_udara': 'Filter Udara',
    'kampas_rem': 'Kampas Rem',
    'rem': 'Kampas Rem',
    'cvt': 'CVT & V-Belt',
    'vbelt': 'V-Belt',
    'aki': 'Aki / Baterai',
    'busi': 'Busi',
    'ban': 'Ban',
    'rantai': 'Rantai & Gir',
    'shock': 'Shockbreaker',
    'shockbreaker': 'Shockbreaker',
    'knalpot': 'Knalpot',
    'coolant': 'Radiator Coolant',
  };
  final key = raw.trim().toLowerCase();
  if (exactMap.containsKey(key)) return exactMap[key]!;
  return key
      .split('_')
      .where((p) => p.isNotEmpty)
      .map((p) => p[0].toUpperCase() + p.substring(1))
      .join(' ');
}

class PartsCatalogScreen extends ConsumerStatefulWidget {
  const PartsCatalogScreen({super.key});

  @override
  ConsumerState<PartsCatalogScreen> createState() => _PartsCatalogScreenState();
}

class _PartsCatalogScreenState extends ConsumerState<PartsCatalogScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'Semua';
  String _sortBy = 'priority'; // priority, name, price_low, price_high

  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatCurrency(num amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  String _sortLabel(String sortBy) {
    switch (sortBy) {
      case 'price_low':
        return 'Termurah';
      case 'price_high':
        return 'Termahal';
      case 'name':
        return 'Nama A-Z';
      default:
        return 'Rekomendasi';
    }
  }

  Future<void> _showFilterModal(
    BuildContext context, {
    required List<String> dbCategories,
    required bool hasActiveMotor,
  }) async {
    final smartFilters = [
      'Semua',
      if (hasActiveMotor) 'Rekomendasi Budget',
      if (hasActiveMotor) 'Perhatian Kesehatan',
    ];

    final uniqueCategories = <String>[];
    final seenLabels = <String>{};
    for (final cat in dbCategories) {
      final label = _formatPartCategoryLabel(cat);
      if (seenLabels.add(label)) {
        uniqueCategories.add(cat);
      }
    }
    uniqueCategories.sort(
      (a, b) =>
          _formatPartCategoryLabel(a).compareTo(_formatPartCategoryLabel(b)),
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: context.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.line,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Filter Katalog Sparepart',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: context.ink,
                      ),
                    ),
                  ),
                  if (_selectedCategory != 'Semua')
                    TextButton(
                      onPressed: () {
                        setState(() => _selectedCategory = 'Semua');
                        Navigator.pop(ctx);
                      },
                      child: const Text('Reset'),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Prioritas & Tampilan',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: context.muted,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: smartFilters
                    .map((cat) => _buildModalFilterChip(ctx, cat))
                    .toList(),
              ),
              if (uniqueCategories.isNotEmpty) ...[
                const SizedBox(height: 18),
                Text(
                  'Kategori Komponen',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: context.muted,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: uniqueCategories
                      .map((cat) => _buildModalFilterChip(ctx, cat))
                      .toList(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalFilterChip(BuildContext sheetCtx, String cat) {
    final isSelected =
        _formatPartCategoryLabel(_selectedCategory) ==
        _formatPartCategoryLabel(cat);
    final isBudget = cat == 'Rekomendasi Budget';
    final isHealth = cat == 'Perhatian Kesehatan';

    Color activeBg = context.ink;
    Color activeText = context.bg;
    IconData? icon;

    if (isBudget) {
      icon = Icons.account_balance_wallet_outlined;
      if (isSelected) {
        activeBg = Colors.green.shade700;
        activeText = Colors.white;
      }
    } else if (isHealth) {
      icon = Icons.health_and_safety_outlined;
      if (isSelected) {
        activeBg = Colors.orange.shade800;
        activeText = Colors.white;
      }
    }

    final borderColor = isSelected
        ? activeBg
        : (isBudget
            ? Colors.green.withValues(alpha: 0.45)
            : (isHealth
                ? Colors.orange.withValues(alpha: 0.45)
                : context.line));

    return TapScale(
      onTap: () {
        setState(() => _selectedCategory = cat);
        Navigator.pop(sheetCtx);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : context.surface2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isSelected
                    ? activeText
                    : (isBudget ? Colors.green : Colors.orange),
              ),
              const SizedBox(width: 6),
            ] else if (isSelected) ...[
              Icon(Icons.check_rounded, size: 14, color: activeText),
              const SizedBox(width: 5),
            ],
            Text(
              _formatPartCategoryLabel(cat),
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? activeText : context.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSortModal(BuildContext context) async {
    const sortOptions = [
      ('priority', 'Rekomendasi Prioritas', Icons.auto_awesome_outlined),
      ('price_low', 'Harga Terendah', Icons.arrow_upward_rounded),
      ('price_high', 'Harga Tertinggi', Icons.arrow_downward_rounded),
      ('name', 'Nama Produk (A–Z)', Icons.sort_by_alpha_rounded),
    ];

    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      backgroundColor: context.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.line,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Urutkan Katalog',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: context.ink,
                ),
              ),
              const SizedBox(height: 12),
              ...sortOptions.map((opt) {
                final isSelected = _sortBy == opt.$1;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TapScale(
                    onTap: () {
                      setState(() => _sortBy = opt.$1);
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? BuildHausTheme.ok.withValues(alpha: 0.14)
                            : context.surface2,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? BuildHausTheme.ok.withValues(alpha: 0.5)
                              : context.line,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            opt.$3,
                            size: 18,
                            color: isSelected
                                ? BuildHausTheme.ok
                                : context.muted,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              opt.$2,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: context.ink,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle_rounded,
                              size: 18,
                              color: BuildHausTheme.ok,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);
    final activeMotor = ref.watch(activeMotorcycleProvider);
    final prioritizedPartsAsync = ref.watch(prioritizedSparepartsProvider);
    final statsAsync = ref.watch(sparepartRecommendationStatsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar
          SliverAppBar(
            pinned: true,
            toolbarHeight: 72,
            backgroundColor: context.bg,
            surfaceTintColor: Colors.transparent,
            titleSpacing: 16,
            title: Row(
              children: [
                const BuildHausLogoCompact(size: 38),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Katalog Sparepart',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: context.ink,
                        ),
                      ),
                      Text(
                        activeMotor != null
                            ? 'Rekomendasi untuk ${activeMotor.nickname}'
                            : 'Semua katalog suku cadang',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.muted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Active Motorcycle Context Banner
          if (activeMotor != null)
            SliverToBoxAdapter(
              child: statsAsync.when(
                data: (stats) => FadeSlideIn(
                  index: 0,
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.surface2,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: context.line),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: context.statusOk.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.two_wheeler_outlined,
                          size: 20,
                          color: context.statusOk,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activeMotor.nickname,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: context.ink,
                              ),
                            ),
                            Text(
                              stats.budgetAmount != null
                                  ? 'Anggaran: ${_formatCurrency(stats.budgetAmount!)}'
                                  : 'Belum ada anggaran aktif',
                              style: TextStyle(
                                fontSize: 11,
                                color: context.muted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (stats.budgetCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.green.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.account_balance_wallet_outlined,
                                size: 12,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${stats.budgetCount} Budget',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (stats.healthCount > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.orange.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.health_and_safety_outlined,
                                size: 12,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${stats.healthCount} Servis',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),

          // Search Box
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari nama suku cadang, merek, atau kategori...',
                  hintStyle: TextStyle(fontSize: 13, color: context.muted),
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

          // Filter & Sort Option Bar (opens clean bottom-sheet modal without horizontal scrolling)
          SliverToBoxAdapter(
            child: FutureBuilder<List<String>>(
              future: db.getAllSparepartCategories(),
              builder: (context, snap) {
                final dbCategories = snap.data ?? [];
                final hasCustomFilter = _selectedCategory != 'Semua';
                final isBudget = _selectedCategory == 'Rekomendasi Budget';
                final isHealth = _selectedCategory == 'Perhatian Kesehatan';
                final filterAccent = isBudget
                    ? Colors.green
                    : (isHealth ? Colors.orange : BuildHausTheme.ok);

                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TapScale(
                          onTap: () => _showFilterModal(
                            context,
                            dbCategories: dbCategories,
                            hasActiveMotor: activeMotor != null,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: hasCustomFilter
                                  ? filterAccent.withValues(alpha: 0.14)
                                  : context.surface2,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: hasCustomFilter
                                    ? filterAccent.withValues(alpha: 0.55)
                                    : context.line,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.tune_rounded,
                                  size: 16,
                                  color: hasCustomFilter
                                      ? filterAccent
                                      : context.muted,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Filter: ${_formatPartCategoryLabel(_selectedCategory)}',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: hasCustomFilter
                                          ? FontWeight.bold
                                          : FontWeight.w600,
                                      color: context.ink,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (hasCustomFilter)
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () => setState(
                                      () => _selectedCategory = 'Semua',
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 4),
                                      child: Icon(
                                        Icons.close_rounded,
                                        size: 16,
                                        color: filterAccent,
                                      ),
                                    ),
                                  )
                                else
                                  Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    size: 18,
                                    color: context.muted,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: TapScale(
                          onTap: () => _showSortModal(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 11,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: _sortBy != 'priority'
                                  ? context.ink.withValues(alpha: 0.12)
                                  : context.surface2,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _sortBy != 'priority'
                                    ? context.ink.withValues(alpha: 0.45)
                                    : context.line,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.swap_vert_rounded,
                                  size: 16,
                                  color: _sortBy != 'priority'
                                      ? context.ink
                                      : context.muted,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    _sortLabel(_sortBy),
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: context.ink,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 18,
                                  color: context.muted,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 6)),

          // Prioritized Main Grid Content
          prioritizedPartsAsync.when(
            data: (allPrioritizedParts) {
              // 1. Filter by category / smart tab
              var filtered = allPrioritizedParts.where((p) {
                if (_selectedCategory == 'Rekomendasi Budget') {
                  return p.isBudgetRecommended;
                }
                if (_selectedCategory == 'Perhatian Kesehatan') {
                  return p.isHealthRecommended;
                }
                if (_selectedCategory != 'Semua') {
                  final targetLabel = _formatPartCategoryLabel(
                    _selectedCategory,
                  );
                  return _formatPartCategoryLabel(p.part.category) ==
                      targetLabel;
                }
                return true;
              }).toList();

              // 2. Filter by search query
              if (_searchQuery.isNotEmpty) {
                final q = _searchQuery.toLowerCase();
                filtered = filtered.where((p) {
                  final name = p.part.name.toLowerCase();
                  final brand = (p.part.brand ?? '').toLowerCase();
                  final cat = p.part.category.toLowerCase();
                  final comp = (p.componentName ?? '').toLowerCase();
                  return name.contains(q) ||
                      brand.contains(q) ||
                      cat.contains(q) ||
                      comp.contains(q);
                }).toList();
              }

              // 3. Sort
              switch (_sortBy) {
                case 'price_low':
                  filtered.sort(
                    (a, b) => (a.part.referencePrice ?? 0).compareTo(
                      b.part.referencePrice ?? 0,
                    ),
                  );
                  break;
                case 'price_high':
                  filtered.sort(
                    (a, b) => (b.part.referencePrice ?? 0).compareTo(
                      a.part.referencePrice ?? 0,
                    ),
                  );
                  break;
                case 'name':
                  filtered.sort((a, b) => a.part.name.compareTo(b.part.name));
                  break;
                case 'priority':
                default:
                  // Priority order: Budget Funded -> Budget Deferred -> Health -> General
                  filtered.sort((a, b) {
                    final tierCmp = a.tier.index.compareTo(b.tier.index);
                    if (tierCmp != 0) return tierCmp;
                    return a.part.name.compareTo(b.part.name);
                  });
                  break;
              }

              if (filtered.isEmpty) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(
                            Icons.search_off_outlined,
                            size: 48,
                            color: context.muted,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Suku cadang tidak ditemukan',
                            style: TextStyle(color: context.muted),
                          ),
                          if (_selectedCategory != 'Semua' ||
                              _searchQuery.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _selectedCategory = 'Semua';
                                  _searchQuery = '';
                                });
                              },
                              child: const Text('Reset Filter'),
                            ),
                          ],
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
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.59,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => FadeSlideIn(
                      key: ValueKey('part_card_${filtered[i].part.id}'),
                      index: i,
                      child: _PartCard(item: filtered[i]),
                    ),
                    childCount: filtered.length,
                  ),
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
            error: (err, _) => SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Gagal memuat rekomendasi: $err',
                    style: TextStyle(color: BuildHausTheme.danger),
                  ),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _PartCard extends StatelessWidget {
  final PrioritizedSparepart item;
  const _PartCard({required this.item});

  IconData _getPartIcon(String name, String category) {
    final n = name.toLowerCase();
    final c = category.toLowerCase();
    if (n.contains('oli') || c.contains('oli')) {
      return Icons.water_drop_outlined;
    }
    if (n.contains('rem') || c.contains('rem') || n.contains('brake')) {
      return Icons.trip_origin_rounded;
    }
    if (n.contains('ban') || c.contains('ban') || n.contains('tire')) {
      return Icons.album_outlined;
    }
    if (n.contains('busi') || c.contains('busi') || n.contains('spark')) {
      return Icons.flash_on_outlined;
    }
    if (n.contains('filter') || c.contains('filter')) {
      return Icons.tune_rounded;
    }
    if (n.contains('aki') || c.contains('aki') || n.contains('baterai')) {
      return Icons.battery_charging_full_outlined;
    }
    if (n.contains('rantai') || c.contains('rantai') || n.contains('chain')) {
      return Icons.link_rounded;
    }
    if (n.contains('cvt') || c.contains('cvt')) {
      return Icons.settings_suggest_outlined;
    }
    if (n.contains('knalpot') || c.contains('knalpot')) {
      return Icons.air_outlined;
    }
    if (n.contains('shock') || c.contains('shock') || n.contains('suspensi')) {
      return Icons.height_outlined;
    }
    return Icons.handyman_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final part = item.part;
    final price = part.referencePrice;
    final priceText = price != null
        ? 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}'
        : 'Hubungi toko';

    Color? badgeBg;
    Color? badgeTextCol;
    IconData? badgeIcon;

    switch (item.tier) {
      case RecommendationTier.budgetFunded:
        badgeBg = Colors.green.shade800;
        badgeTextCol = Colors.white;
        badgeIcon = Icons.account_balance_wallet_outlined;
        break;
      case RecommendationTier.budgetDeferred:
        badgeBg = Colors.amber.shade900;
        badgeTextCol = Colors.white;
        badgeIcon = Icons.schedule_outlined;
        break;
      case RecommendationTier.healthAttention:
        badgeBg = Colors.deepOrange.shade800;
        badgeTextCol = Colors.white;
        badgeIcon = Icons.health_and_safety_outlined;
        break;
      case RecommendationTier.generalCatalog:
        badgeBg = null;
        badgeTextCol = null;
        badgeIcon = null;
        break;
    }

    return TapScale(
      pressedScale: 0.97,
      onTap: () => _showPartDetail(context),
      child: Container(
        decoration: BoxDecoration(
          color: context.surface2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: item.isBudgetRecommended
                ? Colors.green.withValues(alpha: 0.5)
                : (item.isHealthRecommended
                    ? Colors.deepOrange.withValues(alpha: 0.5)
                    : context.line),
            width: item.tier != RecommendationTier.generalCatalog ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Studio Image Bay (unobstructed rounded studio frame)
            Container(
              height: 102,
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
              decoration: BoxDecoration(
                color: context.surface3.withValues(alpha: 0.7),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
              ),
              child: Builder(
                builder: (ctx) {
                  final assetPath = SparepartImageHelper.getAssetPath(
                    part.category,
                    part.name,
                  );
                  if (assetPath != null) {
                    return Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F6FA),
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.14),
                        ),
                      ),
                      padding: const EdgeInsets.all(6),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          assetPath,
                          fit: BoxFit.contain,
                          cacheWidth: 220,
                          errorBuilder: (ctx, err, stack) => Center(
                            child: Icon(
                              _getPartIcon(part.name, part.category),
                              size: 38,
                              color: context.muted,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  return Container(
                    decoration: BoxDecoration(
                      color: context.surface2,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Center(
                      child: Icon(
                        _getPartIcon(part.name, part.category),
                        size: 38,
                        color: item.isBudgetRecommended
                            ? Colors.green
                            : (item.isHealthRecommended
                                ? Colors.deepOrange
                                : context.ink),
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(11, 8, 11, 11),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.badgeText != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (badgeIcon != null) ...[
                              Icon(badgeIcon, size: 10, color: badgeTextCol),
                              const SizedBox(width: 4),
                            ],
                            Expanded(
                              child: Text(
                                item.badgeText!,
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                  color: badgeTextCol,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                    Row(
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: context.soft,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              _formatPartCategoryLabel(part.category),
                              style: TextStyle(
                                fontSize: 9.5,
                                color: context.muted,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        if (part.isVerified) ...[
                          const SizedBox(width: 4),
                          Tooltip(
                            message: 'Katalog Resmi Terverifikasi',
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: BuildHausTheme.ok.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Icon(
                                Icons.verified_rounded,
                                size: 11,
                                color: BuildHausTheme.ok,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      part.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                        height: 1.25,
                        color: context.ink,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (part.brand != null && part.brand!.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        part.brand!,
                        style: TextStyle(fontSize: 10.5, color: context.muted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Est. $priceText',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11.5,
                              color: BuildHausTheme.warn,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 10,
                          color: context.muted,
                        ),
                      ],
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

  void _showPartDetail(BuildContext context) {
    final part = item.part;
    final price = part.referencePrice;
    final priceText = price != null
        ? 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}'
        : 'Hubungi toko';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.65,
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

              // Recommendation Reason Callout
              if (item.tier == RecommendationTier.budgetFunded) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 20,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Prioritas 1: Sesuai Anggaran Aktif',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.reason ??
                                  'Suku cadang ini dialokasikan dan didanai dalam rencana anggaran servis motor aktif Anda.',
                              style: TextStyle(
                                fontSize: 11,
                                color: context.ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ] else if (item.tier == RecommendationTier.budgetDeferred) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.amber.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.schedule_outlined,
                        size: 20,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Prioritas 1: Rencana Servis (Perlu Tabungan)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.amber,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.reason ??
                                  'Komponen ini direkomendasikan untuk diservis, namun memerlukan tabungan tambahan agar mencukupi.',
                              style: TextStyle(
                                fontSize: 11,
                                color: context.ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ] else if (item.tier == RecommendationTier.healthAttention) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.deepOrange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.health_and_safety_outlined,
                        size: 20,
                        color: Colors.deepOrange,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Prioritas 2: Perhatian Kondisi Kesehatan',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.deepOrange,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.reason ??
                                  'Komponen ${item.componentName ?? ''} memerlukan tindakan perawatan atau penggantian.',
                              style: TextStyle(
                                fontSize: 11,
                                color: context.ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Part Image / Icon Header Container
              Container(
                width: double.infinity,
                height: 148,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.surface2,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.line),
                ),
                child: Builder(
                  builder: (ctx) {
                    final assetPath = SparepartImageHelper.getAssetPath(
                      part.category,
                      part.name,
                    );
                    if (assetPath != null) {
                      return Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F6FA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            assetPath,
                            fit: BoxFit.contain,
                            cacheWidth: 320,
                            errorBuilder: (ctx, err, stack) => Center(
                              child: Icon(
                                _getPartIcon(part.name, part.category),
                                size: 56,
                                color: item.isBudgetRecommended
                                    ? Colors.green
                                    : (item.isHealthRecommended
                                        ? Colors.deepOrange
                                        : context.ink),
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    return Center(
                      child: Icon(
                        _getPartIcon(part.name, part.category),
                        size: 56,
                        color: item.isBudgetRecommended
                            ? Colors.green
                            : (item.isHealthRecommended
                                ? Colors.deepOrange
                                : context.ink),
                      ),
                    );
                  },
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
                  _formatPartCategoryLabel(part.category),
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
              const SizedBox(height: 10),
              Consumer(
                builder: (bCtx, ref, _) {
                  final activeMotor = ref.watch(activeMotorcycleProvider);
                  final fitments =
                      ref.watch(allSparepartFitmentsProvider).value ?? [];
                  final isMatchedForActive =
                      activeMotor?.modelId != null &&
                      fitments.any(
                        (f) =>
                            f.sparepartId == part.id &&
                            f.modelId == activeMotor!.modelId,
                      );
                  final badgeCol = isMatchedForActive
                      ? BuildHausTheme.ok
                      : BuildHausTheme.warn;
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: badgeCol.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: badgeCol.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isMatchedForActive
                              ? Icons.verified_outlined
                              : Icons.info_outline,
                          size: 16,
                          color: badgeCol,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isMatchedForActive
                                ? 'Terverifikasi cocok untuk ${activeMotor!.nickname}'
                                : 'Referensi katalog umum — verifikasi part number untuk motor Anda',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: badgeCol,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
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
                  '* Estimasi harga referensi pasar',
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
