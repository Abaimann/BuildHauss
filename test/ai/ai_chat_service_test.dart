import 'dart:io';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buildhaus/core/ai/ai_chat_service.dart';
import 'package:buildhaus/core/ai/model_download_service.dart';
import 'package:buildhaus/core/ai/offline_ai_runtime.dart';
import 'package:buildhaus/core/database/app_database.dart';

/// Test mock of [OfflineAiRuntime] for simulating loaded LLM inference in unit tests.
class MockTestAiRuntime implements OfflineAiRuntime {
  bool supported = true;
  bool loaded = false;
  String mockedTokenOutput =
      'Gejala pada motor menunjukkan keausan pada roller CVT.';

  @override
  Future<bool> isSupported() async => supported;

  @override
  Future<bool> isModelLoaded() async => loaded;

  @override
  Future<void> loadModel({
    required String modelPath,
    int threads = 4,
    int contextSize = 2048,
  }) async {
    loaded = true;
  }

  @override
  Stream<String> generateChat({
    required List<RuntimeChatMessage> messages,
    int maxTokens = 512,
    double temperature = 0.7,
  }) async* {
    final tokens = mockedTokenOutput.split(' ');
    for (final token in tokens) {
      yield '$token ';
    }
  }

  @override
  Stream<String> generate({
    required String prompt,
    int maxTokens = 512,
    double temperature = 0.7,
  }) async* {
    yield mockedTokenOutput;
  }

  @override
  Future<void> stop() async {}

  @override
  Future<void> unload() async {
    loaded = false;
  }

  @override
  Future<void> dispose() async {
    loaded = false;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late Directory tempDir;
  late MockTestAiRuntime mockRuntime;
  late AiChatService chatService;
  late int motorcycleId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    tempDir = await Directory.systemTemp.createTemp('buildhaus_chat_test_');
    mockRuntime = MockTestAiRuntime();

    motorcycleId = await db.insertMotorcycle(
      MotorcyclesCompanion.insert(
        nickname: 'Vario 160 Test',
        manufactureYear: 2022,
        plateNumber: const Value('B 9999 XYZ'),
      ),
    );

    chatService = AiChatService(
      db: db,
      runtime: mockRuntime,
      downloadService: ModelDownloadService(db: db, baseDirectory: tempDir),
    );
  });

  tearDown(() async {
    await db.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('Tahap 04 — AI Chat Service & Fallback Tests', () {
    test(
      '1. Runs transparent rule-based fallback when model is not installed',
      () async {
        ComplaintAnalysisData? completedAnalysis;

        final stream = chatService.sendMessage(
          motorcycleId: motorcycleId,
          userText: 'Tarikan motor gredek di CVT saat tarikan awal',
          onAnalysisComplete: (a) => completedAnalysis = a,
        );

        final tokens = await stream.toList();
        final fullResponse = tokens.join();

        expect(
          fullResponse,
          contains('Analisis Dasar — AI Offline Belum Aktif'),
        );
        expect(fullResponse, contains('CVT'));
        expect(completedAnalysis, isNotNull);
        expect(completedAnalysis!.mode, equals('rule_based'));
        expect(completedAnalysis!.symptoms, contains('Gredek / getaran CVT'));
        expect(completedAnalysis!.componentCandidates, contains('Roller CVT'));
      },
    );

    test(
      '2. Safety red flags trigger immediate warning in fallback mode',
      () async {
        ComplaintAnalysisData? completedAnalysis;

        final stream = chatService.sendMessage(
          motorcycleId: motorcycleId,
          userText: 'Rem blong saat mau berhenti di lampu merah',
          onAnalysisComplete: (a) => completedAnalysis = a,
        );

        final tokens = await stream.toList();
        final fullResponse = tokens.join();

        expect(fullResponse, contains('PERINGATAN KESELAMATAN KRITIS'));
        expect(fullResponse, contains('JANGAN mengendarai sepeda motor'));
        expect(completedAnalysis, isNotNull);
        expect(completedAnalysis!.riskLevel, equals('high'));
        expect(completedAnalysis!.requiresMechanic, isTrue);
      },
    );

    test(
      '3. Chat messages and structured analysis are persisted in SQLite',
      () async {
        final stream = chatService.sendMessage(
          motorcycleId: motorcycleId,
          userText: 'Kapan harus ganti oli mesin?',
          onAnalysisComplete: (_) {},
        );

        await stream.drain();

        // Verify complaints table
        final complaints = await db.getComplaints(motorcycleId);
        expect(complaints.length, equals(1));
        final complaint = complaints.first;
        expect(complaint.description, equals('Kapan harus ganti oli mesin?'));

        // Verify complaint_messages table (user message and assistant message)
        final messages = await db.getComplaintMessages(complaint.id);
        expect(messages.length, equals(2));
        expect(messages[0].role, equals('user'));
        expect(messages[0].content, equals('Kapan harus ganti oli mesin?'));
        expect(messages[1].role, equals('assistant'));
        expect(
          messages[1].content,
          contains('Analisis Dasar — AI Offline Belum Aktif'),
        );
        expect(messages[1].analysisMode, equals('rule_based'));

        // Verify complaint_analyses table
        final analysis = await db.getLatestAnalysis(complaint.id);
        expect(analysis, isNotNull);
        expect(analysis!.analysisMode, equals('rule_based'));
        expect(analysis.symptomsJson, contains('oli'));
      },
    );

    test(
      '4. Chat routes to LLM runtime when model installation is completed',
      () async {
        // Create a dummy model file in tempDir so file.exists() returns true
        final modelsDir = Directory('${tempDir.path}/ai_models');
        await modelsDir.create(recursive: true);
        final modelFile = File('${modelsDir.path}/Qwen3-0.6B-Q4_K_M.gguf');
        await modelFile.writeAsString('dummy model bytes');

        // Simulate completed model installation in database
        await db.insertAiModelInstall(
          AiModelInstallsCompanion.insert(
            modelName: 'Qwen3-0.6B-GGUF',
            version: '1.0.0',
            filePath: modelFile.path,
            sha256:
                'ac2d97712095a558e31573f62f466a3f9d93990898b0ec79d7c974c1780d524a',
            downloadStatus: const Value('completed'),
          ),
        );
        mockRuntime.loaded = true;

        ComplaintAnalysisData? completedAnalysis;

        final stream = chatService.sendMessage(
          motorcycleId: motorcycleId,
          userText: 'Suara kasar di bagian mesin',
          onAnalysisComplete: (a) => completedAnalysis = a,
        );

        final tokens = await stream.toList();
        final fullResponse = tokens.join();

        expect(fullResponse, contains('keausan pada roller CVT'));
        expect(completedAnalysis, isNotNull);
        expect(completedAnalysis!.mode, equals('llm'));
        expect(completedAnalysis!.modelVersion, equals('gemini-2.5-flash'));
      },
    );

    test(
      '5. Chat routes directly to online LLM runtime when runtime is ready without needing any downloaded GGUF file',
      () async {
        mockRuntime.loaded = true;

        ComplaintAnalysisData? completedAnalysis;

        final stream = chatService.sendMessage(
          motorcycleId: motorcycleId,
          userText: 'Tarikan motor terasa berat dan boros bensin',
          onAnalysisComplete: (a) => completedAnalysis = a,
        );

        final tokens = await stream.toList();
        final fullResponse = tokens.join();

        expect(fullResponse, contains(mockRuntime.mockedTokenOutput));
        expect(completedAnalysis, isNotNull);
        expect(completedAnalysis!.mode, equals('llm'));
        expect(completedAnalysis!.modelVersion, equals('gemini-2.5-flash'));
      },
    );
  });
}
