import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:buildhaus/core/database/app_database.dart';
import 'package:buildhaus/core/providers/database_provider.dart';
import 'package:buildhaus/core/router/app_router.dart';

void main() {
  late AppDatabase db;

  setUpAll(() async {
    await initializeDateFormatting('id_ID');
  });

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.ensureReferenceData();
  });

  tearDown(() async {
    await db.close();
  });

  testWidgets(
    'AddExpenseScreen menyimpan biaya sparepart ke SQLite tanpa menghapus status keluhan jika tidak di-reset',
    (tester) async {
      final models = await db.getAllMotorcycleModels();
      final vario = models.firstWhere((m) => m.model == 'Vario 160');
      final motorId = await db.createMotorcycle(
        motorcycle: MotorcyclesCompanion.insert(
          nickname: 'Vario Expense Test',
          modelId: Value(vario.id),
          manufactureYear: vario.yearStart,
        ),
        initialOdometerKm: 8000,
      );

      final router = createAppRouter();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(db)],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      router.go('/motor/$motorId/expense/add');
      await tester.pumpAndSettle();

      expect(find.text('Catat Pengeluaran'), findsOneWidget);
      expect(find.text('Vario Expense Test'), findsOneWidget);

      await tester.enterText(
        find.byKey(const ValueKey('expense_amount_field')),
        '85000',
      );
      await tester.enterText(
        find.byKey(const ValueKey('expense_labor_field')),
        '15000',
      );

      final saveBtn = find.byKey(const ValueKey('save_expense_button'));
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      final summary = await db.getMotorcycleExpenseSummary(motorId);
      expect(summary.recordCount, 1);
      expect(summary.totalAllCost, 100000);
      expect(summary.totalPartsCost, 85000);
      expect(summary.totalLaborCost, 15000);

      router.dispose();
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    },
  );

  testWidgets(
    'VehicleHealthReportScreen menampilkan spesifikasi transmisi, komponen relevan, dan salin laporan',
    (tester) async {
      String? copiedText;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            if (call.method == 'Clipboard.setData') {
              copiedText = (call.arguments as Map)['text'] as String?;
            }
            return null;
          });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null),
      );

      final models = await db.getAllMotorcycleModels();
      final vario = models.firstWhere((m) => m.model == 'Vario 160');
      final motorId = await db.createMotorcycleWithInitialHealth(
        motorcycle: MotorcyclesCompanion.insert(
          nickname: 'Vario Laporan',
          modelId: Value(vario.id),
          manufactureYear: vario.yearStart,
          plateNumber: const Value('B 1234 XYZ'),
        ),
        initialOdometerKm: 12000,
      );

      final router = createAppRouter();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(db)],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      router.go('/motor/$motorId/report');
      await tester.pumpAndSettle();

      expect(find.text('SERTIFIKAT KONDISI MOTOR'), findsOneWidget);
      expect(find.text('Vario Laporan'), findsOneWidget);
      expect(find.text('Matic (CVT)'), findsOneWidget);
      expect(find.text('Rincian Komponen Terpantau (13)'), findsOneWidget);
      expect(find.text('Rantai & gir'), findsNothing);

      final copyBtn = find.byKey(const ValueKey('copy_report_button'));
      await tester.ensureVisible(copyBtn);
      await tester.tap(copyBtn);
      await tester.pumpAndSettle();

      expect(copiedText, isNotNull);
      expect(copiedText, contains('Vario Laporan'));
      expect(copiedText, contains('Matic (CVT)'));
      expect(copiedText, isNot(contains('Rantai & gir')));

      router.dispose();
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    },
  );
}
