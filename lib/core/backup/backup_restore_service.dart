import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:cryptography/cryptography.dart' as crypto_pkg;
import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../database/app_database.dart';

/// Preview information extracted from a backup file before performing restore.
class BackupPreviewInfo {
  final String appName;
  final String appVersion;
  final int schemaVersion;
  final DateTime createdAt;
  final bool isEncrypted;
  final int motorcyclesCount;
  final int odometerLogsCount;
  final int serviceRecordsCount;
  final int complaintsCount;
  final int budgetPlansCount;
  final int remindersCount;

  const BackupPreviewInfo({
    required this.appName,
    required this.appVersion,
    required this.schemaVersion,
    required this.createdAt,
    required this.isEncrypted,
    required this.motorcyclesCount,
    required this.odometerLogsCount,
    required this.serviceRecordsCount,
    required this.complaintsCount,
    required this.budgetPlansCount,
    required this.remindersCount,
  });
}

/// Service handling offline backup generation and atomic restoration for BuildHaus.
class BackupRestoreService {
  final AppDatabase _db;
  final Directory? _customBackupDir;

  static const String appIdentifier = 'BuildHaus';
  static const int currentBackupFormatVersion =
      2; // v2: AES-256-GCM + PBKDF2-SHA256 (100k iter)
  static const int currentSchemaVersion = 4;

  BackupRestoreService({required AppDatabase db, Directory? customBackupDir})
    : _db = db,
      _customBackupDir = customBackupDir;

  /// Returns the target directory for storing BuildHaus backup files.
  Future<Directory> getBackupDirectory() async {
    final customDir = _customBackupDir;
    if (customDir != null) {
      if (!await customDir.exists()) {
        await customDir.create(recursive: true);
      }
      return customDir;
    }

    final docDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory(p.join(docDir.path, 'backups'));
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir;
  }

  /// Lists all `.bhb` (BuildHaus Backup) files in the backup directory, sorted by newest first.
  Future<List<File>> listBackupFiles() async {
    final dir = await getBackupDirectory();
    if (!await dir.exists()) return [];

    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.bhb'))
        .toList();

    files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
    return files;
  }

  /// Exports all user data into a `.bhb` file.
  /// If [passphrase] is provided, data is encrypted using authenticated PBKDF2 + HMAC.
  Future<File> createBackup({String? passphrase}) async {
    final now = DateTime.now();
    final timestampStr =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_'
        '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';

    // 1. Gather all user records from SQLite database
    final motors = await _db.getAllMotorcycles();
    final odoLogs = await _db.select(_db.odometerLogs).get();
    final compStatuses = await _db.select(_db.componentStatuses).get();
    final services = await _db.select(_db.serviceRecords).get();
    final serviceItems = await _db.select(_db.serviceItems).get();
    final inspections = await _db.select(_db.selfInspections).get();
    final inspectionAnswers = await _db.select(_db.inspectionAnswers).get();
    final complaints = await _db.select(_db.complaints).get();
    final complaintMessages = await _db.select(_db.complaintMessages).get();
    final complaintAnalyses = await _db.select(_db.complaintAnalyses).get();
    final budgetPlans = await _db.select(_db.budgetPlans).get();
    final serviceRecs = await _db.select(_db.serviceRecommendations).get();
    final recItems = await _db.select(_db.recommendationItems).get();
    final reminders = await _db.select(_db.localReminders).get();
    final settings = await _db.getAllSettings();

    // 2. Build structured payload
    final dataMap = <String, dynamic>{
      'motorcycles': motors
          .map(
            (m) => {
              'id': m.id,
              'model_id': m.modelId,
              'nickname': m.nickname,
              'manufacture_year': m.manufactureYear,
              'plate_number': m.plateNumber,
              'emoji': m.emoji,
              'usage_profile': m.usageProfile,
              'is_primary': m.isPrimary,
              'created_at': m.createdAt.toIso8601String(),
              'updated_at': m.updatedAt.toIso8601String(),
            },
          )
          .toList(),
      'odometer_logs': odoLogs
          .map(
            (o) => {
              'id': o.id,
              'motorcycle_id': o.motorcycleId,
              'odometer_km': o.odometerKm,
              'recorded_at': o.recordedAt.toIso8601String(),
              'source': o.source,
              'note': o.note,
            },
          )
          .toList(),
      'component_statuses': compStatuses
          .map(
            (c) => {
              'id': c.id,
              'motorcycle_id': c.motorcycleId,
              'component_type_id': c.componentTypeId,
              'estimated_status': c.estimatedStatus,
              'score': c.score,
              'explanation': c.explanation,
              'confidence': c.confidence,
              'calculated_at': c.calculatedAt.toIso8601String(),
              'rule_version': c.ruleVersion,
            },
          )
          .toList(),
      'service_records': services
          .map(
            (s) => {
              'id': s.id,
              'motorcycle_id': s.motorcycleId,
              'serviced_at': s.servicedAt.toIso8601String(),
              'odometer_km': s.odometerKm,
              'workshop_name': s.workshopName,
              'notes': s.notes,
              'total_cost': s.totalCost,
              'created_at': s.createdAt.toIso8601String(),
            },
          )
          .toList(),
      'service_items': serviceItems
          .map(
            (i) => {
              'id': i.id,
              'service_record_id': i.serviceRecordId,
              'component_type_id': i.componentTypeId,
              'sparepart_id': i.sparepartId,
              'action': i.action,
              'parts_cost': i.partsCost,
              'labor_cost': i.laborCost,
              'total_cost': i.totalCost,
              'notes': i.notes,
            },
          )
          .toList(),
      'self_inspections': inspections
          .map(
            (ins) => {
              'id': ins.id,
              'motorcycle_id': ins.motorcycleId,
              'inspected_at': ins.inspectedAt.toIso8601String(),
              'notes': ins.notes,
              'risk_level': ins.riskLevel,
              'status': ins.status,
            },
          )
          .toList(),
      'inspection_answers': inspectionAnswers
          .map(
            (a) => {
              'id': a.id,
              'inspection_id': a.inspectionId,
              'question_code': a.questionCode,
              'answer': a.answer,
              'answer_type': a.answerType,
              'risk_flag': a.riskFlag,
            },
          )
          .toList(),
      'complaints': complaints
          .map(
            (c) => {
              'id': c.id,
              'motorcycle_id': c.motorcycleId,
              'inspection_id': c.inspectionId,
              'resolved_by_service_id': c.resolvedByServiceId,
              'title': c.title,
              'description': c.description,
              'status': c.status,
              'opened_at': c.openedAt.toIso8601String(),
              'closed_at': c.closedAt?.toIso8601String(),
              'odometer_km': c.odometerKm,
              'updated_at': c.updatedAt.toIso8601String(),
            },
          )
          .toList(),
      'complaint_messages': complaintMessages
          .map(
            (m) => {
              'id': m.id,
              'complaint_id': m.complaintId,
              'role': m.role,
              'content': m.content,
              'created_at': m.createdAt.toIso8601String(),
              'analysis_mode': m.analysisMode,
            },
          )
          .toList(),
      'complaint_analyses': complaintAnalyses
          .map(
            (a) => {
              'id': a.id,
              'complaint_id': a.complaintId,
              'symptoms_json': a.symptomsJson,
              'component_candidates_json': a.componentCandidatesJson,
              'follow_up_json': a.followUpJson,
              'historical_matches_json': a.historicalMatchesJson,
              'risk_level': a.riskLevel,
              'summary': a.summary,
              'model_version': a.modelVersion,
              'analysis_mode': a.analysisMode,
              'analyzed_at': a.analyzedAt.toIso8601String(),
            },
          )
          .toList(),
      'budget_plans': budgetPlans
          .map(
            (b) => {
              'id': b.id,
              'motorcycle_id': b.motorcycleId,
              'budget_amount': b.budgetAmount,
              'period': b.period,
              'created_at': b.createdAt.toIso8601String(),
              'notes': b.notes,
            },
          )
          .toList(),
      'service_recommendations': serviceRecs
          .map(
            (r) => {
              'id': r.id,
              'budget_plan_id': r.budgetPlanId,
              'estimated_total': r.estimatedTotal,
              'rule_version': r.ruleVersion,
              'generated_at': r.generatedAt.toIso8601String(),
              'data_freshness': r.dataFreshness,
              'explanation': r.explanation,
            },
          )
          .toList(),
      'recommendation_items': recItems
          .map(
            (ri) => {
              'id': ri.id,
              'recommendation_id': ri.recommendationId,
              'component_type_id': ri.componentTypeId,
              'sparepart_id': ri.sparepartId,
              'priority': ri.priority,
              'decision': ri.decision,
              'estimated_cost': ri.estimatedCost,
              'estimated_labor_cost': ri.estimatedLaborCost,
              'reason': ri.reason,
              'consequence_if_delayed': ri.consequenceIfDelayed,
              'requires_inspection': ri.requiresInspection,
            },
          )
          .toList(),
      'local_reminders': reminders
          .map(
            (rem) => {
              'id': rem.id,
              'motorcycle_id': rem.motorcycleId,
              'component_type_id': rem.componentTypeId,
              'reminder_type': rem.reminderType,
              'due_odometer_km': rem.dueOdometerKm,
              'due_date': rem.dueDate?.toIso8601String(),
              'enabled': rem.enabled,
              'last_scheduled_at': rem.lastScheduledAt?.toIso8601String(),
              'notification_id': rem.notificationId,
            },
          )
          .toList(),
      'app_settings': settings,
    };

    final rawJsonPayload = jsonEncode(dataMap);
    final payloadBytes = utf8.encode(rawJsonPayload);
    final checksum = sha256.convert(payloadBytes).toString();

    // 3. Build top-level envelope
    final envelope = <String, dynamic>{
      'app': appIdentifier,
      'app_version': '1.0.0',
      'format_version': currentBackupFormatVersion,
      'schema_version': currentSchemaVersion,
      'created_at': now.toIso8601String(),
      'checksum_sha256': checksum,
      'is_encrypted': passphrase != null && passphrase.trim().isNotEmpty,
      'summary': {
        'motorcycles_count': motors.length,
        'odometer_logs_count': odoLogs.length,
        'service_records_count': services.length,
        'complaints_count': complaints.length,
        'budget_plans_count': budgetPlans.length,
        'reminders_count': reminders.length,
      },
    };

    if (passphrase != null && passphrase.trim().isNotEmpty) {
      // Authenticated AES-256-GCM encryption with PBKDF2-HMAC-SHA256 (100,000 iterations)
      final saltBytes = _generateRandomBytes(16);
      final pbkdf2 = crypto_pkg.Pbkdf2(
        macAlgorithm: crypto_pkg.Hmac.sha256(),
        iterations: 100000,
        bits: 256,
      );
      final secretKey = await pbkdf2.deriveKey(
        secretKey: crypto_pkg.SecretKey(utf8.encode(passphrase.trim())),
        nonce: saltBytes,
      );

      final aesGcm = crypto_pkg.AesGcm.with256bits();
      final nonce = aesGcm.newNonce();

      final secretBox = await aesGcm.encrypt(
        payloadBytes,
        secretKey: secretKey,
        nonce: nonce,
      );

      envelope['algorithm'] = 'AES-256-GCM';
      envelope['kdf'] = 'PBKDF2-HMAC-SHA256';
      envelope['kdf_iterations'] = 100000;
      envelope['salt'] = base64Encode(saltBytes);
      envelope['nonce'] = base64Encode(secretBox.nonce);
      envelope['auth_tag'] = base64Encode(secretBox.mac.bytes);
      envelope['payload'] = base64Encode(secretBox.cipherText);
    } else {
      // Unencrypted payload
      envelope['data'] = dataMap;
    }

    final backupDir = await getBackupDirectory();
    final fileName = 'buildhaus_backup_$timestampStr.bhb';
    final targetFile = File(p.join(backupDir.path, fileName));

    await targetFile.writeAsString(
      const JsonEncoder.withIndent('  ').convert(envelope),
    );

    // Record last backup timestamp in SQLite settings
    await _db.setSetting('backup_last_at', now.toIso8601String());

    return targetFile;
  }

  /// Inspects a backup file and returns its preview metadata without restoring or altering the database.
  Future<BackupPreviewInfo> inspectBackupFile(
    File file, {
    String? passphrase,
  }) async {
    if (!await file.exists()) {
      throw FileSystemException('File backup tidak ditemukan.', file.path);
    }

    final content = await file.readAsString();
    final Map<String, dynamic> envelope = jsonDecode(content);

    final app = envelope['app'] as String?;
    if (app != appIdentifier) {
      throw const FormatException('Format file bukan backup resmi BuildHaus.');
    }

    final schemaVersion = envelope['schema_version'] as int? ?? 1;
    if (schemaVersion > currentSchemaVersion) {
      throw FormatException(
        'Versi schema backup ($schemaVersion) lebih baru daripada versi yang didukung aplikasi ($currentSchemaVersion).',
      );
    }

    final isEncrypted = envelope['is_encrypted'] as bool? ?? false;
    final summary = envelope['summary'] as Map<String, dynamic>? ?? {};

    return BackupPreviewInfo(
      appName: app ?? appIdentifier,
      appVersion: envelope['app_version'] as String? ?? '1.0.0',
      schemaVersion: schemaVersion,
      createdAt:
          DateTime.tryParse(envelope['created_at'] as String? ?? '') ??
          DateTime.now(),
      isEncrypted: isEncrypted,
      motorcyclesCount: summary['motorcycles_count'] as int? ?? 0,
      odometerLogsCount: summary['odometer_logs_count'] as int? ?? 0,
      serviceRecordsCount: summary['service_records_count'] as int? ?? 0,
      complaintsCount: summary['complaints_count'] as int? ?? 0,
      budgetPlansCount: summary['budget_plans_count'] as int? ?? 0,
      remindersCount: summary['reminders_count'] as int? ?? 0,
    );
  }

  /// Restores all user data from a `.bhb` file in an atomic SQLite transaction.
  Future<void> restoreBackup(File file, {String? passphrase}) async {
    if (!await file.exists()) {
      throw FileSystemException('File backup tidak ditemukan.', file.path);
    }

    final content = await file.readAsString();
    final Map<String, dynamic> envelope = jsonDecode(content);

    if (envelope['app'] != appIdentifier) {
      throw const FormatException('File backup tidak valid untuk BuildHaus.');
    }

    final isEncrypted = envelope['is_encrypted'] as bool? ?? false;
    Map<String, dynamic> dataMap;

    if (isEncrypted) {
      if (passphrase == null || passphrase.trim().isEmpty) {
        throw const FormatException(
          'Backup ini terenkripsi. Masukkan kata sandi untuk memulihkan.',
        );
      }

      final formatVersion = envelope['format_version'] as int? ?? 1;
      final saltBase64 = envelope['salt'] as String?;
      final payloadBase64 = envelope['payload'] as String?;

      if (saltBase64 == null || payloadBase64 == null) {
        throw const FormatException('Metadata enkripsi backup tidak lengkap.');
      }

      final saltBytes = base64Decode(saltBase64);
      final encryptedPayload = base64Decode(payloadBase64);
      List<int> decryptedBytes;

      if (formatVersion >= 2) {
        // Format v2: NIST AES-256-GCM authenticated decryption
        final nonceBase64 = envelope['nonce'] as String?;
        final authTagBase64 = envelope['auth_tag'] as String?;
        if (nonceBase64 == null || authTagBase64 == null) {
          throw const FormatException(
            'Parameter AES-GCM nonce atau auth_tag hilang.',
          );
        }

        final nonce = base64Decode(nonceBase64);
        final macBytes = base64Decode(authTagBase64);
        final iterations = envelope['kdf_iterations'] as int? ?? 100000;

        final pbkdf2 = crypto_pkg.Pbkdf2(
          macAlgorithm: crypto_pkg.Hmac.sha256(),
          iterations: iterations,
          bits: 256,
        );
        final secretKey = await pbkdf2.deriveKey(
          secretKey: crypto_pkg.SecretKey(utf8.encode(passphrase.trim())),
          nonce: saltBytes,
        );

        final aesGcm = crypto_pkg.AesGcm.with256bits();
        try {
          decryptedBytes = await aesGcm.decrypt(
            crypto_pkg.SecretBox(
              encryptedPayload,
              nonce: nonce,
              mac: crypto_pkg.Mac(macBytes),
            ),
            secretKey: secretKey,
          );
        } on crypto_pkg.SecretBoxAuthenticationError {
          throw const FormatException('Kata sandi salah atau data rusak.');
        }
      } else {
        // Format v1: Legacy PBKDF2 HMAC-SHA256 + keystream for backward compatibility
        final authTag = envelope['auth_tag'] as String?;
        if (authTag == null) {
          throw const FormatException('Metadata auth_tag legacy v1 hilang.');
        }

        final key = _deriveKeyLegacy(passphrase.trim(), saltBytes);
        final calculatedTag = Hmac(
          sha256,
          key,
        ).convert(encryptedPayload).toString();

        if (calculatedTag != authTag) {
          throw const FormatException('Kata sandi salah atau data rusak.');
        }

        decryptedBytes = _xorCipher(encryptedPayload, key);
      }

      final expectedChecksum = envelope['checksum_sha256'] as String?;
      if (expectedChecksum != null) {
        final actualChecksum = sha256.convert(decryptedBytes).toString();
        if (actualChecksum != expectedChecksum) {
          throw const FormatException(
            'Checksum validasi data gagal setelah dekripsi.',
          );
        }
      }

      final jsonStr = utf8.decode(decryptedBytes);
      dataMap = jsonDecode(jsonStr);
    } else {
      final rawData = envelope['data'] as Map<String, dynamic>?;
      if (rawData == null) {
        throw const FormatException('Data payload backup kosong.');
      }

      final expectedChecksum = envelope['checksum_sha256'] as String?;
      if (expectedChecksum != null) {
        final actualChecksum = sha256
            .convert(utf8.encode(jsonEncode(rawData)))
            .toString();
        if (actualChecksum != expectedChecksum) {
          throw const FormatException('Checksum integritas data tidak cocok.');
        }
      }

      dataMap = rawData;
    }

    // Atomic SQLite restoration
    await _db.transaction(() async {
      // Step A: Wipe all existing user tables in reverse foreign key order
      await _db.delete(_db.recommendationItems).go();
      await _db.delete(_db.serviceRecommendations).go();
      await _db.delete(_db.budgetPlans).go();
      await _db.delete(_db.complaintAnalyses).go();
      await _db.delete(_db.complaintMessages).go();
      await _db.delete(_db.complaints).go();
      await _db.delete(_db.inspectionAnswers).go();
      await _db.delete(_db.selfInspections).go();
      await _db.delete(_db.serviceItems).go();
      await _db.delete(_db.serviceRecords).go();
      await _db.delete(_db.componentStatuses).go();
      await _db.delete(_db.odometerLogs).go();
      await _db.delete(_db.localReminders).go();
      await _db.delete(_db.motorcycles).go();

      // Step B: Insert records in topological order preserving original primary keys
      final motors = (dataMap['motorcycles'] as List? ?? [])
          .cast<Map<String, dynamic>>();
      for (final m in motors) {
        await _db
            .into(_db.motorcycles)
            .insert(
              MotorcyclesCompanion.insert(
                id: Value(m['id'] as int),
                modelId: Value(m['model_id'] as int?),
                nickname: m['nickname'] as String,
                manufactureYear: m['manufacture_year'] as int,
                plateNumber: Value(m['plate_number'] as String?),
                emoji: Value(m['emoji'] as String? ?? '🏍️'),
                usageProfile: Value(
                  m['usage_profile'] as String? ?? 'campuran',
                ),
                createdAt: Value(DateTime.parse(m['created_at'] as String)),
                updatedAt: Value(DateTime.parse(m['updated_at'] as String)),
                isPrimary: Value(m['is_primary'] as bool? ?? false),
              ),
            );
      }

      final odos = (dataMap['odometer_logs'] as List? ?? [])
          .cast<Map<String, dynamic>>();
      for (final o in odos) {
        await _db
            .into(_db.odometerLogs)
            .insert(
              OdometerLogsCompanion.insert(
                id: Value(o['id'] as int),
                motorcycleId: o['motorcycle_id'] as int,
                odometerKm: (o['odometer_km'] as num).toDouble(),
                recordedAt: DateTime.parse(o['recorded_at'] as String),
                source: Value(o['source'] as String? ?? 'manual'),
                note: Value(o['note'] as String?),
              ),
            );
      }

      final statuses = (dataMap['component_statuses'] as List? ?? [])
          .cast<Map<String, dynamic>>();
      for (final s in statuses) {
        await _db
            .into(_db.componentStatuses)
            .insert(
              ComponentStatusesCompanion.insert(
                id: Value(s['id'] as int),
                motorcycleId: s['motorcycle_id'] as int,
                componentTypeId: s['component_type_id'] as int,
                estimatedStatus: s['estimated_status'] as String,
                score: Value((s['score'] as num?)?.toDouble()),
                explanation: s['explanation'] as String? ?? '',
                confidence: Value((s['confidence'] as num?)?.toDouble()),
                calculatedAt: DateTime.parse(s['calculated_at'] as String),
                ruleVersion: s['rule_version'] as String? ?? 'v1',
              ),
            );
      }

      final services = (dataMap['service_records'] as List? ?? [])
          .cast<Map<String, dynamic>>();
      for (final s in services) {
        await _db
            .into(_db.serviceRecords)
            .insert(
              ServiceRecordsCompanion.insert(
                id: Value(s['id'] as int),
                motorcycleId: s['motorcycle_id'] as int,
                servicedAt: DateTime.parse(s['serviced_at'] as String),
                odometerKm: Value((s['odometer_km'] as num?)?.toDouble()),
                workshopName: Value(s['workshop_name'] as String?),
                notes: Value(s['notes'] as String?),
                totalCost: Value(s['total_cost'] as int? ?? 0),
                createdAt: Value(DateTime.parse(s['created_at'] as String)),
              ),
            );
      }

      final sItems = (dataMap['service_items'] as List? ?? [])
          .cast<Map<String, dynamic>>();
      for (final item in sItems) {
        await _db
            .into(_db.serviceItems)
            .insert(
              ServiceItemsCompanion.insert(
                id: Value(item['id'] as int),
                serviceRecordId: item['service_record_id'] as int,
                componentTypeId: Value(item['component_type_id'] as int?),
                sparepartId: Value(item['sparepart_id'] as int?),
                action: item['action'] as String,
                partsCost: Value(item['parts_cost'] as int? ?? 0),
                laborCost: Value(item['labor_cost'] as int? ?? 0),
                totalCost: Value(item['total_cost'] as int? ?? 0),
                notes: Value(item['notes'] as String?),
              ),
            );
      }

      final selfInsps = (dataMap['self_inspections'] as List? ?? [])
          .cast<Map<String, dynamic>>();
      for (final si in selfInsps) {
        await _db
            .into(_db.selfInspections)
            .insert(
              SelfInspectionsCompanion.insert(
                id: Value(si['id'] as int),
                motorcycleId: si['motorcycle_id'] as int,
                inspectedAt: Value(
                  DateTime.parse(si['inspected_at'] as String),
                ),
                notes: Value(si['notes'] as String?),
                riskLevel: Value(si['risk_level'] as String?),
                status: Value(si['status'] as String? ?? 'draft'),
              ),
            );
      }

      final answers = (dataMap['inspection_answers'] as List? ?? [])
          .cast<Map<String, dynamic>>();
      for (final a in answers) {
        await _db
            .into(_db.inspectionAnswers)
            .insert(
              InspectionAnswersCompanion.insert(
                id: Value(a['id'] as int),
                inspectionId: a['inspection_id'] as int,
                questionCode: a['question_code'] as String,
                answer: a['answer'] as String,
                answerType: Value(a['answer_type'] as String?),
                riskFlag: Value(a['risk_flag'] as bool? ?? false),
              ),
            );
      }

      final comps = (dataMap['complaints'] as List? ?? [])
          .cast<Map<String, dynamic>>();
      for (final c in comps) {
        await _db
            .into(_db.complaints)
            .insert(
              ComplaintsCompanion.insert(
                id: Value(c['id'] as int),
                motorcycleId: c['motorcycle_id'] as int,
                inspectionId: Value(c['inspection_id'] as int?),
                resolvedByServiceId: Value(c['resolved_by_service_id'] as int?),
                title: c['title'] as String,
                description: c['description'] as String,
                status: Value(c['status'] as String? ?? 'baru'),
                openedAt: Value(DateTime.parse(c['opened_at'] as String)),
                closedAt: Value(
                  c['closed_at'] != null
                      ? DateTime.parse(c['closed_at'] as String)
                      : null,
                ),
                odometerKm: Value((c['odometer_km'] as num?)?.toDouble()),
                updatedAt: Value(DateTime.parse(c['updated_at'] as String)),
              ),
            );
      }

      final compMsgs = (dataMap['complaint_messages'] as List? ?? [])
          .cast<Map<String, dynamic>>();
      for (final m in compMsgs) {
        await _db
            .into(_db.complaintMessages)
            .insert(
              ComplaintMessagesCompanion.insert(
                id: Value(m['id'] as int),
                complaintId: m['complaint_id'] as int,
                role: m['role'] as String,
                content: m['content'] as String,
                createdAt: Value(DateTime.parse(m['created_at'] as String)),
                analysisMode: Value(m['analysis_mode'] as String?),
              ),
            );
      }

      final compAnalyses = (dataMap['complaint_analyses'] as List? ?? [])
          .cast<Map<String, dynamic>>();
      for (final ca in compAnalyses) {
        await _db
            .into(_db.complaintAnalyses)
            .insert(
              ComplaintAnalysesCompanion.insert(
                id: Value(ca['id'] as int),
                complaintId: ca['complaint_id'] as int,
                symptomsJson: ca['symptoms_json'] as String,
                componentCandidatesJson: Value(
                  ca['component_candidates_json'] as String?,
                ),
                followUpJson: Value(ca['follow_up_json'] as String?),
                historicalMatchesJson: Value(
                  ca['historical_matches_json'] as String?,
                ),
                riskLevel: ca['risk_level'] as String,
                summary: ca['summary'] as String,
                modelVersion: Value(ca['model_version'] as String?),
                analysisMode: ca['analysis_mode'] as String,
                analyzedAt: Value(DateTime.parse(ca['analyzed_at'] as String)),
              ),
            );
      }

      final bPlans = (dataMap['budget_plans'] as List? ?? [])
          .cast<Map<String, dynamic>>();
      for (final bp in bPlans) {
        await _db
            .into(_db.budgetPlans)
            .insert(
              BudgetPlansCompanion.insert(
                id: Value(bp['id'] as int),
                motorcycleId: bp['motorcycle_id'] as int,
                budgetAmount: bp['budget_amount'] as int,
                period: Value(bp['period'] as String?),
                createdAt: Value(DateTime.parse(bp['created_at'] as String)),
                notes: Value(bp['notes'] as String?),
              ),
            );
      }

      final sRecs = (dataMap['service_recommendations'] as List? ?? [])
          .cast<Map<String, dynamic>>();
      for (final sr in sRecs) {
        await _db
            .into(_db.serviceRecommendations)
            .insert(
              ServiceRecommendationsCompanion.insert(
                id: Value(sr['id'] as int),
                budgetPlanId: sr['budget_plan_id'] as int,
                estimatedTotal: sr['estimated_total'] as int,
                ruleVersion: sr['rule_version'] as String,
                generatedAt: Value(
                  DateTime.parse(sr['generated_at'] as String),
                ),
                dataFreshness: Value(sr['data_freshness'] as String?),
                explanation: Value(sr['explanation'] as String?),
              ),
            );
      }

      final rItems = (dataMap['recommendation_items'] as List? ?? [])
          .cast<Map<String, dynamic>>();
      for (final ri in rItems) {
        await _db
            .into(_db.recommendationItems)
            .insert(
              RecommendationItemsCompanion.insert(
                id: Value(ri['id'] as int),
                recommendationId: ri['recommendation_id'] as int,
                componentTypeId: ri['component_type_id'] as int,
                sparepartId: Value(ri['sparepart_id'] as int?),
                priority: ri['priority'] as String,
                decision: ri['decision'] as String,
                estimatedCost: Value(ri['estimated_cost'] as int?),
                estimatedLaborCost: Value(ri['estimated_labor_cost'] as int?),
                reason: ri['reason'] as String,
                consequenceIfDelayed: Value(
                  ri['consequence_if_delayed'] as String?,
                ),
                requiresInspection: Value(
                  ri['requires_inspection'] as bool? ?? false,
                ),
              ),
            );
      }

      final rems = (dataMap['local_reminders'] as List? ?? [])
          .cast<Map<String, dynamic>>();
      for (final rem in rems) {
        await _db
            .into(_db.localReminders)
            .insert(
              LocalRemindersCompanion.insert(
                id: Value(rem['id'] as int),
                motorcycleId: rem['motorcycle_id'] as int,
                componentTypeId: Value(rem['component_type_id'] as int?),
                reminderType: rem['reminder_type'] as String,
                dueOdometerKm: Value(
                  (rem['due_odometer_km'] as num?)?.toDouble(),
                ),
                dueDate: Value(
                  rem['due_date'] != null
                      ? DateTime.parse(rem['due_date'] as String)
                      : null,
                ),
                enabled: Value(rem['enabled'] as bool? ?? true),
                lastScheduledAt: Value(
                  rem['last_scheduled_at'] != null
                      ? DateTime.parse(rem['last_scheduled_at'] as String)
                      : null,
                ),
                notificationId: Value(rem['notification_id'] as int?),
              ),
            );
      }

      // Restore app settings if present
      final appSettings = (dataMap['app_settings'] as Map<String, dynamic>?);
      if (appSettings != null) {
        for (final entry in appSettings.entries) {
          await _db.setSetting(entry.key, entry.value.toString());
        }
      }

      // Foreign key integrity check across the entire restored database
      final fkViolations = await _db
          .customSelect('PRAGMA foreign_key_check')
          .get();
      if (fkViolations.isNotEmpty) {
        throw StateError(
          'Integritas database gagal: Terdeteksi ${fkViolations.length} pelanggaran relasi foreign key.',
        );
      }
    });

    // Record last restore timestamp
    await _db.setSetting('restore_last_at', DateTime.now().toIso8601String());
  }

  // --- Cryptographic & Key Derivation Utilities ---

  List<int> _generateRandomBytes(int length) {
    final rand = Random.secure();
    return List<int>.generate(length, (_) => rand.nextInt(256));
  }

  /// Legacy v1 PBKDF2 HMAC-SHA256 key derivation with 10,000 iterations for backward compatibility
  List<int> _deriveKeyLegacy(String passphrase, List<int> salt) {
    var key = Hmac(sha256, utf8.encode(passphrase)).convert(salt).bytes;
    for (int i = 1; i < 10000; i++) {
      key = Hmac(sha256, key).convert(salt).bytes;
    }
    return key;
  }

  /// Legacy v1 symmetric XOR stream cipher for backward compatibility
  List<int> _xorCipher(List<int> data, List<int> key) {
    final result = List<int>.filled(data.length, 0);
    for (int i = 0; i < data.length; i++) {
      result[i] = data[i] ^ key[i % key.length];
    }
    return result;
  }
}
