import 'package:buildhaus/core/ai/ai_chat_service.dart';
import 'package:buildhaus/core/database/app_database.dart';
import 'package:buildhaus/core/engines/health_engine.dart';
import 'package:buildhaus/core/engines/motorcycle_specs.dart';
import 'package:buildhaus/core/engines/self_inspection_engine.dart';
import 'package:buildhaus/core/platform/native_platform_service.dart';
import 'package:buildhaus/core/providers/app_providers.dart';
import 'package:buildhaus/core/providers/database_provider.dart';
import 'package:buildhaus/core/utils/formatters.dart';
import 'package:buildhaus/features/parts/presentation/providers/parts_providers.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FixedMotorNotifier extends ActiveMotorcycleNotifier {
  final Motorcycle _motor;
  _FixedMotorNotifier(super.ref, this._motor) {
    state = _motor;
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

  group('Validasi Auth Email-Only & Sandi Ketat', () {
    test('validateEmail menolak nomor HP dan format non-email', () {
      expect(AuthNotifier.validateEmail(''), isNotNull);
      expect(AuthNotifier.validateEmail('081234567890'), isNotNull);
      expect(AuthNotifier.validateEmail('budi@'), isNotNull);
      expect(AuthNotifier.validateEmail('budi@email.com'), isNull);
    });

    test('validatePassword mewajibkan >=8 char, tanpa spasi, huruf kapital, dan angka', () {
      expect(AuthNotifier.validatePassword('Abc1234'), isNotNull); // < 8 char
      expect(AuthNotifier.validatePassword('Abc 12345'), isNotNull); // ada spasi
      expect(AuthNotifier.validatePassword('abcdefg1'), isNotNull); // tanpa kapital
      expect(AuthNotifier.validatePassword('Abcdefgh'), isNotNull); // tanpa angka
      expect(AuthNotifier.validatePassword('Motor2026'), isNull);
    });

    test('ThemeModeNotifier hanya Gelap dan Terang, default Gelap, tolak Sistem', () async {
      await db.setSetting('theme_mode', 'system');
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);

      // Saat init & load 'system' harus jatuh ke ThemeMode.dark
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(container.read(themeModeProvider), ThemeMode.dark);

      await container.read(themeModeProvider.notifier).setTheme(ThemeMode.system);
      expect(container.read(themeModeProvider), ThemeMode.dark);

      await container.read(themeModeProvider.notifier).setTheme(ThemeMode.light);
      expect(container.read(themeModeProvider), ThemeMode.light);
    });
  });

  group('Formatter Odometer Bertitik & Plat Nomor Otomatis Spasi', () {
    test('OdometerTextInputFormatter & parseOdometerDouble konsisten', () {
      const formatter = OdometerTextInputFormatter();
      final res = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(
          text: '14500',
          selection: TextSelection.collapsed(offset: 5),
        ),
      );
      expect(res.text, '14.500');
      expect(Formatters.parseOdometerDouble(res.text), 14500.0);
      expect(Formatters.parseOdometerDouble('1.250.000 km'), 1250000.0);
    });

    test('IndonesiaPlateTextInputFormatter menyisipkan spasi otomatis', () {
      final formatter = IndonesiaPlateTextInputFormatter();
      final plat1 = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(
          text: 'b2841rdm',
          selection: TextSelection.collapsed(offset: 8),
        ),
      );
      expect(plat1.text, 'B 2841 RDM');

      final plat2 = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(
          text: 'ab123cd',
          selection: TextSelection.collapsed(offset: 7),
        ),
      );
      expect(plat2.text, 'AB 123 CD');
    });
  });

  group('Katalog Honda/Yamaha/Kawasaki Sejak 1990 & Pertanyaan Adaptif', () {
    test('Katalog hanya berisi Honda, Yamaha, Kawasaki dengan model sejak 1990', () async {
      final models = await db.getAllMotorcycleModels();
      expect(models.any((m) => m.brand == 'Suzuki'), isFalse);
      expect(models.any((m) => m.brand == 'Honda' && m.yearStart == 1990), isTrue);
      expect(models.any((m) => m.brand == 'Yamaha' && m.yearStart == 1990), isTrue);
      expect(models.any((m) => m.brand == 'Kawasaki' && m.yearStart <= 1996), isTrue);
      expect(MotorcycleSpecs.isAllowedBrand('Honda'), isTrue);
      expect(MotorcycleSpecs.isAllowedBrand('Yamaha'), isTrue);
      expect(MotorcycleSpecs.isAllowedBrand('Kawasaki'), isTrue);
      expect(MotorcycleSpecs.isAllowedBrand('Suzuki'), isFalse);
    });

    test('Pertanyaan inspeksi beradaptasi sesuai jenis & tahun motor', () async {
      final models = await db.getAllMotorcycleModels();
      final vario160 = models.firstWhere((m) => m.model.contains('Vario 160'));
      final w175 = models.firstWhere((m) => m.model.contains('W175'));
      final rxKing = models.firstWhere((m) => m.model.contains('RX-King'));

      final qVario = SelfInspectionEngine.questionsForMotorcycle(
        vario160,
        manufactureYear: 2024,
      );
      final qW175 = SelfInspectionEngine.questionsForMotorcycle(
        w175,
        manufactureYear: 2021,
      );
      final qRx = SelfInspectionEngine.questionsForMotorcycle(
        rxKing,
        manufactureYear: 1995,
      );

      expect(qVario.any((q) => q.componentName == 'CVT'), isTrue);
      expect(qVario.any((q) => q.componentName == 'Radiator coolant'), isTrue);
      expect(qVario.any((q) => q.componentName == 'Rantai & gir'), isFalse);

      expect(qW175.any((q) => q.componentName == 'Rantai & gir'), isTrue);
      expect(qW175.any((q) => q.componentName == 'CVT'), isFalse);
      expect(qW175.any((q) => q.componentName == 'Radiator coolant'), isFalse);

      expect(
        qRx.any((q) => q.question.toLowerCase().contains('oli samping')),
        isTrue,
      );
    });
  });

  group('Kesehatan Motor Berbeda Sesuai Tipe & Tahun Terbit', () {
    test('Motor keluaran 1995 memiliki penyesuaian interval lebih ketat dari motor 2024', () async {
      final models = await db.getAllMotorcycleModels();
      final types = await db.getAllComponentTypes();
      final rules = await db.getAllMaintenanceRules();
      final oliType = types.firstWhere((c) => c.name == 'Oli mesin');
      final astrea = models.firstWhere((m) => m.model.contains('Astrea'));
      final vario = models.firstWhere((m) => m.model.contains('Vario 160'));

      final now = DateTime.now();
      final dummyRecord = ServiceRecord(
        id: 1,
        motorcycleId: 1,
        servicedAt: now.subtract(const Duration(days: 30)),
        odometerKm: 10000,
        workshopName: 'Bengkel Uji',
        totalCost: 60000,
        notes: null,
        createdAt: now,
      );
      final itemWithRecord = [
        ServiceItemWithRecord(
          item: ServiceItem(
            id: 1,
            serviceRecordId: 1,
            componentTypeId: oliType.id,
            action: 'replace',
            sparepartId: null,
            partsCost: 50000,
            laborCost: 10000,
            totalCost: 60000,
          ),
          record: dummyRecord,
        ),
      ];

      final oldEngine = HealthEngine(
        statuses: const [],
        serviceRecords: [dummyRecord],
        odometerLogs: const [],
        rules: rules,
        componentTypes: types,
        currentOdometer: 12100,
        serviceItemsWithRecords: itemWithRecord,
        motorcycleModelId: astrea.id,
        manufactureYear: 1995,
        motorcycleModel: astrea,
      );
      final newEngine = HealthEngine(
        statuses: const [],
        serviceRecords: [dummyRecord],
        odometerLogs: const [],
        rules: rules,
        componentTypes: types,
        currentOdometer: 12100,
        serviceItemsWithRecords: itemWithRecord,
        motorcycleModelId: vario.id,
        manufactureYear: 2024,
        motorcycleModel: vario,
      );

      final resOld = oldEngine.calculateHealth(oliType.id);
      final resNew = newEngine.calculateHealth(oliType.id);

      expect(resOld.score, isNotNull);
      expect(resNew.score, isNotNull);
      expect(resOld.score!, lessThan(resNew.score!));
    });
  });

  group('Sparepart Filter Ketat, Budget Priority & Query Toko Terdekat', () {
    test('PrioritizedSpareparts untuk CBR150R mengecualikan CVT & part Yamaha', () async {
      final models = await db.getAllMotorcycleModels();
      final cbrModel = models.firstWhere((m) => m.model.contains('CBR150R'));
      final motorId = await db.createMotorcycle(
        motorcycle: MotorcyclesCompanion.insert(
          nickname: 'CBR Uji Filter',
          modelId: Value(cbrModel.id),
          manufactureYear: 2023,
        ),
        initialOdometerKm: 12000,
      );
      final cbr = (await db.getMotorcycle(motorId))!;

      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          activeMotorcycleProvider.overrideWith(
            (ref) => _FixedMotorNotifier(ref, cbr),
          ),
        ],
      );
      addTearDown(container.dispose);

      final prioritized = await container.read(prioritizedSparepartsProvider.future);
      expect(prioritized, isNotEmpty);
      expect(
        prioritized.any((p) {
          final text = '${p.part.name} ${p.part.brand ?? ''}'.toLowerCase();
          return text.contains('yamalube') ||
              text.contains('yamaha') ||
              text.contains('v-belt') ||
              text.contains('roller') ||
              text.contains('gardan');
        }),
        isFalse,
      );
    });

    test('NativePlatformService.buildRepairShopQuery membangun query Maps relevan', () {
      expect(
        NativePlatformService.buildRepairShopQuery(
          brand: 'Honda',
          partName: 'Kampas Rem',
        ),
        contains('ahass'),
      );
      expect(
        NativePlatformService.buildRepairShopQuery(
          brand: 'Kawasaki',
          partName: 'Oli',
        ),
        contains('kawasaki'),
      );
    });
  });

  group('AI Guardrail Anti Off-Topic', () {
    test('Menolak pertanyaan aneh/di luar motor tanpa membuat keluhan palsu', () async {
      expect(
        AiChatService.isMotorcycleRelatedQuery('Tolong buatin resep nasi goreng'),
        isFalse,
      );
      expect(
        AiChatService.isMotorcycleRelatedQuery('Siapa pemenang pilpres 2024?'),
        isFalse,
      );
      expect(
        AiChatService.isMotorcycleRelatedQuery('Kerjakan PR matematika integral dong'),
        isFalse,
      );
      expect(
        AiChatService.isMotorcycleRelatedQuery('Rem depan motor berdecit saat pelan'),
        isTrue,
      );
      expect(
        AiChatService.isMotorcycleRelatedQuery('Vario gredek pas tarikan awal'),
        isTrue,
      );

      final models = await db.getAllMotorcycleModels();
      final vario = models.firstWhere((m) => m.model.contains('Vario 160'));
      final motorId = await db.createMotorcycle(
        motorcycle: MotorcyclesCompanion.insert(
          nickname: 'Vario AI Guard',
          modelId: Value(vario.id),
          manufactureYear: 2023,
        ),
        initialOdometerKm: 5000,
      );

      final ai = AiChatService(db: db);
      ComplaintAnalysisData? doneAnalysis;
      final reply = await ai
          .sendMessage(
            motorcycleId: motorId,
            userText: 'Buatkan kode python game slot dan resep nasi goreng',
            onAnalysisComplete: (a) => doneAnalysis = a,
          )
          .join();

      expect(reply.toLowerCase(), contains('motor'));
      expect(doneAnalysis?.mode, 'rule_based');
      expect(doneAnalysis?.symptoms, isEmpty);
      expect(doneAnalysis?.componentCandidates, isEmpty);
      final complaints = await db.getComplaints(motorId);
      expect(complaints, isEmpty);
    });
  });
}
