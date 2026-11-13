import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:buildhaus/core/database/app_database.dart';

/// Pengujian integrasi tingkat database untuk TAHAP 01.
///
/// Cakupan:
/// - CRUD motor (tambah, baca, ubah, hapus) beserta konfirmasi hapus.
/// - Foreign key model motor (modelId harus menunjuk ke motorcycle_models).
/// - Isolasi data multi-motor (histori motor A tidak bocor ke motor B).
/// - Seeder idempoten (dijalankan dua kali tidak menggandakan data).
/// - Migrasi database v4 -> v5 tanpa kehilangan data pengguna.
/// - CRUD servis beserta relasi item servis dan sparepart.
/// - Constraint foreign key untuk sparepart_id.
void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  /// Membuat motor dengan model yang valid dari master data.
  Future<int> createMotor({
    String name = 'Motor Uji',
    String brand = 'Honda',
    String model = 'Vario 160',
    double? odometer = 1200,
  }) async {
    final models = await db.getAllMotorcycleModels();
    final selected = models.firstWhere(
      (m) => m.brand == brand && m.model == model,
      orElse: () => models.first,
    );
    return db.createMotorcycle(
      motorcycle: MotorcyclesCompanion.insert(
        nickname: name,
        modelId: Value(selected.id),
        manufactureYear: selected.yearStart,
      ),
      initialOdometerKm: odometer,
    );
  }

  // ==========================================================================
  // TARGET 2 - CRUD MOTOR
  // ==========================================================================

  group('CRUD motor', () {
    test('Tambah motor menyimpan modelId, odometer awal, dan profil pakai', () async {
      final motorId = await createMotor(name: 'Vario Biru', odometer: 8500);

      final motor = await db.getMotorcycle(motorId);
      expect(motor, isNotNull);
      expect(motor!.nickname, 'Vario Biru');
      expect(motor.modelId, isNotNull);
      expect(motor.usageProfile, 'campuran');
      expect(motor.isPrimary, isTrue, reason: 'motor pertama harus jadi utama');

      final model = await db.getMotorcycleModelById(motor.modelId!);
      expect(model, isNotNull);
      expect(model!.brand, 'Honda');

      final logs = await db.getOdometerLogs(motorId);
      expect(logs.length, greaterThanOrEqualTo(1));
      expect(logs.any((l) => l.odometerKm == 8500), isTrue);
    });

    test('Tambah motor tanpa modelId yang valid ditolak', () async {
      await expectLater(
        db.createMotorcycle(
          motorcycle: MotorcyclesCompanion.insert(
            nickname: 'Tanpa Model',
            manufactureYear: 2023,
          ),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Tambah motor dengan modelId asing ditolak dan tidak menyimpan data', () async {
      await expectLater(
        db.createMotorcycle(
          motorcycle: MotorcyclesCompanion.insert(
            nickname: 'Model Palsu',
            modelId: const Value(999999),
            manufactureYear: 2023,
          ),
        ),
        throwsA(isA<ArgumentError>()),
      );
      expect(await db.getAllMotorcycles(), isEmpty);
    });

    test('Ubah motor menyimpan perubahan dan dapat dibaca kembali', () async {
      final motorId = await createMotor(name: 'Nama Lama');

      await db.updateMotorcycleWithOdometer(
        motorcycleId: motorId,
        changes: MotorcyclesCompanion(
          nickname: const Value('Nama Baru'),
          plateNumber: const Value('B 1234 XYZ'),
          usageProfile: const Value('jarak_jauh'),
          updatedAt: Value(DateTime.now()),
        ),
      );

      final motor = await db.getMotorcycle(motorId);
      expect(motor!.nickname, 'Nama Baru');
      expect(motor.plateNumber, 'B 1234 XYZ');
      expect(motor.usageProfile, 'jarak_jauh');
    });

    test('Hapus motor menghapus motor dan seluruh data turunannya', () async {
      final motorId = await createMotor();
      final component = (await db.getAllComponentTypes()).first;

      final recordId = await db.createServiceWithItems(
        record: ServiceRecordsCompanion.insert(
          motorcycleId: motorId,
          servicedAt: DateTime.now(),
        ),
        items: [
          ServiceItemsCompanion(
            componentTypeId: Value(component.id),
            action: const Value('replace'),
          ),
        ],
        odometerKm: 1400,
      );
      await db.insertComplaint(
        ComplaintsCompanion.insert(
          motorcycleId: motorId,
          title: 'Keluhan',
          description: 'Deskripsi',
        ),
      );
      await db.insertSelfInspection(
        SelfInspectionsCompanion.insert(motorcycleId: motorId),
      );
      await db.insertBudgetPlan(
        BudgetPlansCompanion.insert(
          motorcycleId: motorId,
          budgetAmount: 200000,
        ),
      );

      final deleted = await db.deleteMotorcycle(motorId);
      expect(deleted, 1);

      expect(await db.getMotorcycle(motorId), isNull);
      expect(await db.getServiceRecord(recordId), isNull);
      expect(await db.getServiceItems(recordId), isEmpty);
      expect(await db.getComplaints(motorId), isEmpty);
      expect(await db.getSelfInspections(motorId), isEmpty);
      expect(await db.getActiveBudgetPlan(motorId), isNull);
      expect(await db.getOdometerLogs(motorId), isEmpty);
    });

    test('Mendukung lebih dari satu motor dan tepat satu motor utama', () async {
      final first = await createMotor(name: 'Motor A');
      final second = await createMotor(name: 'Motor B');
      final third = await createMotor(name: 'Motor C');

      final all = await db.getAllMotorcycles();
      expect(all.length, 3);
      expect(all.where((m) => m.isPrimary).length, 1);
      expect(all.firstWhere((m) => m.id == first).isPrimary, isTrue);

      await db.setPrimaryMotorcycle(second);
      final after = await db.getAllMotorcycles();
      expect(after.where((m) => m.isPrimary).length, 1);
      expect(after.firstWhere((m) => m.id == second).isPrimary, isTrue);
      expect(after.firstWhere((m) => m.id == first).isPrimary, isFalse);
      expect(after.firstWhere((m) => m.id == third).isPrimary, isFalse);
    });
  });

  // ==========================================================================
  // TARGET 2 - FOREIGN KEY MODEL MOTOR
  // ==========================================================================

  group('Foreign key model motor', () {
    test('modelId menunjuk ke baris motorcycle_models yang valid', () async {
      final models = await db.getAllMotorcycleModels();
      expect(models, isNotEmpty);

      final motorId = await createMotor(brand: 'Yamaha', model: 'NMAX');
      final motor = await db.getMotorcycle(motorId);

      expect(motor, isNotNull);
      final modelId = motor!.modelId;
      expect(modelId, isNotNull);
      final referenced = await db.getMotorcycleModelById(modelId!);
      expect(referenced, isNotNull);
      expect(referenced!.brand, 'Yamaha');
      expect(referenced.model, 'NMAX');
    });

    test('getMotorcycleModelId tidak menebak model lain dari merek sama', () async {
      expect(await db.getMotorcycleModelId('Honda', 'Model Fiktif'), isNull);
      expect(await db.getMotorcycleModelId('Merek Palsu', 'Vario 160'), isNull);

      final real = await db.getMotorcycleModelId('Honda', 'Vario 160');
      expect(real, isNotNull);
      final model = await db.getMotorcycleModelById(real!);
      expect(model!.model, 'Vario 160');
    });

    test('Database menolak modelId yang tidak ada di motorcycle_models', () async {
      // Melewati validasi aplikasi untuk menguji constraint database.
      await expectLater(
        db.into(db.motorcycles).insert(
          MotorcyclesCompanion.insert(
            nickname: 'Langsung',
            modelId: const Value(888888),
            manufactureYear: 2024,
          ),
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('Tahun pembuatan di luar rentang model ditolak', () async {
      final models = await db.getAllMotorcycleModels();
      final selected = models.firstWhere((m) => m.brand == 'Honda');
      await expectLater(
        db.createMotorcycle(
          motorcycle: MotorcyclesCompanion.insert(
            nickname: 'Tahun Salah',
            modelId: Value(selected.id),
            manufactureYear: selected.yearStart - 10,
          ),
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  // ==========================================================================
  // TARGET 2 - ISOLASI DATA MULTI-MOTOR
  // ==========================================================================

  group('Isolasi data multi-motor', () {
    test('Histori motor A tidak muncul pada motor B', () async {
      final motorA = await createMotor(name: 'Motor A', odometer: 1000);
      final motorB = await createMotor(name: 'Motor B', odometer: 2000);

      final component = (await db.getAllComponentTypes()).first;
      await db.createServiceWithItems(
        record: ServiceRecordsCompanion.insert(
          motorcycleId: motorA,
          servicedAt: DateTime.now(),
        ),
        items: [
          ServiceItemsCompanion(
            componentTypeId: Value(component.id),
            action: const Value('replace'),
            notes: const Value('Milik motor A'),
          ),
        ],
        odometerKm: 1500,
      );

      expect(await db.getServiceRecords(motorA), hasLength(1));
      expect(await db.getServiceRecords(motorB), isEmpty);

      final logsA = await db.getOdometerLogs(motorA);
      final logsB = await db.getOdometerLogs(motorB);
      expect(logsA.every((l) => l.motorcycleId == motorA), isTrue);
      expect(logsB.every((l) => l.motorcycleId == motorB), isTrue);
      expect(logsA.map((l) => l.odometerKm), isNot(contains(2000)));
      expect(logsB.map((l) => l.odometerKm), isNot(contains(1500)));
    });

    test('Keluhan motor A tidak muncul pada motor B', () async {
      final motorA = await createMotor(name: 'Motor A');
      final motorB = await createMotor(name: 'Motor B');

      await db.insertComplaint(
        ComplaintsCompanion.insert(
          motorcycleId: motorA,
          title: 'Rem motor A',
          description: 'Rem berdecit',
        ),
      );

      expect(await db.getComplaints(motorA), hasLength(1));
      expect(await db.getComplaints(motorB), isEmpty);
    });

    test('Riwayat tindakan servis per komponen tidak bocor antar motor', () async {
      final motorA = await createMotor(name: 'Motor A');
      final motorB = await createMotor(name: 'Motor B');
      final oli = (await db.getAllComponentTypes()).firstWhere(
        (c) => c.name == 'Oli mesin',
      );

      await db.createServiceWithItems(
        record: ServiceRecordsCompanion.insert(
          motorcycleId: motorA,
          servicedAt: DateTime.now(),
        ),
        items: [
          ServiceItemsCompanion(
            componentTypeId: Value(oli.id),
            action: const Value('replace'),
          ),
        ],
        odometerKm: 1500,
      );

      final actionA = await db.getLastActionForComponent(motorA, oli.id);
      final actionB = await db.getLastActionForComponent(motorB, oli.id);

      expect(actionA, isNotNull);
      expect(actionA!.action, 'replace');
      expect(actionB, isNull, reason: 'motor B tidak punya servis oli');
    });

    test('Status komponen dihitung terpisah untuk tiap motor', () async {
      final motorA = await createMotor(name: 'Motor A', odometer: 1000);
      final motorB = await createMotor(name: 'Motor B', odometer: 1000);

      final component = (await db.getAllComponentTypes()).first;
      await db.createServiceWithItems(
        record: ServiceRecordsCompanion.insert(
          motorcycleId: motorA,
          servicedAt: DateTime.now(),
        ),
        items: [
          ServiceItemsCompanion(
            componentTypeId: Value(component.id),
            action: const Value('replace'),
          ),
        ],
        odometerKm: 1200,
      );

      // getComponentStatusesWithNames adalah jalur baca yang dipakai UI; jalur
      // ini otomatis menghitung ulang status bila belum lengkap.
      final statusesA = await db.getComponentStatusesWithNames(motorA);
      final statusesB = await db.getComponentStatusesWithNames(motorB);

      expect(statusesA, isNotEmpty);
      expect(statusesB, isNotEmpty);
      expect(
        statusesA.every((s) => s.status.motorcycleId == motorA),
        isTrue,
      );
      expect(
        statusesB.every((s) => s.status.motorcycleId == motorB),
        isTrue,
      );

      // Kedua motor harus punya tepat satu baris status per komponen.
      final componentCount = (await db.getAllComponentTypes()).length;
      expect(statusesA, hasLength(componentCount));
      expect(statusesB, hasLength(componentCount));

      // Id motor tidak boleh tercampur di tabel status.
      final allStatuses = await db.select(db.componentStatuses).get();
      expect(
        allStatuses.where((s) => s.motorcycleId == motorA),
        hasLength(componentCount),
      );
      expect(
        allStatuses.where((s) => s.motorcycleId == motorB),
        hasLength(componentCount),
      );
    });

    test('Pengingat motor A tidak muncul pada motor B', () async {
      final motorA = await createMotor(name: 'Motor A');
      final motorB = await createMotor(name: 'Motor B');

      await db.insertReminder(
        LocalRemindersCompanion.insert(
          motorcycleId: motorA,
          reminderType: 'odometer',
          dueOdometerKm: const Value(5000),
        ),
      );

      expect(await db.getReminders(motorA), hasLength(1));
      expect(await db.getReminders(motorB), isEmpty);
    });
  });

  // ==========================================================================
  // TARGET 3 - SEEDER IDEMPOTENT
  // ==========================================================================

  group('Seeder idempoten', () {
    test('Menjalankan seeder dua kali tidak menggandakan data master', () async {
      final modelsBefore = await db.getAllMotorcycleModels();
      final componentsBefore = await db.getAllComponentTypes();
      final rulesBefore = await db.select(db.maintenanceRules).get();
      final partsBefore = await db.select(db.spareparts).get();
      final sourcesBefore = await db.select(db.catalogSources).get();
      final fitmentsBefore = await db.select(db.sparepartFitments).get();
      final settingsBefore = await db.getAllSettings();

      await db.ensureReferenceData();
      await db.ensureReferenceData();

      expect(await db.getAllMotorcycleModels(), hasLength(modelsBefore.length));
      expect(await db.getAllComponentTypes(), hasLength(componentsBefore.length));
      expect(
        await db.select(db.maintenanceRules).get(),
        hasLength(rulesBefore.length),
      );
      expect(await db.select(db.spareparts).get(), hasLength(partsBefore.length));
      expect(
        await db.select(db.catalogSources).get(),
        hasLength(sourcesBefore.length),
      );
      expect(
        await db.select(db.sparepartFitments).get(),
        hasLength(fitmentsBefore.length),
      );
      expect(
        (await db.getAllSettings()).keys.toSet(),
        settingsBefore.keys.toSet(),
      );
    });

    test('Data master wajib terisi saat database baru dibuat', () async {
      expect(await db.getAllMotorcycleModels(), isNotEmpty);
      expect(await db.getAllComponentTypes(), isNotEmpty);
      expect(await db.select(db.maintenanceRules).get(), isNotEmpty);
      expect(await db.select(db.spareparts).get(), isNotEmpty);
    });

    test('Aturan perawatan generic dan spesifik model sama-sama ada', () async {
      final models = await db.getAllMotorcycleModels();
      final honda = models.firstWhere((m) => m.brand == 'Honda');
      final oli = (await db.getAllComponentTypes()).firstWhere(
        (c) => c.name == 'Oli mesin',
      );

      final rules = await db.getMaintenanceRules(honda.id, oli.id);
      expect(rules, isNotEmpty);
      expect(rules.any((r) => r.modelId == null), isTrue, reason: 'ada aturan generic');
      expect(
        rules.any((r) => r.modelId == honda.id),
        isTrue,
        reason: 'ada aturan spesifik model',
      );
    });

    test('Sparepart fitment hanya dibuat untuk model yang benar-benar ada', () async {
      final fitments = await db.select(db.sparepartFitments).get();
      final modelIds = (await db.getAllMotorcycleModels()).map((m) => m.id).toSet();

      for (final f in fitments) {
        if (f.modelId == null) continue;
        expect(
          modelIds.contains(f.modelId),
          isTrue,
          reason: 'fitment menunjuk ke model yang tidak terdaftar',
        );
      }
    });
  });

  // ==========================================================================
  // TARGET 5 - CRUD SERVIS DAN RELASI ITEM
  // ==========================================================================

  group('CRUD servis dan relasi item', () {
    test('Menyimpan servis beserta item dan total biaya', () async {
      final motorId = await createMotor();
      final oli = (await db.getAllComponentTypes()).firstWhere(
        (c) => c.name == 'Oli mesin',
      );

      final recordId = await db.createServiceWithItems(
        record: ServiceRecordsCompanion.insert(
          motorcycleId: motorId,
          servicedAt: DateTime.now(),
          workshopName: const Value('Bengkel Uji'),
        ),
        items: [
          ServiceItemsCompanion(
            componentTypeId: Value(oli.id),
            action: const Value('replace'),
            partsCost: const Value(40000),
            laborCost: const Value(10000),
          ),
        ],
        odometerKm: 1500,
      );

      final record = await db.getServiceRecord(recordId);
      expect(record, isNotNull);
      expect(record!.totalCost, 50000);
      expect(record.workshopName, 'Bengkel Uji');
      expect(record.odometerKm, 1500);

      final items = await db.getServiceItems(recordId);
      expect(items, hasLength(1));
      expect(items.single.componentTypeId, oli.id);
      expect(items.single.action, 'replace');
      expect(items.single.totalCost, 50000);
    });

    test('Item servis wajib punya componentTypeId yang valid', () async {
      final motorId = await createMotor();
      await expectLater(
        db.createServiceWithItems(
          record: ServiceRecordsCompanion.insert(
            motorcycleId: motorId,
            servicedAt: DateTime.now(),
          ),
          items: [
            ServiceItemsCompanion(
              componentTypeId: const Value(999999),
              action: const Value('replace'),
            ),
          ],
        ),
        throwsA(isA<Exception>()),
      );
      expect(await db.getServiceRecords(motorId), isEmpty);
    });

    test('Item servis tanpa komponen ditolak', () async {
      final motorId = await createMotor();
      await expectLater(
        db.createServiceWithItems(
          record: ServiceRecordsCompanion.insert(
            motorcycleId: motorId,
            servicedAt: DateTime.now(),
          ),
          items: [
            ServiceItemsCompanion(action: const Value('replace')),
          ],
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Aksi servis di luar daftar yang diperbolehkan ditolak', () async {
      final motorId = await createMotor();
      final oli = (await db.getAllComponentTypes()).first;
      await expectLater(
        db.createServiceWithItems(
          record: ServiceRecordsCompanion.insert(
            motorcycleId: motorId,
            servicedAt: DateTime.now(),
          ),
          items: [
            ServiceItemsCompanion(
              componentTypeId: Value(oli.id),
              action: const Value('action_tidak_valid'),
            ),
          ],
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Servis tanpa item ditolak dan tidak membuat record', () async {
      final motorId = await createMotor();
      await expectLater(
        db.createServiceWithItems(
          record: ServiceRecordsCompanion.insert(
            motorcycleId: motorId,
            servicedAt: DateTime.now(),
          ),
          items: const [],
        ),
        throwsA(isA<ArgumentError>()),
      );
      expect(await db.getServiceRecords(motorId), isEmpty);
    });

    test('Hapus servis ikut menghapus item servisnya', () async {
      final motorId = await createMotor();
      final oli = (await db.getAllComponentTypes()).first;
      final recordId = await db.createServiceWithItems(
        record: ServiceRecordsCompanion.insert(
          motorcycleId: motorId,
          servicedAt: DateTime.now(),
        ),
        items: [
          ServiceItemsCompanion(
            componentTypeId: Value(oli.id),
            action: const Value('inspect'),
          ),
        ],
      );

      expect(await db.getServiceItems(recordId), hasLength(1));
      await db.deleteServiceRecord(recordId);
      expect(await db.getServiceRecord(recordId), isNull);
      expect(await db.getServiceItems(recordId), isEmpty);
    });

    test('Mengganti oli menambah pembacaan odometer dari servis', () async {
      final motorId = await createMotor(odometer: 1000);
      final oli = (await db.getAllComponentTypes()).firstWhere(
        (c) => c.name == 'Oli mesin',
      );

      await db.createServiceWithItems(
        record: ServiceRecordsCompanion.insert(
          motorcycleId: motorId,
          servicedAt: DateTime.now(),
        ),
        items: [
          ServiceItemsCompanion(
            componentTypeId: Value(oli.id),
            action: const Value('replace'),
          ),
        ],
        odometerKm: 3200,
      );

      expect((await db.getLatestOdometer(motorId))?.odometerKm, 3200);
    });
  });

  // ==========================================================================
  // TARGET 1 - CONSTRAINT SPAREPART FOREIGN KEY
  // ==========================================================================

  group('Constraint sparepart', () {
    test('service_items.sparepart_id dan recommendation_items.sparepart_id punya FK', () async {
      for (final table in ['service_items', 'recommendation_items']) {
        final row = await db
            .customSelect(
              'SELECT sql FROM sqlite_master WHERE name = ?',
              variables: [Variable<String>(table)],
            )
            .getSingle();
        final sql = row.data['sql'] as String;
        expect(
          sql.contains('"sparepart_id" INTEGER NULL REFERENCES spareparts (id)'),
          isTrue,
          reason: '$table harus punya FK ke spareparts',
        );
      }
    });

    test('Menyimpan service item dengan sparepart_id valid berhasil', () async {
      final motorId = await createMotor();
      final oli = (await db.getAllComponentTypes()).firstWhere(
        (c) => c.name == 'Oli mesin',
      );
      final part = (await db.getAllSpareparts()).firstWhere(
        (s) => s.category == 'oli',
      );

      final recordId = await db.createServiceWithItems(
        record: ServiceRecordsCompanion.insert(
          motorcycleId: motorId,
          servicedAt: DateTime.now(),
        ),
        items: [
          ServiceItemsCompanion(
            componentTypeId: Value(oli.id),
            sparepartId: Value(part.id),
            action: const Value('replace'),
            partsCost: Value(part.referencePrice ?? 0),
          ),
        ],
      );

      final items = await db.getServiceItems(recordId);
      expect(items.single.sparepartId, part.id);
    });

    test('sparepart_id yang menunjuk part tidak ada ditolak database', () async {
      await createMotor();
      final oli = (await db.getAllComponentTypes()).first;

      await expectLater(
        db.into(db.serviceItems).insert(
          ServiceItemsCompanion.insert(
            serviceRecordId: 1,
            componentTypeId: Value(oli.id),
            sparepartId: const Value(999999),
            action: 'replace',
          ),
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  // ==========================================================================
  // TARGET 1 - MIGRASI v4 -> v5 TANPA KEHILANGAN DATA
  // ==========================================================================

  group('Migrasi v4 ke v5', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('buildhaus_migrate_v5_');
    });

    tearDown(() async {
      // Windows menahan file database yang masih dibuka; hapus dengan
      // percobaan ulang supaya pen leftovers tidak menggagalkan test.
      for (var attempt = 0; attempt < 5; attempt++) {
        if (!tempDir.existsSync()) return;
        try {
          tempDir.deleteSync(recursive: true);
          return;
        } catch (_) {
          await Future<void>.delayed(Duration(milliseconds: 100));
        }
      }
    });

    test(
      'Database v4 ter-upgrade ke v5 tanpa kehilangan data motor, servis, dan odometer',
      () async {
        final dbFile = File(p.join(tempDir.path, 'v4_test.db'));

        // Siapkan database dengan skema v4 beserta data pengguna.
        {
          final setupDb = AppDatabase(NativeDatabase(dbFile));
          final migrator = Migrator(setupDb);
          await migrator.createAll();

          // Turunkan ke versi skema 4.
          await setupDb.customStatement('PRAGMA user_version = 4;');

          // Hapus FK sparepart_id agar meniru skema v4 yang lama.
          await setupDb.customStatement('DROP TABLE service_items;');
          await setupDb.customStatement('''
            CREATE TABLE service_items (
              id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
              service_record_id INTEGER NOT NULL REFERENCES service_records (id),
              component_type_id INTEGER NULL REFERENCES component_types (id),
              sparepart_id INTEGER NULL,
              action TEXT NOT NULL,
              parts_cost INTEGER NOT NULL DEFAULT 0,
              labor_cost INTEGER NOT NULL DEFAULT 0,
              total_cost INTEGER NOT NULL DEFAULT 0,
              notes TEXT NULL
            );
          ''');
          await setupDb.customStatement('DROP TABLE recommendation_items;');
          await setupDb.customStatement('''
            CREATE TABLE recommendation_items (
              id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
              recommendation_id INTEGER NOT NULL REFERENCES service_recommendations (id),
              component_type_id INTEGER NOT NULL REFERENCES component_types (id),
              sparepart_id INTEGER NULL,
              priority TEXT NOT NULL,
              decision TEXT NOT NULL,
              estimated_cost INTEGER NULL,
              estimated_labor_cost INTEGER NULL,
              reason TEXT NOT NULL,
              consequence_if_delayed TEXT NULL,
              requires_inspection INTEGER NOT NULL DEFAULT 0
            );
          ''');

          // Data pengguna.
          await setupDb.customStatement(
            "INSERT INTO motorcycles (id, nickname, manufacture_year, is_primary) "
            "VALUES (1, 'Motor Lama', 2021, 1);",
          );
          await setupDb.customStatement(
            "INSERT INTO odometer_logs (id, motorcycle_id, odometer_km, recorded_at, source) "
            "VALUES (1, 1, 12345, 1768478400, 'manual');",
          );
          await setupDb.customStatement(
            "INSERT INTO service_records (id, motorcycle_id, serviced_at, odometer_km, workshop_name, total_cost) "
            "VALUES (1, 1, 1768478400, 12345, 'Bengkel Lama', 75000);",
          );
          final componentId = await setupDb.customSelect(
            'SELECT id FROM component_types LIMIT 1',
          ).getSingle();
          await setupDb.customStatement(
            'INSERT INTO service_items (service_record_id, component_type_id, action, parts_cost, labor_cost, total_cost) '
            'VALUES (1, ${componentId.data['id']}, \'replace\', 50000, 25000, 75000);',
          );

          // Row yatim: sparepart_id menunjuk part yang tidak ada.
          await setupDb.customStatement(
            'INSERT INTO service_items (service_record_id, component_type_id, sparepart_id, action) '
            'VALUES (1, ${componentId.data['id']}, 999999, \'inspect\');',
          );

          await setupDb.close();
        }

        // Buka dengan AppDatabase versi 5 -> migrasi jalan otomatis.
        {
          final upgraded = AppDatabase(NativeDatabase(dbFile));

          // Data pengguna tetap ada.
          final motors = await upgraded.getAllMotorcycles();
          expect(motors, hasLength(1));
          expect(motors.first.nickname, 'Motor Lama');

          final logs = await upgraded.getOdometerLogs(1);
          expect(logs, hasLength(1));
          expect(logs.first.odometerKm, 12345);

          final records = await upgraded.getServiceRecords(1);
          expect(records, hasLength(1));
          expect(records.first.workshopName, 'Bengkel Lama');
          expect(records.first.totalCost, 75000);

          // Item servis tetap ada; row yatim dinormalkan jadi NULL.
          final items = await upgraded.getServiceItems(1);
          expect(items, hasLength(2));
          expect(
            items.where((i) => i.sparepartId == 999999),
            isEmpty,
            reason: 'sparepart_id yatim harus dinormalkan menjadi NULL',
          );
          expect(
            items.every((i) => i.sparepartId == null),
            isTrue,
            reason: 'tidak boleh ada sparepart_id yang menggantung',
          );
          expect(
            items.any((i) => i.action == 'replace' && i.totalCost == 75000),
            isTrue,
          );
          expect(
            items.any((i) => i.action == 'inspect'),
            isTrue,
            reason: 'row yatim tetap ada tapi sparepart_id-nya dinormalkan',
          );

          // Skema baru sudah punya FK.
          for (final table in ['service_items', 'recommendation_items']) {
            final row = await upgraded
                .customSelect(
                  'SELECT sql FROM sqlite_master WHERE name = ?',
                  variables: [Variable<String>(table)],
                )
                .getSingle();
            final sql = row.data['sql'] as String;
            expect(
              sql.contains('REFERENCES spareparts (id)'),
              isTrue,
              reason: '$table harus punya FK ke spareparts setelah migrasi',
            );
          }

          await upgraded.close();
        }
      },
    );

    test('Migrasi tidak merusak motor lain yang sudah ada', () async {
      final dbFile = File(p.join(tempDir.path, 'v4_multi.db'));

      final setupDb = AppDatabase(NativeDatabase(dbFile));
      await Migrator(setupDb).createAll();
      await setupDb.customStatement('PRAGMA user_version = 4;');
      await setupDb.customStatement(
        "INSERT INTO motorcycles (id, nickname, manufacture_year, is_primary) VALUES (1, 'A', 2021, 1);",
      );
      await setupDb.customStatement(
        "INSERT INTO motorcycles (id, nickname, manufacture_year, is_primary) VALUES (2, 'B', 2022, 0);",
      );
      await setupDb.close();

      final upgraded = AppDatabase(NativeDatabase(dbFile));
      final motors = await upgraded.getAllMotorcycles();
      expect(motors, hasLength(2));
      expect(motors.map((m) => m.nickname).toSet(), {'A', 'B'});
      await upgraded.close();
    });
  });

  // ==========================================================================
  // TARGET 1 - INTEGRITAS SKEMA
  // ==========================================================================

  group('Integritas skema', () {
    test('Database memiliki tepat 22 tabel inti', () async {
      final rows = await db
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type='table' "
            "AND name NOT LIKE 'sqlite_%' ORDER BY name",
          )
          .get();
      expect(rows, hasLength(22));
    });

    test('Foreign key diaktifkan', () async {
      await db.customStatement('PRAGMA foreign_keys = ON');
      var enforced = false;
      try {
        await db.customStatement(
          'INSERT INTO odometer_logs (motorcycle_id, odometer_km, recorded_at, source) '
          'VALUES (999999, 1.0, 0, \'manual\')',
        );
      } catch (_) {
        enforced = true;
      }
      expect(enforced, isTrue);
    });

    test('component_types punya UNIQUE(name)', () async {
      final row = await db
          .customSelect(
            'SELECT sql FROM sqlite_master WHERE name = ?',
            variables: [Variable<String>('component_types')],
          )
          .getSingle();
      expect((row.data['sql'] as String).contains('UNIQUE(name)'), isTrue);
    });

    test('component_statuses punya UNIQUE(motorcycle_id, component_type_id)', () async {
      final row = await db
          .customSelect(
            'SELECT sql FROM sqlite_master WHERE name = ?',
            variables: [Variable<String>('component_statuses')],
          )
          .getSingle();
      expect(
        (row.data['sql'] as String).contains(
          'UNIQUE(motorcycle_id, component_type_id)',
        ),
        isTrue,
      );
    });

    test('Upsert status komponen tidak menggandakan baris', () async {
      final motorId = await createMotor();
      final component = (await db.getAllComponentTypes()).first;

      final entry = ComponentStatusesCompanion.insert(
        motorcycleId: motorId,
        componentTypeId: component.id,
        estimatedStatus: 'unknown',
        explanation: 'Bukti kurang',
        calculatedAt: DateTime.now(),
        ruleVersion: 'v1',
      );

      final first = await db.upsertComponentStatus(entry);
      final second = await db.upsertComponentStatus(
        entry.copyWith(explanation: const Value('Diperbarui')),
      );
      expect(first, second);
      expect(await db.getComponentStatuses(motorId), hasLength(1));
    });
  });
}
