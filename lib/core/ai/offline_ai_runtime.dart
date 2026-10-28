import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// Generic message representation for chat generation.
class RuntimeChatMessage {
  final String role; // 'system', 'user', 'assistant'
  final String content;

  const RuntimeChatMessage({required this.role, required this.content});

  Map<String, dynamic> toJson() => {'role': role, 'content': content};
}

/// Abstract contract for offline LLM runtimes.
abstract class OfflineAiRuntime {
  Future<bool> isSupported();
  Future<bool> isModelLoaded();
  Future<void> loadModel({
    required String modelPath,
    int threads = 4,
    int contextSize = 2048,
  });
  Stream<String> generateChat({
    required List<RuntimeChatMessage> messages,
    int maxTokens = 512,
    double temperature = 0.7,
  });
  Stream<String> generate({
    required String prompt,
    int maxTokens = 512,
    double temperature = 0.7,
  });
  Future<void> stop();
  Future<void> unload();
  Future<void> dispose();
}

/// Lightweight fallback implementation of [OfflineAiRuntime] without native C++ bindings.
class AndroidOfflineAiRuntime implements OfflineAiRuntime {
  bool _isLoaded = false;
  String? _currentModelPath;

  @override
  Future<bool> isSupported() async {
    if (!kIsWeb && Platform.isAndroid) {
      return true;
    }
    return false;
  }

  @override
  Future<bool> isModelLoaded() async {
    if (!await isSupported()) return false;
    return _isLoaded;
  }

  @override
  Future<void> loadModel({
    required String modelPath,
    int threads = 4,
    int contextSize = 2048,
  }) async {
    final file = File(modelPath);
    if (!await file.exists()) {
      throw FileSystemException('File model GGUF tidak ditemukan', modelPath);
    }

    if (!await isSupported()) {
      throw UnsupportedError(
        'Offline AI runtime hanya didukung pada perangkat Android',
      );
    }

    _isLoaded = true;
    _currentModelPath = modelPath;
  }

  /// Path to the currently loaded model, if any.
  String? get currentModelPath => _currentModelPath;

  @override
  Stream<String> generateChat({
    required List<RuntimeChatMessage> messages,
    int maxTokens = 512,
    double temperature = 0.7,
  }) {
    if (!_isLoaded) {
      throw StateError('Model offline belum dimuat ke memori.');
    }
    return const Stream.empty();
  }

  @override
  Stream<String> generate({
    required String prompt,
    int maxTokens = 512,
    double temperature = 0.7,
  }) {
    if (!_isLoaded) {
      throw StateError('Model offline belum dimuat ke memori.');
    }
    return const Stream.empty();
  }

  @override
  Future<void> stop() async {}

  @override
  Future<void> unload() async {
    _isLoaded = false;
    _currentModelPath = null;
  }

  @override
  Future<void> dispose() async {
    await unload();
  }
}
