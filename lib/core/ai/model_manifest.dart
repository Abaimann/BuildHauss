import 'package:equatable/equatable.dart';

/// Specification for an on-device offline AI model.
///
/// Contains verified provenance metadata, checksums, and hardware requirements.
class ModelManifest extends Equatable {
  final String modelId;
  final String name;
  final String version;
  final String quantization;
  final String fileName;
  final String repository;
  final String downloadUrl;
  final int fileSizeBytes;
  final String sha256;
  final String license;
  final int minRamGb;
  final int minStorageMb;
  final int minAndroidApi;
  final String chatTemplate;
  final String description;

  const ModelManifest({
    required this.modelId,
    required this.name,
    required this.version,
    required this.quantization,
    required this.fileName,
    required this.repository,
    required this.downloadUrl,
    required this.fileSizeBytes,
    required this.sha256,
    required this.license,
    required this.minRamGb,
    required this.minStorageMb,
    required this.minAndroidApi,
    required this.chatTemplate,
    required this.description,
  });

  /// Default official candidate model for BuildHaus: Qwen3 0.6B quantized at Q4_K_M.
  ///
  /// Provenance:
  /// - Base Architecture: Qwen3 dense 0.6B multilingual language model
  /// - Quantization: 4-bit medium (Q4_K_M) via llama.cpp
  /// - Host: Hugging Face official repository (unsloth/Qwen3-0.6B-GGUF)
  /// - License: Apache 2.0
  /// - Exact LFS OID / SHA-256 verified from repository metadata
  static const ModelManifest defaultManifest = ModelManifest(
    modelId: 'qwen3-0.6b-q4_k_m',
    name: 'Qwen3-0.6B-GGUF',
    version: '1.0.0',
    quantization: 'Q4_K_M',
    fileName: 'Qwen3-0.6B-Q4_K_M.gguf',
    repository: 'unsloth/Qwen3-0.6B-GGUF',
    downloadUrl:
        'https://huggingface.co/unsloth/Qwen3-0.6B-GGUF/resolve/main/Qwen3-0.6B-Q4_K_M.gguf',
    fileSizeBytes: 396705472, // ~378.3 MB
    sha256: 'ac2d97712095a558e31573f62f466a3f9d93990898b0ec79d7c974c1780d524a',
    license: 'Apache 2.0',
    minRamGb: 2,
    minStorageMb: 500,
    minAndroidApi: 26,
    chatTemplate: 'chatml',
    description:
        'Model on-device ringan untuk pemahaman keluhan sepeda motor '
        'dan estimasi komponen yang perlu diperiksa secara offline.',
  );

  /// Validates whether this manifest contains all required non-empty fields,
  /// a positive file size, a valid HTTP/HTTPS URL, and a 64-character hex SHA-256 checksum.
  bool get isValid {
    if (modelId.trim().isEmpty) return false;
    if (name.trim().isEmpty) return false;
    if (version.trim().isEmpty) return false;
    if (quantization.trim().isEmpty) return false;
    if (fileName.trim().isEmpty || !fileName.endsWith('.gguf')) return false;
    if (fileSizeBytes <= 0) return false;
    if (minRamGb <= 0 || minStorageMb <= 0 || minAndroidApi <= 0) return false;

    // Validate URL scheme
    final uri = Uri.tryParse(downloadUrl);
    if (uri == null || (!uri.isScheme('http') && !uri.isScheme('https'))) {
      return false;
    }

    // Validate SHA-256: exactly 64 lowercase/uppercase hex characters
    final shaRegex = RegExp(r'^[a-fA-F0-9]{64}$');
    if (!shaRegex.hasMatch(sha256.trim())) return false;

    return true;
  }

  /// Formats the file size into human-readable string (e.g. 378.3 MB).
  String get formattedSize {
    final mb = fileSizeBytes / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }

  Map<String, dynamic> toJson() => {
    'model_id': modelId,
    'name': name,
    'version': version,
    'quantization': quantization,
    'file_name': fileName,
    'repository': repository,
    'download_url': downloadUrl,
    'file_size_bytes': fileSizeBytes,
    'sha256': sha256,
    'license': license,
    'min_ram_gb': minRamGb,
    'min_storage_mb': minStorageMb,
    'min_android_api': minAndroidApi,
    'chat_template': chatTemplate,
    'description': description,
  };

  factory ModelManifest.fromJson(Map<String, dynamic> json) {
    return ModelManifest(
      modelId: json['model_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      version: json['version'] as String? ?? '',
      quantization: json['quantization'] as String? ?? '',
      fileName: json['file_name'] as String? ?? '',
      repository: json['repository'] as String? ?? '',
      downloadUrl: json['download_url'] as String? ?? '',
      fileSizeBytes: (json['file_size_bytes'] as num?)?.toInt() ?? 0,
      sha256: json['sha256'] as String? ?? '',
      license: json['license'] as String? ?? '',
      minRamGb: (json['min_ram_gb'] as num?)?.toInt() ?? 2,
      minStorageMb: (json['min_storage_mb'] as num?)?.toInt() ?? 500,
      minAndroidApi: (json['min_android_api'] as num?)?.toInt() ?? 26,
      chatTemplate: json['chat_template'] as String? ?? 'chatml',
      description: json['description'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [
    modelId,
    name,
    version,
    quantization,
    fileName,
    repository,
    downloadUrl,
    fileSizeBytes,
    sha256,
    license,
    minRamGb,
    minStorageMb,
    minAndroidApi,
    chatTemplate,
  ];
}
