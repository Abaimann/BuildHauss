import 'package:drift/drift.dart';
import 'app_database.dart';
import '../engines/reminder_engine.dart';

/// Seeder for realistic sample motorcycle data.
/// Populates 3 realistic Indonesian motorcycle profiles with complete history:
/// 1. Honda Vario 160 (Primary, 2023, Plat B DKI, harian)
/// 2. Yamaha Aerox 155 (2022, Plat D Bandung, jarak jauh)
/// 3. Honda Beat Street (2021, Plat B Bekasi, campuran)
class SampleDataSeeder {
  final AppDatabase db;

  const SampleDataSeeder(this.db);

  /// Seeds 3 realistic sample motorcycles with odometer logs, service records,
  /// component statuses for all 14 parts, and synchronized reminders.
  /// If [force] is true, previous user data is cleared before seeding.
  /// If [force] is false (default), it skips seeding if any motorcycle already exists.
  Future<List<int>> seedRealisticSampleMotorcycles({bool force = false}) async {
    final existing = await db.getAllMotorcycles();
    if (existing.isNotEmpty && !force) {
      return existing.map((m) => m.id).toList();
    }

    if (force) {
      await db.clearAllUserData();
    }

    await db.ensureReferenceData();
    final models = await db.getAllMotorcycleModels();
    final componentTypes = await db.getAllComponentTypes();

    final varioModel = models.firstWhere(
      (m) => m.brand.toLowerCase() == 'honda' && m.model.contains('Vario 160'),
      orElse: () => models.firstWhere(
        (m) => m.brand.toLowerCase() == 'honda',
        orElse: () => models.first,
      ),
    );
    final aeroxModel = models.firstWhere(
      (m) => m.brand.toLowerCase() == 'yamaha' && m.model.contains('Aerox'),
      orElse: () => models.firstWhere(
        (m) => m.brand.toLowerCase() == 'yamaha',
        orElse: () => models.first,
      ),
    );
    final beatModel = models.firstWhere(
      (m) => m.brand.toLowerCase() == 'honda' && m.model.contains('Beat'),
      orElse: () => models.first,
    );

    // Retrieve all 14 component types
    final oliMesin = componentTypes.firstWhere(
      (c) => c.name.toLowerCase().contains('oli mesin'),
      orElse: () => componentTypes.first,
    );
    final kampasRem = componentTypes.firstWhere(
      (c) => c.name.toLowerCase().contains('kampas rem'),
      orElse: () => componentTypes.first,
    );
    final aki = componentTypes.firstWhere(
      (c) => c.name.toLowerCase().contains('aki'),
      orElse: () => componentTypes.first,
    );
    final ban = componentTypes.firstWhere(
      (c) => c.name.toLowerCase().contains('ban'),
      orElse: () => componentTypes.first,
    );
    final filterUdara = componentTypes.firstWhere(
      (c) => c.name.toLowerCase().contains('filter udara'),
      orElse: () => componentTypes.first,
    );
    final busi = componentTypes.firstWhere(
      (c) => c.name.toLowerCase().contains('busi'),
      orElse: () => componentTypes.first,
    );
    final cvt = componentTypes.firstWhere(
      (c) => c.name.toLowerCase().contains('cvt'),
      orElse: () => componentTypes.first,
    );
    final knalpot = componentTypes.firstWhere(
      (c) => c.name.toLowerCase().contains('knalpot'),
      orElse: () => componentTypes.first,
    );
    final oliGardan = componentTypes.firstWhere(
      (c) => c.name.toLowerCase().contains('oli gardan'),
      orElse: () => oliMesin,
    );
    final minyakRem = componentTypes.firstWhere(
      (c) => c.name.toLowerCase().contains('minyak rem'),
      orElse: () => kampasRem,
    );
    final coolant = componentTypes.firstWhere(
      (c) => c.name.toLowerCase().contains('radiator coolant'),
      orElse: () => filterUdara,
    );
    final rantaiGir = componentTypes.firstWhere(
      (c) => c.name.toLowerCase().contains('rantai'),
      orElse: () => cvt,
    );
    final suspensi = componentTypes.firstWhere(
      (c) => c.name.toLowerCase().contains('suspensi'),
      orElse: () => componentTypes.first,
    );
    final filterOli = componentTypes.firstWhere(
      (c) => c.name.toLowerCase().contains('filter oli'),
      orElse: () => oliMesin,
    );

    final createdIds = <int>[];
    final now = DateTime.now();

    // ====================================================
    // MOTOR 1: Honda Vario 160 (Primary)
    // ====================================================
    final motor1Id = await db.createMotorcycle(
      motorcycle: MotorcyclesCompanion.insert(
        modelId: Value(varioModel.id),
        nickname: 'Vario 160 Hitam',
        manufactureYear: 2023,
        plateNumber: const Value('B 4192 TZX'),
        emoji: const Value('🛵'),
        usageProfile: const Value('harian_dalam_kota'),
      ),
    );
    createdIds.add(motor1Id);

    // Initial baseline odometer: 95 days ago at 12000 km
    await db.insertOdometerLog(
      OdometerLogsCompanion.insert(
        motorcycleId: motor1Id,
        odometerKm: 12000.0,
        recordedAt: now.subtract(const Duration(days: 95)),
        source: const Value('manual'),
        note: const Value('Odometer awal pencatatan'),
      ),
    );

    // Service 1: 65 days ago at 13000 km (covers 10 components)
    await db.createServiceWithItems(
      record: ServiceRecordsCompanion.insert(
        motorcycleId: motor1Id,
        servicedAt: now.subtract(const Duration(days: 65)),
        odometerKm: const Value(13000.0),
        workshopName: const Value('AHASS Astra Motor Dewi Sartika'),
        notes: const Value(
          'Servis berkala 13.000 km: ganti busi, filter, oli gardan, CVT, coolant, & part kelistrikan.',
        ),
      ),
      items: [
        ServiceItemsCompanion.insert(
          serviceRecordId: 0,
          componentTypeId: Value(oliMesin.id),
          action: 'replace',
          partsCost: const Value(55000),
          laborCost: const Value(15000),
          notes: const Value('AHM Oil SPX2 0.8L'),
        ),
        ServiceItemsCompanion.insert(
          serviceRecordId: 0,
          componentTypeId: Value(filterOli.id),
          action: 'replace',
          partsCost: const Value(18000),
          laborCost: const Value(10000),
          notes: const Value('Saringan Kasa Filter Oli Honda Vario 160'),
        ),
        ServiceItemsCompanion.insert(
          serviceRecordId: 0,
          componentTypeId: Value(busi.id),
          action: 'replace',
          partsCost: const Value(35000),
          laborCost: const Value(10000),
          notes: const Value('Busi NGK CPR8EA-9 standard'),
        ),
        ServiceItemsCompanion.insert(
          serviceRecordId: 0,
          componentTypeId: Value(filterUdara.id),
          action: 'replace',
          partsCost: const Value(45000),
          laborCost: const Value(10000),
          notes: const Value('Filter Udara Honda Genuine Vario 160'),
        ),
        ServiceItemsCompanion.insert(
          serviceRecordId: 0,
          componentTypeId: Value(oliGardan.id),
          action: 'replace',
          partsCost: const Value(16000),
          laborCost: const Value(5000),
          notes: const Value('AHM Oil Scooter Gear Oil 120ml'),
        ),
        ServiceItemsCompanion.insert(
          serviceRecordId: 0,
          componentTypeId: Value(cvt.id),
          action: 'replace',
          partsCost: const Value(135000),
          laborCost: const Value(40000),
          notes: const Value('Paket Roller & V-Belt Kit Vario 160'),
        ),
        ServiceItemsCompanion.insert(
          serviceRecordId: 0,
          componentTypeId: Value(coolant.id),
          action: 'replace',
          partsCost: const Value(24000),
          laborCost: const Value(10000),
          notes: const Value('AHM Radiator Coolant Pre-mix 1L'),
        ),
        ServiceItemsCompanion.insert(
          serviceRecordId: 0,
          componentTypeId: Value(aki.id),
          action: 'replace',
          partsCost: const Value(180000),
          laborCost: const Value(10000),
          notes: const Value('Aki GS GTZ6V MF Sealed'),
        ),
        ServiceItemsCompanion.insert(
          serviceRecordId: 0,
          componentTypeId: Value(suspensi.id),
          action: 'replace',
          partsCost: const Value(65000),
          laborCost: const Value(35000),
          notes: const Value('Servis Shock Depan & Ganti Seal Oli'),
        ),
        ServiceItemsCompanion.insert(
          serviceRecordId: 0,
          componentTypeId: Value(knalpot.id),
          action: 'replace',
          partsCost: const Value(15000),
          laborCost: const Value(10000),
          notes: const Value('Gasket Paking Knalpot Tembaga Matic'),
        ),
        ServiceItemsCompanion.insert(
          serviceRecordId: 0,
          componentTypeId: Value(rantaiGir.id),
          action: 'replace',
          partsCost: const Value(85000),
          laborCost: const Value(25000),
          notes: const Value('Final Gear Bearing Set Matic'),
        ),
      ],
      odometerKm: 13000.0,
    );

    // Service 2: 35 days ago at 14000 km (covers remaining 4 components: oli mesin, kampas rem, minyak rem, ban)
    await db.createServiceWithItems(
      record: ServiceRecordsCompanion.insert(
        motorcycleId: motor1Id,
        servicedAt: now.subtract(const Duration(days: 35)),
        odometerKm: const Value(14000.0),
        workshopName: const Value('AHASS Astra Motor Dewi Sartika'),
        notes: const Value(
          'Servis berkala 14.000 km: ganti oli mesin, kampas rem depan, minyak rem DOT 4, dan ban.',
        ),
      ),
      items: [
        ServiceItemsCompanion.insert(
          serviceRecordId: 0,
          componentTypeId: Value(oliMesin.id),
          action: 'replace',
          partsCost: const Value(55000),
          laborCost: const Value(15000),
          notes: const Value('AHM Oil SPX2 0.8L'),
        ),
        ServiceItemsCompanion.insert(
          serviceRecordId: 0,
          componentTypeId: Value(kampasRem.id),
          action: 'replace',
          partsCost: const Value(48000),
          laborCost: const Value(15000),
          notes: const Value('Kampas Rem Depan Honda Vario 160'),
        ),
        ServiceItemsCompanion.insert(
          serviceRecordId: 0,
          componentTypeId: Value(minyakRem.id),
          action: 'replace',
          partsCost: const Value(18000),
          laborCost: const Value(10000),
          notes: const Value('Honda Genuine Brake Fluid DOT 4 50ml'),
        ),
        ServiceItemsCompanion.insert(
          serviceRecordId: 0,
          componentTypeId: Value(ban.id),
          action: 'replace',
          partsCost: const Value(245000),
          laborCost: const Value(25000),
          notes: const Value('Ban IRC Fasti Tubeless 100/80-14'),
        ),
      ],
      odometerKm: 14000.0,
    );

    // Latest odometer reading: 1 day ago at 14500 km
    await db.insertOdometerLog(
      OdometerLogsCompanion.insert(
        motorcycleId: motor1Id,
        odometerKm: 14500.0,
        recordedAt: now.subtract(const Duration(days: 1)),
        source: const Value('manual'),
        note: const Value('Odometer terkini'),
      ),
    );

    // Self Inspection for Vario 160
    await db.saveCompleteSelfInspection(
      motorcycleId: motor1Id,
      riskLevel: 'aman',
      answers: {
        'rem_respons': 'normal',
        'rem_bunyi': 'hening',
        'kebocoran_cairan': 'bersih',
        'ban_kondisi': 'bagus',
        'kemudi_stang': 'lurus_stabil',
        'kelistrikan_lampu': 'menyala_terang',
        'mesin_suara': 'halus',
        'cvt_transmisi': 'mulus',
      },
      notes: 'Pemeriksaan mandiri: kondisi motor sangat terawat dan siap pakai.',
    );

    // Budget Plan for Vario 160
    await db.saveCompleteBudgetPlan(
      motorcycleId: motor1Id,
      budgetAmount: 500000,
      period: 'bulanan',
      recommendations: [],
      notes: 'Alokasi budget bulanan perawatan Honda Vario 160',
    );

    // AI Consultation for Vario 160
    final complaint1Id = await db.insertComplaint(
      ComplaintsCompanion.insert(
        motorcycleId: motor1Id,
        openedAt: Value(now.subtract(const Duration(days: 15))),
        title: 'Getaran CVT pada tarikan awal',
        description:
            'Ada getaran halus di CVT saat motor mulai jalan dari posisi berhenti.',
        status: const Value('analyzed'),
      ),
    );
    await db.insertComplaintMessage(
      ComplaintMessagesCompanion.insert(
        complaintId: complaint1Id,
        role: 'user',
        content:
            'Halo, Vario 160 saya saat tarikan awal dari berhenti ada getaran seperti gredek halus di bagian CVT. Kira-kira kenapa ya?',
        createdAt: Value(now.subtract(const Duration(days: 15))),
      ),
    );
    await db.insertComplaintMessage(
      ComplaintMessagesCompanion.insert(
        complaintId: complaint1Id,
        role: 'assistant',
        content:
            'Halo! Gejala gredek tarikan awal pada skutik Honda umumnya disebabkan oleh kotoran residu kampas ganda di mangkok kopling CVT. Solusinya cukup lakukan servis pembersihan mangkok CVT dan pemberian gemuk/grease CVT baru di bengkel.',
        createdAt: Value(now.subtract(const Duration(days: 15))),
      ),
    );
    await db.insertComplaintAnalysis(
      ComplaintAnalysesCompanion.insert(
        complaintId: complaint1Id,
        analyzedAt: Value(now.subtract(const Duration(days: 15))),
        analysisMode: 'rule_based',
        riskLevel: 'rendah',
        summary: 'Pembersihan mangkok kopling ganda & grease CVT',
        symptomsJson: '["gredek_awal", "getaran_cvt"]',
        componentCandidatesJson: const Value('["CVT"]'),
      ),
    );

    // ====================================================
    // MOTOR 2: Yamaha Aerox 155
    // ====================================================
    final motor2Id = await db.createMotorcycle(
      motorcycle: MotorcyclesCompanion.insert(
        modelId: Value(aeroxModel.id),
        nickname: 'Aerox Biru Doff',
        manufactureYear: 2022,
        plateNumber: const Value('D 5821 ABL'),
        emoji: const Value('🏍️'),
        usageProfile: const Value('jarak_jauh'),
      ),
    );
    createdIds.add(motor2Id);

    // Initial baseline odometer: 100 days ago at 25000 km
    await db.insertOdometerLog(
      OdometerLogsCompanion.insert(
        motorcycleId: motor2Id,
        odometerKm: 25000.0,
        recordedAt: now.subtract(const Duration(days: 100)),
        source: const Value('manual'),
        note: const Value('Odometer awal pencatatan'),
      ),
    );

    // Service 1: 70 days ago at 26200 km (covers 12 components)
    await db.createServiceWithItems(
      record: ServiceRecordsCompanion.insert(
        motorcycleId: motor2Id,
        servicedAt: now.subtract(const Duration(days: 70)),
        odometerKm: const Value(26200.0),
        workshopName: const Value('Yamaha Flagship Shop Bandung'),
        notes: const Value(
          'Servis besar 26.200 km: CVT kit, oli gardan, filter oli, coolant, suspensi, paking knalpot & busi.',
        ),
      ),
      items: [
        ServiceItemsCompanion.insert(
          serviceRecordId: 0,
          componentTypeId: Value(oliMesin.id),
          action: 'replace',
          partsCost: const Value(65000),
          laborCost: const Value(20000),
          notes: const Value('Yamalube Super Matic 1L 10W-40'),
        ),
        ServiceItemsCompanion.insert(
          serviceRecordId: 0,
          componentTypeId: Value(cvt.id),
          action: 'replace',
          partsCost: const Value(145000),
          laborCost: const Value(45000),
          notes: const Value('Yamaha V-Belt & Roller Kit Aerox Original'),
        ),
        ServiceItemsCompanion.insert(
          serviceRecordId: 0,
          componentTypeId: Value(oliGardan.id),
          action: 'replace',
          partsCost: const Value(17500),
          laborCost: const Value(5000),
          notes: const Value('Yamalube Motor Gear Oil 100ml'),
        ),
        ServiceItemsCompanion.insert(
          serviceRecordId: 0,
          componentTypeId: Value(filterOli.id),
          action: 'replace',
          partsCost: const Value(28000),
          laborCost: const Value(10000),
          notes: const Value('Filter Oli Yamaha NMAX/Aerox Original'),
        ),
        ServiceItemsCompanion.insert(
          serviceRecordId: 0,
          componentTypeId: Value(filterUdara.id),
          action: 'replace',
          partsCost: const Value(55000),
          laborCost: const Value(10000),
          notes: const Value('Filter Udara Yamaha Aerox Original'),
        ),
        ServiceItemsCompanion.insert(
          serviceRecordId: 0,
          componentTypeId: Value(busi.id),
          action: 'replace',
          partsCost: const Value(55000),
          laborCost: const Value(10000),
          notes: const Value('NGK CPR8EA-9 Busi Iridium Aerox'),
        ),
        ServiceItemsCompanion.insert(
          serviceRecordId: 0,
          componentTypeId: Value(coolant.id),
          action: 'replace',
          partsCost: const Value(35000),
          laborCost: const Value(15000),
          notes: const Value('Yamacoolant Pre-mix 1L'),
        ),
        ServiceItemsCompanion.insert(
          serviceRecordId: 0,
          componentTypeId: Value(minyakRem.id),
          action: 'replace',
          partsCost: const Value(22000),
          laborCost: const Value(10000),
          notes: const Value('Yamalube Brake Fluid DOT 4'),
        ),
        ServiceItemsCompanion.insert(
          serviceRecordId: 0,
          componentTypeId: Value(aki.id),
          action: 'replace',
          partsCost: const Value(195000),
          laborCost: const Value(10000),
          notes: const Value('Aki Yuasa YTZ6V MF Sealed'),
        ),
        ServiceItemsCompanion.insert(
          serviceRecordId: 0,
          componentTypeId: Value(ban.id),
          action: 'replace',
          partsCost: const Value(320000),
          laborCost: const Value(30000),
          notes: const Value('Ban Michelin Pilot Street 110/80-14 Tubeless'),
        ),
        ServiceItemsCompanion.insert(
          serviceRecordId: 0,
          componentTypeId: Value(suspensi.id),
          action: 'replace',
          partsCost: const Value(75000),
          laborCost: const Value(40000),
          notes: const Value('Servis Shock Depan & Ganti Oli Suspensi'),
        ),
        ServiceItemsCompanion.insert(
          serviceRecordId: 0,
          componentTypeId: Value(knalpot.id),
          action: 'replace',
          partsCost: const Value(18000),
          laborCost: const Value(15000),
          notes: const Value('Paking Knalpot Yamaha Aerox Original'),
        ),
        ServiceItemsCompanion.insert(
          serviceRecordId: 0,
          componentTypeId: Value(rantaiGir.id),
          action: 'replace',
          partsCost: const Value(95000),
          laborCost: const Value(30000),
          notes: const Value('Final Gear Bearing Set Yamaha Matic'),
        ),
      ],
      odometerKm: 26200.0,
    );

    // Service 2: 35 days ago at 27400 km (covers oli mesin & kampas rem)
    await db.createServiceWithItems(
      record: ServiceRecordsCompanion.insert(
        motorcycleId: motor2Id,
        servicedAt: now.subtract(const Duration(days: 35)),
        odometerKm: const Value(27400.0),
        workshopName: const Value('Yamaha Flagship Shop Bandung'),
        notes: const Value(
          'Servis rutin 27.400 km: ganti oli Yamalube & kampas rem depan original.',
        ),
      ),
      items: [
        ServiceItemsCompanion.insert(
          serviceRecordId: 0,
          componentTypeId: Value(oliMesin.id),
          action: 'replace',
          partsCost: const Value(65000),
          laborCost: const Value(20000),
          notes: const Value('Yamalube Super Matic 1L 10W-40'),
        ),
        ServiceItemsCompanion.insert(
          serviceRecordId: 0,
          componentTypeId: Value(kampasRem.id),
          action: 'replace',
          partsCost: const Value(55000),
          laborCost: const Value(15000),
          notes: const Value('Kampas Rem Depan Yamaha NMAX/Aerox Original'),
        ),
      ],
      odometerKm: 27400.0,
    );

    // Latest odometer reading: 2 days ago at 28200 km
    await db.insertOdometerLog(
      OdometerLogsCompanion.insert(
        motorcycleId: motor2Id,
        odometerKm: 28200.0,
        recordedAt: now.subtract(const Duration(days: 2)),
        source: const Value('manual'),
        note: const Value('Odometer terkini'),
      ),
    );

    // Budget Plan for Aerox 155
    await db.saveCompleteBudgetPlan(
      motorcycleId: motor2Id,
      budgetAmount: 750000,
      period: 'bulanan',
      recommendations: [],
      notes: 'Alokasi budget bulanan touring Yamaha Aerox 155',
    );

    // ====================================================
    // MOTOR 3: Honda Beat Street
    // ====================================================
    final motor3Id = await db.createMotorcycle(
      motorcycle: MotorcyclesCompanion.insert(
        modelId: Value(beatModel.id),
        nickname: 'Beat Street Putih',
        manufactureYear: 2021,
        plateNumber: const Value('B 3804 KPM'),
        emoji: const Value('🛵'),
        usageProfile: const Value('campuran'),
      ),
    );
    createdIds.add(motor3Id);

    // Initial baseline odometer: 100 days ago at 31000 km
    await db.insertOdometerLog(
      OdometerLogsCompanion.insert(
        motorcycleId: motor3Id,
        odometerKm: 31000.0,
        recordedAt: now.subtract(const Duration(days: 100)),
        source: const Value('manual'),
        note: const Value('Odometer awal pencatatan'),
      ),
    );

    // Service 1: 70 days ago at 31800 km (covers 12 components)
    await db.createServiceWithItems(
      record: ServiceRecordsCompanion.insert(
        motorcycleId: motor3Id,
        servicedAt: now.subtract(const Duration(days: 70)),
        odometerKm: const Value(31800.0),
        workshopName: const Value('Bengkel Mitra Rejeki Motor'),
        notes: const Value(
          'Servis besar 31.800 km: ganti ban, oli mesin, CVT, kampas rem, aki, oli gardan & part pelindung.',
        ),
      ),
      items: [
        ServiceItemsCompanion.insert(
          serviceRecordId: 0,
          componentTypeId: Value(oliMesin.id),
          action: 'replace',
          partsCost: const Value(48000),
          laborCost: const Value(15000),
          notes: const Value('AHM Oil MPX2 0.8L'),
        ),
        ServiceItemsCompanion.insert(
          serviceRecordId: 0,
          componentTypeId: Value(ban.id),
          action: 'replace',
          partsCost: const Value(195000),
          laborCost: const Value(25000),
          notes: const Value('Ban FDR Sport Zevo 90/80-14 Tubeless'),
        ),
        ServiceItemsCompanion.insert(
          serviceRecordId: 0,
          componentTypeId: Value(oliGardan.id),
          action: 'replace',
          partsCost: const Value(16000),
          laborCost: const Value(5000),
          notes: const Value('AHM Oil Scooter Gear Oil 120ml'),
        ),
        ServiceItemsCompanion.insert(
          serviceRecordId: 0,
          componentTypeId: Value(kampasRem.id),
          action: 'replace',
          partsCost: const Value(35000),
          laborCost: const Value(15000),
          notes: const Value('Kampas Rem Depan Honda Beat Original'),
        ),
        ServiceItemsCompanion.insert(
          serviceRecordId: 0,
          componentTypeId: Value(cvt.id),
          action: 'replace',
          partsCost: const Value(85000),
          laborCost: const Value(30000),
          notes: const Value('Roller Beat & V-Belt Bando Kit'),
        ),
        ServiceItemsCompanion.insert(
          serviceRecordId: 0,
          componentTypeId: Value(aki.id),
          action: 'replace',
          partsCost: const Value(165000),
          laborCost: const Value(10000),
          notes: const Value('Aki GS GTZ5S MF Sealed Beat'),
        ),
        ServiceItemsCompanion.insert(
          serviceRecordId: 0,
          componentTypeId: Value(minyakRem.id),
          action: 'replace',
          partsCost: const Value(18000),
          laborCost: const Value(10000),
          notes: const Value('Honda Genuine Brake Fluid DOT 4'),
        ),
        ServiceItemsCompanion.insert(
          serviceRecordId: 0,
          componentTypeId: Value(coolant.id),
          action: 'replace',
          partsCost: const Value(22000),
          laborCost: const Value(10000),
          notes: const Value('Prestone Radiator Coolant 1L'),
        ),
        ServiceItemsCompanion.insert(
          serviceRecordId: 0,
          componentTypeId: Value(filterOli.id),
          action: 'replace',
          partsCost: const Value(18000),
          laborCost: const Value(10000),
          notes: const Value('Saringan Kasa Filter Oli Honda'),
        ),
        ServiceItemsCompanion.insert(
          serviceRecordId: 0,
          componentTypeId: Value(suspensi.id),
          action: 'replace',
          partsCost: const Value(55000),
          laborCost: const Value(25000),
          notes: const Value('Servis Shockbreaker Belakang Beat'),
        ),
        ServiceItemsCompanion.insert(
          serviceRecordId: 0,
          componentTypeId: Value(knalpot.id),
          action: 'replace',
          partsCost: const Value(15000),
          laborCost: const Value(10000),
          notes: const Value('Gasket Paking Knalpot Tembaga'),
        ),
        ServiceItemsCompanion.insert(
          serviceRecordId: 0,
          componentTypeId: Value(rantaiGir.id),
          action: 'replace',
          partsCost: const Value(65000),
          laborCost: const Value(25000),
          notes: const Value('Final Gear Inspection & Bearing Matic'),
        ),
      ],
      odometerKm: 31800.0,
    );

    // Service 2: 35 days ago at 33300 km (covers filter udara & busi)
    await db.createServiceWithItems(
      record: ServiceRecordsCompanion.insert(
        motorcycleId: motor3Id,
        servicedAt: now.subtract(const Duration(days: 35)),
        odometerKm: const Value(33300.0),
        workshopName: const Value('Bengkel Mitra Rejeki Motor'),
        notes: const Value('Servis rutin: ganti filter udara dan busi baru.'),
      ),
      items: [
        ServiceItemsCompanion.insert(
          serviceRecordId: 0,
          componentTypeId: Value(filterUdara.id),
          action: 'replace',
          partsCost: const Value(28000),
          laborCost: const Value(10000),
          notes: const Value('Filter Udara Honda Genuine Beat'),
        ),
        ServiceItemsCompanion.insert(
          serviceRecordId: 0,
          componentTypeId: Value(busi.id),
          action: 'replace',
          partsCost: const Value(25000),
          laborCost: const Value(10000),
          notes: const Value('NGK CR7HSA Busi Standard Beat'),
        ),
      ],
      odometerKm: 33300.0,
    );

    // Latest odometer reading: 3 days ago at 34100 km
    await db.insertOdometerLog(
      OdometerLogsCompanion.insert(
        motorcycleId: motor3Id,
        odometerKm: 34100.0,
        recordedAt: now.subtract(const Duration(days: 3)),
        source: const Value('manual'),
        note: const Value('Odometer terkini'),
      ),
    );

    // Self Inspection for Beat Street
    await db.saveCompleteSelfInspection(
      motorcycleId: motor3Id,
      riskLevel: 'perhatian',
      answers: {
        'rem_respons': 'normal',
        'rem_bunyi': 'gesekan_ringan',
        'kebocoran_cairan': 'bersih',
        'ban_kondisi': 'menipis',
        'kemudi_stang': 'agak_berat',
        'kelistrikan_lampu': 'menyala_terang',
        'mesin_suara': 'halus',
        'cvt_transmisi': 'mulus',
      },
      notes:
          'Rem sedikit berdecit saat basah, tekanan angin ban depan terasa kurang.',
    );

    // Budget Plan for Beat Street
    await db.saveCompleteBudgetPlan(
      motorcycleId: motor3Id,
      budgetAmount: 350000,
      period: 'bulanan',
      recommendations: [],
      notes: 'Alokasi budget bulanan komuter Honda Beat Street',
    );

    // AI Consultation for Beat Street
    final complaint3Id = await db.insertComplaint(
      ComplaintsCompanion.insert(
        motorcycleId: motor3Id,
        openedAt: Value(now.subtract(const Duration(days: 20))),
        title: 'Rem depan agak berdecit',
        description: 'Saat mengerem setelah hujan ada bunyi decit halus.',
        status: const Value('resolved'),
      ),
    );
    await db.insertComplaintMessage(
      ComplaintMessagesCompanion.insert(
        complaintId: complaint3Id,
        role: 'user',
        content:
            'Rem depan motor Beat saya suka bunyi decit halus kalau habis lewat jalan becek.',
        createdAt: Value(now.subtract(const Duration(days: 20))),
      ),
    );
    await db.insertComplaintMessage(
      ComplaintMessagesCompanion.insert(
        complaintId: complaint3Id,
        role: 'assistant',
        content:
            'Bunyi decitan halus setelah hujan atau jalan berdebu biasanya disebabkan oleh partikel pasir/debu menempel di cakram rem. Cukup cuci bersih atau semprot brake cleaner di area kaliper rem.',
        createdAt: Value(now.subtract(const Duration(days: 20))),
      ),
    );
    await db.insertComplaintAnalysis(
      ComplaintAnalysesCompanion.insert(
        complaintId: complaint3Id,
        analyzedAt: Value(now.subtract(const Duration(days: 20))),
        analysisMode: 'rule_based',
        riskLevel: 'rendah',
        summary: 'Pembersihan piringan cakram dengan air atau brake cleaner',
        symptomsJson: '["rem_bunyi", "decit_hujan"]',
        componentCandidatesJson: const Value('["Kampas rem"]'),
      ),
    );

    // Recalculate component statuses and synchronize reminders for each motorcycle
    final reminderEngine = ReminderEngine(db: db);
    for (final id in createdIds) {
      await db.recalculateComponentStatuses(id);
      await reminderEngine.syncRemindersForMotorcycle(id);
    }

    return createdIds;
  }
}
