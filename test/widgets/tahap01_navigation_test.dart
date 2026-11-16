import 'package:drift/drift.dart' hide Column;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:buildhaus/core/database/app_database.dart';
import 'package:buildhaus/core/providers/database_provider.dart';
import 'package:buildhaus/core/router/app_router.dart';
import 'package:go_router/go_router.dart';
import 'package:buildhaus/features/ai_assistant/presentation/screens/ai_assistant_screen.dart';
import 'package:buildhaus/features/ai_assistant/presentation/screens/ai_model_manager_screen.dart';
import 'package:buildhaus/features/budget/presentation/screens/budget_screen.dart';
import 'package:buildhaus/features/complaints/presentation/screens/complaints_screen.dart';
import 'package:buildhaus/features/health/presentation/screens/health_screen.dart';
import 'package:buildhaus/features/health/presentation/screens/vehicle_health_report_screen.dart';
import 'package:buildhaus/features/history/presentation/screens/history_screen.dart';
import 'package:buildhaus/features/home/presentation/screens/home_screen.dart';
import 'package:buildhaus/features/mileage/presentation/screens/odometer_history_screen.dart';
import 'package:buildhaus/features/mileage/presentation/screens/odometer_screen.dart';
import 'package:buildhaus/features/motorcycles/presentation/screens/add_motorcycle_screen.dart';
import 'package:buildhaus/features/motorcycles/presentation/screens/edit_motorcycle_screen.dart';
import 'package:buildhaus/features/parts/presentation/screens/parts_catalog_screen.dart';
import 'package:buildhaus/features/reminders/presentation/screens/reminders_screen.dart';
import 'package:buildhaus/features/self_inspection/presentation/screens/self_inspection_screen.dart';
import 'package:buildhaus/features/service_history/presentation/screens/add_expense_screen.dart';
import 'package:buildhaus/features/service_history/presentation/screens/add_service_screen.dart';
import 'package:buildhaus/features/settings/presentation/screens/backup_screen.dart';
import 'package:buildhaus/features/settings/presentation/screens/licenses_screen.dart';
import 'package:buildhaus/features/settings/presentation/screens/restore_screen.dart';

/// Pengujian navigasi otomatis untuk TAHAP 01.
///
/// Memastikan setiap rute penting benar-benar membuka layar yang sesuai labelnya
/// dan tidak pernah mendarat di layar yang tidak relevan.
void main() {
  late AppDatabase db;
  late GoRouter router;

  setUpAll(() async {
    // Aplikasi menginisialisasi data locale intl di main(); test widget
    // harus melakukan hal yang sama agar Formatters.date() tidak melempar.
    await initializeDateFormatting('id_ID');
  });

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.ensureReferenceData();
    // Bypass auth + onboarding supaya rute non-shell bisa diuji langsung.
    await db.setSetting('auth_logged_in', 'true');
    await db.setSetting('onboarding_completed', 'true');

    final models = await db.getAllMotorcycleModels();
    final model = models.first;
    await db.createMotorcycle(
      motorcycle: MotorcyclesCompanion.insert(
        nickname: 'Motor Navigasi',
        modelId: Value(model.id),
        manufactureYear: model.yearStart,
      ),
      initialOdometerKm: 5000,
    );

    // Router baru untuk tiap test: GoRouter menyimpan state navigasi di
    // instansnya, sehingga router global akan membawa lokasi dari test
    // sebelumnya dan Destination tidak pernah ditemukan.
    router = createAppRouter();
  });

  tearDown(() async {
    router.dispose();
    await db.close();
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump(const Duration(milliseconds: 600));
  }

  Future<void> drain(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 200));
  }

  /// Pindah ke rute tertentu lalu tunggu sampai transisi selesai.
  ///
  /// GoRouter memproses perubahan rute pada frame berikutnya, jadi diperlukan
  /// `pump()` tanpa durasi sebelum menunggu animasi transisi.
  Future<void> goTo(WidgetTester tester, String location) async {
    router.go(location);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();
  }

  group('Navigasi rute shell', () {
    for (final entry in <String, Type>{
      '/home': HomeScreen,
      '/health': HealthScreen,
      '/parts': PartsCatalogScreen,
      '/history': HistoryScreen,
    }.entries) {
      testWidgets('${entry.key} membuka ${entry.value}', (tester) async {
        await pumpApp(tester);

        await goTo(tester, entry.key);

        expect(find.byType(entry.value), findsOneWidget);
        expect(find.text('Page not found'), findsNothing);

        await drain(tester);
      });
    }
  });

  group('Navigasi rute motor', () {
    testWidgets('/add-motor membuka Tambah Motor', (tester) async {
      await pumpApp(tester);
        await goTo(tester, '/add-motor');

      expect(find.byType(AddMotorcycleScreen), findsOneWidget);
      expect(find.text('Page not found'), findsNothing);

      await drain(tester);
    });

    testWidgets('/motor/:id/edit membuka Edit Motor', (tester) async {
      await pumpApp(tester);
      final motors = await db.getAllMotorcycles();
        await goTo(tester, '/motor/${motors.first.id}/edit');

      expect(find.byType(EditMotorcycleScreen), findsOneWidget);
      expect(find.text('Page not found'), findsNothing);

      await drain(tester);
    });

    testWidgets('/motor/:id/odometer membuka layar Odometer', (tester) async {
      await pumpApp(tester);
      final motors = await db.getAllMotorcycles();
        await goTo(tester, '/motor/${motors.first.id}/odometer');

      expect(find.byType(OdometerScreen), findsOneWidget);
      expect(find.text('Page not found'), findsNothing);

      await drain(tester);
    });

    testWidgets(
      '/motor/:id/odometer-history membuka riwayat odometer',
      (tester) async {
        await pumpApp(tester);
        final motors = await db.getAllMotorcycles();
        await goTo(tester, '/motor/${motors.first.id}/odometer-history');

        expect(find.byType(OdometerHistoryScreen), findsOneWidget);
        expect(find.text('Page not found'), findsNothing);

        await drain(tester);
      },
    );

    testWidgets('/motor/:id/inspection membuka Uji Mandiri', (tester) async {
      await pumpApp(tester);
      final motors = await db.getAllMotorcycles();
        await goTo(tester, '/motor/${motors.first.id}/inspection');

      expect(find.byType(SelfInspectionScreen), findsOneWidget);
      expect(find.text('Page not found'), findsNothing);

      await drain(tester);
    });

    testWidgets('/motor/:id/service/add membuka Catat Servis', (tester) async {
      await pumpApp(tester);
      final motors = await db.getAllMotorcycles();
        await goTo(tester, '/motor/${motors.first.id}/service/add');

      expect(find.byType(AddServiceScreen), findsOneWidget);
      expect(find.text('Page not found'), findsNothing);

      await drain(tester);
    });

    testWidgets('/motor/:id/oil/add membuka Catat Servis', (tester) async {
      await pumpApp(tester);
      final motors = await db.getAllMotorcycles();
        await goTo(tester, '/motor/${motors.first.id}/oil/add');

      expect(find.byType(AddServiceScreen), findsOneWidget);
      expect(find.text('Page not found'), findsNothing);

      await drain(tester);
    });
  });

  group('Navigasi rute pengingat', () {
    testWidgets('/motor/:id/reminders membuka daftar pengingat', (tester) async {
      await pumpApp(tester);
      final motors = await db.getAllMotorcycles();
        await goTo(tester, '/motor/${motors.first.id}/reminders');

      expect(find.byType(RemindersScreen), findsOneWidget);
      expect(find.text('Page not found'), findsNothing);

      await drain(tester);
    });

    testWidgets(
      '/motor/:id/reminder/add membuka daftar pengingat dengan form tambah aktif',
      (tester) async {
        await pumpApp(tester);
        final motors = await db.getAllMotorcycles();
        await goTo(tester, '/motor/${motors.first.id}/reminder/add');

        expect(find.byType(RemindersScreen), findsOneWidget);
        expect(find.text('Page not found'), findsNothing);

        // Rute "tambah" harus langsung menampilkan sheet tambah pengingat.
        expect(
          find.byType(BottomSheet),
          findsOneWidget,
          reason: 'rute reminder/add harus membuka form tambah, bukan daftar saja',
        );

        await drain(tester);
      },
    );
  });

  group('Navigasi rute pengaturan', () {
    testWidgets('/backup membuka Backup Data, bukan layar lain', (tester) async {
      await pumpApp(tester);
        await goTo(tester, '/backup');

      expect(find.byType(BackupScreen), findsOneWidget);
      expect(find.byType(BudgetScreen), findsNothing);
      expect(find.text('Page not found'), findsNothing);

      await drain(tester);
    });

    testWidgets('/restore buka Restore Data, bukan layar lain', (tester) async {
      await pumpApp(tester);
        await goTo(tester, '/restore');

      expect(find.byType(RestoreScreen), findsOneWidget);
      expect(find.byType(BudgetScreen), findsNothing);
      expect(find.text('Page not found'), findsNothing);

      await drain(tester);
    });

    testWidgets('/licenses membuka layar Lisensi', (tester) async {
      await pumpApp(tester);
        await goTo(tester, '/licenses');

      expect(find.byType(LicensesScreen), findsOneWidget);
      expect(find.byType(BudgetScreen), findsNothing);
      expect(find.text('Page not found'), findsNothing);

      await drain(tester);
    });
  });

  group('Navigasi rute fitur lain', () {
    testWidgets('/budget membuka Prioritas Servis', (tester) async {
      await pumpApp(tester);
        await goTo(tester, '/budget');

      expect(find.byType(BudgetScreen), findsOneWidget);
      expect(find.text('Page not found'), findsNothing);

      await drain(tester);
    });

    testWidgets('/complaints membuka daftar Keluhan', (tester) async {
      await pumpApp(tester);
        await goTo(tester, '/complaints');

      expect(find.byType(ComplaintsScreen), findsOneWidget);
      expect(find.text('Page not found'), findsNothing);

      await drain(tester);
    });

    testWidgets('/ai-chat membuka AI Assistant', (tester) async {
      await pumpApp(tester);
        await goTo(tester, '/ai-chat');

      expect(find.byType(AiAssistantScreen), findsOneWidget);
      expect(find.text('Page not found'), findsNothing);

      await drain(tester);
    });

    testWidgets('/ai-model membuka pengelola model AI', (tester) async {
      await pumpApp(tester);
        await goTo(tester, '/ai-model');

      expect(find.byType(AiModelManagerScreen), findsOneWidget);
      expect(find.text('Page not found'), findsNothing);

      await drain(tester);
    });

    testWidgets(
      '/motor/:id/expense/add membuka AddExpenseScreen, bukan layar servis',
      (tester) async {
        await pumpApp(tester);
        final motors = await db.getAllMotorcycles();
        await goTo(tester, '/motor/${motors.first.id}/expense/add');

        expect(find.byType(AddExpenseScreen), findsOneWidget);
        expect(find.byType(AddServiceScreen), findsNothing);
        expect(find.text('Page not found'), findsNothing);

        await drain(tester);
      },
    );

    testWidgets(
      '/motor/:id/report membuka VehicleHealthReportScreen',
      (tester) async {
        await pumpApp(tester);
        final motors = await db.getAllMotorcycles();
        await goTo(tester, '/motor/${motors.first.id}/report');

        expect(find.byType(VehicleHealthReportScreen), findsOneWidget);
        expect(find.text('Laporan Kondisi Motor'), findsOneWidget);
        expect(find.text('Page not found'), findsNothing);

        await drain(tester);
      },
    );
  });

  group('Rute yang dihapus', () {
    testWidgets('/edit-motor/:id sudah tidak ada (duplikat /motor/:id/edit)', (
      tester,
    ) async {
      await pumpApp(tester);
      final motors = await db.getAllMotorcycles();
      await goTo(tester, '/edit-motor/${motors.first.id}');

      // Rute yang dihapus tidak boleh membuka layar Edit Motor.
      expect(find.byType(EditMotorcycleScreen), findsNothing);
      // GoRouter tidak menampilkan halaman "not found"; navigasi ke rute yang
      // tidak terdaftar ditolak tanpa membuka layar yang salah.
      expect(find.text('Page not found'), findsNothing);

      await drain(tester);
    });
  });
}
