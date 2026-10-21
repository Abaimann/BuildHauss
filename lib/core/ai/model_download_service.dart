import 'dart:async';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../database/app_database.dart';
import 'model_manifest.dart';

/// Status of the model download lifecycle.
enum DownloadStatus { idle, downloading, paused, verifying, completed, failed }

/// Progress state emitted during model download, verification, and installation.
class ModelDownloadState {
  final DownloadStatus status;
  final int bytesDownloaded;
  final int totalBytes;
  final double progressRatio;
  final String? errorMessage;
  final String? localPath;
  final ModelManifest manifest;

  const ModelDownloadState({
    required this.status,
    required this.bytesDownloaded,
    required this.totalBytes,
    required this.progressRatio,
    this.errorMessage,
    this.localPath,
    required this.manifest,
  });

  factory ModelDownloadState.initial(ModelManifest manifest) {
    return ModelDownloadState(
      status: DownloadStatus.idle,
      bytesDownloaded: 0,
      totalBytes: manifest.fileSizeBytes,
      progressRatio: 0.0,
      manifest: manifest,
    );
  }

  ModelDownloadState copyWith({
    DownloadStatus? status,
    int? bytesDownloaded,
    int? totalBytes,
    double? progressRatio,
    String? errorMessage,
    String? localPath,
    ModelManifest? manifest,
  }) {
    return ModelDownloadState(
      status: status ?? this.status,
      bytesDownloaded: bytesDownloaded ?? this.bytesDownloaded,
      totalBytes: totalBytes ?? this.totalBytes,
      progressRatio: progressRatio ?? this.progressRatio,
      errorMessage: errorMessage,
      localPath: localPath ?? this.localPath,
      manifest: manifest ?? this.manifest,
    );
  }
}

/// Service that manages real HTTP GGUF model downloading, HTTP Range resume,
/// SHA-256 verification, atomic installation, and persistence in SQLite.
class ModelDownloadService {
  final AppDatabase _db;
  final Dio _dio;
  final ModelManifest _manifest;
  final Directory? _baseDirectory;

  CancelToken? _cancelToken;
  final _stateController = StreamController<ModelDownloadState>.broadcast();
  late ModelDownloadState _currentState;

  ModelDownloadService({
    required AppDatabase db,
    Dio? dio,
    ModelManifest manifest = ModelManifest.defaultManifest,
    Directory? baseDirectory,
  }) : _db = db,
       _dio =
           dio ??
           Dio(
             BaseOptions(
               connectTimeout: const Duration(seconds: 30),
               receiveTimeout: const Duration(minutes: 60),
               sendTimeout: const Duration(seconds: 30),
             ),
           ),
       _manifest = manifest,
       _baseDirectory = baseDirectory {
    _currentState = ModelDownloadState.initial(_manifest);
  }

  Stream<ModelDownloadState> get stateStream => _stateController.stream;
  ModelDownloadState get currentState => _currentState;

  void _emit(ModelDownloadState state) {
    _currentState = state;
    if (!_stateController.isClosed) {
      _stateController.add(state);
    }
  }

  /// Returns the private application directory for storing AI models.
  Future<Directory> getModelDirectory() async {
    if (_baseDirectory != null) {
      final modelDir = Directory(p.join(_baseDirectory.path, 'ai_models'));
      if (!await modelDir.exists()) {
        await modelDir.create(recursive: true);
      }
      return modelDir;
    }
    final appDir = await getApplicationDocumentsDirectory();
    final modelDir = Directory(p.join(appDir.path, 'ai_models'));
    if (!await modelDir.exists()) {
      await modelDir.create(recursive: true);
    }
    return modelDir;
  }

  /// Returns the target destination path of the installed GGUF model.
  Future<File> getModelFile() async {
    final dir = await getModelDirectory();
    return File(p.join(dir.path, _manifest.fileName));
  }

  /// Returns the temporary partial file used while downloading.
  Future<File> getPartialFile() async {
    final dir = await getModelDirectory();
    return File(p.join(dir.path, '${_manifest.fileName}.part'));
  }

  /// Initializes status from SQLite database and local disk state.
  Future<ModelDownloadState> checkCurrentStatus() async {
    final targetFile = await getModelFile();
    final installed = await _db.getInstalledModel();

    if (installed != null && await targetFile.exists()) {
      final size = await targetFile.length();
      _emit(
        _currentState.copyWith(
          status: DownloadStatus.completed,
          bytesDownloaded: size,
          totalBytes: size,
          progressRatio: 1.0,
          localPath: targetFile.path,
        ),
      );
      return _currentState;
    }

    final partFile = await getPartialFile();
    if (await partFile.exists()) {
      final partSize = await partFile.length();
      final ratio = _manifest.fileSizeBytes > 0
          ? (partSize / _manifest.fileSizeBytes).clamp(0.0, 1.0)
          : 0.0;
      _emit(
        _currentState.copyWith(
          status: DownloadStatus.paused,
          bytesDownloaded: partSize,
          totalBytes: _manifest.fileSizeBytes,
          progressRatio: ratio,
        ),
      );
      return _currentState;
    }

    _emit(ModelDownloadState.initial(_manifest));
    return _currentState;
  }

  /// Starts or resumes downloading the model file from Hugging Face with HTTP Range support.
  Future<void> startDownload() async {
    if (_currentState.status == DownloadStatus.downloading ||
        _currentState.status == DownloadStatus.verifying) {
      return;
    }

    if (!_manifest.isValid) {
      final err =
          'Manifest model tidak valid: periksa URL, ukuran, dan SHA-256.';
      _emit(
        _currentState.copyWith(
          status: DownloadStatus.failed,
          errorMessage: err,
        ),
      );
      throw StateError(err);
    }

    _cancelToken = CancelToken();

    final targetFile = await getModelFile();
    final partFile = await getPartialFile();

    // If final file already exists and matches expected size, verify it
    if (await targetFile.exists()) {
      final size = await targetFile.length();
      if (size == _manifest.fileSizeBytes) {
        await _verifyAndFinalize(targetFile);
        return;
      }
    }

    int existingBytes = 0;
    if (await partFile.exists()) {
      existingBytes = await partFile.length();
      if (existingBytes > _manifest.fileSizeBytes) {
        // File corrupted or oversized: delete and start fresh
        await partFile.delete();
        existingBytes = 0;
      }
    }

    _emit(
      _currentState.copyWith(
        status: DownloadStatus.downloading,
        bytesDownloaded: existingBytes,
        totalBytes: _manifest.fileSizeBytes,
        progressRatio: _manifest.fileSizeBytes > 0
            ? existingBytes / _manifest.fileSizeBytes
            : 0.0,
      ),
    );

    // Save pending record to SQLite
    final pendingModel = await _db.getPendingModel();
    int installRecordId;
    if (pendingModel != null) {
      installRecordId = pendingModel.id;
      await _db.updateAiModelInstall(
        AiModelInstallsCompanion(
          downloadStatus: const Value('downloading'),
          fileSizeBytes: Value(_manifest.fileSizeBytes),
          lastError: const Value(null),
        ),
        installRecordId,
      );
    } else {
      installRecordId = await _db.insertAiModelInstall(
        AiModelInstallsCompanion(
          modelName: Value(_manifest.name),
          version: Value(_manifest.version),
          filePath: Value(targetFile.path),
          sha256: Value(_manifest.sha256),
          fileSizeBytes: Value(_manifest.fileSizeBytes),
          downloadStatus: const Value('downloading'),
          sourceUrl: Value(_manifest.downloadUrl),
        ),
      );
    }

    IOSink? sink;
    try {
      final headers = <String, dynamic>{};
      if (existingBytes > 0) {
        headers['Range'] = 'bytes=$existingBytes-';
      }

      final response = await _dio.get<ResponseBody>(
        _manifest.downloadUrl,
        options: Options(
          responseType: ResponseType.stream,
          headers: headers,
          validateStatus: (status) =>
              status != null && (status >= 200 && status < 300),
        ),
        cancelToken: _cancelToken,
      );

      final statusCode = response.statusCode ?? 200;
      final bool isRangeAccepted = statusCode == 206;

      if (existingBytes > 0 && !isRangeAccepted) {
        // Server ignored Range header and sent full content from 0; reset file
        sink = partFile.openWrite(mode: FileMode.write);
        existingBytes = 0;
      } else {
        sink = partFile.openWrite(
          mode: existingBytes > 0 ? FileMode.append : FileMode.write,
        );
      }

      int totalReceived = existingBytes;

      await for (final chunk in response.data!.stream) {
        sink.add(chunk);
        totalReceived += chunk.length;

        final ratio = _manifest.fileSizeBytes > 0
            ? (totalReceived / _manifest.fileSizeBytes).clamp(0.0, 1.0)
            : 0.0;

        _emit(
          _currentState.copyWith(
            status: DownloadStatus.downloading,
            bytesDownloaded: totalReceived,
            totalBytes: _manifest.fileSizeBytes,
            progressRatio: ratio,
          ),
        );
      }

      await sink.flush();
      await sink.close();
      sink = null;

      // Verification step
      await _verifyAndFinalize(partFile, installRecordId: installRecordId);
    } catch (e) {
      if (sink != null) {
        await sink.flush();
        await sink.close();
      }

      if (e is DioException && CancelToken.isCancel(e)) {
        // Paused or cancelled
        await _db.updateAiModelInstall(
          AiModelInstallsCompanion(
            downloadStatus: const Value('paused'),
            lastError: const Value('Download dijeda oleh pengguna'),
          ),
          installRecordId,
        );
        _emit(_currentState.copyWith(status: DownloadStatus.paused));
        return;
      }

      final errorMsg = 'Download gagal: ${e.toString()}';
      await _db.updateAiModelInstall(
        AiModelInstallsCompanion(
          downloadStatus: const Value('failed'),
          lastError: Value(errorMsg),
        ),
        installRecordId,
      );

      _emit(
        _currentState.copyWith(
          status: DownloadStatus.failed,
          errorMessage: errorMsg,
        ),
      );
      rethrow;
    }
  }

  /// Verifies SHA-256 hash of [sourceFile] and moves it atomically to final destination.
  Future<void> _verifyAndFinalize(
    File sourceFile, {
    int? installRecordId,
  }) async {
    _emit(
      _currentState.copyWith(
        status: DownloadStatus.verifying,
        progressRatio: 1.0,
      ),
    );

    final targetFile = await getModelFile();

    // Verify SHA-256
    final calculatedSha = await calculateSha256(sourceFile);
    final expectedSha = _manifest.sha256.trim().toLowerCase();

    if (calculatedSha.toLowerCase() != expectedSha) {
      // Hash mismatch! Remove corrupted source file
      if (await sourceFile.exists()) {
        await sourceFile.delete();
      }

      final errorMsg =
          'Verifikasi SHA-256 GAGAL: Model rusak atau tidak valid.\n'
          'Harapan: $expectedSha\n'
          'Aktual: $calculatedSha';

      if (installRecordId != null) {
        await _db.updateAiModelInstall(
          AiModelInstallsCompanion(
            downloadStatus: const Value('failed'),
            lastError: Value(errorMsg),
          ),
          installRecordId,
        );
      }

      _emit(
        _currentState.copyWith(
          status: DownloadStatus.failed,
          errorMessage: errorMsg,
        ),
      );
      throw StateError(errorMsg);
    }

    // Hash is valid! Atomic rename to target file
    if (sourceFile.path != targetFile.path) {
      if (await targetFile.exists()) {
        await targetFile.delete();
      }
      await sourceFile.rename(targetFile.path);
    }

    final finalSize = await targetFile.length();

    // Update database record to completed
    final recordId = installRecordId ?? (await _db.getPendingModel())?.id;
    if (recordId != null) {
      await _db.updateAiModelInstall(
        AiModelInstallsCompanion(
          downloadStatus: const Value('completed'),
          fileSizeBytes: Value(finalSize),
          installedAt: Value(DateTime.now()),
          lastError: const Value(null),
        ),
        recordId,
      );
    } else {
      await _db.insertAiModelInstall(
        AiModelInstallsCompanion(
          modelName: Value(_manifest.name),
          version: Value(_manifest.version),
          filePath: Value(targetFile.path),
          sha256: Value(_manifest.sha256),
          fileSizeBytes: Value(finalSize),
          downloadStatus: const Value('completed'),
          installedAt: Value(DateTime.now()),
          sourceUrl: Value(_manifest.downloadUrl),
        ),
      );
    }

    _emit(
      _currentState.copyWith(
        status: DownloadStatus.completed,
        bytesDownloaded: finalSize,
        totalBytes: finalSize,
        progressRatio: 1.0,
        localPath: targetFile.path,
        errorMessage: null,
      ),
    );
  }

  /// Calculates SHA-256 checksum for the provided [file] using chunked streaming.
  static Future<String> calculateSha256(File file) async {
    final digest = await sha256.bind(file.openRead()).first;
    return digest.toString();
  }

  /// Pauses the download without deleting partial progress.
  void pauseDownload() {
    if (_cancelToken != null && !_cancelToken!.isCancelled) {
      _cancelToken!.cancel('User paused download');
    }
    _emit(_currentState.copyWith(status: DownloadStatus.paused));
  }

  /// Cancels the download and removes partial files.
  Future<void> cancelDownload() async {
    if (_cancelToken != null && !_cancelToken!.isCancelled) {
      _cancelToken!.cancel('User cancelled download');
    }

    final partFile = await getPartialFile();
    if (await partFile.exists()) {
      await partFile.delete();
    }

    final pending = await _db.getPendingModel();
    if (pending != null) {
      await _db.updateAiModelInstall(
        AiModelInstallsCompanion(
          downloadStatus: const Value('failed'),
          lastError: const Value('Dibatalkan oleh pengguna'),
        ),
        pending.id,
      );
    }

    _emit(
      ModelDownloadState.initial(
        _manifest,
      ).copyWith(status: DownloadStatus.idle),
    );
  }

  /// Deletes the local model file and clears the install record from SQLite.
  Future<void> deleteModel() async {
    final targetFile = await getModelFile();
    if (await targetFile.exists()) {
      await targetFile.delete();
    }

    final partFile = await getPartialFile();
    if (await partFile.exists()) {
      await partFile.delete();
    }

    // Delete record from ai_model_installs
    await (_db.delete(
      _db.aiModelInstalls,
    )..where((t) => t.modelName.equals(_manifest.name))).go();

    _emit(ModelDownloadState.initial(_manifest));
  }

  void dispose() {
    _stateController.close();
  }
}
