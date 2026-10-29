import 'package:flutter/material.dart';

/// Helper to provide memory-efficient, local WebP asset images for spareparts.
class SparepartImageHelper {
  /// Known asset mapping by category and common category aliases
  static const Map<String, String> _categoryAssetMap = {
    // Oli
    'oli_mesin': 'assets/images/parts/oli_mesin.webp',
    'oli': 'assets/images/parts/oli_mesin.webp',
    'oli_gardan': 'assets/images/parts/oli_gardan.webp',
    'oli_transmisi': 'assets/images/parts/oli_gardan.webp',
    'transmisi': 'assets/images/parts/oli_gardan.webp',

    // Pengereman
    'kampas_rem': 'assets/images/parts/kampas_rem.webp',
    'rem': 'assets/images/parts/kampas_rem.webp',
    'pengereman': 'assets/images/parts/kampas_rem.webp',
    'minyak_rem': 'assets/images/parts/minyak_rem.webp',

    // Pengapian & Kelistrikan
    'busi': 'assets/images/parts/busi.webp',
    'aki': 'assets/images/parts/aki.webp',
    'kelistrikan': 'assets/images/parts/aki.webp',

    // Filter
    'filter': 'assets/images/parts/filter_udara.webp',
    'filter_udara': 'assets/images/parts/filter_udara.webp',
    'filter_oli': 'assets/images/parts/filter_oli.webp',

    // Ban & Roda
    'ban': 'assets/images/parts/ban.webp',
    'roda': 'assets/images/parts/ban.webp',

    // Penggerak & Transmisi
    'cvt': 'assets/images/parts/cvt.webp',
    'rantai': 'assets/images/parts/rantai.webp',

    // Pendingin
    'coolant': 'assets/images/parts/radiator_coolant.webp',
    'radiator_coolant': 'assets/images/parts/radiator_coolant.webp',
    'pendingin': 'assets/images/parts/radiator_coolant.webp',

    // Kaki-kaki & Suspensi
    'shock': 'assets/images/parts/shockbreaker.webp',
    'shockbreaker': 'assets/images/parts/shockbreaker.webp',
    'suspensi': 'assets/images/parts/shockbreaker.webp',

    // Gas Buang
    'knalpot': 'assets/images/parts/knalpot.webp',
  };

  /// Returns the asset path for a sparepart based on its category and name.
  /// Returns null if no matching local asset exists.
  static String? getAssetPath(String category, [String? name]) {
    final catKey = category.trim().toLowerCase();
    if (_categoryAssetMap.containsKey(catKey)) {
      return _categoryAssetMap[catKey];
    }

    // Keyword-based fallback matching from name or category string
    final text = '${category.toLowerCase()} ${name?.toLowerCase() ?? ''}';

    if (text.contains('oli') && (text.contains('gardan') || text.contains('transmisi') || text.contains('gear'))) {
      return 'assets/images/parts/oli_gardan.webp';
    }
    if (text.contains('oli') || text.contains('lubricant') || text.contains('engine oil')) {
      return 'assets/images/parts/oli_mesin.webp';
    }
    if (text.contains('rem') || text.contains('brake') || text.contains('kampas')) {
      return 'assets/images/parts/kampas_rem.webp';
    }
    if (text.contains('busi') || text.contains('spark')) {
      return 'assets/images/parts/busi.webp';
    }
    if (text.contains('aki') || text.contains('battery') || text.contains('accu')) {
      return 'assets/images/parts/aki.webp';
    }
    if (text.contains('ban') || text.contains('tire') || text.contains('tyre')) {
      return 'assets/images/parts/ban.webp';
    }
    if (text.contains('cvt') || text.contains('belt') || text.contains('roller')) {
      return 'assets/images/parts/cvt.webp';
    }
    if (text.contains('rantai') || text.contains('chain') || text.contains('gir') || text.contains('gear set')) {
      return 'assets/images/parts/rantai.webp';
    }
    if (text.contains('filter') && text.contains('udara') || text.contains('air filter')) {
      return 'assets/images/parts/filter_udara.webp';
    }
    if (text.contains('filter') && text.contains('oli') || text.contains('oil filter')) {
      return 'assets/images/parts/filter_oli.webp';
    }
    if (text.contains('radiator') || text.contains('coolant') || text.contains('air pendingin')) {
      return 'assets/images/parts/radiator_coolant.webp';
    }
    if (text.contains('minyak rem') || text.contains('brake fluid')) {
      return 'assets/images/parts/minyak_rem.webp';
    }
    if (text.contains('shock') || text.contains('suspensi') || text.contains('damper')) {
      return 'assets/images/parts/shockbreaker.webp';
    }
    if (text.contains('knalpot') || text.contains('exhaust') || text.contains('muffler') || text.contains('gasket')) {
      return 'assets/images/parts/knalpot.webp';
    }

    return null;
  }

  /// Builds a memory-optimized Image widget with fallback.
  /// Enforces [cacheWidth] to prevent OOM / RAM bloat.
  static Widget buildThumbnail({
    required String category,
    String? name,
    double width = 56,
    double height = 56,
    int cacheWidth = 200,
    BorderRadius? borderRadius,
    Widget Function(BuildContext)? fallbackBuilder,
  }) {
    final asset = getAssetPath(category, name);
    final radius = borderRadius ?? BorderRadius.circular(10);

    if (asset == null) {
      return fallbackBuilder != null
          ? fallbackBuilder(WidgetsBinding.instance.rootElement!)
          : const SizedBox.shrink();
    }

    return ClipRRect(
      borderRadius: radius,
      child: Image.asset(
        asset,
        width: width,
        height: height,
        fit: BoxFit.contain,
        cacheWidth: cacheWidth,
        errorBuilder: (context, error, stackTrace) {
          if (fallbackBuilder != null) {
            return fallbackBuilder(context);
          }
          return Container(
            width: width,
            height: height,
            color: Colors.white.withValues(alpha: 0.04),
            child: const Icon(Icons.handyman_outlined, size: 24, color: Colors.grey),
          );
        },
      ),
    );
  }
}
