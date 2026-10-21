import 'dart:async';
import 'dart:convert';
import 'package:drift/drift.dart';

import '../database/app_database.dart';
import 'ai_context_retriever.dart';
import 'ai_safety_guard.dart';
import 'model_download_service.dart';
import 'offline_ai_runtime.dart';

/// Parsed structured analysis of a motorcycle complaint.
class ComplaintAnalysisData {
  final List<String> symptoms;
  final List<String> componentCandidates;
  final List<String> followUpQuestions;
  final List<String> possibleCauses;
  final String inspectionAdvice;
  final String riskLevel; // 'low', 'medium', 'high'
  final String uncertainty; // 'low', 'medium', 'high'
  final bool requiresMechanic;
  final String mode; // 'llm' or 'rule_based'
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

/// Service that coordinates user chat messages, context retrieval from SQLite,
/// deterministic safety guard validation, offline LLM inference, and fallback handling.
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
       _runtime = runtime ?? AndroidOfflineAiRuntime(),
       _downloadService = downloadService ?? ModelDownloadService(db: db),
       _contextRetriever = contextRetriever ?? AiContextRetriever(db: db);

  OfflineAiRuntime get runtime => _runtime;
  ModelDownloadService get downloadService => _downloadService;

  /// Checks whether offline LLM is ready for on-device inference.
  Future<bool> isLlmReady() async {
    final status = await _downloadService.checkCurrentStatus();
    if (status.status != DownloadStatus.completed) return false;
    final isSupported = await _runtime.isSupported();
    return isSupported;
  }

  /// Ensures the offline model is loaded into RAM.
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

  /// Processes a user message in a chat thread.
  ///
  /// Emits streaming tokens and resolves with the final assistant response string.
  /// Automatically persists messages and structured analysis to SQLite.
  Stream<String> sendMessage({
    required int motorcycleId,
    int? complaintId,
    required String userText,
    required void Function(ComplaintAnalysisData analysis) onAnalysisComplete,
  }) async* {
    // 1. Evaluate deterministic safety rules first
    final safety = AiSafetyGuard.evaluate(userText);

    // 2. Retrieve isolated motorcycle context from SQLite
    final motorContext = await _contextRetriever.retrieveContext(motorcycleId);

    // 3. Ensure complaint record exists in SQLite
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

    // 4. Save user message to database
    await _db.insertComplaintMessage(
      ComplaintMessagesCompanion(
        complaintId: Value(activeComplaintId),
        role: const Value('user'),
        content: Value(userText),
      ),
    );

    // Check if offline LLM is ready
    final canUseLlm = await isLlmReady();

    if (canUseLlm) {
      try {
        await ensureModelLoaded();

        // Build system prompt with isolated motorcycle context
        final contextPrompt =
            motorContext?.toPromptContext(currentComplaintText: userText) ??
            'Motor ID: $motorcycleId';

        final systemPrompt =
            'Anda adalah BuildHaus AI, asisten konsultasi awal perawatan sepeda motor pribadi di Indonesia.\n'
            'Tugas Anda: memahami keluhan motor pengguna, mengidentifikasi gejala, memperkirakan komponen terkait, '
            'mengajukan pertanyaan lanjutan, dan memberikan saran pemeriksaan awal secara sopan dan terstruktur.\n\n'
            'PENTING:\n'
            '- Anda BUKAN mekanik profesional dan BUKAN diagnosis pasti.\n'
            '- Jangan mengarang harga sparepart, part number, atau klaim kepastian 100%.\n'
            '- Jika ada tanda bahaya rem, bensin, atau ban, utamakan keselamatan jiwa.\n\n'
            '$contextPrompt';

        // Fetch conversation history for this complaint thread (multi-turn support)
        final pastMessages = await _db.getComplaintMessages(activeComplaintId);
        final messages = <RuntimeChatMessage>[
          RuntimeChatMessage(role: 'system', content: systemPrompt),
        ];

        final recentPast = pastMessages.length > 8
            ? pastMessages.sublist(pastMessages.length - 8)
            : pastMessages;

        if (recentPast.isNotEmpty) {
          for (final m in recentPast) {
            messages.add(
              RuntimeChatMessage(
                role: m.role,
                content: m.content,
              ),
            );
          }
        } else {
          messages.add(RuntimeChatMessage(role: 'user', content: userText));
        }

        final fullResponseBuffer = StringBuffer();

        // Stream tokens from native llama.cpp
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

        // If safety red flags were detected, append critical warning if not already emphasized
        String finalContent = fullResponse;
        if (safety.hasRedFlag &&
            !finalContent.contains('⚠️ PERINGATAN KESELAMATAN')) {
          finalContent = '${safety.warningMessage}\n\n$finalContent';
        }

        // Save assistant message
        await _db.insertComplaintMessage(
          ComplaintMessagesCompanion(
            complaintId: Value(activeComplaintId),
            role: const Value('assistant'),
            content: Value(finalContent),
            analysisMode: const Value('llm'),
          ),
        );

        // Build and save structured analysis
        final analysis = _buildStructuredAnalysis(
          userText: userText,
          assistantText: finalContent,
          safety: safety,
          mode: 'llm',
        );

        await _saveAnalysisRecord(activeComplaintId, analysis);
        onAnalysisComplete(analysis);
        return;
      } catch (e) {
        // Fallback to rule-based analysis on error
      }
    }

    // Fallback: Transparent Rule-Based Analysis
    final fallbackResponse = _generateRuleBasedFallback(userText, safety);

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
    onAnalysisComplete(analysis);
  }

  /// Transparent rule-based fallback response generator.
  String _generateRuleBasedFallback(
    String input,
    SafetyEvaluationResult safety,
  ) {
    final lower = input.toLowerCase();
    final buffer = StringBuffer();

    buffer.writeln('📋 [Analisis Dasar — AI Offline Belum Aktif]\n');

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
      buffer.writeln(
        '  3. Untuk analisis mendalam, unduh model AI offline di Akun > AI Model.',
      );
      buffer.writeln(
        '• Pertanyaan Lanjutan: Sudah berapa lama gejala ini Anda rasakan?',
      );
    }

    return buffer.toString().trim();
  }

  /// Builds structured analysis data for persistence in SQLite.
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
      modelVersion: mode == 'llm' ? 'Qwen3-0.6B' : null,
    );
  }

  /// Saves structured complaint analysis record to SQLite `complaint_analyses` table.
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
  }
}
