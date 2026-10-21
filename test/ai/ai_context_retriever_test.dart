import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buildhaus/core/ai/ai_context_retriever.dart';
import 'package:buildhaus/core/database/app_database.dart';

void main() {
  late AppDatabase db;
  late AiContextRetriever retriever;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    retriever = AiContextRetriever(db: db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Tahap 04 — AI Context Retriever & Multi-Motor Isolation Tests', () {
    test(
      '1. Retrieves motorcycle context and formats prompt correctly',
      () async {
        // Seed motorcycle model
        final modelId = await db.insertMotorcycleModel(
          MotorcycleModelsCompanion.insert(
            brand: 'Honda',
            model: 'Vario 160',
            variant: const Value('CBS-ISS SP'),
            yearStart: 2022,
          ),
        );

        // Seed motorcycle
        final motorId = await db.insertMotorcycle(
          MotorcyclesCompanion.insert(
            modelId: Value(modelId),
            nickname: 'Si Hitam',
            manufactureYear: 2023,
            plateNumber: const Value('B 1234 CD'),
            usageProfile: const Value('komuter'),
          ),
        );

        // Seed odometer log
        await db.insertOdometerLog(
          OdometerLogsCompanion.insert(
            motorcycleId: motorId,
            odometerKm: 12500,
            recordedAt: DateTime.now().subtract(const Duration(days: 10)),
          ),
        );
        await db.insertOdometerLog(
          OdometerLogsCompanion.insert(
            motorcycleId: motorId,
            odometerKm: 12800,
            recordedAt: DateTime.now(),
          ),
        );

        // Seed service record
        await db.insertServiceRecord(
          ServiceRecordsCompanion.insert(
            motorcycleId: motorId,
            servicedAt: DateTime.now().subtract(const Duration(days: 30)),
            odometerKm: const Value(12000),
            notes: const Value('Ganti oli mesin MPX2'),
            totalCost: const Value(75000),
          ),
        );

        // Retrieve context
        final context = await retriever.retrieveContext(motorId);

        expect(context, isNotNull);
        expect(context!.motorcycle.nickname, equals('Si Hitam'));
        expect(context.motorcycleModel?.brand, equals('Honda'));
        expect(context.motorcycleModel?.model, equals('Vario 160'));
        expect(context.latestOdometerKm, equals(12800.0));
        expect(context.averageDailyKm, closeTo(30.0, 1.0));
        expect(context.recentServices.length, equals(1));

        // Test prompt formatting
        final promptText = context.toPromptContext();
        expect(promptText, contains('Si Hitam'));
        expect(promptText, contains('Honda Vario 160'));
        expect(promptText, contains('12800 km'));
        expect(promptText, contains('Ganti oli mesin MPX2'));
      },
    );

    test(
      '2. Multi-motorcycle isolation: Motor A context never bleeds into Motor B',
      () async {
        // Motor A
        final motorA = await db.insertMotorcycle(
          MotorcyclesCompanion.insert(
            nickname: 'Motor A - Honda Beat',
            manufactureYear: 2021,
            plateNumber: const Value('B 1111 AA'),
          ),
        );
        await db.insertComplaint(
          ComplaintsCompanion.insert(
            motorcycleId: motorA,
            title: 'CVT bunyi decit di Motor A',
            description: 'Bunyi decit di RPM rendah',
          ),
        );

        // Motor B
        final motorB = await db.insertMotorcycle(
          MotorcyclesCompanion.insert(
            nickname: 'Motor B - Yamaha Aerox',
            manufactureYear: 2022,
            plateNumber: const Value('D 2222 BB'),
          ),
        );
        await db.insertComplaint(
          ComplaintsCompanion.insert(
            motorcycleId: motorB,
            title: 'Shock belakang keras di Motor B',
            description: 'Terasa keras saat boncengan',
          ),
        );

        // Retrieve Motor A
        final contextA = await retriever.retrieveContext(motorA);
        final promptA = contextA!.toPromptContext();

        expect(promptA, contains('Motor A - Honda Beat'));
        expect(promptA, contains('CVT bunyi decit di Motor A'));
        expect(promptA, isNot(contains('Motor B - Yamaha Aerox')));
        expect(promptA, isNot(contains('Shock belakang keras di Motor B')));

        // Retrieve Motor B
        final contextB = await retriever.retrieveContext(motorB);
        final promptB = contextB!.toPromptContext();

        expect(promptB, contains('Motor B - Yamaha Aerox'));
        expect(promptB, contains('Shock belakang keras di Motor B'));
        expect(promptB, isNot(contains('Motor A - Honda Beat')));
        expect(promptB, isNot(contains('CVT bunyi decit di Motor A')));
      },
    );

    test(
      '3. Detects recurring similar complaints and adds context note',
      () async {
        final motorId = await db.insertMotorcycle(
          MotorcyclesCompanion.insert(
            nickname: 'Scoopy Harian',
            manufactureYear: 2020,
          ),
        );

        // Past complaint about CVT
        await db.insertComplaint(
          ComplaintsCompanion.insert(
            motorcycleId: motorId,
            title: 'Gredek CVT saat akselerasi',
            description: 'Getar parah di CVT saat mulai jalan',
          ),
        );

        final context = await retriever.retrieveContext(motorId);
        final prompt = context!.toPromptContext(
          currentComplaintText: 'Ada getaran gredek lagi di bagian CVT',
        );

        expect(prompt, contains('CATATAN KELUHAN SERUPA:'));
        expect(prompt, contains('Gredek CVT saat akselerasi'));
      },
    );
  });
}
