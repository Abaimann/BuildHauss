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

  /// Mendaftarkan 5 jenis motor yang berbeda beserta data lengkap lintas
  /// 3 merek resmi (Honda, Yamaha, Kawasaki):
  /// 1. Honda Vario 160 — Skutik Maxi Harian (Matic, Radiator)
  /// 2. Yamaha NMAX — Skutik Touring Premium (Matic, Radiator)
  /// 3. Kawasaki KLX 150 — Motor Trail / Dual-Sport (Manual Rantai, Air-Cooled, Karburator)
  /// 4. Honda CBR150R — Motor Sport Fairing 150cc (Manual Rantai, Radiator)
  /// 5. Kawasaki W175 — Motor Retro Klasik (Manual Rantai, Air-Cooled, Karburator)
  Future<List<int>> seedDiverseFiveMotorcycles({bool force = false}) async {
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
    final spareparts = await db.getAllSpareparts();

    MotorcycleModel findModel(String brand, String keyword) {
      return models.firstWhere(
        (m) =>
            m.brand.toLowerCase() == brand.toLowerCase() &&
            m.model.toLowerCase().contains(keyword.toLowerCase()),
        orElse: () => models.firstWhere(
          (m) => m.brand.toLowerCase() == brand.toLowerCase(),
          orElse: () => models.first,
        ),
      );
    }

    int? findComponentId(String keyword) {
      final k = keyword.toLowerCase();
      for (final c in componentTypes) {
        if (c.name.toLowerCase().contains(k)) return c.id;
      }
      return null;
    }

    int? findSparepartId(String? keyword) {
      if (keyword == null || keyword.isEmpty) return null;
      final k = keyword.toLowerCase();
      for (final p in spareparts) {
        if (p.name.toLowerCase().contains(k)) return p.id;
      }
      return null;
    }

    final specs = <_DiverseMotorSpec>[
      _DiverseMotorSpec(
        brand: 'Honda',
        modelKeyword: 'Vario 160',
        nickname: 'Vario 160 Maxi Harian',
        manufactureYear: 2024,
        plateNumber: 'B 4512 VRO',
        emoji: '🛵',
        usageProfile: 'harian_dalam_kota',
        isPrimary: true,
        baselineDaysAgo: 95,
        baselineKm: 9200,
        baselineNote: 'Odometer awal pencatatan skutik harian',
        odometerLogs: const [
          (60, 10450.0, 'Update bulanan rute kantor Jakarta'),
          (30, 11680.0, 'Catat kilometer sebelum servis berkala'),
          (4, 12450.0, 'Pencatatan terbaru akhir pekan'),
        ],
        services: const [
          _SeedServiceSpec(
            daysAgo: 25,
            odometerKm: 11850.0,
            workshop: 'AHASS Astra Motor Dewi Sartika',
            notes: 'Servis berkala 12.000 km: ganti oli mesin, gardan & kuras coolant.',
            resolveComplaints: true,
            items: [
              ('oli mesin', 'spx2', 'replace', 65000, 15000, 'AHM Oil SPX2 10W-30 0.8L'),
              ('oli gardan', 'ahm oil scooter gear', 'replace', 18000, 10000, 'AHM Oil Scooter Gear Oil 120ml'),
              ('radiator coolant', 'ahm radiator coolant', 'replace', 24000, 15000, 'AHM Radiator Coolant Pre-mix 1L'),
              ('kampas rem', 'kampas', 'inspect', 0, 10000, 'Kampas rem depan masih tebal 70%'),
            ],
          ),
          _SeedServiceSpec(
            daysAgo: 9,
            odometerKm: 12250.0,
            workshop: 'Spooring & Steam BuildHaus Point',
            notes: 'Perawatan bodi & cek tekanan ban tubeless',
            resolveComplaints: false,
            items: [
              ('ban', 'ban', 'repair', 35000, 25000, 'Isi nitrogen & tambal ban belakang'),
            ],
          ),
        ],
        inspectionRisk: 'rendah',
        inspectionAnswers: const {
          'oli': 'bersih',
          'rem': 'pakem',
          'ban': 'baik',
          'mesin': 'halus',
        },
        inspectionNotes: 'Kondisi prima untuk komuter harian dalam kota.',
        budgetAmount: 450000,
        budgetNotes: 'Budget perawatan bulanan Honda Vario 160',
        complaint: _SeedComplaintSpec(
          daysAgo: 6,
          title: 'Tarikan awal sedikit berat saat macet',
          description: 'Saat stop & go di kemacetan terasa sedikit gredek ringan.',
          status: 'open',
          userMsg: 'Vario 160 saya tarikan bawahnya agak bergetar pelan pas macet.',
          assistantMsg:
              'Gejala gredek ringan pada CVT skutik 160cc umum terjadi akibat debu menumpuk di mangkok kopling ganda. Disarankan pembersihan CVT saat servis berikutnya.',
          riskLevel: 'sedang',
          summary: 'Perlu pembersihan rumah kopling & area CVT',
          symptomsJson: '["gredek", "tarikan_berat"]',
          componentsJson: '["CVT"]',
        ),
      ),
      _DiverseMotorSpec(
        brand: 'Yamaha',
        modelKeyword: 'NMAX',
        nickname: 'NMAX 155 Touring',
        manufactureYear: 2023,
        plateNumber: 'D 6188 NMX',
        emoji: '🏍️',
        usageProfile: 'perjalanan_jauh',
        isPrimary: false,
        baselineDaysAgo: 92,
        baselineKm: 14200,
        baselineNote: 'Start pencatatan skutik touring Bandung',
        odometerLogs: const [
          (58, 16100.0, 'Selesai turing Lembang - Ciwidey'),
          (28, 17850.0, 'Cek kilometer menuju interval 18.000 km'),
          (3, 18900.0, 'Odometer terkini pasca turing akhir pekan'),
        ],
        services: const [
          _SeedServiceSpec(
            daysAgo: 40,
            odometerKm: 16900.0,
            workshop: 'Yamaha Flagship Shop Bandung',
            notes: 'Servis CVT lengkap + ganti V-Belt & oli gardan untuk persiapan touring.',
            resolveComplaints: true,
            items: [
              ('oli mesin', 'yamalube', 'replace', 62000, 15000, 'Yamalube Power Matic 10W-40'),
              ('oli gardan', 'yamalube motor gear', 'replace', 17500, 10000, 'Yamalube Motor Gear Oil 100ml'),
              ('cvt', 'v-belt yamaha genuine', 'replace', 135000, 35000, 'V-Belt Yamaha Genuine Aerox/NMAX'),
            ],
          ),
          _SeedServiceSpec(
            daysAgo: 12,
            odometerKm: 18450.0,
            workshop: 'Planet Ban Soekarno Hatta',
            notes: 'Pengeluaran penggantian pentil tubeless & cairan anti bocor',
            resolveComplaints: false,
            items: [
              ('ban', 'ban', 'repair', 85000, 20000, 'Balancing ringan & cairan tubeless'),
            ],
          ),
        ],
        inspectionRisk: 'sedang',
        inspectionAnswers: const {
          'oli': 'wajar',
          'cvt': 'agak_bergetar',
          'ban': 'mulai_aus',
          'mesin': 'halus',
        },
        inspectionNotes: 'Filter udara perlu dibersihkan karena rute turing berdebu.',
        budgetAmount: 650000,
        budgetNotes: 'Dana perawatan rutin skutik touring NMAX 155',
        complaint: _SeedComplaintSpec(
          daysAgo: 5,
          title: 'Tarikan menanjak terasa tertahan',
          description: 'Filter udara terasa kotor setelah melewati jalur pegunungan berdebu.',
          status: 'open',
          userMsg: 'NMAX saya napas atasnya agak berat waktu dipakai nanjak setelah hujan dan debu.',
          assistantMsg:
              'Filter udara kotor mengurangi suplai udara ke ruang bakar sehingga tenaga terasa tertahan di tanjakan. Cek kondisi filter udara & lakukan penggantian bila elemen kertas menghitam.',
          riskLevel: 'sedang',
          summary: 'Inspeksi atau ganti elemen filter udara',
          symptomsJson: '["tenaga_hilang", "filter_kotor"]',
          componentsJson: '["Filter udara", "CVT"]',
        ),
      ),
      _DiverseMotorSpec(
        brand: 'Kawasaki',
        modelKeyword: 'KLX 150',
        nickname: 'KLX 150 Trail Offroad',
        manufactureYear: 2014,
        plateNumber: 'B 3891 KLX',
        emoji: '⚙️',
        usageProfile: 'campuran',
        isPrimary: false,
        baselineDaysAgo: 90,
        baselineKm: 19100,
        baselineNote: 'Odometer awal motor trail dual-sport karburator',
        odometerLogs: const [
          (55, 20800.0, 'Dipakai jalur tanah & operasional harian'),
          (22, 22100.0, 'Pencatatan kilometer pasca setel rantai & karburator'),
          (2, 23400.0, 'Odometer terkini motor trail KLX 150'),
        ],
        services: const [
          _SeedServiceSpec(
            daysAgo: 18,
            odometerKm: 22250.0,
            workshop: 'Kawasaki Greentech Trail & Service',
            notes: 'Ganti rantai set lengkap, busi, & oli mesin 4T trail manual.',
            resolveComplaints: true,
            items: [
              ('oli mesin', 'oli mesin kawasaki', 'replace', 88000, 20000, 'Oli Mesin Kawasaki Genuine 4T 10W-40 1L'),
              ('rantai', 'rantai & gir set kawasaki', 'replace', 265000, 35000, 'Rantai & Gir Set Kawasaki KLX 150 Heavy Duty'),
              ('busi', 'busi', 'replace', 25000, 10000, 'Ganti busi standar & pembersihan karburator'),
            ],
          ),
          _SeedServiceSpec(
            daysAgo: 6,
            odometerKm: 23050.0,
            workshop: 'Bengkel Trail Sumber Jaya',
            notes: 'Pembersihan filter udara & pelumasan rantai offroad',
            resolveComplaints: false,
            items: [
              ('rantai', 'rantai', 'inspect', 45000, 0, 'Pelumas rantai semprot & cek ketegangan'),
            ],
          ),
        ],
        inspectionRisk: 'rendah',
        inspectionAnswers: const {
          'oli': 'bersih',
          'rantai': 'kencang_terlumasi',
          'rem': 'pakem',
          'aki': 'kuat',
        },
        inspectionNotes: 'Trail karburator berpendingin udara 2014 — rantai baru & terlumasi.',
        budgetAmount: 450000,
        budgetNotes: 'Anggaran perawatan motor trail dual-sport Kawasaki KLX 150',
        complaint: _SeedComplaintSpec(
          daysAgo: 21,
          title: 'Rantai kendur berdecit setelah jalur tanah',
          description: 'Bunyi gemeretak dari roda belakang sebelum penggantian rantai set.',
          status: 'resolved',
          userMsg: 'Rantai Kawasaki KLX 150 saya bunyi kasar tiap akselerasi gigi 2 ke 3 setelah lewat jalur lumpur.',
          assistantMsg:
              'Gir belakang yang runcing dan rantai aus memicu bunyi kasar saat torsi berpindah. Penggantian 1 set rantai dan gir heavy duty sudah mengatasi sumber bunyi.',
          riskLevel: 'rendah',
          summary: 'Sudah diganti dengan Rantai & Gir Set Kawasaki KLX 150',
          symptomsJson: '["rantai_berisik"]',
          componentsJson: '["Rantai & gir"]',
        ),
      ),
      _DiverseMotorSpec(
        brand: 'Honda',
        modelKeyword: 'CBR150R',
        nickname: 'CBR150R Sport Fairing',
        manufactureYear: 2023,
        plateNumber: 'F 2190 CBR',
        emoji: '🏁',
        usageProfile: 'perjalanan_jauh',
        isPrimary: false,
        baselineDaysAgo: 88,
        baselineKm: 11500,
        baselineNote: 'Odometer awal motor sport fairing 150cc',
        odometerLogs: const [
          (52, 13200.0, 'Sunmori rute Puncak - Bogor'),
          (24, 14700.0, 'Catat odometer pasca kuras radiator'),
          (2, 15600.0, 'Kilometer terbaru sport fairing'),
        ],
        services: const [
          _SeedServiceSpec(
            daysAgo: 32,
            odometerKm: 14100.0,
            workshop: 'AHASS Wing Big Bike Bogor',
            notes: 'Servis motor sport: oli full synthetic SPX1, kuras coolant & minyak rem DOT 4.',
            resolveComplaints: true,
            items: [
              ('oli mesin', 'spx1', 'replace', 72000, 25000, 'AHM Oil SPX1 10W-30 sport'),
              ('radiator coolant', 'ahm radiator coolant', 'replace', 24000, 20000, 'AHM Radiator Coolant Pre-mix 1L'),
              ('minyak rem', 'honda genuine brake fluid', 'replace', 18000, 20000, 'Honda Genuine Brake Fluid DOT 4 50ml'),
            ],
          ),
          _SeedServiceSpec(
            daysAgo: 10,
            odometerKm: 15250.0,
            workshop: 'SpeedShop Biker Bogor',
            notes: 'Pengeluaran paddock stand & perawatan rantai O-ring',
            resolveComplaints: false,
            items: [
              ('suspensi', 'shock', 'inspect', 180000, 35000, 'Inspeksi preload suspensi & seal shock'),
            ],
          ),
        ],
        inspectionRisk: 'tinggi',
        inspectionAnswers: const {
          'oli': 'bersih',
          'rem_depan': 'hampir_habis',
          'rantai': 'perlu_pelumas',
          'coolant': 'penuh',
        },
        inspectionNotes: 'Kampas rem depan menipis dan butuh pengecekan segera.',
        budgetAmount: 750000,
        budgetNotes: 'Alokasi perawatan motor sport CBR150R',
        complaint: _SeedComplaintSpec(
          daysAgo: 3,
          title: 'Kampas rem depan kurang menggigit saat kecepatan tinggi',
          description: 'Tuas rem depan harus ditarik lebih dalam & terasa getar halus.',
          status: 'open',
          userMsg: 'Rem depan CBR150R saya terasa kurang pakem waktu ngerem mendadak di jalan menurun.',
          assistantMsg:
              'PERHATIAN KESELAMATAN: Ketebalan kampas rem depan yang menipis mengurangi daya cengkeram cakram. Segera inspeksi ketebalan kampas dan bersihkan piston kaliper sebelum dipakai perjalanan jauh.',
          riskLevel: 'tinggi',
          summary: 'Prioritas keselamatan: segera cek & ganti kampas rem depan',
          symptomsJson: '["rem_kurang_pakem", "tuas_dalam"]',
          componentsJson: '["Kampas rem", "Minyak rem"]',
        ),
      ),
      _DiverseMotorSpec(
        brand: 'Kawasaki',
        modelKeyword: 'W175',
        nickname: 'W175 Retro Klasik',
        manufactureYear: 2021,
        plateNumber: 'B 5704 KAW',
        emoji: '🕶️',
        usageProfile: 'campuran',
        isPrimary: false,
        baselineDaysAgo: 85,
        baselineKm: 5400,
        baselineNote: 'Odometer awal motor retro klasik akhir pekan',
        odometerLogs: const [
          (48, 6200.0, 'Riding pagi kota tua & kemang'),
          (18, 7100.0, 'Cek odometer pasca servis karburator'),
          (1, 7850.0, 'Odometer terkini Kawasaki W175'),
        ],
        services: const [
          _SeedServiceSpec(
            daysAgo: 15,
            odometerKm: 7300.0,
            workshop: 'Kawasaki Greentech Classic Garage',
            notes: 'Servis motor retro: ganti oli Kawasaki Genuine 4T + penyetelan rantai & klep.',
            resolveComplaints: true,
            items: [
              ('oli mesin', 'oli mesin kawasaki', 'replace', 88000, 35000, 'Oli Mesin Kawasaki Genuine 4T 10W-40 1L'),
              ('rantai', 'rantai & gir set kawasaki w175', 'replace', 265000, 45000, 'Rantai & Gir Set Kawasaki W175 / Ninja 250SL'),
            ],
          ),
          _SeedServiceSpec(
            daysAgo: 3,
            odometerKm: 7780.0,
            workshop: 'Retro Shine Detailing',
            notes: 'Detailing chrome tangki & poles pelek jari-jari',
            resolveComplaints: false,
            items: [
              ('aki', 'aki', 'inspect', 150000, 0, 'Cek voltase aki 12.7V & detailing bodi klasik'),
            ],
          ),
        ],
        inspectionRisk: 'rendah',
        inspectionAnswers: const {
          'oli': 'bersih',
          'aki': 'normal',
          'rantai': 'kencang',
          'mesin': 'halus',
        },
        inspectionNotes: 'Motor klasik berpendingin udara dalam kondisi terawat dan siap riding.',
        budgetAmount: 500000,
        budgetNotes: 'Dana perawatan rutin Kawasaki W175 retro klasik',
        complaint: _SeedComplaintSpec(
          daysAgo: 17,
          title: 'Mesin sedikit susah langsam saat pagi dingin',
          description: 'Butuh choke sebentar saat starter pagi sebelum servis karburator.',
          status: 'resolved',
          userMsg: 'W175 saya agak susah langsam kalau dinyalakan pagi hari.',
          assistantMsg:
              'Pada motor retro karburator berpendingin udara, penyetelan pilot screw dan pembersihan spuyer mengembalikan idle stabil di pagi hari.',
          riskLevel: 'rendah',
          summary: 'Sudah disetel ulang saat servis karburator & ganti oli',
          symptomsJson: '["langsam_tidak_stabil"]',
          componentsJson: '["Busi", "Filter udara"]',
        ),
      ),
    ];

    final createdIds = <int>[];
    final now = DateTime.now();

    await db.transaction(() async {
      for (final spec in specs) {
      final model = findModel(spec.brand, spec.modelKeyword);
      final motorId = await db.createMotorcycle(
        motorcycle: MotorcyclesCompanion.insert(
          modelId: Value(model.id),
          nickname: spec.nickname,
          manufactureYear: spec.manufactureYear,
          plateNumber: Value(spec.plateNumber),
          emoji: Value(spec.emoji),
          usageProfile: Value(spec.usageProfile),
          isPrimary: Value(spec.isPrimary),
        ),
      );
      createdIds.add(motorId);

      await db.insertOdometerLog(
        OdometerLogsCompanion.insert(
          motorcycleId: motorId,
          odometerKm: spec.baselineKm,
          recordedAt: now.subtract(Duration(days: spec.baselineDaysAgo)),
          source: const Value('manual'),
          note: Value(spec.baselineNote),
        ),
      );

      for (final (daysAgo, km, note) in spec.odometerLogs) {
        await db.insertOdometerLog(
          OdometerLogsCompanion.insert(
            motorcycleId: motorId,
            odometerKm: km,
            recordedAt: now.subtract(Duration(days: daysAgo)),
            source: const Value('manual'),
            note: Value(note),
          ),
        );
      }

      for (final srv in spec.services) {
        final companions = <ServiceItemsCompanion>[];
        var partsSum = 0;
        var laborSum = 0;
        for (final (compKw, partKw, action, partsCost, laborCost, itemNotes)
            in srv.items) {
          final compId = findComponentId(compKw);
          final partId = findSparepartId(partKw);
          partsSum += partsCost;
          laborSum += laborCost;
          companions.add(
            ServiceItemsCompanion.insert(
              serviceRecordId: 0,
              componentTypeId: Value(compId),
              sparepartId: Value(partId),
              action: action,
              partsCost: Value(partsCost),
              laborCost: Value(laborCost),
              totalCost: Value(partsCost + laborCost),
              notes: Value(itemNotes),
            ),
          );
        }

        await db.createServiceWithItems(
          record: ServiceRecordsCompanion.insert(
            motorcycleId: motorId,
            servicedAt: now.subtract(Duration(days: srv.daysAgo)),
            odometerKm: Value(srv.odometerKm),
            workshopName: Value(srv.workshop),
            notes: Value(srv.notes),
            totalCost: Value(partsSum + laborSum),
          ),
          items: companions,
          odometerKm: srv.odometerKm,
          resolveComplaints: srv.resolveComplaints,
        );
      }

      await db.saveCompleteSelfInspection(
        motorcycleId: motorId,
        riskLevel: spec.inspectionRisk,
        answers: spec.inspectionAnswers,
        notes: spec.inspectionNotes,
      );

      await db.saveCompleteBudgetPlan(
        motorcycleId: motorId,
        budgetAmount: spec.budgetAmount,
        period: 'bulanan',
        recommendations: const [],
        notes: spec.budgetNotes,
      );

      if (spec.complaint != null) {
        final c = spec.complaint!;
        final cId = await db.insertComplaint(
          ComplaintsCompanion.insert(
            motorcycleId: motorId,
            openedAt: Value(now.subtract(Duration(days: c.daysAgo))),
            title: c.title,
            description: c.description,
            status: Value(c.status),
          ),
        );
        await db.insertComplaintMessage(
          ComplaintMessagesCompanion.insert(
            complaintId: cId,
            role: 'user',
            content: c.userMsg,
            createdAt: Value(now.subtract(Duration(days: c.daysAgo))),
          ),
        );
        await db.insertComplaintMessage(
          ComplaintMessagesCompanion.insert(
            complaintId: cId,
            role: 'assistant',
            content: c.assistantMsg,
            createdAt: Value(now.subtract(Duration(days: c.daysAgo))),
          ),
        );
        await db.insertComplaintAnalysis(
          ComplaintAnalysesCompanion.insert(
            complaintId: cId,
            analyzedAt: Value(now.subtract(Duration(days: c.daysAgo))),
            analysisMode: 'rule_based',
            riskLevel: c.riskLevel,
            summary: c.summary,
            symptomsJson: c.symptomsJson,
            componentCandidatesJson: Value(c.componentsJson),
          ),
        );
      }

      final oliId = findComponentId('oli mesin');
      await db.insertReminder(
        LocalRemindersCompanion.insert(
          motorcycleId: motorId,
          componentTypeId: Value(oliId),
          reminderType: 'odometer',
          dueOdometerKm: Value(spec.odometerLogs.last.$2 + 2000),
          dueDate: Value(now.add(const Duration(days: 35))),
          enabled: const Value(true),
          lastScheduledAt: Value(now),
        ),
      );

      await db.recalculateComponentStatuses(motorId);
    }
    });

    final reminderEngine = ReminderEngine(db: db);
    for (final id in createdIds) {
      await reminderEngine.syncRemindersForMotorcycle(id);
    }

    return createdIds;
  }
}

class _DiverseMotorSpec {
  final String brand;
  final String modelKeyword;
  final String nickname;
  final int manufactureYear;
  final String plateNumber;
  final String emoji;
  final String usageProfile;
  final bool isPrimary;
  final int baselineDaysAgo;
  final double baselineKm;
  final String baselineNote;
  final List<(int, double, String)> odometerLogs;
  final List<_SeedServiceSpec> services;
  final String inspectionRisk;
  final Map<String, String> inspectionAnswers;
  final String inspectionNotes;
  final int budgetAmount;
  final String budgetNotes;
  final _SeedComplaintSpec? complaint;

  const _DiverseMotorSpec({
    required this.brand,
    required this.modelKeyword,
    required this.nickname,
    required this.manufactureYear,
    required this.plateNumber,
    required this.emoji,
    required this.usageProfile,
    required this.isPrimary,
    required this.baselineDaysAgo,
    required this.baselineKm,
    required this.baselineNote,
    required this.odometerLogs,
    required this.services,
    required this.inspectionRisk,
    required this.inspectionAnswers,
    required this.inspectionNotes,
    required this.budgetAmount,
    required this.budgetNotes,
    this.complaint,
  });
}

class _SeedServiceSpec {
  final int daysAgo;
  final double odometerKm;
  final String workshop;
  final String notes;
  final bool resolveComplaints;
  final List<(String, String?, String, int, int, String)> items;

  const _SeedServiceSpec({
    required this.daysAgo,
    required this.odometerKm,
    required this.workshop,
    required this.notes,
    required this.resolveComplaints,
    required this.items,
  });
}

class _SeedComplaintSpec {
  final int daysAgo;
  final String title;
  final String description;
  final String status;
  final String userMsg;
  final String assistantMsg;
  final String riskLevel;
  final String summary;
  final String symptomsJson;
  final String componentsJson;

  const _SeedComplaintSpec({
    required this.daysAgo,
    required this.title,
    required this.description,
    required this.status,
    required this.userMsg,
    required this.assistantMsg,
    required this.riskLevel,
    required this.summary,
    required this.symptomsJson,
    required this.componentsJson,
  });
}
