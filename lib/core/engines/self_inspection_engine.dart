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

  /// Evaluates a map of answer codes and yields a detailed safety & risk assessment.
  static SelfInspectionEvaluation evaluate(Map<String, String> answers) {
    final findings = <InspectionFinding>[];
    final safetyAlerts = <InspectionFinding>[];
    final affectedComponents = <String>{};

    for (final q in questions) {
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
