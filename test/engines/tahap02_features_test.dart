import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:buildhaus/core/database/app_database.dart';
import 'package:buildhaus/core/database/sample_data_seeder.dart';
import 'package:buildhaus/core/engines/motorcycle_specs.dart';
import 'package:buildhaus/core/providers/app_providers.dart';
import 'package:buildhaus/core/providers/database_provider.dart';
import 'package:buildhaus/features/parts/presentation/providers/parts_providers.dart';

class _TestActiveMotorNotifier extends ActiveMotorcycleNotifier {
  _TestActiveMotorNotifier(super.ref, Motorcycle? motor) {
    state = motor;
  }
}

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.ensureReferenceData();
  });

  tearDown(() async {
    await db.close();
  });

  group('Tahap 02 — Smart Filter Komponen Berdasarkan Tipe Motor', () {
    test('Vario 160 (matic liquid-cooled) tidak memantau Rantai & gir', () async {
      final models = await db.getAllMotorcycleModels();
      final vario = models.firstWhere(
        (m) => m.brand == 'Honda' && m.model == 'Vario 160',
      );
      final comps = await db.getApplicableComponentsForModel(vario.id);
      final names = comps.map((c) => c.name).toSet();

      expect(names.contains('CVT'), isTrue);
      expect(names.contains('Oli gardan'), isTrue);
      expect(names.contains('Radiator coolant'), isTrue);
      expect(names.contains('Rantai & gir'), isFalse);
      expect(MotorcycleSpecs.transmissionLabel(vario), 'Matic (CVT)');
    });

    test('Beat Street (matic air-cooled) tidak memantau Rantai & gir maupun Radiator coolant', () async {
      final models = await db.getAllMotorcycleModels();
      final beat = models.firstWhere(
        (m) => m.brand == 'Honda' && m.model == 'Beat Street',
      );
      final comps = await db.getApplicableComponentsForModel(beat.id);
      final names = comps.map((c) => c.name).toSet();

      expect(names.contains('CVT'), isTrue);
      expect(names.contains('Oli gardan'), isTrue);
      expect(names.contains('Rantai & gir'), isFalse);
      expect(names.contains('Radiator coolant'), isFalse);
    });

    test('CBR150R (manual liquid-cooled) memantau Rantai & gir serta Coolant, bukan CVT', () async {
      final models = await db.getAllMotorcycleModels();
      final cbr = models.firstWhere(
        (m) => m.brand == 'Honda' && m.model == 'CBR150R',
      );
      final comps = await db.getApplicableComponentsForModel(cbr.id);
      final names = comps.map((c) => c.name).toSet();

      expect(names.contains('Rantai & gir'), isTrue);
      expect(names.contains('Radiator coolant'), isTrue);
      expect(names.contains('CVT'), isFalse);
      expect(names.contains('Oli gardan'), isFalse);
      expect(MotorcycleSpecs.transmissionLabel(cbr), 'Manual (Rantai)');
    });

    test('Kawasaki W175 (manual air-cooled) hanya memantau 11 komponen yang relevan', () async {
      final models = await db.getAllMotorcycleModels();
      final w175 = models.firstWhere(
        (m) => m.brand == 'Kawasaki' && m.model == 'W175',
      );
      final comps = await db.getApplicableComponentsForModel(w175.id);
      final names = comps.map((c) => c.name).toSet();

      expect(names.contains('Rantai & gir'), isTrue);
      expect(names.contains('CVT'), isFalse);
      expect(names.contains('Oli gardan'), isFalse);
      expect(names.contains('Radiator coolant'), isFalse);
      expect(comps.length, 11);
    });

    test('Mengubah model motor dari Manual ke Matic membersihkan status komponen tidak relevan', () async {
      final models = await db.getAllMotorcycleModels();
      final cbr = models.firstWhere((m) => m.model == 'CBR150R');
      final vario = models.firstWhere((m) => m.model == 'Vario 160');

      final motorId = await db.createMotorcycle(
        motorcycle: MotorcyclesCompanion.insert(
          nickname: 'Motor Test Swap',
          modelId: Value(cbr.id),
          manufactureYear: cbr.yearStart,
        ),
        initialOdometerKm: 5000,
      );

      final beforeNames = (await db.getComponentStatusesWithNames(motorId))
          .map((s) => s.componentName)
          .toSet();
      expect(beforeNames.contains('Rantai & gir'), isTrue);
      expect(beforeNames.contains('CVT'), isFalse);

      await db.updateMotorcycleWithOdometer(
        motorcycleId: motorId,
        changes: MotorcyclesCompanion(
          modelId: Value(vario.id),
          manufactureYear: Value(vario.yearStart),
        ),
      );

      final afterNames = (await db.getComponentStatusesWithNames(motorId))
          .map((s) => s.componentName)
          .toSet();
      expect(afterNames.contains('Rantai & gir'), isFalse);
      expect(afterNames.contains('CVT'), isTrue);
    });
  });

  group('Tahap 02 — Keamanan Auth Lokal & Penghapusan Plaintext', () {
    test('Database baru tidak lagi menyemai kredensial plaintext di registered_users_json', () async {
      final raw = await db.getSetting('registered_users_json');
      expect(raw, isNull);
    });

    test('Register menyimpan passwordHash + salt, bukan password plaintext', () async {
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(authProvider.notifier);
      final err = await notifier.register(
        name: 'Rider Uji',
        email: 'rider@uji.id',
        password: 'supersecret123',
      );
      expect(err, isNull);

      final raw = await db.getSetting('registered_users_json');
      expect(raw, isNotNull);
      expect(raw!.contains('supersecret123'), isFalse);

      final list = jsonDecode(raw) as List<dynamic>;
      final stored = Map<String, dynamic>.from(list.first as Map);
      expect(stored.containsKey('password'), isFalse);
      expect(stored['passwordHash'], isNotEmpty);
      expect(stored['passwordSalt'], isNotEmpty);

      await notifier.logout();
      final badLogin = await notifier.login(
        email: 'rider@uji.id',
        password: 'salah',
      );
      expect(badLogin, isNotNull);

      final okLogin = await notifier.login(
        email: 'rider@uji.id',
        password: 'supersecret123',
      );
      expect(okLogin, isNull);
    });

    test('Login akun lama plaintext otomatis memigrasi ke hash', () async {
      await db.setSetting(
        'registered_users_json',
        jsonEncode([
          {
            'name': 'User Lama',
            'email': 'lama@uji.id',
            'password': 'oldpassword',
            'initial': 'UL',
          },
        ]),
      );

      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);

      final err = await container
          .read(authProvider.notifier)
          .login(email: 'lama@uji.id', password: 'oldpassword');
      expect(err, isNull);

      final upgradedRaw = await db.getSetting('registered_users_json');
      expect(upgradedRaw!.contains('oldpassword'), isFalse);
      final list = jsonDecode(upgradedRaw) as List<dynamic>;
      final account = Map<String, dynamic>.from(list.first as Map);
      expect(account.containsKey('password'), isFalse);
      expect(account['passwordHash'], isNotEmpty);
      expect(account['passwordSalt'], isNotEmpty);
    });
  });

  group('Tahap 02 — Katalog Fitment 4 Merek, Ringkasan Biaya & Index v6', () {
    test('Keempat merek (Honda, Yamaha, Suzuki, Kawasaki) memiliki fitment terverifikasi', () async {
      final models = await db.getAllMotorcycleModels();
      for (final brand in ['Honda', 'Yamaha', 'Suzuki', 'Kawasaki']) {
        final brandModels = models.where((m) => m.brand == brand).toList();
        expect(brandModels, isNotEmpty);
        int verifiedCount = 0;
        for (final m in brandModels) {
          verifiedCount += (await db.getSparepartsForModel(m.id)).length;
        }
        expect(
          verifiedCount,
          greaterThan(0),
          reason: '$brand seharusnya punya fitment terverifikasi',
        );
      }
    });

    test('Ringkasan pengeluaran motor menghitung total part, jasa, dan bulan ini', () async {
      final models = await db.getAllMotorcycleModels();
      final motorId = await db.createMotorcycle(
        motorcycle: MotorcyclesCompanion.insert(
          nickname: 'Motor Biaya',
          modelId: Value(models.first.id),
          manufactureYear: models.first.yearStart,
        ),
        initialOdometerKm: 1000,
      );
      final comp = (await db.getApplicableComponentsForModel(
        models.first.id,
      )).first;

      await db.createServiceWithItems(
        record: ServiceRecordsCompanion.insert(
          motorcycleId: motorId,
          servicedAt: DateTime.now(),
        ),
        items: [
          ServiceItemsCompanion.insert(
            serviceRecordId: 0,
            componentTypeId: Value(comp.id),
            action: 'replace',
            partsCost: const Value(50000),
            laborCost: const Value(15000),
          ),
        ],
      );

      final summary = await db.getMotorcycleExpenseSummary(motorId);
      expect(summary.recordCount, 1);
      expect(summary.totalAllCost, 65000);
      expect(summary.totalMonthCost, 65000);
      expect(summary.totalPartsCost, 50000);
      expect(summary.totalLaborCost, 15000);
    });

    test('Index SQLite performa v6 dibuat di database baru dan migrasi', () async {
      final tempDir = Directory.systemTemp.createTempSync('buildhaus_v6_idx_');
      try {
        final dbFile = File(p.join(tempDir.path, 'v5_to_v6.db'));
        {
          final setupDb = AppDatabase(NativeDatabase(dbFile));
          await setupDb.ensureReferenceData();
          await setupDb.customStatement('PRAGMA user_version = 5;');
          await setupDb.customStatement(
            'DROP INDEX IF EXISTS idx_odometer_logs_motor_date;',
          );
          await setupDb.close();
        }
        {
          final upgraded = AppDatabase(NativeDatabase(dbFile));
          final rows = await upgraded
              .customSelect(
                "SELECT name FROM sqlite_master WHERE type = 'index' AND name LIKE 'idx_%'",
              )
              .get();
          final idxNames = rows.map((r) => r.data['name'] as String).toSet();
          expect(idxNames, contains('idx_odometer_logs_motor_date'));
          expect(idxNames, contains('idx_component_statuses_motor'));
          expect(idxNames, contains('idx_service_records_motor_date'));
          expect(idxNames, contains('idx_local_reminders_motor_enabled'));
          await upgraded.close();
        }
      } finally {
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      }
    });

    test('Katalog sparepart bebas duplikat & migrasi v7 menggabungkan duplikat dengan aman', () async {
      final parts = await db.getAllSpareparts();
      final byName = <String, List<Sparepart>>{};
      for (final part in parts) {
        byName.putIfAbsent(part.name.trim().toLowerCase(), () => []).add(part);
      }
      for (final entry in byName.entries) {
        expect(
          entry.value.length,
          1,
          reason: 'Sparepart "${entry.key}" tidak boleh terduplikasi',
        );
      }

      final coolants = byName['ahm radiator coolant pre-mix 1l']!;
      expect(coolants.length, 1);
      expect(coolants.first.isVerified, isTrue);
      expect(coolants.first.partNumber, '08CLA-G01-W01');

      final tempDir = Directory.systemTemp.createTempSync('buildhaus_v7_dedup_');
      try {
        final dbFile = File(p.join(tempDir.path, 'v6_to_v7.db'));
        late int motorId;
        {
          final setupDb = AppDatabase(NativeDatabase(dbFile));
          try {
            await setupDb.ensureReferenceData();
            final dupId = await setupDb.into(setupDb.spareparts).insert(
                  SparepartsCompanion.insert(
                    name: 'AHM Radiator Coolant Pre-mix 1L',
                    partNumber: const Value('HN-COOL1L'),
                    category: 'coolant',
                    brand: const Value('Honda'),
                    referencePrice: const Value(24000),
                    isVerified: const Value(false),
                  ),
                );
            final models = await setupDb.getAllMotorcycleModels();
            final comps = await setupDb.getAllComponentTypes();
            motorId = await setupDb.createMotorcycle(
              motorcycle: MotorcyclesCompanion.insert(
                modelId: Value(models.first.id),
                nickname: 'Vario Uji Duplikat',
                manufactureYear: 2023,
              ),
            );
            await setupDb.createServiceWithItems(
              record: ServiceRecordsCompanion.insert(
                motorcycleId: motorId,
                servicedAt: DateTime.now(),
              ),
              items: [
                ServiceItemsCompanion.insert(
                  serviceRecordId: 0,
                  componentTypeId: Value(comps.first.id),
                  sparepartId: Value(dupId),
                  action: 'replace',
                ),
              ],
            );
            await setupDb.customStatement('PRAGMA user_version = 6;');
          } finally {
            await setupDb.close();
          }
        }
        {
          final upgraded = AppDatabase(NativeDatabase(dbFile));
          try {
            final allParts = await upgraded.getAllSpareparts();
            final upgradedCoolants = allParts
                .where((p) => p.name == 'AHM Radiator Coolant Pre-mix 1L')
                .toList();
            expect(upgradedCoolants.length, 1);
            expect(upgradedCoolants.first.isVerified, isTrue);

            final serviceItems = await upgraded.getAllServiceItemsForMotorcycle(
              motorId,
            );
            expect(serviceItems, isNotEmpty);
            expect(
              serviceItems.first.item.sparepartId,
              upgradedCoolants.first.id,
            );
          } finally {
            await upgraded.close();
          }
        }
      } finally {
        try {
          if (tempDir.existsSync()) {
            tempDir.deleteSync(recursive: true);
          }
        } on FileSystemException {
          // Windows SQLite handle release can lag briefly after close().
        }
      }
    });

    test('seedDiverseFiveMotorcycles mendaftarkan 5 jenis motor berbeda beserta data lengkap', () async {
      final createdIds = await SampleDataSeeder(
        db,
      ).seedDiverseFiveMotorcycles();
      expect(createdIds.length, 5);

      final motors = await db.getAllMotorcycles();
      expect(motors.length, 5);

      final models = await db.getAllMotorcycleModels();
      final modelById = {for (final m in models) m.id: m};
      final brands = <String>{};
      final modelNames = <String>{};

      for (final motor in motors) {
        final model = modelById[motor.modelId]!;
        brands.add(model.brand);
        modelNames.add(model.model);

        final odos = await db.getOdometerLogs(motor.id);
        final services = await db.getServiceRecords(motor.id);
        final inspections = await db.getSelfInspections(motor.id);
        final budgets = await db.getBudgetPlanHistory(motor.id);
        final complaints = await db.getComplaints(motor.id);
        final reminders = await db.getReminders(motor.id);
        final compStatuses = await db.getComponentStatusesWithNames(motor.id);
        final compNames = compStatuses.map((s) => s.componentName).toSet();

        expect(odos.length, greaterThanOrEqualTo(4));
        expect(services.length, greaterThanOrEqualTo(2));
        expect(inspections, isNotEmpty);
        expect(budgets, isNotEmpty);
        expect(complaints, isNotEmpty);
        expect(reminders, isNotEmpty);

        if (model.model.contains('Smash') || model.model.contains('W175')) {
          expect(compNames.contains('Rantai & gir'), isTrue);
          expect(compNames.contains('CVT'), isFalse);
          expect(compNames.contains('Oli gardan'), isFalse);
          expect(compNames.contains('Radiator coolant'), isFalse);
        } else if (model.model.contains('CBR150R')) {
          expect(compNames.contains('Rantai & gir'), isTrue);
          expect(compNames.contains('Radiator coolant'), isTrue);
          expect(compNames.contains('CVT'), isFalse);
          expect(compNames.contains('Oli gardan'), isFalse);
        } else {
          expect(compNames.contains('CVT'), isTrue);
          expect(compNames.contains('Oli gardan'), isTrue);
          expect(compNames.contains('Radiator coolant'), isTrue);
          expect(compNames.contains('Rantai & gir'), isFalse);
        }
      }

      expect(brands, {'Honda', 'Yamaha', 'Suzuki', 'Kawasaki'});
      expect(
        modelNames,
        {'Vario 160', 'NMAX', 'Smash FI', 'CBR150R', 'W175'},
      );
      final vario = motors.firstWhere((m) => m.nickname.contains('Vario'));
      expect((await db.getLatestOdometer(vario.id))?.odometerKm, 12450.0);
    });

    test('Rekomendasi sparepart motor manual (CBR150R) tidak memprioritaskan part skutik/oli gardan', () async {
      await SampleDataSeeder(db).seedDiverseFiveMotorcycles();
      final motors = await db.getAllMotorcycles();
      final cbr = motors.firstWhere((m) => m.nickname.contains('CBR150R'));

      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          activeMotorcycleProvider.overrideWith(
            (ref) => _TestActiveMotorNotifier(ref, cbr),
          ),
        ],
      );
      addTearDown(container.dispose);

      final prioritized = await container.read(
        prioritizedSparepartsProvider.future,
      );
      final prioritizedHealthOrBudget = prioritized.where(
        (p) => p.tier != RecommendationTier.generalCatalog,
      );

      expect(
        prioritizedHealthOrBudget.any(
          (p) =>
              p.part.category == 'oli_gardan' ||
              p.part.category == 'cvt' ||
              p.part.category == 'vbelt' ||
              p.part.name.toLowerCase().contains('scooter'),
        ),
        isFalse,
      );
    });
  });
}
