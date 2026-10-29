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
            'Kamu adalah BuildHaus AI, teman riding sekaligus teman ngobrol perawatan motor pribadi di Indonesia.\n\n'
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
