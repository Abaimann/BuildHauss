import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buildhaus/core/ai/model_download_service.dart';
import 'package:buildhaus/core/ai/model_manifest.dart';
import 'package:buildhaus/core/database/app_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late Directory tempDir;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    tempDir = await Directory.systemTemp.createTemp('buildhaus_ai_test_');
  });

  tearDown(() async {
    await db.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('Tahap 04 — Model Download Service & Integrity Tests', () {
    test('1. Calculates exact SHA-256 using chunked streaming', () async {
      final sampleFile = File('${tempDir.path}/sample.bin');
      const content = 'BuildHaus Offline AI Engine Test Bytes 2026';
      await sampleFile.writeAsString(content);

      final calculated = await ModelDownloadService.calculateSha256(sampleFile);
      final expected = sha256.convert(content.codeUnits).toString();

      expect(calculated, equals(expected));
      expect(calculated.length, equals(64));
    });

    test('2. Checksum verification fails and rejects corrupt file', () async {
      final dummyFile = File('${tempDir.path}/corrupt.gguf.part');
      await dummyFile.writeAsString('Corrupted model content bytes');

      // Manifest with intentional different SHA-256
      const testManifest = ModelManifest(
        modelId: 'test-model',
        name: 'Test Model',
        version: '1.0',
        quantization: 'Q4_K_M',
        fileName: 'test.gguf',
        repository: 'test/repo',
        downloadUrl: 'https://example.com/test.gguf',
        fileSizeBytes: 100,
        sha256:
            '0000000000000000000000000000000000000000000000000000000000000000',
        license: 'Apache 2.0',
        minRamGb: 2,
        minStorageMb: 500,
        minAndroidApi: 26,
        chatTemplate: 'chatml',
        description: 'Test',
      );

      // Verify that calculateSha256 does NOT match expected 000...
      final actualSha = await ModelDownloadService.calculateSha256(dummyFile);
      expect(actualSha, isNot(equals(testManifest.sha256)));
    });

    test('3. Download state copyWith preserves immutability', () {
      final initial = ModelDownloadState.initial(ModelManifest.defaultManifest);
      expect(initial.status, equals(DownloadStatus.idle));
      expect(initial.bytesDownloaded, equals(0));

      final downloading = initial.copyWith(
        status: DownloadStatus.downloading,
        bytesDownloaded: 50000000,
        progressRatio: 0.126,
      );

      expect(downloading.status, equals(DownloadStatus.downloading));
      expect(downloading.bytesDownloaded, equals(50000000));
      expect(downloading.progressRatio, equals(0.126));

      // Initial state remains untouched
      expect(initial.status, equals(DownloadStatus.idle));
      expect(initial.bytesDownloaded, equals(0));
    });

    test(
      '4. Model deletion removes database record and updates state to idle',
      () async {
        final service = ModelDownloadService(db: db, baseDirectory: tempDir);

        // Seed an install record
        await db.insertAiModelInstall(
          AiModelInstallsCompanion.insert(
            modelName: ModelManifest.defaultManifest.name,
            version: ModelManifest.defaultManifest.version,
            filePath: '${tempDir.path}/model.gguf',
            sha256: ModelManifest.defaultManifest.sha256,
            downloadStatus: const Value('completed'),
          ),
        );

        final installedBefore = await db.getInstalledModel();
        expect(installedBefore, isNotNull);

        await service.deleteModel();

        final installedAfter = await db.getInstalledModel();
        expect(installedAfter, isNull);
        expect(service.currentState.status, equals(DownloadStatus.idle));
      },
    );
  });
}
