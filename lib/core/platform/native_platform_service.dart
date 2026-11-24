import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Layanan bridge platform native Android untuk membuka peta bengkel terdekat
/// dan memilih foto profil pengguna langsung dari galeri perangkat.
class NativePlatformService {
  const NativePlatformService._();

  @visibleForTesting
  static const MethodChannel channel = MethodChannel(
    'com.buildhaus.buildhaus/platform',
  );

  /// Menyusun query pencarian bengkel / toko sparepart Indonesia yang spesifik
  /// berdasarkan merek sepeda motor dan/atau nama sparepart/komponen.
  static String buildRepairShopQuery({String? brand, String? partName}) {
    final cleanBrand = brand?.trim() ?? '';
    final cleanPart = partName?.trim() ?? '';
    final lowerBrand = cleanBrand.toLowerCase();

    if (cleanPart.isNotEmpty) {
      if (lowerBrand.contains('honda')) {
        return 'bengkel resmi ahass sparepart $cleanPart terdekat';
      }
      if (lowerBrand.contains('yamaha')) {
        return 'bengkel resmi yamaha sparepart $cleanPart terdekat';
      }
      if (lowerBrand.contains('suzuki')) {
        return 'bengkel resmi suzuki motor sparepart $cleanPart terdekat';
      }
      if (lowerBrand.contains('kawasaki')) {
        return 'bengkel kawasaki sparepart $cleanPart terdekat';
      }
      if (cleanBrand.isNotEmpty) {
        return 'bengkel motor $cleanBrand toko sparepart $cleanPart terdekat';
      }
      return 'bengkel motor toko sparepart $cleanPart terdekat';
    }

    if (lowerBrand.contains('honda')) {
      return 'bengkel resmi ahass terdekat';
    }
    if (lowerBrand.contains('yamaha')) {
      return 'bengkel resmi yamaha terdekat';
    }
    if (lowerBrand.contains('suzuki')) {
      return 'bengkel resmi suzuki motor terdekat';
    }
    if (lowerBrand.contains('kawasaki')) {
      return 'bengkel kawasaki sparepart terdekat';
    }
    if (cleanBrand.isNotEmpty) {
      return 'bengkel motor $cleanBrand terdekat';
    }
    return 'bengkel motor toko sparepart terdekat';
  }

  /// Membuka aplikasi Google Maps / peta bawaan menggunakan [query] kustom.
  /// Mengembalikan `false` secara aman pada test atau platform tanpa plugin.
  static Future<bool> openMaps(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return false;
    try {
      final opened = await channel.invokeMethod<bool>('openMaps', {
        'query': trimmed,
      });
      return opened ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  /// Membuka Google Maps untuk mencari bengkel / toko sparepart terdekat
  /// yang sesuai dengan [brand] motor dan/atau [partName].
  static Future<bool> openNearestRepairShop({
    String? brand,
    String? partName,
  }) async {
    final query = buildRepairShopQuery(brand: brand, partName: partName);
    return openMaps(query);
  }

  /// Membuka pemilih gambar native Android, mengecilkan foto maks 512px,
  /// dan mengembalikan path file lokal (atau `null` bila dibatalkan/tidak tersedia).
  static Future<String?> pickProfileImage() async {
    try {
      final path = await channel.invokeMethod<String>('pickProfileImage');
      if (path == null || path.trim().isEmpty) return null;
      return path;
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }
}
