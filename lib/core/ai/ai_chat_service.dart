import 'dart:async';
import 'dart:convert';
import 'package:drift/drift.dart';

import '../database/app_database.dart';
import 'ai_context_retriever.dart';
import 'ai_safety_guard.dart';
import 'gemini_ai_runtime.dart';
import 'model_download_service.dart';
import 'offline_ai_runtime.dart';

/// Data analisis terstruktur hasil penguraian keluhan sepeda motor.
class ComplaintAnalysisData {
  final List<String> symptoms;
  final List<String> componentCandidates;
  final List<String> followUpQuestions;
  final List<String> possibleCauses;
  final String inspectionAdvice;
  final String riskLevel; // 'low', 'medium', 'high'
  final String uncertainty; // 'low', 'medium', 'high'
  final bool requiresMechanic;
  final String mode; // 'llm' atau 'rule_based'
  final String? modelVersion;

  const ComplaintAnalysisData({
    required this.symptoms,
    required this.componentCandidates,
    required this.followUpQuestions,
    required this.possibleCauses,
    required this.inspectionAdvice,
    required this.riskLevel,
    required this.uncertainty,
    required this.requiresMechanic,
    required this.mode,
    this.modelVersion,
  });

  Map<String, dynamic> toJson() => {
    'symptoms': symptoms,
    'component_candidates': componentCandidates,
    'follow_up_questions': followUpQuestions,
    'possible_causes': possibleCauses,
    'inspection_advice': inspectionAdvice,
    'risk_level': riskLevel,
    'uncertainty': uncertainty,
    'requires_mechanic': requiresMechanic,
    'mode': mode,
    'model_version': modelVersion,
  };
}

/// Layanan yang mengkoordinasikan percakapan pengguna, pengambilan konteks motor dari SQLite,
/// validasi aturan keselamatan deterministik, inferensi AI Gemini/LLM, serta fallback aturan dasar.
class AiChatService {
  final AppDatabase _db;
  final OfflineAiRuntime _runtime;
  final ModelDownloadService _downloadService;
  final AiContextRetriever _contextRetriever;

  AiChatService({
    required AppDatabase db,
    OfflineAiRuntime? runtime,
    ModelDownloadService? downloadService,
    AiContextRetriever? contextRetriever,
  }) : _db = db,
       _runtime = runtime ?? GeminiAiRuntime(db: db),
       _downloadService = downloadService ?? ModelDownloadService(db: db),
       _contextRetriever = contextRetriever ?? AiContextRetriever(db: db);

  OfflineAiRuntime get runtime => _runtime;
  ModelDownloadService get downloadService => _downloadService;

  static const Set<String> _hardOffTopicTokens = {
    'coding',
    'ngoding',
    'programming',
    'pemrograman',
    'programmer',
    'python',
    'javascript',
    'typescript',
    'golang',
    'html',
    'css',
    'php',
    'kotlin',
    'flutter',
    'dart',
    'sql',
    'pilpres',
    'pemilu',
    'pilkada',
    'presiden',
    'wapres',
    'partai',
    'dpr',
    'mpr',
    'politik',
    'zodiak',
    'horoskop',
    'tarot',
    'shio',
    'primbon',
    'ramalan',
    'judi',
    'slot',
    'gacor',
    'togel',
    'kasino',
    'poker',
    'taruhan',
    'kripto',
    'crypto',
    'bitcoin',
    'ethereum',
    'blockchain',
    'nft',
    'forex',
    'saham',
    'trading',
    'valorant',
    'pubg',
    'mlbb',
    'genshin',
    'minecraft',
    'roblox',
    'drakor',
    'anime',
    'manga',
    'pacar',
    'pacaran',
    'asmara',
    'selingkuh',
    'jodoh',
    'matematika',
    'aljabar',
    'kalkulus',
    'trigonometri',
    'integral',
  };

  static const List<String> _hardOffTopicPhrases = [
    'resep masak',
    'resep masakan',
    'cara memasak',
    'nasi goreng',
    'mobile legends',
    'free fire',
    'pr matematika',
    'tugas kuliah',
    'ramalan zodiak',
    'judi online',
    'slot gacor',
  ];

  static const Set<String> _softOffTopicTokens = {
    'resep',
    'masak',
    'masakan',
    'memasak',
    'kuliner',
    'skripsi',
    'tesis',
    'makalah',
    'jurnal',
    'pr',
    'homework',
    'fisika',
    'kimia',
    'biologi',
    'sejarah',
    'geografi',
    'cinta',
    'galau',
    'mantan',
    'game',
    'gaming',
    'film',
    'bioskop',
    'lagu',
    'lirik',
    'puisi',
    'cerpen',
    'novel',
    'dongeng',
    'diet',
    'kalori',
    'sepakbola',
    'cuaca',
  };

  static const Set<String> _greetingTokens = {
    'halo',
    'hai',
    'hi',
    'hello',
    'helo',
    'pagi',
    'siang',
    'sore',
    'malam',
    'assalamualaikum',
    'permisi',
    'bro',
    'sob',
    'min',
    'tes',
    'test',
    'p',
    'oy',
    'oi',
  };

  static const Set<String> _motorTokens = {
    'motor',
    'motornya',
    'motorku',
    'motormu',
    'otomotif',
    'matic',
    'skutik',
    'bebek',
    'kopling',
    'honda',
    'yamaha',
    'suzuki',
    'kawasaki',
    'vespa',
    'piaggio',
    'ahass',
    'ahm',
    'yamalube',
    'vario',
    'beat',
    'pcx',
    'adv',
    'scoopy',
    'genio',
    'stylo',
    'supra',
    'cbr',
    'cbr150',
    'cbr150r',
    'cb150',
    'cb150r',
    'revo',
    'sonic',
    'crf',
    'verza',
    'nmax',
    'aerox',
    'mio',
    'freego',
    'lexi',
    'fazzio',
    'filano',
    'vixion',
    'r15',
    'r25',
    'mt15',
    'mt25',
    'jupiter',
    'smash',
    'satria',
    'gsx',
    'shogun',
    'ninja',
    'w175',
    'z125',
    'klx',
    'oli',
    'pelumas',
    'gardan',
    'kampas',
    'rem',
    'ngerem',
    'pengereman',
    'cakram',
    'tromol',
    'kaliper',
    'ban',
    'velg',
    'pelek',
    'tubeless',
    'pentil',
    'aki',
    'accu',
    'klakson',
    'sein',
    'sekring',
    'spul',
    'kiprok',
    'dinamo',
    'starter',
    'stater',
    'engkol',
    'busi',
    'koil',
    'cdi',
    'ecu',
    'ecm',
    'injeksi',
    'injektor',
    'karburator',
    'karbu',
    'spuyer',
    'pelampung',
    'cvt',
    'vbelt',
    'roller',
    'pulley',
    'puli',
    'rantai',
    'gir',
    'sprocket',
    'knalpot',
    'radiator',
    'coolant',
    'thermostat',
    'suspensi',
    'shock',
    'shockbreaker',
    'sokbreker',
    'komstir',
    'stang',
    'setang',
    'spion',
    'tangki',
    'bensin',
    'bbm',
    'pertalite',
    'pertamax',
    'odometer',
    'kilometer',
    'km',
    'speedometer',
    'klep',
    'keteng',
    'piston',
    'seher',
    'silinder',
    'paking',
    'gasket',
    'laher',
    'bearing',
    'swingarm',
    'servis',
    'service',
    'bengkel',
    'mekanik',
    'montir',
    'sparepart',
    'onderdil',
    'gredek',
    'brebet',
    'berebet',
    'nyendat',
    'tersendat',
    'ngempos',
    'ngeden',
    'mogok',
    'nembak',
    'ngebul',
    'berdecit',
    'klotok',
    'nglitik',
    'oleng',
    'selip',
    'blong',
    'ambles',
    'ngelos',
    'rembes',
    'overheat',
    'tarikan',
    'akselerasi',
    'kompresi',
    'langsam',
    'stasioner',
    'idle',
    'berkendara',
    'riding',
    'bohlam',
    'headlamp',
    'stoplamp',
    'kempes',
    'kempis',
    'botak',
    'benjol',
  };

  static const List<String> _motorPhrases = [
    'sepeda motor',
    'roda dua',
    'oli mesin',
    'oli gardan',
    'oli samping',
    'ganti oli',
    'kampas rem',
    'minyak rem',
    'filter udara',
    'saringan udara',
    'filter oli',
    'saringan oli',
    'v-belt',
    'kampas ganda',
    'mangkok ganda',
    'radiator coolant',
    'water pump',
    'fuel pump',
    'kick starter',
    'electric starter',
    'lampu motor',
    'lampu depan',
    'lampu belakang',
    'lampu rem',
    'lampu sein',
    'lampu sen',
    'lampu utama',
    'lampu redup',
    'lampu mati',
    'indikator mil',
    'check engine',
    'mesin panas',
    'suara kasar',
    'susah hidup',
    'susah nyala',
    'mati mendadak',
    'mati total',
    'bau bensin',
    'bocor bensin',
    'bahan bakar',
    'boros bensin',
    'tekanan angin',
    'tune up',
    'suku cadang',
    'kom stir',
    'as shock',
    'seal shock',
    'kabel gas',
    'kabel rem',
    'kabel kopling',
    '2 tak',
    '2-tak',
    '4 tak',
    '4-tak',
    'mx king',
    'rx king',
    'fiz r',
    'f1zr',
    'x-ride',
    'mt-15',
    'mt-25',
    'ninja 250',
    'zx-25',
    'komponen motor',
    'perawatan motor',
    'kesehatan motor',
  ];

  static bool _hasMotorSignal(String normalized, Set<String> tokenSet) {
    return tokenSet.any(_motorTokens.contains) ||
        _motorPhrases.any(normalized.contains);
  }

  static bool _isPureGreeting(String input) {
    final normalized = input.trim().toLowerCase();
    if (normalized.isEmpty) return false;
    final tokens = RegExp(r'[a-z0-9]+')
        .allMatches(normalized)
        .map((m) => m.group(0)!)
        .toList();
    if (tokens.isEmpty) return false;
    final tokenSet = tokens.toSet();
    if (_hardOffTopicPhrases.any(normalized.contains) ||
        tokenSet.any(_hardOffTopicTokens.contains) ||
        tokenSet.any(_softOffTopicTokens.contains)) {
      return false;
    }
    if (_hasMotorSignal(normalized, tokenSet)) return false;
    return tokens.length <= 4 &&
        normalized.length <= 36 &&
        tokenSet.any(_greetingTokens.contains);
  }

  /// Memeriksa apakah input pengguna relevan dengan domain sepeda motor
  /// (perawatan, keluhan, diagnosa, sparepart, keselamatan, atau sapaan awal pendek).
  static bool isMotorcycleRelatedQuery(String input) {
    final normalized = input.trim().toLowerCase();
    if (normalized.isEmpty) return false;

    final tokens = RegExp(r'[a-z0-9]+')
        .allMatches(normalized)
        .map((m) => m.group(0)!)
        .toList();
    if (tokens.isEmpty) return false;

    final tokenSet = tokens.toSet();

    // 1. Tolak langsung topik non-motor yang jelas
    if (_hardOffTopicPhrases.any(normalized.contains) ||
        tokenSet.any(_hardOffTopicTokens.contains)) {
      return false;
    }

    final hasMotorSignal = _hasMotorSignal(normalized, tokenSet);

    // 2. Tolak topik lunak non-motor bila tidak memiliki konteks sepeda motor
    if (!hasMotorSignal && tokenSet.any(_softOffTopicTokens.contains)) {
      return false;
    }

    if (hasMotorSignal) return true;

    // 3. Toleransi sapaan awal singkat tanpa kata kunci off-topic
    return tokens.length <= 4 &&
        normalized.length <= 36 &&
        tokenSet.any(_greetingTokens.contains);
  }

  /// Pesan penolakan ramah khas BuildHaus untuk pertanyaan di luar topik sepeda motor.
  static String buildOffTopicResponse() {
    return 'Waduh, maaf ya bro! Aku BuildHaus AI, asisten khusus buat urusan sepeda motor aja nih 🏍️\n\n'
        'Topik di luar perawatan atau dunia motor belum bisa aku bantu jawab. '
        'Yuk balik bahas motor kamu — misalnya soal keluhan mesin/CVT/rem, jadwal ganti oli, kecocokan sparepart, atau kondisi komponen motor!';
  }

  /// Memeriksa apakah mesin AI siap digunakan (baik lewat API key Gemini maupun model lokal).
  Future<bool> isLlmReady() async {
    if (await _runtime.isModelLoaded()) return true;
    final status = await _downloadService.checkCurrentStatus();
    if (status.status == DownloadStatus.completed) {
      return await _runtime.isSupported();
    }
    return false;
  }

  /// Memastikan model AI telah dimuat ke dalam memori RAM.
  Future<void> ensureModelLoaded() async {
    if (await _runtime.isModelLoaded()) return;

    final modelFile = await _downloadService.getModelFile();
    if (!await modelFile.exists()) {
      throw StateError('File model offline belum diunduh.');
    }

    await _runtime.loadModel(
      modelPath: modelFile.path,
      threads: 4,
      contextSize: 2048,
    );
  }

  /// Memproses pesan dari pengguna dalam suatu riwayat keluhan (chat thread).
  ///
  /// Mengalirkan token teks secara streaming dan menghasilkan jawaban asisten AI.
  /// Secara otomatis menyimpan riwayat pesan dan hasil analisis terstruktur ke SQLite.
  Stream<String> sendMessage({
    required int motorcycleId,
    int? complaintId,
    required String userText,
    required void Function(ComplaintAnalysisData analysis) onAnalysisComplete,
  }) async* {
    // 0. Guardrail lapis pertama: tolak topik off-topic di luar sepeda motor
    // tanpa membuat keluhan baru atau menurunkan status kesehatan komponen motor.
    if (!isMotorcycleRelatedQuery(userText)) {
      final offTopicResponse = buildOffTopicResponse();
      if (complaintId != null && complaintId > 0) {
        await _db.insertComplaintMessage(
          ComplaintMessagesCompanion(
            complaintId: Value(complaintId),
            role: const Value('user'),
            content: Value(userText),
          ),
        );
        await _db.insertComplaintMessage(
          ComplaintMessagesCompanion(
            complaintId: Value(complaintId),
            role: const Value('assistant'),
            content: Value(offTopicResponse),
            analysisMode: const Value('rule_based'),
          ),
        );
      }
      yield offTopicResponse;
      onAnalysisComplete(
        ComplaintAnalysisData(
          symptoms: const [],
          componentCandidates: const [],
          followUpQuestions: const [],
          possibleCauses: const [],
          inspectionAdvice: offTopicResponse,
          riskLevel: 'low',
          uncertainty: 'low',
          requiresMechanic: false,
          mode: 'rule_based',
        ),
      );
      return;
    }

    // 0b. Sapaan awal singkat (tanpa keluhan/gejala motor): balas ramah tanpa mencatat keluhan palsu
    if (_isPureGreeting(userText) && (complaintId == null || complaintId <= 0)) {
      const greetingReply =
          'Halo bro! 👋 Aku BuildHaus AI, siap bantu cek urusan motor kamu.\n\n'
          'Ada gejala apa nih di motornya — misalnya soal rem, oli mesin, CVT/rantai, aki, atau jadwal servis? Ceritakan aja biar langsung aku bantu analisa!';
      yield greetingReply;
      onAnalysisComplete(
        const ComplaintAnalysisData(
          symptoms: [],
          componentCandidates: [],
          followUpQuestions: [],
          possibleCauses: [],
          inspectionAdvice: greetingReply,
          riskLevel: 'low',
          uncertainty: 'low',
          requiresMechanic: false,
          mode: 'rule_based',
        ),
      );
      return;
    }

    // 1. Evaluasi aturan keselamatan deterministik terlebih dahulu (Safety Override)
    final safety = AiSafetyGuard.evaluate(userText);

    // 2. Ambil konteks terisolasi sepeda motor dari SQLite
    final motorContext = await _contextRetriever.retrieveContext(motorcycleId);

    // 3. Pastikan data record keluhan sudah tersimpan di tabel SQLite
    int activeComplaintId = complaintId ?? 0;
    if (activeComplaintId <= 0) {
      activeComplaintId = await _db.insertComplaint(
        ComplaintsCompanion(
          motorcycleId: Value(motorcycleId),
          title: Value(
            userText.length > 50 ? '${userText.substring(0, 47)}...' : userText,
          ),
          description: Value(userText),
          status: const Value('dianalisis'),
          odometerKm: Value(motorContext?.latestOdometerKm),
        ),
      );
    }

    // 4. Simpan pesan pengguna ke database SQLite
    await _db.insertComplaintMessage(
      ComplaintMessagesCompanion(
        complaintId: Value(activeComplaintId),
        role: const Value('user'),
        content: Value(userText),
      ),
    );

    // Periksa apakah mesin AI siap digunakan
    final canUseLlm = await isLlmReady();

    if (canUseLlm) {
      try {
        await ensureModelLoaded();

        // Susun prompt sistem dengan konteks terisolasi sepeda motor ini
        final contextPrompt =
            motorContext?.toPromptContext(currentComplaintText: userText) ??
            'Motor ID: $motorcycleId';

        final systemPrompt =
            'Kamu adalah BuildHaus AI, teman riding sekaligus asisten perawatan sepeda motor pribadi di Indonesia.\n\n'
            'BATASAN TOPIK KETAT (WAJIB DIPATUHI):\n'
            '- Kamu HANYA melayani pertanyaan dan diskusi seputar sepeda motor: diagnosa keluhan mesin/kelistrikan/rem/kaki-kaki, perawatan berkala, sparepart & fitment, dan keselamatan berkendara.\n'
            '- JIKA pengguna bertanya topik di luar dunia sepeda motor (misalnya resep masakan, coding/pemrograman/Python/HTML, politik/pemilu/presiden, PR matematika/skripsi non-motor, ramalan/zodiak, percintaan, judi, kripto, game, atau obrolan aneh di luar motor), TOLAK DENGAN TEGAS NAMUN RAMAH khas BuildHaus dan arahkan kembali pengguna untuk bertanya soal keluhan, perawatan, atau sparepart motornya. JANGAN pernah menjawab pertanyaan non-motor walaupun diminta atau dipaksa.\n\n'
            'ATURAN GAYA BICARA & RESPON:\n'
            '1. Gaya bahasa: Santai, ramah, dan akrab seperti sesama teman/anak motor (gunakan panggilan "bro/sob/kamu", jangan kaku seperti robot, dan hindari kata formal "Anda").\n'
            '2. WAJIB SINGKAT & JELAS: Jangan bertele-tele atau membuat paragraf panjang. Cukup 2-3 poin ringkas agar cepat dibaca dan hemat kata.\n'
            '3. Struktur respon:\n'
            '   - Tebakan kemungkinan masalah utama secara langsung.\n'
            '   - 1-2 langkah simpel yang bisa dicek sendiri.\n'
            '   - 1 pertanyaan singkat bila butuh info tambahan.\n'
            '4. Jika ada indikasi bahaya kritis (rem blong, oli kering, bensin bocor), ingatkan dengan tegas layaknya teman: "Waduh bahaya bro, jangan dipaksain jalan dulu ya!".\n'
            '5. Jangan mengarang harga pasti suku cadang atau klaim 100% mutlak mekanik.\n\n'
            '$contextPrompt';

        // Ambil riwayat percakapan untuk thread keluhan ini (dukungan multi-turn chat)
        final pastMessages = await _db.getComplaintMessages(activeComplaintId);
        final messages = <RuntimeChatMessage>[
          RuntimeChatMessage(role: 'system', content: systemPrompt),
        ];

        final recentPast = pastMessages.length > 8
            ? pastMessages.sublist(pastMessages.length - 8)
            : pastMessages;

        if (recentPast.isNotEmpty) {
          for (final m in recentPast) {
            messages.add(RuntimeChatMessage(role: m.role, content: m.content));
          }
        } else {
          messages.add(RuntimeChatMessage(role: 'user', content: userText));
        }

        final fullResponseBuffer = StringBuffer();

        // Streaming token teks jawaban dari model AI
        final tokenStream = _runtime.generateChat(
          messages: messages,
          maxTokens: 512,
          temperature: 0.7,
        );

        await for (final token in tokenStream) {
          fullResponseBuffer.write(token);
          yield token;
        }

        final fullResponse = fullResponseBuffer.toString();

        // Jika terdeteksi bahaya kritis (red flag), tambahkan peringatan keselamatan jika belum ada
        String finalContent = fullResponse;
        if (safety.hasRedFlag &&
            !finalContent.contains('⚠️ PERINGATAN KESELAMATAN')) {
          finalContent = '${safety.warningMessage}\n\n$finalContent';
        }

        // Simpan pesan jawaban asisten AI ke database SQLite
        await _db.insertComplaintMessage(
          ComplaintMessagesCompanion(
            complaintId: Value(activeComplaintId),
            role: const Value('assistant'),
            content: Value(finalContent),
            analysisMode: const Value('llm'),
          ),
        );

        // Susun dan simpan data analisis terstruktur
        final analysis = _buildStructuredAnalysis(
          userText: userText,
          assistantText: finalContent,
          safety: safety,
          mode: 'llm',
        );

        await _saveAnalysisRecord(activeComplaintId, analysis);
        await _db.recalculateComponentStatuses(motorcycleId);
        onAnalysisComplete(analysis);
        return;
      } catch (e) {
        // Fallback ke analisis berbasis aturan dasar jika terjadi kendala pada model AI
      }
    }

    // Fallback: Analisis Berbasis Aturan Dasar yang Transparan
    final fallbackResponse = _generateRuleBasedFallback(
      userText,
      safety,
      modelInstalled: canUseLlm,
    );

    yield fallbackResponse;

    await _db.insertComplaintMessage(
      ComplaintMessagesCompanion(
        complaintId: Value(activeComplaintId),
        role: const Value('assistant'),
        content: Value(fallbackResponse),
        analysisMode: const Value('rule_based'),
      ),
    );

    final analysis = _buildStructuredAnalysis(
      userText: userText,
      assistantText: fallbackResponse,
      safety: safety,
      mode: 'rule_based',
    );

    await _saveAnalysisRecord(activeComplaintId, analysis);
    await _db.recalculateComponentStatuses(motorcycleId);
    onAnalysisComplete(analysis);
  }

  /// Generator respon fallback berbasis aturan dasar yang transparan.
  String _generateRuleBasedFallback(
    String input,
    SafetyEvaluationResult safety, {
    bool modelInstalled = false,
  }) {
    final lower = input.toLowerCase();
    final buffer = StringBuffer();

    if (modelInstalled) {
      buffer.writeln(
        '📋 [Analisis Cerdas Motor — Model AI Terpasang (Mode Aturan Motor)]\n',
      );
      buffer.writeln(
        'ℹ️ Model Qwen3 0.6B terpasang. Berjalan dalam mode Aturan Motor Aman '
        '(Native LLM ARM64 aktif otomatis saat diinstal pada smartphone fisik Android).\n',
      );
    } else {
      buffer.writeln('📋 [Analisis Dasar — AI Offline Belum Aktif]\n');
    }

    if (safety.hasRedFlag) {
      buffer.writeln(safety.warningMessage);
      buffer.writeln();
      return buffer.toString().trim();
    }

    if (lower.contains('oli') || lower.contains('mesin panas')) {
      buffer.writeln('🛢️ Analisis Sistem Pelumasan / Oli Mesin:');
      buffer.writeln('• Gejala: Terkait pelumasan atau suhu mesin berlebih.');
      buffer.writeln(
        '• Komponen Terkait: Oli mesin, filter oli, paking/seal mesin.',
      );
      buffer.writeln('• Saran Pemeriksaan:');
      buffer.writeln(
        '  1. Periksa dipstick oli saat mesin dingin dan motor di standar tengah.',
      );
      buffer.writeln(
        '  2. Perhatikan warna dan kekentalan oli (apakah hitam pekat atau berbusa).',
      );
      buffer.writeln(
        '  3. Catat riwayat penggantian oli terakhir di menu Riwayat Servis.',
      );
      buffer.writeln(
        '• Pertanyaan Lanjutan: Kapan terakhir kali motor ganti oli dan berapa km yang ditempuh?',
      );
    } else if (lower.contains('starter') ||
        lower.contains('aki') ||
        lower.contains('mati total')) {
      buffer.writeln('🔋 Analisis Sistem Kelistrikan / Starter:');
      buffer.writeln(
        '• Gejala: Motor sulit dinyalakan atau tidak merespons tombol starter.',
      );
      buffer.writeln(
        '• Komponen Terkait: Aki (Accu), bendik/relay starter, dinamo starter, sekring.',
      );
      buffer.writeln('• Saran Pemeriksaan:');
      buffer.writeln(
        '  1. Nyalakan klakson atau lampu utama; jika redup/lemah, aki kemungkinan drop.',
      );
      buffer.writeln(
        '  2. Periksa apakah terdengar bunyi klik dari bawah jok saat tombol starter ditekan.',
      );
      buffer.writeln(
        '• Pertanyaan Lanjutan: Apakah kick starter masih bisa digunakan untuk menyalakan mesin?',
      );
    } else if (lower.contains('cvt') ||
        lower.contains('gredek') ||
        lower.contains('tarikan berat')) {
      buffer.writeln('⚙️ Analisis Transmisi CVT / Tarikan:');
      buffer.writeln(
        '• Gejala: Getaran (gredek) pada kecepatan rendah atau tarikan terasa berat.',
      );
      buffer.writeln(
        '• Komponen Terkait: V-belt, roller CVT, kampas ganda, mangkok kopling.',
      );
      buffer.writeln('• Saran Pemeriksaan:');
      buffer.writeln('  1. Bersihkan debu dan residu kampas pada ruang CVT.');
      buffer.writeln('  2. Periksa keausan roller dan keretakan pada v-belt.');
      buffer.writeln(
        '• Pertanyaan Lanjutan: Apakah gredek muncul saat mulai jalan dari posisi berhenti?',
      );
    } else {
      buffer.writeln('💡 Analisis Keluhan:');
      buffer.writeln(
        '• Keluhan Anda telah dicatat dalam riwayat keluhan sepeda motor.',
      );
      buffer.writeln('• Saran Pemeriksaan Awal:');
      buffer.writeln(
        '  1. Perhatikan apakah gejala muncul terus-menerus atau hanya pada kecepatan/kondisi tertentu.',
      );
      buffer.writeln(
        '  2. Cek menu Kesehatan Motor untuk melihat kondisi komponen yang mendekati batas servis.',
      );
      if (modelInstalled) {
        buffer.writeln(
          '  3. Gunakan panduan ini untuk inspeksi mandiri atau bawa ke bengkel resmi terdekat.',
        );
      } else {
        buffer.writeln(
          '  3. Untuk analisis mendalam dengan Google Gemini 2.5 Flash (Online tanpa download model), atur API Key di menu Akun > Konfigurasi AI.',
        );
      }
      buffer.writeln(
        '• Pertanyaan Lanjutan: Sudah berapa lama gejala ini Anda rasakan?',
      );
    }

    return buffer.toString().trim();
  }

  /// Menyusun data analisis terstruktur untuk disimpan di database SQLite.
  ComplaintAnalysisData _buildStructuredAnalysis({
    required String userText,
    required String assistantText,
    required SafetyEvaluationResult safety,
    required String mode,
  }) {
    final lower = userText.toLowerCase();
    final symptoms = <String>[];
    final components = <String>[];
    final causes = <String>[];
    final followUps = <String>[];

    if (lower.contains('rem')) {
      symptoms.add('Gangguan pengereman');
      components.add('Kampas rem');
      components.add('Minyak rem');
      causes.add('Kampas rem aus atau angin palsu di selang rem');
      followUps.add('Apakah tuas rem terasa ambles saat ditarik?');
    }
    if (lower.contains('oli') || lower.contains('panas')) {
      symptoms.add('Mesin panas / oli');
      components.add('Oli mesin');
      causes.add('Volume oli berkurang atau viskositas menurun');
      followUps.add('Kapan terakhir kali Anda melakukan penggantian oli?');
    }
    if (lower.contains('starter') || lower.contains('aki')) {
      symptoms.add('Sulit starter');
      components.add('Aki (Battery)');
      components.add('Dinamo starter');
      causes.add('Tegangan aki drop atau relay kotor');
      followUps.add('Apakah klakson berbunyi normal saat kontak ON?');
    }
    if (lower.contains('cvt') || lower.contains('gredek')) {
      symptoms.add('Gredek / getaran CVT');
      components.add('Roller CVT');
      components.add('Kampas ganda');
      causes.add('Mangkok ganda kotor atau roller aus');
      followUps.add('Apakah getaran terasa saat RPM rendah?');
    }
    if (lower.contains('ban')) {
      symptoms.add('Masalah ban');
      components.add('Ban luar');
      causes.add('Tekanan angin tidak sesuai atau tapak ban aus');
      followUps.add('Kapan terakhir kali Anda memeriksa tekanan angin ban?');
    }

    if (symptoms.isEmpty) {
      symptoms.add('Keluhan umum performa mesin/motor');
      components.add('Komponen umum');
      causes.add('Perlu pemeriksaan lebih lanjut');
      followUps.add('Kapan gejala ini pertama kali dirasakan?');
    }

    String risk = 'low';
    bool reqMechanic = false;

    if (safety.hasRedFlag) {
      risk = 'high';
      reqMechanic = true;
    } else if (lower.contains('rem') ||
        lower.contains('oli') ||
        lower.contains('gredek')) {
      risk = 'medium';
      reqMechanic = false;
    }

    return ComplaintAnalysisData(
      symptoms: symptoms,
      componentCandidates: components,
      followUpQuestions: followUps,
      possibleCauses: causes,
      inspectionAdvice: assistantText,
      riskLevel: risk,
      uncertainty: mode == 'llm' ? 'medium' : 'high',
      requiresMechanic: reqMechanic,
      mode: mode,
      modelVersion: mode == 'llm' ? 'gemini-2.5-flash' : null,
    );
  }

  /// Menyimpan rekaman analisis keluhan terstruktur ke tabel `complaint_analyses` di SQLite.
  Future<void> _saveAnalysisRecord(
    int complaintId,
    ComplaintAnalysisData analysis,
  ) async {
    await _db.insertComplaintAnalysis(
      ComplaintAnalysesCompanion(
        complaintId: Value(complaintId),
        symptomsJson: Value(jsonEncode(analysis.symptoms)),
        componentCandidatesJson: Value(
          jsonEncode(analysis.componentCandidates),
        ),
        followUpJson: Value(jsonEncode(analysis.followUpQuestions)),
        historicalMatchesJson: Value(jsonEncode(analysis.possibleCauses)),
        riskLevel: Value(analysis.riskLevel),
        summary: Value(
          analysis.inspectionAdvice.length > 200
              ? '${analysis.inspectionAdvice.substring(0, 197)}...'
              : analysis.inspectionAdvice,
        ),
        modelVersion: Value(analysis.modelVersion),
        analysisMode: Value(analysis.mode),
        analyzedAt: Value(DateTime.now()),
      ),
    );
    await _db.updateComplaint(
      ComplaintsCompanion(
        status: const Value('perlu_pemeriksaan'),
        updatedAt: Value(DateTime.now()),
      ),
      complaintId,
    );
  }
}
