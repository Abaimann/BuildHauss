import '../database/app_database.dart';

/// Klasifikasi teknis model motor untuk memfilter komponen, sistem bahan bakar,
/// kategori usia, dan interval perawatan berdasarkan tipe motor serta tahun terbit.
class MotorcycleSpecs {
  const MotorcycleSpecs._();

  static const _maticKeywords = [
    // Honda Matic
    'vario',
    'beat',
    'pcx',
    'adv',
    'scoopy',
    'genio',
    'spacy',
    'stylo',
    // Yamaha Matic
    'nmax',
    'aerox',
    'xmax',
    'mio',
    'soul',
    'fino',
    'xeon',
    'freego',
    'x-ride',
    'xride',
    'gear 125',
    'gear125',
    'fazzio',
    'filano',
    'lexi',
    // Legacy Suzuki Matic (untuk kompatibilitas database pengguna lama)
    'address',
    'nex',
    'burgman',
  ];

  static const _manualKeywords = [
    // Honda Manual (Bebek, Sport, Trail, Klasik 1990+)
    'astrea',
    'prima',
    'legenda',
    'supra',
    'revo',
    'blade',
    'karisma',
    'cs1',
    'sonic',
    'win 100',
    'win100',
    'gl pro',
    'gl-pro',
    'gl max',
    'gl-max',
    'tiger',
    'megapro',
    'mega pro',
    'verza',
    'cb150',
    'cbr',
    'crf',
    // Yamaha Manual (Bebek, Sport, Trail, 2-Tak 1990+)
    'alfa',
    'force 1',
    'force1',
    'f1zr',
    'f1z',
    'vega',
    'jupiter',
    'mx king',
    'rx-king',
    'rx king',
    'rx-s',
    'rx s',
    'rxs',
    'scorpio',
    'byson',
    'vixion',
    'r15',
    'r25',
    'mt-15',
    'mt15',
    'mt-25',
    'mt25',
    'xsr',
    'wr 155',
    'wr155',
    // Kawasaki Manual (Bebek, Sport, Trail, Retro, 2-Tak 1990+)
    'ninja',
    'zx-25',
    'zx25',
    'kaze',
    'blitz',
    'athlete',
    'edge',
    'klx',
    'd-tracker',
    'dtracker',
    'w175',
    'estrella',
    'w250',
    'versys',
    'z125',
    'z250',
    // Legacy Suzuki Manual (untuk kompatibilitas database pengguna lama)
    'smash',
    'satria',
    'gsx',
  ];

  static const _liquidCooledKeywords = [
    // Honda Liquid-Cooled
    'vario 125',
    'vario 150',
    'vario 160',
    'pcx',
    'adv',
    'stylo',
    'supra gtr',
    'cs1',
    'sonic',
    'cb150r',
    'cb150x',
    'cbr',
    'crf250',
    // Yamaha Liquid-Cooled
    'xeon',
    'lexi',
    'nmax',
    'aerox',
    'xmax',
    'jupiter mx',
    'mx king',
    'vixion',
    'r15',
    'r25',
    'mt-15',
    'mt15',
    'mt-25',
    'mt25',
    'xsr 155',
    'xsr155',
    'wr 155',
    'wr155',
    // Kawasaki Liquid-Cooled
    'ninja 150',
    'ninja 250',
    'zx-25',
    'zx25',
    'versys',
    'z250',
    'klx 250',
    // Legacy Suzuki Liquid-Cooled
    'satria',
    'gsx',
  ];

  static const _twoStrokeKeywords = [
    'rx-king',
    'rx king',
    'rx-s',
    'rx s',
    'rxs',
    'alfa',
    'force 1',
    'force1',
    'f1zr',
    'f1z',
    'ninja 150',
    '2-tak',
    '2 tak',
  ];

  static final _explicitFiPattern = RegExp(
    r'(?:^|[^a-z0-9])(pgm-fi|fi|ymjet|injeksi|injection|esp|blue\s*core|vva|hybrid|connected|w175\s*l)(?:[^a-z0-9]|$)',
  );

  static const _alwaysFiModelKeywords = [
    // Honda
    'vario 125',
    'vario 150',
    'vario 160',
    'pcx',
    'adv',
    'stylo',
    'genio',
    'beat street',
    'supra gtr',
    'sonic',
    'verza',
    'cb150r',
    'cb150x',
    'cbr250rr',
    'crf150',
    // Yamaha
    'nmax',
    'aerox',
    'xmax',
    'lexi',
    'freego',
    'gear 125',
    'gear125',
    'fazzio',
    'filano',
    'x-ride',
    'xride',
    'mio m3',
    'jupiter z1',
    'mx king',
    'vixion',
    'r15',
    'r25',
    'mt-15',
    'mt15',
    'mt-25',
    'mt25',
    'xsr',
    'wr 155',
    'wr155',
    // Kawasaki
    'ninja 250sl',
    'zx-25',
    'zx25',
    'klx 230',
    'estrella',
    'w250',
    'versys',
    'z125',
    'z250',
  ];

  static const _carburetorModelKeywords = [
    'astrea',
    'prima',
    'legenda',
    'win 100',
    'win100',
    'gl pro',
    'gl-pro',
    'gl max',
    'gl-max',
    'tiger',
    'scorpio',
    'mio sporty',
    'mio smile',
    'mio soul',
    'vega r',
    'vega zr',
    'kaze',
    'blitz',
    'athlete',
    'edge',
    'karisma',
    'cs1',
    'supra 100',
    'supra fit',
    'blade 110',
  ];

  /// Mengembalikan `true` hanya untuk 3 merek resmi yang didukung ('honda', 'yamaha', 'kawasaki').
  static bool isAllowedBrand(String brand) {
    final normalized = brand.trim().toLowerCase();
    return normalized == 'honda' ||
        normalized == 'yamaha' ||
        normalized == 'kawasaki';
  }

  /// Mengembalikan `true` untuk motor bermesin 2-Tak (RX-King, RX-S, Alfa, Force 1, F1ZR, Ninja 150).
  static bool is2Stroke(MotorcycleModel? model) {
    if (model == null) return false;
    final text =
        '${model.brand} ${model.model} ${model.variant ?? ''} ${model.generation ?? ''}'
            .toLowerCase();
    return _twoStrokeKeywords.any(text.contains);
  }

  /// Mengembalikan `true` jika model motor menggunakan sistem bahan bakar karburator.
  static bool isCarburetor(MotorcycleModel? model, {int? manufactureYear}) {
    if (model == null) {
      return manufactureYear != null && manufactureYear <= 2010;
    }

    final text =
        '${model.brand} ${model.model} ${model.variant ?? ''} ${model.generation ?? ''}'
            .toLowerCase();

    if (is2Stroke(model)) return true;
    if (text.contains('karbu') || text.contains('carb')) return true;

    final hasExplicitFi =
        _explicitFiPattern.hasMatch(text) ||
        _alwaysFiModelKeywords.any(text.contains) ||
        (text.contains('cbr150r') &&
            (manufactureYear == null || manufactureYear >= 2011));
    if (hasExplicitFi) return false;

    if (_carburetorModelKeywords.any(text.contains)) return true;

    if (text.contains('megapro') || text.contains('mega pro')) return true;
    if (text.contains('klx 150') || text.contains('d-tracker')) return true;
    if (text.contains('w175')) return true;
    if (text.contains('ninja 250') &&
        (manufactureYear == null || manufactureYear <= 2012) &&
        (model.yearEnd == null || model.yearEnd! <= 2012)) {
      return true;
    }

    if (manufactureYear != null && manufactureYear <= 2010) {
      return true;
    }

    return false;
  }

  static String fuelSystemLabel(
    MotorcycleModel? model, {
    int? manufactureYear,
  }) {
    if (model == null && manufactureYear == null) return 'Standar';
    if (is2Stroke(model)) return '2-Tak Karburator';
    if (isCarburetor(model, manufactureYear: manufactureYear)) {
      return 'Karburator';
    }
    return 'Injeksi (FI)';
  }

  static String ageCategoryLabel(int manufactureYear) {
    if (manufactureYear <= 2005) return 'Klasik (>20 th)';
    if (manufactureYear <= 2015) return 'Menengah (11-20 th)';
    return 'Modern';
  }

  /// Mengembalikan faktor pengali interval perawatan (0.78..1.0) berdasarkan usia motor,
  /// karakter mesin (2-tak / karburator), serta sensitivitas komponen kelistrikan/seal.
  static double ageIntervalMultiplier(
    int? manufactureYear, {
    MotorcycleModel? model,
    String? componentName,
  }) {
    double multiplier;
    if (manufactureYear == null || manufactureYear >= 2016) {
      multiplier = 1.0;
    } else if (manufactureYear <= 2004) {
      multiplier = 0.80;
    } else {
      multiplier = 0.90;
    }

    final twoStroke = is2Stroke(model);
    final carb = isCarburetor(model, manufactureYear: manufactureYear);
    final compLower = componentName?.trim().toLowerCase() ?? '';

    final isIgnitionOrExhaust =
        compLower.contains('busi') ||
        compLower.contains('knalpot') ||
        compLower.contains('filter udara') ||
        compLower.contains('oli mesin');
    final isElectricalOrSeal =
        compLower.contains('aki') ||
        compLower.contains('suspensi') ||
        compLower.contains('minyak rem') ||
        compLower.contains('radiator');

    if (twoStroke) {
      if (isIgnitionOrExhaust) {
        multiplier -= 0.05;
      } else {
        multiplier -= 0.03;
      }
    } else if (carb) {
      if (compLower.contains('busi') || compLower.contains('filter udara')) {
        multiplier -= 0.04;
      } else if (compLower.contains('oli mesin')) {
        multiplier -= 0.03;
      } else if (manufactureYear != null && manufactureYear >= 2016) {
        multiplier -= 0.02;
      }
    }

    if (manufactureYear != null && manufactureYear <= 2015 && isElectricalOrSeal) {
      multiplier -= manufactureYear <= 2004 ? 0.03 : 0.02;
    }

    return multiplier.clamp(0.78, 1.0).toDouble();
  }

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
    if (text.contains('vario 110')) {
      if (text.contains('esp') || _explicitFiPattern.hasMatch(text)) {
        return false;
      }
      return true;
    }
    if (_liquidCooledKeywords.any(text.contains)) return true;
    // Model terdaftar lain pada katalog berpendingin udara.
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
