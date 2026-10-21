import 'package:flutter_test/flutter_test.dart';
import 'package:buildhaus/core/ai/model_manifest.dart';

void main() {
  group('Tahap 04 — Model Manifest Tests', () {
    test('1. Default Qwen3 0.6B manifest is valid and complete', () {
      final manifest = ModelManifest.defaultManifest;

      expect(manifest.isValid, isTrue);
      expect(manifest.modelId, equals('qwen3-0.6b-q4_k_m'));
      expect(manifest.name, equals('Qwen3-0.6B-GGUF'));
      expect(manifest.quantization, equals('Q4_K_M'));
      expect(manifest.fileName, endsWith('.gguf'));
      expect(manifest.fileSizeBytes, equals(396705472));
      expect(manifest.sha256.length, equals(64));
      expect(manifest.license, equals('Apache 2.0'));
      expect(manifest.minRamGb, equals(2));
      expect(manifest.minStorageMb, equals(500));
      expect(manifest.minAndroidApi, equals(26));
      expect(manifest.formattedSize, contains('378.3 MB'));
    });

    test('2. Manifest rejects empty modelId, name, or filename', () {
      const invalid = ModelManifest(
        modelId: '',
        name: '',
        version: '1.0',
        quantization: 'Q4_K_M',
        fileName: 'invalid.bin', // not .gguf
        repository: 'test/repo',
        downloadUrl: 'https://example.com/model.bin',
        fileSizeBytes: 1000,
        sha256:
            'ac2d97712095a558e31573f62f466a3f9d93990898b0ec79d7c974c1780d524a',
        license: 'Apache 2.0',
        minRamGb: 2,
        minStorageMb: 500,
        minAndroidApi: 26,
        chatTemplate: 'chatml',
        description: '',
      );

      expect(invalid.isValid, isFalse);
    });

    test('3. Manifest rejects invalid SHA-256 checksum format', () {
      final badSha = ModelManifest.defaultManifest.toJson();
      badSha['sha256'] = 'invalid_non_hex_sha256';

      final manifest = ModelManifest.fromJson(badSha);
      expect(manifest.isValid, isFalse);
    });

    test('4. Manifest rejects zero or negative file size', () {
      final zeroSize = ModelManifest.defaultManifest.toJson();
      zeroSize['file_size_bytes'] = 0;

      final manifest = ModelManifest.fromJson(zeroSize);
      expect(manifest.isValid, isFalse);
    });

    test('5. Manifest rejects non-HTTP/HTTPS URLs', () {
      final badUrl = ModelManifest.defaultManifest.toJson();
      badUrl['download_url'] = 'ftp://ftp.example.com/model.gguf';

      final manifest = ModelManifest.fromJson(badUrl);
      expect(manifest.isValid, isFalse);
    });

    test('6. Manifest JSON serialization roundtrip preserves all fields', () {
      final original = ModelManifest.defaultManifest;
      final json = original.toJson();
      final reconstructed = ModelManifest.fromJson(json);

      expect(reconstructed, equals(original));
      expect(reconstructed.isValid, isTrue);
    });
  });
}
