import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/buildhaus_logo.dart';
import '../providers/parts_providers.dart';

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
            ),
          ),

          // Active Motorcycle Context Banner
          if (activeMotor != null)
            SliverToBoxAdapter(
              child: statsAsync.when(
                data: (stats) => Container(
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

          // Category & Smart Filter Chips
          SliverToBoxAdapter(
            child: FutureBuilder<List<String>>(
              future: db.getAllSparepartCategories(),
              builder: (context, snap) {
                final dbCategories = snap.data ?? [];
                final smartFilters = [
                  'Semua',
                  if (activeMotor != null) 'Rekomendasi Budget',
                  if (activeMotor != null) 'Perhatian Kesehatan',
                  ...dbCategories,
                ];

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: smartFilters.map((cat) {
                      final isSelected = _selectedCategory == cat;
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

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedCategory = cat),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected ? activeBg : context.surface2,
                              borderRadius: BorderRadius.circular(99),
                              border: Border.all(
                                color: isSelected
                                    ? activeBg
                                    : (isBudget
                                        ? Colors.green.withValues(alpha: 0.4)
                                        : (isHealth
                                            ? Colors.orange
                                                .withValues(alpha: 0.4)
                                            : context.line)),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (icon != null) ...[
                                  Icon(
                                    icon,
                                    size: 13,
                                    color: isSelected
                                        ? activeText
                                        : (isBudget
                                            ? Colors.green
                                            : Colors.orange),
                                  ),
                                  const SizedBox(width: 5),
                                ],
                                Text(
                                  cat,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? activeText
                                        : context.ink,
                                  ),
                                ),
                              ],
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

          // Sort Row
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Text(
                    'Urutan: ',
                    style: TextStyle(fontSize: 12, color: context.muted),
                  ),
                  ...[
                    ('priority', 'Rekomendasi'),
                    ('price_low', 'Harga ⬆'),
                    ('price_high', 'Harga ⬇'),
                    ('name', 'Nama'),
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
                  return p.part.category.toLowerCase() ==
                      _selectedCategory.toLowerCase();
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
                    childAspectRatio: 0.68,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _PartCard(item: filtered[i]),
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

    return GestureDetector(
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
            // Top Image / Icon Area with Recommendation Badge
            Container(
              height: 85,
              decoration: BoxDecoration(
                color: context.surface3,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      _getPartIcon(part.name, part.category),
                      size: 42,
                      color: item.isBudgetRecommended
                          ? Colors.green
                          : (item.isHealthRecommended
                              ? Colors.deepOrange
                              : context.ink),
                    ),
                  ),
                  if (item.badgeText != null)
                    Positioned(
                      top: 6,
                      left: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
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
                              const SizedBox(width: 3),
                            ],
                            Expanded(
                              child: Text(
                                item.badgeText!,
                                style: TextStyle(
                                  fontSize: 9,
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
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    const SizedBox(height: 4),
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
                        fontSize: 11,
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

              // Part Icon Header Container
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: context.surface2,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.line),
                ),
                child: Center(
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
