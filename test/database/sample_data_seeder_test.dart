import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:buildhaus/core/database/app_database.dart';
import 'package:buildhaus/core/database/sample_data_seeder.dart';

void main() {
  late AppDatabase db;
  late SampleDataSeeder seeder;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    seeder = SampleDataSeeder(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('SampleDataSeeder - 3 Realistic Motorcycles', () {
    test('seeds 3 realistic motorcycles with full history', () async {
      final initialMotors = await db.getAllMotorcycles();
      expect(initialMotors, isEmpty);

      final createdIds = await seeder.seedRealisticSampleMotorcycles();
      expect(createdIds.length, 3);

      final allMotors = await db.getAllMotorcycles();
      expect(allMotors.length, 3);

      // Motor 1: Vario 160
      final vario = allMotors.firstWhere((m) => m.id == createdIds[0]);
      expect(vario.nickname, 'Vario 160 Hitam');
      expect(vario.plateNumber, 'B 4192 TZX');
      expect(vario.manufactureYear, 2023);
      expect(vario.usageProfile, 'harian_dalam_kota');
      expect(vario.isPrimary, isTrue);

      final varioOdoLogs = await db.getOdometerLogs(vario.id);
      expect(varioOdoLogs.length, 4); // initial + 3 logs
      final latestVarioOdo = await db.getLatestOdometer(vario.id);
      expect(latestVarioOdo?.odometerKm, 14500.0);

      final varioServices = await db.getServiceRecords(vario.id);
      expect(varioServices.length, 2);

      // Motor 2: Aerox 155
      final aerox = allMotors.firstWhere((m) => m.id == createdIds[1]);
      expect(aerox.nickname, 'Aerox Biru Doff');
      expect(aerox.plateNumber, 'D 5821 ABL');
      expect(aerox.manufactureYear, 2022);
      expect(aerox.usageProfile, 'jarak_jauh');
      expect(aerox.isPrimary, isFalse);

      final aeroxOdoLogs = await db.getOdometerLogs(aerox.id);
      expect(aeroxOdoLogs.length, 4);
      final latestAeroxOdo = await db.getLatestOdometer(aerox.id);
      expect(latestAeroxOdo?.odometerKm, 28200.0);

      final aeroxServices = await db.getServiceRecords(aerox.id);
      expect(aeroxServices.length, 2);

      // Motor 3: Beat Street
      final beat = allMotors.firstWhere((m) => m.id == createdIds[2]);
      expect(beat.nickname, 'Beat Street Putih');
      expect(beat.plateNumber, 'B 3804 KPM');
      expect(beat.manufactureYear, 2021);
      expect(beat.usageProfile, 'campuran');
      expect(beat.isPrimary, isFalse);

      final beatOdoLogs = await db.getOdometerLogs(beat.id);
      expect(beatOdoLogs.length, 4);
      final latestBeatOdo = await db.getLatestOdometer(beat.id);
      expect(latestBeatOdo?.odometerKm, 34100.0);

      final beatServices = await db.getServiceRecords(beat.id);
      expect(beatServices.length, 2);

      // Reminders created for all 3 motors
      final reminders = await db.getAllReminders();
      expect(reminders.isNotEmpty, isTrue);
    });

    test('calling seeder again without force does not duplicate data', () async {
      await seeder.seedRealisticSampleMotorcycles();
      final countBefore = (await db.getAllMotorcycles()).length;
      expect(countBefore, 3);

      final secondRun = await seeder.seedRealisticSampleMotorcycles();
      expect(secondRun.length, 3);

      final countAfter = (await db.getAllMotorcycles()).length;
      expect(countAfter, 3);
    });
  });
}
