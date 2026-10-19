import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buildhaus/core/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });
  tearDown(() async => db.close());

  Future<int> addMotor({int? modelId, String name = 'Motor uji'}) async {
    final models = await db.getAllMotorcycleModels();
    final selected = models.firstWhere((m) => m.id == (modelId ?? models.first.id));
    return db.createMotorcycle(
      motorcycle: MotorcyclesCompanion.insert(
        nickname: name,
        modelId: Value(selected.id),
        manufactureYear: selected.yearStart,
      ),
      initialOdometerKm: 1200,
    );
  }

  test('Seeder repeated does not add duplicate master records', () async {
    final firstModels = await db.getAllMotorcycleModels();
    final firstParts = await db.select(db.spareparts).get();
    final firstRules = await db.select(db.maintenanceRules).get();
    await db.ensureReferenceData();
    await db.ensureReferenceData();
    expect((await db.getAllMotorcycleModels()).length, firstModels.length);
    expect((await db.select(db.spareparts).get()).length, firstParts.length);
    expect((await db.select(db.maintenanceRules).get()).length, firstRules.length);
  });

  test('Create motorcycle with odometer is atomic and isolated', () async {
    final first = await addMotor(name: 'A');
    final second = await addMotor(name: 'B');
    expect((await db.getOdometerLogs(first)).length, 1);
    expect((await db.getOdometerLogs(second)).length, 1);
    expect((await db.getAllMotorcycles()).where((m) => m.isPrimary).length, 1);
    await expectLater(db.createMotorcycle(
      motorcycle: MotorcyclesCompanion.insert(
        nickname: 'Invalid',
        modelId: const Value(999999),
        manufactureYear: 2023,
      ),
    ), throwsA(isA<ArgumentError>()));
    expect((await db.getAllMotorcycles()).length, 2);
  });

  test('Unknown model is not substituted by same-brand model', () async {
    expect(await db.getMotorcycleModelId('Honda', 'Model Fiktif'), isNull);
  });

  test('Service visit with item and odometer is stored together', () async {
    final motorcycleId = await addMotor();
    final component = (await db.getAllComponentTypes()).first;
    final recordId = await db.createServiceWithItems(
      record: ServiceRecordsCompanion.insert(
        motorcycleId: motorcycleId,
        servicedAt: DateTime.now(),
      ),
      items: [ServiceItemsCompanion(
        componentTypeId: Value(component.id),
        action: const Value('replace'),
        partsCost: const Value(40000),
        laborCost: const Value(5000),
      )],
      odometerKm: 1400,
    );
    expect((await db.getServiceRecord(recordId))?.totalCost, 45000);
    expect((await db.getServiceItems(recordId)).single.componentTypeId, component.id);
    expect((await db.getLatestOdometer(motorcycleId))?.odometerKm, 1400);
    expect((await db.getOdometerLogs(motorcycleId)).length, 2);
    expect((await db.getServiceRecord(recordId))?.odometerKm, 1400);
    expect((await db.getComponentStatuses(motorcycleId)), isNotEmpty);
  });

  test('Readings from the same motor at the same second are both retained', () async {
    final motorcycleId = await addMotor();
    final first = (await db.getLatestOdometer(motorcycleId))!;
    final component = (await db.getAllComponentTypes()).first;

    final recordId = await db.createServiceWithItems(
      record: ServiceRecordsCompanion.insert(
        motorcycleId: motorcycleId,
        servicedAt: first.recordedAt,
      ),
      items: [ServiceItemsCompanion(
        componentTypeId: Value(component.id),
        action: const Value('inspect'),
      )],
      odometerKm: 1400,
    );
    final logs = await db.getOdometerLogs(motorcycleId);
    expect(logs.length, 2);
    expect(logs.map((l) => l.odometerKm), [1400, 1200]);
    expect(logs[0].recordedAt, logs[1].recordedAt);
    expect((await db.getServiceRecord(recordId))?.odometerKm, 1400);
    expect((await db.getLatestOdometer(motorcycleId))?.odometerKm, 1400);
  });

  test('Invalid service item rolls back record and odometer', () async {
    final motorcycleId = await addMotor();
    await expectLater(db.createServiceWithItems(
      record: ServiceRecordsCompanion.insert(
        motorcycleId: motorcycleId,
        servicedAt: DateTime.now(),
      ),
      items: [ServiceItemsCompanion(
        componentTypeId: const Value(999999),
        action: const Value('replace'),
      )],
      odometerKm: 1500,
    ), throwsA(isA<Exception>()));
    expect(await db.getServiceRecords(motorcycleId), isEmpty);
    expect((await db.getLatestOdometer(motorcycleId))?.odometerKm, 1200);
  });

  test('Upsert component status does not duplicate row', () async {
    final motorcycleId = await addMotor();
    final component = (await db.getAllComponentTypes()).first;
    final entry = ComponentStatusesCompanion.insert(
      motorcycleId: motorcycleId,
      componentTypeId: component.id,
      estimatedStatus: 'unknown',
      explanation: 'Insufficient evidence',
      calculatedAt: DateTime.now(),
      ruleVersion: 'unverified',
    );
    final id = await db.upsertComponentStatus(entry);
    final updated = await db.upsertComponentStatus(entry.copyWith(
      explanation: const Value('Updated without duplicate'),
    ));
    expect(id, updated);
    expect((await db.getComponentStatuses(motorcycleId)).length, 1);
  });

  test('Deleting motor removes dependent service, complaints, inspection and budget', () async {
    final motorcycleId = await addMotor();
    final another = await addMotor(name: 'Keep');
    final component = (await db.getAllComponentTypes()).first;
    final recordId = await db.createServiceWithItems(
      record: ServiceRecordsCompanion.insert(motorcycleId: motorcycleId, servicedAt: DateTime.now()),
      items: [ServiceItemsCompanion(
        componentTypeId: Value(component.id), action: const Value('inspect'),
      )],
    );
    await db.insertComplaint(ComplaintsCompanion.insert(
      motorcycleId: motorcycleId,
      title: 'Keluhan uji', description: 'Mesin berisik',
      resolvedByServiceId: Value(recordId),
    ));
    await db.insertBudgetPlan(BudgetPlansCompanion.insert(
      motorcycleId: motorcycleId, budgetAmount: 100000,
    ));
    await db.insertSelfInspection(SelfInspectionsCompanion.insert(
      motorcycleId: motorcycleId,
    ));
    await db.deleteMotorcycle(motorcycleId);
    expect(await db.getMotorcycle(motorcycleId), isNull);
    expect(await db.getServiceRecord(recordId), isNull);
    expect(await db.getComplaints(motorcycleId), isEmpty);
    expect(await db.getMotorcycle(another), isNotNull);
    expect((await db.getAllMotorcycles()).where((m) => m.isPrimary).length, 1);
  });

  test('Different models do not inherit each other specific rules', () async {
    final models = await db.getAllMotorcycleModels();
    final honda = models.firstWhere((m) => m.brand == 'Honda' && m.model == 'Vario 160');
    final yamaha = models.firstWhere((m) => m.brand == 'Yamaha' && m.model == 'NMAX');
    final component = (await db.getAllComponentTypes()).firstWhere((c) => c.name == 'Oli mesin');
    final hondaRules = await db.getMaintenanceRules(honda.id, component.id);
    final yamahaRules = await db.getMaintenanceRules(yamaha.id, component.id);
    expect(hondaRules.where((r) => r.modelId == yamaha.id), isEmpty);
    expect(yamahaRules.where((r) => r.modelId == honda.id), isEmpty);
  });
}
