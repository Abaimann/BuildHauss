import '../database/app_database.dart';
import 'motorcycle_specs.dart';

/// Model for an option in self-inspection questions
class InspectionOption {
  final String code;
  final String label;
  final String icon;
  final bool isIssue;
  final String riskLevel; // 'none', 'low', 'medium', 'high'
  final bool isSafetyCritical;
  final String? advice;

  const InspectionOption({
    required this.code,
    required this.label,
    required this.icon,
    this.isIssue = false,
    this.riskLevel = 'none',
    this.isSafetyCritical = false,
    this.advice,
  });
}

/// Model for a structured self-inspection question
class InspectionQuestion {
  final String code;
  final String title;
  final String category;
  final String componentName;
  final String question;
  final List<InspectionOption> options;

  const InspectionQuestion({
    required this.code,
    required this.title,
    required this.category,
    required this.componentName,
    required this.question,
    required this.options,
  });

  /// Evaluates an answer code and returns the selected option
  InspectionOption? getSelectedOption(String? answerCode) {
    if (answerCode == null) return null;
    return options.where((o) => o.code == answerCode).firstOrNull;
  }
}

/// Represents an identified problem/finding from an inspection
class InspectionFinding {
  final String questionCode;
  final String questionTitle;
  final String category;
  final String componentName;
  final String answerLabel;
  final String riskLevel; // 'low', 'medium', 'high'
  final bool isSafetyCritical;
  final String advice;

  const InspectionFinding({
    required this.questionCode,
    required this.questionTitle,
    required this.category,
    required this.componentName,
    required this.answerLabel,
    required this.riskLevel,
    required this.isSafetyCritical,
    required this.advice,
  });
}

/// Comprehensive evaluation result of a self-inspection
class SelfInspectionEvaluation {
  final String riskLevel; // 'low', 'medium', 'high'
  final int totalIssues;
  final bool hasSafetyAlert;
  final List<InspectionFinding> safetyAlerts;
  final List<InspectionFinding> allFindings;
  final Set<String> affectedComponentNames;
  final String summaryTitle;
  final String summaryExplanation;
  final String disclaimer;

  const SelfInspectionEvaluation({
    required this.riskLevel,
    required this.totalIssues,
    required this.hasSafetyAlert,
    required this.safetyAlerts,
    required this.allFindings,
    required this.affectedComponentNames,
    required this.summaryTitle,
    required this.summaryExplanation,
    this.disclaimer =
        'Hasil pemeriksaan mandiri ini merupakan panduan observasi awal pengguna, bukan diagnosis mekanik resmi pabrikan.',
  });
}

/// Deterministic, meaning-based engine for motor self-inspections.
///
/// Features:
/// - Semantic answer evaluation (an answer is evaluated based on its clinical/physical meaning,
///   never simply assuming 'no' is an issue or 'yes' is safe).
/// - Safety alert detection for critical hazards (brake failure, fuel leaks, tyre blowout hazard, steering wobble).
/// - Maps findings directly to affected components for HealthEngine integration.
class SelfInspectionEngine {
  static const List<InspectionQuestion> questions = [
    InspectionQuestion(
      code: 'rem_respons',
      title: 'Daya & Respons Rem',
      category: 'pengereman',
      componentName: 'Kampas rem',
      question: 'Bagaimana respons dan daya cengkeram rem motor Anda?',
      options: [
        InspectionOption(
          code: 'normal',
          label: 'Pakem dan merespons normal',
          icon: '✅',
          isIssue: false,
          riskLevel: 'none',
        ),
        InspectionOption(
          code: 'lemah',
          label: 'Kurang pakem / tuas harus ditarik dalam',
          icon: '⚠️',
          isIssue: true,
          riskLevel: 'high',
          isSafetyCritical: true,
          advice:
              'Daya rem melemah. Segera periksa ketebalan kampas rem dan volume minyak rem sebelum berkendara.',
        ),
        InspectionOption(
          code: 'blong',
          label: 'Rem terasa blong atau tidak menggigit sama sekali',
          icon: '🚨',
          isIssue: true,
          riskLevel: 'high',
          isSafetyCritical: true,
          advice:
              'BAHAYA KESELAMATAN! Rem tidak berfungsi dengan baik. JANGAN kendarai motor ini sampai diperiksa oleh mekanik.',
        ),
        InspectionOption(
          code: 'unknown',
          label: 'Tidak yakin / belum dicoba',
          icon: '❓',
          isIssue: false,
          riskLevel: 'low',
          advice:
              'Lakukan pengetesan rem pada kecepatan rendah di tempat aman.',
        ),
      ],
    ),
    InspectionQuestion(
      code: 'rem_bunyi',
      title: 'Suara Pengereman',
      category: 'pengereman',
      componentName: 'Kampas rem',
      question:
          'Apakah rem mengeluarkan suara berdecit keras atau gesekan logam saat ditekan?',
      options: [
        InspectionOption(
          code: 'hening',
          label: 'Tidak, rem hening dan bekerja mulus',
          icon: '✅',
          isIssue: false,
          riskLevel: 'none',
        ),
        InspectionOption(
          code: 'gesekan_ringan',
          label: 'Kadang berdecit saat basah / berdebu',
          icon: '⚠️',
          isIssue: true,
          riskLevel: 'medium',
          isSafetyCritical: false,
          advice:
              'Suara berdecit bisa karena kotoran atau kampas mulai tipis. Bersihkan dan periksa kondisi kampas.',
        ),
        InspectionOption(
          code: 'gesekan_logam',
          label: 'Ya, bunyi gesekan logam yang mengikis keras',
          icon: '🚨',
          isIssue: true,
          riskLevel: 'high',
          isSafetyCritical: true,
          advice:
              'Kampas rem kemungkinan telah habis dan mengikis piringan cakram secara langsung. Ganti segera.',
        ),
      ],
    ),
    InspectionQuestion(
      code: 'kebocoran_cairan',
      title: 'Kebocoran Bahan Bakar & Cairan',
      category: 'mesin',
      componentName: 'Oli mesin',
      question:
          'Apakah ada tetesan cairan di bawah motor atau bau bahan bakar yang menyengat?',
      options: [
        InspectionOption(
          code: 'bersih',
          label: 'Bersih, tidak ada tetesan atau bau bensin',
          icon: '✅',
          isIssue: false,
          riskLevel: 'none',
        ),
        InspectionOption(
          code: 'rembesan_oli',
          label: 'Ada rembesan atau tetesan oli di blok mesin/knalpot',
          icon: '⚠️',
          isIssue: true,
          riskLevel: 'medium',
          isSafetyCritical: false,
          advice:
              'Terdapat kebocoran oli. Periksa ring baut pembuangan oli dan paking mesin sebelum volume oli berkurang drastis.',
        ),
        InspectionOption(
          code: 'bocor_bensin',
          label: 'Bau bensin menyengat atau ada tetesan bahan bakar',
          icon: '🚨',
          isIssue: true,
          riskLevel: 'high',
          isSafetyCritical: true,
          advice:
              'BAHAYA KEBAKARAN! Ditemukan kebocoran bahan bakar. JANGAN nyalakan mesin atau sumber api di dekat motor.',
        ),
      ],
    ),
    InspectionQuestion(
      code: 'ban_kondisi',
      title: 'Kondisi Fisik Ban',
      category: 'roda',
      componentName: 'Ban',
      question: 'Bagaimana kondisi fisik dan ketebalan tapak ban?',
      options: [
        InspectionOption(
          code: 'bagus',
          label: 'Alur tapak masih tebal dan tidak ada retak',
          icon: '✅',
          isIssue: false,
          riskLevel: 'none',
        ),
        InspectionOption(
          code: 'menipis',
          label: 'Alur mulai menipis mendekati tonjolan TWI',
          icon: '⚠️',
          isIssue: true,
          riskLevel: 'medium',
          isSafetyCritical: false,
          advice:
              'Tapak ban mulai menipis. Daya cengkeram berkurang saat hujan; rencanakan penggantian ban.',
        ),
        InspectionOption(
          code: 'botak_benjol',
          label: 'Ban botak licin, benjol, atau terdapat retak parah',
          icon: '🚨',
          isIssue: true,
          riskLevel: 'high',
          isSafetyCritical: true,
          advice:
              'BAHAYA PECAH BAN & TERGELINCIR! Ban dalam kondisi berbahaya. Segera ganti sebelum digunakan berkendara.',
        ),
      ],
    ),
    InspectionQuestion(
      code: 'kemudi_stang',
      title: 'Kestabilan Stang Kemudi',
      category: 'kemudi',
      componentName: 'Ban',
      question:
          'Apakah stang kemudi terasa goyang, berat, atau menarik ke satu sisi saat jalan lurus?',
      options: [
        InspectionOption(
          code: 'lurus_stabil',
          label: 'Stang stabil, lurus, dan ringan',
          icon: '✅',
          isIssue: false,
          riskLevel: 'none',
        ),
        InspectionOption(
          code: 'agak_berat',
          label: 'Stang terasa agak berat (mungkin kurang angin)',
          icon: '⚠️',
          isIssue: true,
          riskLevel: 'low',
          isSafetyCritical: false,
          advice:
              'Periksa tekanan angin ban depan dan belakang sesuai rekomendasi.',
        ),
        InspectionOption(
          code: 'goyang_narik',
          label: 'Stang goyang kencang atau menarik ke satu sisi',
          icon: '🚨',
          isIssue: true,
          riskLevel: 'high',
          isSafetyCritical: true,
          advice:
              'Gangguan pengendalian! Komstir kemudi, velg bengkok, atau shockbreaker tidak seimbang mengancam stabilitas.',
        ),
      ],
    ),
    InspectionQuestion(
      code: 'kelistrikan_lampu',
      title: 'Lampu Utama & Rem',
      category: 'kelistrikan',
      componentName: 'Aki',
      question:
          'Apakah lampu utama depan dan lampu rem belakang menyala terang dan normal?',
      options: [
        InspectionOption(
          code: 'menyala_terang',
          label: 'Ya, semua lampu menyala terang dan normal',
          icon: '✅',
          isIssue: false,
          riskLevel: 'none',
        ),
        InspectionOption(
          code: 'redup',
          label: 'Lampu redup / klakson terdengar lemah',
          icon: '⚠️',
          isIssue: true,
          riskLevel: 'medium',
          isSafetyCritical: false,
          advice:
              'Aki atau sistem pengisian (spul/kiprok) melemah. Periksa voltase aki motor.',
        ),
        InspectionOption(
          code: 'mati',
          label: 'Lampu utama atau lampu rem mati total',
          icon: '🚨',
          isIssue: true,
          riskLevel: 'high',
          isSafetyCritical: true,
          advice:
              'Lampu mati sangat berbahaya bagi keselamatan berkendara di malam hari. Ganti bohlam/cek sekring segera.',
        ),
      ],
    ),
    InspectionQuestion(
      code: 'mesin_suara',
      title: 'Suara & Getaran Mesin',
      category: 'mesin',
      componentName: 'Oli mesin',
      question:
          'Apakah terdengar suara kasar yang tidak biasa dari bagian mesin saat stasioner?',
      options: [
        InspectionOption(
          code: 'halus',
          label: 'Suara mesin normal dan halus',
          icon: '✅',
          isIssue: false,
          riskLevel: 'none',
        ),
        InspectionOption(
          code: 'kasar_klotok',
          label: 'Terdengar suara klotok-klotok atau gesekan kasar',
          icon: '⚠️',
          isIssue: true,
          riskLevel: 'high',
          isSafetyCritical: false,
          advice:
              'Suara kasar pada mesin mengindikasikan volume oli kurang, rantai keteng kendor, atau celah klep renggang.',
        ),
        InspectionOption(
          code: 'getaran_parah',
          label: 'Mesin bergetar sangat kuat dan sulit stasioner',
          icon: '⚠️',
          isIssue: true,
          riskLevel: 'medium',
          isSafetyCritical: false,
          advice:
              'Periksa busi, karet mounting mesin, dan setelan idle karburator/injeksi.',
        ),
      ],
    ),
    InspectionQuestion(
      code: 'cvt_transmisi',
      title: 'Akselerasi & CVT/Rantai',
      category: 'transmisi',
      componentName: 'CVT',
      question:
          'Bagaimana tarikan motor saat memutar tuas gas untuk akselerasi awal?',
      options: [
        InspectionOption(
          code: 'mulus',
          label: 'Responsif, halus tanpa getaran abnormal',
          icon: '✅',
          isIssue: false,
          riskLevel: 'none',
        ),
        InspectionOption(
          code: 'gredek',
          label: 'Gredek / bergetar berlebihan pada kecepatan rendah',
          icon: '⚠️',
          isIssue: true,
          riskLevel: 'low',
          isSafetyCritical: false,
          advice:
              'Penyebab umum gredek adalah mangkok ganda CVT kotor atau roller aus. Jadwalkan servis pembersihan CVT.',
        ),
        InspectionOption(
          code: 'selip_meraung',
          label: 'Mesin meraung kencang tapi motor lambat berjalan (selip)',
          icon: '⚠️',
          isIssue: true,
          riskLevel: 'medium',
          isSafetyCritical: false,
          advice:
              'V-belt atau kampas kopling CVT mengalami selip. Periksakan sebelum v-belt putus di jalan.',
        ),
      ],
    ),
  ];

  // ===========================================================================
  // PERTANYAAN DINAMIS SESUAI SPESIFIKASI & TAHUN MOTOR
  // ===========================================================================

  static bool _isSportDoubleDisc(MotorcycleModel? model) {
    if (model == null) return false;
    final text = '${model.brand} ${model.model} ${model.variant ?? ''}'
        .toLowerCase();
    return text.contains('cbr') ||
        text.contains('cb150') ||
        text.contains('r15') ||
        text.contains('r25') ||
        text.contains('mt-15') ||
        text.contains('mt-25') ||
        text.contains('ninja') ||
        text.contains('zx-25') ||
        text.contains('gsx') ||
        text.contains('vixion') ||
        text.contains('sonic') ||
        text.contains('satria');
  }

  static InspectionQuestion _brakeQuestionFor({
    required bool? isMatic,
    required bool isSportDoubleDisc,
  }) {
    final String questionText;
    if (isSportDoubleDisc) {
      questionText =
          'Bagaimana respons rem cakram depan & belakang (double disc) motor sport Anda saat pengereman?';
    } else if (isMatic == true) {
      questionText =
          'Bagaimana respons rem cakram depan dan rem belakang (tromol/cakram) motor matic Anda?';
    } else if (isMatic == false) {
      questionText =
          'Bagaimana respons rem cakram depan dan rem tromol/cakram belakang motor manual Anda?';
    } else {
      questionText =
          'Bagaimana respons dan daya cengkeram rem cakram/tromol motor Anda?';
    }

    return InspectionQuestion(
      code: 'dyn_rem_respons',
      title: 'Daya & Respons Rem',
      category: 'pengereman',
      componentName: 'Kampas rem',
      question: questionText,
      options: const [
        InspectionOption(
          code: 'pakem',
          label: 'Pakem, halus, dan tuas rem merespons mantap',
          icon: '✅',
          isIssue: false,
          riskLevel: 'none',
        ),
        InspectionOption(
          code: 'agak_dalam',
          label: 'Agak dalam / perlu tarikan tuas atau injakan pedal lebih dalam',
          icon: '⚠️',
          isIssue: true,
          riskLevel: 'high',
          isSafetyCritical: true,
          advice:
              'Daya rem melemah. Segera cek ketebalan kampas rem, setelan tromol, dan ketinggian minyak rem.',
        ),
        InspectionOption(
          code: 'bunyi_macet',
          label: 'Berdecit keras atau piston kaliper terasa seret/macet',
          icon: '⚠️',
          isIssue: true,
          riskLevel: 'medium',
          isSafetyCritical: false,
          advice:
              'Kampas rem mulai menipis atau kaliper kotor. Bersihkan debu rem dan periksa ketebalan kampas/cakram.',
        ),
        InspectionOption(
          code: 'blong',
          label: 'Rem blong, ngelos, atau tidak menggigit sama sekali',
          icon: '🚨',
          isIssue: true,
          riskLevel: 'high',
          isSafetyCritical: true,
          advice:
              'BAHAYA KESELAMATAN! Rem tidak berfungsi dengan baik. JANGAN kendarai motor ini sebelum ditangani mekanik.',
        ),
      ],
    );
  }

  static const InspectionQuestion _oilQuestion2Stroke = InspectionQuestion(
    code: 'dyn_oli_2tak',
    title: 'Oli Samping & Kebocoran Mesin (2-Tak)',
    category: 'mesin',
    componentName: 'Oli mesin',
    question:
        'Bagaimana kecukupan oli samping (2T), kondisi rembesan blok mesin, dan apakah ada bau bensin?',
    options: [
      InspectionOption(
        code: 'normal',
        label: 'Oli samping cukup, blok mesin kering, dan bebas bau bensin',
        icon: '✅',
        isIssue: false,
        riskLevel: 'none',
      ),
      InspectionOption(
        code: 'oli_samping_kurang',
        label: 'Oli samping menipis atau pasokan pompa oli samping terasa kering',
        icon: '🚨',
        isIssue: true,
        riskLevel: 'high',
        isSafetyCritical: true,
        advice:
            'BAHAYA MESIN MACET! Motor 2-Tak wajib memiliki pasokan oli samping cukup sebelum dikendarai agar piston tidak macet.',
      ),
      InspectionOption(
        code: 'rembes_blok',
        label: 'Ada rembesan oli transmisi/blok mesin atau seal kruk as basah',
        icon: '⚠️',
        isIssue: true,
        riskLevel: 'medium',
        isSafetyCritical: false,
        advice:
            'Periksa oli gearbox 2-Tak serta kondisi paking dan seal kruk as agar pelumasan tetap aman.',
      ),
      InspectionOption(
        code: 'bocor_bensin',
        label: 'Bau bensin menyengat atau karburator banjir meneteskan bensin',
        icon: '🚨',
        isIssue: true,
        riskLevel: 'high',
        isSafetyCritical: true,
        advice:
            'BAHAYA KEBAKARAN! Ditemukan kebocoran bahan bakar. JANGAN nyalakan mesin atau dekatkan sumber api.',
      ),
    ],
  );

  static const InspectionQuestion _oilQuestion4Stroke = InspectionQuestion(
    code: 'dyn_oli_4tak',
    title: 'Kebocoran Cairan & Kondisi Oli',
    category: 'mesin',
    componentName: 'Oli mesin',
    question:
        'Bagaimana kondisi warna & volume oli di dipstick/kaca intip, serta apakah ada rembesan cairan atau bau bensin?',
    options: [
      InspectionOption(
        code: 'normal',
        label: 'Volume oli pas di batas dipstick, warna wajar, dan blok bersih',
        icon: '✅',
        isIssue: false,
        riskLevel: 'none',
      ),
      InspectionOption(
        code: 'oli_kotor_susut',
        label: 'Oli hitam pekat, encer, atau volume berkurang di bawah batas',
        icon: '⚠️',
        isIssue: true,
        riskLevel: 'medium',
        isSafetyCritical: false,
        advice:
            'Oli sudah jenuh atau menyusut. Jadwalkan ganti oli mesin dan cek apakah ada penguapan berlebih.',
      ),
      InspectionOption(
        code: 'rembes_bau_bensin',
        label: 'Ada rembesan oli di blok/baut tap atau oli berbau bensin',
        icon: '⚠️',
        isIssue: true,
        riskLevel: 'high',
        isSafetyCritical: false,
        advice:
            'Periksa paking mesin, ring baut pembuangan oli, atau indikasi kebocoran bensin masuk ke ruang oli.',
      ),
      InspectionOption(
        code: 'bocor_bensin',
        label: 'Bau bensin menyengat atau ada tetesan bahan bakar di bawah motor',
        icon: '🚨',
        isIssue: true,
        riskLevel: 'high',
        isSafetyCritical: true,
        advice:
            'BAHAYA KEBAKARAN! Ditemukan kebocoran bahan bakar. JANGAN nyalakan mesin atau sumber api di dekat motor.',
      ),
    ],
  );

  static const InspectionQuestion _coolingLiquidQuestion = InspectionQuestion(
    code: 'dyn_pendingin_radiator',
    title: 'Pendinginan Radiator Coolant',
    category: 'pendingin',
    componentName: 'Radiator coolant',
    question:
        'Bagaimana level coolant di tabung reservoir radiator, kondisi kisi radiator, dan kerja kipas saat mesin panas?',
    options: [
      InspectionOption(
        code: 'normal',
        label: 'Level coolant di antara LOWER–UPPER dan suhu mesin stabil',
        icon: '✅',
        isIssue: false,
        riskLevel: 'none',
      ),
      InspectionOption(
        code: 'coolant_kurang',
        label: 'Air reservoir mendekati/di bawah LOWER atau terlihat keruh',
        icon: '⚠️',
        isIssue: true,
        riskLevel: 'medium',
        isSafetyCritical: false,
        advice:
            'Tambahkan atau kuras radiator coolant dengan cairan khusus radiator (hindari air keran biasa).',
      ),
      InspectionOption(
        code: 'overheat',
        label: 'Indikator suhu/overheat menyala, kipas mati, atau radiator bocor',
        icon: '🚨',
        isIssue: true,
        riskLevel: 'high',
        isSafetyCritical: true,
        advice:
            'Mesin berisiko overheat parah! Segera matikan mesin, tunggu dingin, dan periksa kebocoran selang/water pump/kipas.',
      ),
    ],
  );

  static const InspectionQuestion _coolingAirQuestion = InspectionQuestion(
    code: 'dyn_pendingin_udara',
    title: 'Sirip Pendingin & Suhu Mesin',
    category: 'mesin',
    componentName: 'Oli mesin',
    question:
        'Apakah sirip pendingin blok mesin bersih dan suhu mesin tetap wajar (tidak cepat panas berlebih)?',
    options: [
      InspectionOption(
        code: 'normal',
        label: 'Sirip pendingin bersih dan panas mesin masih wajar',
        icon: '✅',
        isIssue: false,
        riskLevel: 'none',
      ),
      InspectionOption(
        code: 'sirip_kotor',
        label: 'Sirip pendingin kotor lumpur/oli sehingga mesin terasa lebih panas',
        icon: '⚠️',
        isIssue: true,
        riskLevel: 'low',
        isSafetyCritical: false,
        advice:
            'Bersihkan kerak lumpur pada sirip silinder agar pelepasan panas mesin berpendingin udara tetap optimal.',
      ),
      InspectionOption(
        code: 'mesin_overheat',
        label: 'Mesin cepat overheat, bau gosong, atau tenaga mendadak drop',
        icon: '⚠️',
        isIssue: true,
        riskLevel: 'high',
        isSafetyCritical: false,
        advice:
            'Panas berlebih pada motor pendingin udara sering dipicu oli kurang/rusak atau setelan BBM terlalu irit. Segera cek oli.',
      ),
    ],
  );

  static const InspectionQuestion _transmissionCvtQuestion = InspectionQuestion(
    code: 'dyn_transmisi_cvt',
    title: 'Transmisi Matic (CVT)',
    category: 'transmisi',
    componentName: 'CVT',
    question:
        'Bagaimana performa CVT saat akselerasi awal (apakah ada gredek rpm rendah, selip, atau suara kasar roller & v-belt)?',
    options: [
      InspectionOption(
        code: 'mulus',
        label: 'Akselerasi halus, responsif tanpa gredek atau selip',
        icon: '✅',
        isIssue: false,
        riskLevel: 'none',
      ),
      InspectionOption(
        code: 'gredek',
        label: 'Gredek / bergetar saat rpm rendah dari posisi diam',
        icon: '⚠️',
        isIssue: true,
        riskLevel: 'medium',
        isSafetyCritical: false,
        advice:
            'Kampas ganda dan mangkok kopling CVT kemungkinan kotor atau aus. Jadwalkan servis pembersihan CVT.',
      ),
      InspectionOption(
        code: 'selip_kasar',
        label: 'Tarikan selip (mesin meraung) atau terdengar bunyi kasar roller/v-belt',
        icon: '⚠️',
        isIssue: true,
        riskLevel: 'high',
        isSafetyCritical: false,
        advice:
            'V-belt atau roller CVT berisiko aus berat. Segera periksa sebelum v-belt putus saat berkendara.',
      ),
    ],
  );

  static const InspectionQuestion _transmissionManualQuestion =
      InspectionQuestion(
        code: 'dyn_transmisi_manual',
        title: 'Rantai, Gir & Kopling',
        category: 'transmisi',
        componentName: 'Rantai & gir',
        question:
            'Bagaimana ketegangan rantai penggerak, kondisi mata gir, dan gigitan kopling saat perpindahan gigi?',
        options: [
          InspectionOption(
            code: 'normal',
            label: 'Rantai kencang pas, mata gir utuh, dan kopling tidak selip',
            icon: '✅',
            isIssue: false,
            riskLevel: 'none',
          ),
          InspectionOption(
            code: 'rantai_kendur',
            label: 'Rantai kendur/berisik atau mata gir mulai runcing tajam',
            icon: '⚠️',
            isIssue: true,
            riskLevel: 'medium',
            isSafetyCritical: false,
            advice:
                'Lumasi dan setel kekencangan rantai; jika mata gir sudah tajam atau rantai tidak rata, ganti satu set rantai & gir.',
          ),
          InspectionOption(
            code: 'selip_kopling',
            label: 'Rantai sangat kendur/macet atau kopling terasa selip saat digas',
            icon: '🚨',
            isIssue: true,
            riskLevel: 'high',
            isSafetyCritical: true,
            advice:
                'Rantai terlalu kendur berisiko lepas/mengunci roda belakang! Segera setel atau ganti rantai & cek kampas kopling.',
          ),
        ],
      );

  static const InspectionQuestion _transmissionUnknownQuestion =
      InspectionQuestion(
        code: 'dyn_transmisi_umum',
        title: 'Transmisi & Akselerasi',
        category: 'transmisi',
        componentName: 'CVT',
        question:
            'Bagaimana kelancaran penyaluran tenaga transmisi saat motor berakselerasi?',
        options: [
          InspectionOption(
            code: 'normal',
            label: 'Penyaluran tenaga halus, responsif, dan tanpa bunyi aneh',
            icon: '✅',
            isIssue: false,
            riskLevel: 'none',
          ),
          InspectionOption(
            code: 'getar_kendur',
            label: 'Ada getaran ringan di putaran rendah atau bunyi berisik transmisi',
            icon: '⚠️',
            isIssue: true,
            riskLevel: 'medium',
            isSafetyCritical: false,
            advice:
                'Periksa komponen penyalur tenaga (CVT/rantai & gir) dan lakukan pembersihan serta pelumasan berkala.',
          ),
          InspectionOption(
            code: 'selip',
            label: 'Mesin meraung namun laju motor terasa selip / tersendat',
            icon: '⚠️',
            isIssue: true,
            riskLevel: 'high',
            isSafetyCritical: false,
            advice:
                'Indikasi keausan kampas kopling, V-belt, atau rantai & gir. Segera periksakan ke bengkel.',
          ),
        ],
      );

  static const InspectionQuestion _fuelIgnition2StrokeQuestion =
      InspectionQuestion(
        code: 'dyn_bbm_2tak',
        title: 'Pengapian & Pembakaran 2-Tak',
        category: 'mesin',
        componentName: 'Busi',
        question:
            'Bagaimana kondisi asap knalpot, pembakaran busi, dan kelancaran langsam mesin 2-Tak Anda?',
        options: [
          InspectionOption(
            code: 'normal',
            label: 'Asap tipis wajar, mesin mudah hidup, dan tarikan spontan',
            icon: '✅',
            isIssue: false,
            riskLevel: 'none',
          ),
          InspectionOption(
            code: 'asap_tebal',
            label: 'Asap putih terlalu tebal atau tarikan terasa berat/ngempos',
            icon: '⚠️',
            isIssue: true,
            riskLevel: 'medium',
            isSafetyCritical: false,
            advice:
                'Periksa setelan pompa oli samping, spuyer karburator, dan bersihkan kerak knalpot/filter udara.',
          ),
          InspectionOption(
            code: 'busi_basah',
            label: 'Busi cepat basah oli/berkerak sehingga brebet atau sering mati',
            icon: '⚠️',
            isIssue: true,
            riskLevel: 'high',
            isSafetyCritical: false,
            advice:
                'Busi basah menandakan campuran oli/bensin terlalu kaya atau pengapian lemah. Cek busi dan setelan karburator.',
          ),
        ],
      );

  static const InspectionQuestion _fuelIgnitionCarbQuestion =
      InspectionQuestion(
        code: 'dyn_bbm_karbu',
        title: 'Suplai Karburator & Filter Udara',
        category: 'mesin',
        componentName: 'Filter udara',
        question:
            'Bagaimana kondisi langsam mesin saat dingin, filter udara, dan respons gas pada karburator?',
        options: [
          InspectionOption(
            code: 'normal',
            label: 'Langsam stabil, mudah starter pagi hari, dan tarikan lancar',
            icon: '✅',
            isIssue: false,
            riskLevel: 'none',
          ),
          InspectionOption(
            code: 'filter_kotor',
            label: 'Filter udara kotor/tersumbat atau konsumsi bensin terasa boros',
            icon: '⚠️',
            isIssue: true,
            riskLevel: 'medium',
            isSafetyCritical: false,
            advice:
                'Bersihkan atau ganti filter udara serta cek warna busi untuk memastikan campuran udara-bensin ideal.',
          ),
          InspectionOption(
            code: 'brebet_susah_starter',
            label: 'Mesin brebet, langsam mati-mati, atau susah hidup saat dingin',
            icon: '⚠️',
            isIssue: true,
            riskLevel: 'high',
            isSafetyCritical: false,
            advice:
                'Karburator kemungkinan kotor pada pilot/main jet atau celah busi tidak tepat. Jadwalkan servis karburator & cek busi.',
          ),
        ],
      );

  static const InspectionQuestion _fuelIgnitionFiQuestion = InspectionQuestion(
    code: 'dyn_bbm_fi',
    title: 'Sistem Injeksi (FI) & Filter Udara',
    category: 'mesin',
    componentName: 'Filter udara',
    question:
        'Apakah tarikan mesin injeksi lancar, filter udara bersih, dan indikator MIL (Check Engine) mati normal?',
    options: [
      InspectionOption(
        code: 'normal',
        label: 'Tarikan halus, irit, dan indikator MIL mati saat mesin hidup',
        icon: '✅',
        isIssue: false,
        riskLevel: 'none',
      ),
      InspectionOption(
        code: 'tersendat_filter',
        label: 'Tarikan agak tersendat/ngempos atau filter udara kotor',
        icon: '⚠️',
        isIssue: true,
        riskLevel: 'medium',
        isSafetyCritical: false,
        advice:
            'Periksa dan ganti filter udara (tipe basah tidak boleh disemprot angin bertekanan) serta cek kebersihan throttle body.',
      ),
      InspectionOption(
        code: 'mil_berkedip',
        label: 'Indikator MIL berkedip/menyala atau mesin brebet parah saat digas',
        icon: '⚠️',
        isIssue: true,
        riskLevel: 'high',
        isSafetyCritical: false,
        advice:
            'Kedipan indikator MIL menandakan kode error sensor injeksi/ECU atau tekanan fuel pump melemah. Segera scan FI di bengkel.',
      ),
    ],
  );

  static InspectionQuestion _tireQuestionFor({required int? manufactureYear}) {
    final isOlder =
        manufactureYear != null && (DateTime.now().year - manufactureYear) >= 10;
    final questionText = isOlder
        ? 'Bagaimana ketebalan alur TWI ban, tekanan angin, dan apakah ada retak samping akibat umur karet pada motor tahun $manufactureYear?'
        : 'Bagaimana ketebalan alur TWI tapak ban, tekanan angin, dan kondisi dinding samping ban?';

    return InspectionQuestion(
      code: 'dyn_ban_tekanan',
      title: 'Ban & Tekanan Angin',
      category: 'roda',
      componentName: 'Ban',
      question: questionText,
      options: const [
        InspectionOption(
          code: 'normal',
          label: 'Alur tapak tebal, tekanan angin pas, dan bebas retak/benjol',
          icon: '✅',
          isIssue: false,
          riskLevel: 'none',
        ),
        InspectionOption(
          code: 'menipis_kurang_angin',
          label: 'Alur mendekati tanda TWI atau tekanan angin sering turun',
          icon: '⚠️',
          isIssue: true,
          riskLevel: 'medium',
          isSafetyCritical: false,
          advice:
              'Periksa tekanan angin sesuai standar pabrikan, cek pentil/kebocoran halus, dan rencanakan ganti ban.',
        ),
        InspectionOption(
          code: 'botak_retak',
          label: 'Ban botak licin, benjol, atau dinding samping retak parah',
          icon: '🚨',
          isIssue: true,
          riskLevel: 'high',
          isSafetyCritical: true,
          advice:
              'BAHAYA PECAH BAN & TERGELINCIR! Ban sudah tidak layak pakai. Segera ganti sebelum digunakan berkendara.',
        ),
      ],
    );
  }

  static const InspectionQuestion _suspensionQuestion = InspectionQuestion(
    code: 'dyn_suspensi_kemudi',
    title: 'Suspensi & Kemudi',
    category: 'suspensi',
    componentName: 'Suspensi',
    question:
        'Bagaimana redaman/rebound sokbreker depan-belakang, kebersihan as shock dari rembesan oli, dan kestabilan komstir?',
    options: [
      InspectionOption(
        code: 'normal',
        label: 'Suspensi nyaman, as shock kering, dan komstir stang stabil',
        icon: '✅',
        isIssue: false,
        riskLevel: 'none',
      ),
      InspectionOption(
        code: 'rembes_jedug',
        label: 'Sokbreker keras/jedug atau ada rembesan oli pada seal as shock',
        icon: '⚠️',
        isIssue: true,
        riskLevel: 'medium',
        isSafetyCritical: false,
        advice:
            'Seal shock bocor atau oli shock berkurang memengaruhi kestabilan pengereman. Jadwalkan servis/ganti seal sokbreker.',
      ),
      InspectionOption(
        code: 'komstir_goyang',
        label: 'Komstir oblak/goyang, stang menarik ke satu sisi, atau shock bocor parah',
        icon: '🚨',
        isIssue: true,
        riskLevel: 'high',
        isSafetyCritical: true,
        advice:
            'GANGGUAN PENGENDALIAN! Komstir oblak atau suspensi tidak seimbang membahayakan manuver. Segera periksa di bengkel.',
      ),
    ],
  );

  static InspectionQuestion _electricalQuestionFor({
    required int? manufactureYear,
  }) {
    final isPre2010 = manufactureYear != null && manufactureYear < 2010;
    final questionText = isPre2010
        ? 'Bagaimana respon electric starter pagi hari, nyala klakson, serta terangnya lampu utama/rem pada motor lawas ($manufactureYear) Anda?'
        : 'Bagaimana respon electric starter pagi hari, suara klakson, dan terangnya lampu utama serta lampu rem?';

    return InspectionQuestion(
      code: 'dyn_kelistrikan_aki',
      title: 'Kelistrikan, Aki & Lampu',
      category: 'kelistrikan',
      componentName: 'Aki',
      question: questionText,
      options: const [
        InspectionOption(
          code: 'normal',
          label: 'Electric starter lancar, klakson lantang, dan semua lampu terang',
          icon: '✅',
          isIssue: false,
          riskLevel: 'none',
        ),
        InspectionOption(
          code: 'lemah_redup',
          label: 'Starter berat di pagi hari, klakson lemah, atau lampu redup',
          icon: '⚠️',
          isIssue: true,
          riskLevel: 'medium',
          isSafetyCritical: false,
          advice:
              'Tegangan aki atau sistem pengisian (kiprok/spul) melemah. Periksa voltase aki dan kabel massa/soket.',
        ),
        InspectionOption(
          code: 'mati_total',
          label: 'Starter tidak menyala sama sekali atau lampu utama/rem mati total',
          icon: '🚨',
          isIssue: true,
          riskLevel: 'high',
          isSafetyCritical: true,
          advice:
              'Lampu utama/rem mati atau kelistrikan drop sangat berisiko saat berkendara. Cek aki, sekring, dan bohlam segera.',
        ),
      ],
    );
  }

  /// Menghasilkan 8 pertanyaan pemeriksaan mandiri yang tepat & spesifik
  /// sesuai model motor (matic/manual, liquid/air-cooled, 2-tak/4-tak,
  /// karburator/injeksi) dan tahun pembuatannya.
  static List<InspectionQuestion> questionsForMotorcycle(
    MotorcycleModel? model, {
    int? manufactureYear,
  }) {
    final matic = MotorcycleSpecs.isMaticOrNull(model);
    final liquidCooled = MotorcycleSpecs.isLiquidCooledOrNull(model);
    final is2T = MotorcycleSpecs.is2Stroke(model);
    final isCarb = MotorcycleSpecs.isCarburetor(
      model,
      manufactureYear: manufactureYear,
    );
    final resolvedYear = manufactureYear ?? model?.yearStart;

    return [
      _brakeQuestionFor(
        isMatic: matic,
        isSportDoubleDisc: _isSportDoubleDisc(model),
      ),
      is2T ? _oilQuestion2Stroke : _oilQuestion4Stroke,
      liquidCooled == true ? _coolingLiquidQuestion : _coolingAirQuestion,
      if (matic == true)
        _transmissionCvtQuestion
      else if (matic == false)
        _transmissionManualQuestion
      else
        _transmissionUnknownQuestion,
      if (is2T)
        _fuelIgnition2StrokeQuestion
      else if (isCarb)
        _fuelIgnitionCarbQuestion
      else
        _fuelIgnitionFiQuestion,
      _tireQuestionFor(manufactureYear: resolvedYear),
      _suspensionQuestion,
      _electricalQuestionFor(manufactureYear: resolvedYear),
    ];
  }

  static List<InspectionQuestion> _allCatalogQuestions({
    MotorcycleModel? model,
    int? manufactureYear,
  }) {
    final byCode = <String, InspectionQuestion>{};
    for (final q in [
      if (model != null || manufactureYear != null)
        ...questionsForMotorcycle(model, manufactureYear: manufactureYear),
      _brakeQuestionFor(isMatic: true, isSportDoubleDisc: false),
      _brakeQuestionFor(isMatic: false, isSportDoubleDisc: false),
      _brakeQuestionFor(isMatic: false, isSportDoubleDisc: true),
      _brakeQuestionFor(isMatic: null, isSportDoubleDisc: false),
      _oilQuestion2Stroke,
      _oilQuestion4Stroke,
      _coolingLiquidQuestion,
      _coolingAirQuestion,
      _transmissionCvtQuestion,
      _transmissionManualQuestion,
      _transmissionUnknownQuestion,
      _fuelIgnition2StrokeQuestion,
      _fuelIgnitionCarbQuestion,
      _fuelIgnitionFiQuestion,
      _tireQuestionFor(manufactureYear: manufactureYear),
      _suspensionQuestion,
      _electricalQuestionFor(manufactureYear: manufactureYear),
      ...questions,
    ]) {
      byCode.putIfAbsent(q.code, () => q);
    }
    return byCode.values.toList();
  }

  /// Evaluates a map of answer codes using questions tailored to [model] and [manufactureYear],
  /// while also recognizing any answer codes from the full inspection catalog.
  static SelfInspectionEvaluation evaluateForMotorcycle(
    Map<String, String> answers, {
    MotorcycleModel? model,
    int? manufactureYear,
  }) {
    return _evaluateWithCatalog(
      answers,
      _allCatalogQuestions(model: model, manufactureYear: manufactureYear),
    );
  }

  /// Evaluates a map of answer codes and yields a detailed safety & risk assessment.
  /// Supports both legacy [questions] and dynamic [questionsForMotorcycle] codes.
  static SelfInspectionEvaluation evaluate(Map<String, String> answers) {
    return _evaluateWithCatalog(answers, _allCatalogQuestions());
  }

  static SelfInspectionEvaluation _evaluateWithCatalog(
    Map<String, String> answers,
    List<InspectionQuestion> catalog,
  ) {
    final findings = <InspectionFinding>[];
    final safetyAlerts = <InspectionFinding>[];
    final affectedComponents = <String>{};

    for (final q in catalog) {
      final answerCode = answers[q.code];
      if (answerCode == null) continue;

      final option = q.getSelectedOption(answerCode);
      if (option != null && option.isIssue) {
        final finding = InspectionFinding(
          questionCode: q.code,
          questionTitle: q.title,
          category: q.category,
          componentName: q.componentName,
          answerLabel: option.label,
          riskLevel: option.riskLevel,
          isSafetyCritical: option.isSafetyCritical,
          advice: option.advice ?? 'Lakukan pemeriksaan lebih lanjut.',
        );

        findings.add(finding);
        affectedComponents.add(q.componentName);

        if (option.isSafetyCritical) {
          safetyAlerts.add(finding);
        }
      }
    }

    final hasSafetyAlert = safetyAlerts.isNotEmpty;
    final highRisks = findings.where((f) => f.riskLevel == 'high').length;
    final mediumRisks = findings.where((f) => f.riskLevel == 'medium').length;

    String overallRisk = 'low';
    String summaryTitle = 'Kondisi Baik';
    String summaryExplanation =
        'Tidak ditemukan indikasi masalah serius dari hasil pengamatan mandiri Anda.';

    if (hasSafetyAlert || highRisks > 0) {
      overallRisk = 'high';
      summaryTitle = 'Peringatan Keselamatan / Risiko Tinggi';
      summaryExplanation =
          'Ditemukan ${findings.length} indikasi masalah, termasuk kondisi keselamatan kritis. Segera periksakan motor ke mekanik profesional.';
    } else if (mediumRisks > 0 || findings.length >= 2) {
      overallRisk = 'medium';
      summaryTitle = 'Perlu Perhatian';
      summaryExplanation =
          'Ditemukan ${findings.length} indikasi yang perlu pemeriksaan atau servis berkala dalam waktu dekat.';
    } else if (findings.isNotEmpty) {
      overallRisk = 'low';
      summaryTitle = 'Catatan Ringan';
      summaryExplanation =
          'Terdapat ${findings.length} catatan ringan untuk dipantau secara berkala.';
    }

    return SelfInspectionEvaluation(
      riskLevel: overallRisk,
      totalIssues: findings.length,
      hasSafetyAlert: hasSafetyAlert,
      safetyAlerts: safetyAlerts,
      allFindings: findings,
      affectedComponentNames: affectedComponents,
      summaryTitle: summaryTitle,
      summaryExplanation: summaryExplanation,
    );
  }
}
