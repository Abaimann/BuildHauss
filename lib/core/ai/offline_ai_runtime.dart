import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:llama_flutter_android/llama_flutter_android.dart' as llama;

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

/// Concrete Android implementation using llama.cpp and Vulkan/ARM64 NEON via [llama.LlamaController].
class AndroidOfflineAiRuntime implements OfflineAiRuntime {
  llama.LlamaController? _controller;
  bool _isLoaded = false;
  String? _currentModelPath;

  @override
  Future<bool> isSupported() async {
    // Requires Android API 26+
    if (!kIsWeb && Platform.isAndroid) {
      return true;
    }
    return false;
  }

  @override
  Future<bool> isModelLoaded() async {
    if (!await isSupported() || _controller == null) return false;
    try {
      return await _controller!.isModelLoaded();
    } catch (_) {
      return _isLoaded;
    }
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

    _controller ??= llama.LlamaController();

    // Check GPU layers via Vulkan detection if available
    int? gpuLayers;
    try {
      final gpu = await _controller!.detectGpu();
      if (gpu.vulkanSupported && gpu.recommendedGpuLayers > 0) {
        gpuLayers = gpu.recommendedGpuLayers;
      }
    } catch (e) {
      debugPrint('GPU detection skipped or unsupported: $e');
    }

    await _controller!.loadModel(
      modelPath: modelPath,
      threads: threads,
      contextSize: contextSize,
      gpuLayers: gpuLayers,
    );

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
    if (_controller == null || !_isLoaded) {
      throw StateError('Model offline belum dimuat ke memori.');
    }

    final llamaMessages = messages
        .map((m) => llama.ChatMessage(role: m.role, content: m.content))
        .toList();

    return _controller!.generateChat(
      messages: llamaMessages,
      template: 'chatml',
      maxTokens: maxTokens,
      temperature: temperature,
    );
  }

  @override
  Stream<String> generate({
    required String prompt,
    int maxTokens = 512,
    double temperature = 0.7,
  }) {
    if (_controller == null || !_isLoaded) {
      throw StateError('Model offline belum dimuat ke memori.');
    }

    return _controller!.generate(
      prompt: prompt,
      maxTokens: maxTokens,
      temperature: temperature,
    );
  }

  @override
  Future<void> stop() async {
    if (_controller != null) {
      await _controller!.stop();
    }
  }

  @override
  Future<void> unload() async {
    if (_controller != null) {
      try {
        await _controller!.stop();
        await _controller!.dispose();
      } catch (_) {}
      _controller = null;
      _isLoaded = false;
      _currentModelPath = null;
    }
  }

  @override
  Future<void> dispose() async {
    await unload();
  }
}
