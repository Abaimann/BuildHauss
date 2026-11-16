import '../database/app_database.dart';

/// Klasifikasi teknis model motor untuk memfilter komponen dan rekomendasi
/// secara akurat berdasarkan tipe transmisi (matic vs manual/rantai) serta
/// sistem pendinginan (radiator coolant vs pendingin udara).
class MotorcycleSpecs {
  const MotorcycleSpecs._();

  static const _maticKeywords = [
    'vario',
    'beat',
    'pcx',
    'adv',
    'scoopy',
    'genio',
    'stylo',
    'nmax',
    'aerox',
    'mio',
    'freego',
    'x-ride',
    'fazzio',
    'filano',
    'lexi',
    'address',
    'nex',
    'burgman',
  ];

  static const _manualKeywords = [
    'supra',
    'cbr',
    'revo',
    'sonic',
    'crf',
    'verza',
    'cb150',
    'vixion',
    'r15',
    'r25',
    'mt-15',
    'mt-25',
    'jupiter',
    'mx king',
    'smash',
    'satria',
    'gsx',
    'ninja',
    'w175',
    'z125',
    'klx',
  ];

  static const _liquidCooledKeywords = [
    'vario 160',
    'vario 125',
    'pcx',
    'adv',
    'stylo',
    'cbr',
    'cb150',
    'sonic',
    'nmax',
    'aerox',
    'lexi',
    'mx king',
    'vixion',
    'r15',
    'r25',
    'mt-15',
    'satria',
    'gsx',
    'ninja 250',
    'zx-25',
  ];

  /// Mengembalikan `true` jika model motor menggunakan transmisi otomatis (CVT).
  /// Mengembalikan `null` bila model belum diketahui sehingga filter tidak membuang data.
  static bool? isMaticOrNull(MotorcycleModel? model) {
    if (model == null) return null;
    final text = '${model.brand} ${model.model} ${model.variant ?? ''}'
        .toLowerCase();
    if (_maticKeywords.any(text.contains)) return true;
    if (_manualKeywords.any(text.contains)) return false;
    return null;
  }

  /// Mengembalikan `true` jika model motor memakai pendingin cairan (radiator coolant).
  /// Mengembalikan `null` bila model belum diketahui.
  static bool? isLiquidCooledOrNull(MotorcycleModel? model) {
    if (model == null) return null;
    final text = '${model.brand} ${model.model} ${model.variant ?? ''}'
        .toLowerCase();
    if (_liquidCooledKeywords.any(text.contains)) return true;
    // Model terdaftar lain pada katalog (Beat Street, Supra X, Mio M3, FreeGo,
    // X-Ride, Address 110, Nex II, Smash FI, W175, Z125) berpendingin udara.
    if (_maticKeywords.any(text.contains) || _manualKeywords.any(text.contains)) {
      return false;
    }
    return null;
  }

  /// Menentukan apakah suatu [component] relevan untuk [model] tertentu
  /// berdasarkan kolom `appliesTo`.
  static bool isComponentApplicable(
    MotorcycleModel? model,
    ComponentType component,
  ) {
    final tag = component.appliesTo?.trim().toLowerCase();
    if (tag == null || tag.isEmpty || model == null) {
      return true;
    }

    switch (tag) {
      case 'matic':
      case 'cvt':
        final matic = isMaticOrNull(model);
        return matic == null || matic;
      case 'manual':
      case 'rantai':
        final matic = isMaticOrNull(model);
        return matic == null || !matic;
      case 'liquid_cooled':
      case 'coolant':
        final liquid = isLiquidCooledOrNull(model);
        return liquid == null || liquid;
      default:
        return true;
    }
  }

  static String transmissionLabel(MotorcycleModel? model) {
    final matic = isMaticOrNull(model);
    if (matic == null) return 'Umum';
    return matic ? 'Matic (CVT)' : 'Manual (Rantai)';
  }

  static String coolingLabel(MotorcycleModel? model) {
    final liquid = isLiquidCooledOrNull(model);
    if (liquid == null) return 'Standar';
    return liquid ? 'Pendingin Cairan (Radiator)' : 'Pendingin Udara';
  }
}
