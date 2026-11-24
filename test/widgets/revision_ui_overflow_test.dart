import 'package:buildhaus/core/database/app_database.dart';
import 'package:buildhaus/core/database/sample_data_seeder.dart';
import 'package:buildhaus/core/providers/app_providers.dart';
import 'package:buildhaus/core/providers/database_provider.dart';
import 'package:buildhaus/core/theme/app_theme.dart';
import 'package:buildhaus/features/account/presentation/screens/account_screen.dart';
import 'package:buildhaus/features/ai_assistant/presentation/screens/ai_assistant_screen.dart';
import 'package:buildhaus/features/auth/presentation/screens/auth_screen.dart';
import 'package:buildhaus/features/auth/presentation/screens/initial_motor_setup_screen.dart';
import 'package:buildhaus/features/health/presentation/screens/health_screen.dart';
import 'package:buildhaus/features/home/presentation/screens/home_screen.dart';
import 'package:buildhaus/features/motorcycles/presentation/screens/add_motorcycle_screen.dart';
import 'package:buildhaus/features/parts/presentation/screens/parts_catalog_screen.dart';
import 'package:buildhaus/features/reminders/presentation/screens/reminders_screen.dart';
import 'package:buildhaus/shared/widgets/app_shell.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _PresetActiveMotorNotifier extends ActiveMotorcycleNotifier {
  _PresetActiveMotorNotifier(super.ref, Motorcycle? initial) {
    state = _motorFixed = initial;
  }
  Motorcycle? _motorFixed;
  Motorcycle? get fixed => _motorFixed;
}

Future<void> _settleBounded(WidgetTester tester) async {
  for (int i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 120));
  }
}

Future<void> _drainWidgetTree(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(milliseconds: 250));
}

Future<void> _pumpNarrowScreen(
  WidgetTester tester, {
  required AppDatabase db,
  required Widget child,
  Motorcycle? activeMotor,
  Future<void> Function(WidgetTester)? verify,
}) async {
  tester.view.physicalSize = const Size(360, 780);
  tester.view.devicePixelRatio = 1.0;
  tester.platformDispatcher.textScaleFactorTestValue = 1.15;

  final capturedErrors = <FlutterErrorDetails>[];
  final prevOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    capturedErrors.add(details);
  };

  try {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          if (activeMotor != null)
            activeMotorcycleProvider.overrideWith(
              (ref) => _PresetActiveMotorNotifier(ref, activeMotor),
            ),
        ],
        child: MaterialApp(
          theme: BuildHausTheme.darkTheme(),
          home: child,
        ),
      ),
    );
    await _settleBounded(tester);

    if (verify != null) {
      await verify(tester);
      await _settleBounded(tester);
    }

    final overflowErrors = capturedErrors
        .where((e) => e.toString().toLowerCase().contains('overflowed'))
        .toList();
    expect(
      overflowErrors,
      isEmpty,
      reason: 'Tidak boleh ada RenderFlex overflow di layar 360x780 (textScale 1.15): '
          '${overflowErrors.map((e) => e.exceptionAsString()).join('\n')}',
    );
  } finally {
    await _drainWidgetTree(tester);
    FlutterError.onError = prevOnError;
    tester.platformDispatcher.clearTextScaleFactorTestValue();
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
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

  group('UI Revisi & Bebas Overflow pada Layar Sempit 360x780 (TextScale 1.15)', () {
    testWidgets('AuthScreen: Email saja, tanpa Nomor HP, bebas overflow', (tester) async {
      await _pumpNarrowScreen(
        tester,
        db: db,
        child: const AuthScreen(),
        verify: (t) async {
          expect(find.text('Email'), findsOneWidget);
          expect(find.textContaining('Nomor HP'), findsNothing);

          await t.tap(find.text('Daftar Akun'));
          await _settleBounded(t);
          expect(find.textContaining('Minimal 8 karakter'), findsOneWidget);
          expect(find.textContaining('Tidak mengandung spasi'), findsOneWidget);
          expect(find.textContaining('1 huruf kapital'), findsOneWidget);
          expect(find.textContaining('1 angka'), findsOneWidget);
        },
      );
    });

    testWidgets('InitialMotorSetupScreen & AddMotorcycleScreen bebas overflow 360px', (tester) async {
      await _pumpNarrowScreen(
        tester,
        db: db,
        child: const InitialMotorSetupScreen(),
        verify: (t) async {
          expect(find.text('Data Kesehatan Motor Pertama'), findsOneWidget);
        },
      );

      await _pumpNarrowScreen(
        tester,
        db: db,
        child: const AddMotorcycleScreen(),
        verify: (t) async {
          expect(find.text('Tambah Motor'), findsOneWidget);
          expect(find.text('Simpan Motor'), findsOneWidget);
        },
      );
    });

    testWidgets('HomeScreen: Tanpa badge waktu & tombol Akun diganti Notif', (tester) async {
      await SampleDataSeeder(db).seedDiverseFiveMotorcycles();
      final motors = await db.getAllMotorcycles();

      await _pumpNarrowScreen(
        tester,
        db: db,
        activeMotor: motors.first,
        child: const HomeScreen(),
        verify: (t) async {
          expect(find.textContaining('Pagi'), findsNothing);
          expect(find.textContaining('Siang'), findsNothing);
          expect(find.textContaining('Sore'), findsNothing);
          expect(find.textContaining('Malam'), findsNothing);
          expect(find.byIcon(Icons.person_outline), findsNothing);
          expect(
            find.byWidgetPredicate(
              (w) =>
                  w is Icon &&
                  (w.icon == Icons.notifications_outlined ||
                      w.icon == Icons.notifications_active_outlined),
            ),
            findsWidgets,
          );
        },
      );
    });

    testWidgets('AccountScreen: Hanya Gelap/Terang, ada Ubah Foto, tanpa Data Contoh & Pengaturan Aplikasi', (tester) async {
      await SampleDataSeeder(db).seedDiverseFiveMotorcycles();
      final motors = await db.getAllMotorcycles();

      await _pumpNarrowScreen(
        tester,
        db: db,
        activeMotor: motors.first,
        child: const AccountScreen(),
        verify: (t) async {
          expect(find.text('Ubah Foto'), findsOneWidget);
          final scrollable = find.byType(Scrollable).first;
          await t.scrollUntilVisible(
            find.text('Gelap'),
            220,
            scrollable: scrollable,
          );
          expect(find.text('Gelap'), findsOneWidget);
          expect(find.text('Terang'), findsOneWidget);
          expect(find.text('Sistem'), findsNothing);

          await t.scrollUntilVisible(
            find.text('Muat 5 Motor Beragam Jenis'),
            220,
            scrollable: scrollable,
          );
          expect(find.text('Muat 5 Motor Beragam Jenis'), findsOneWidget);
          expect(find.text('Muat Data Motor Contoh'), findsNothing);
          expect(find.text('Pengaturan Aplikasi'), findsNothing);
        },
      );
    });

    testWidgets('HealthScreen, PartsCatalogScreen, RemindersScreen, AiAssistantScreen bebas overflow 360px', (tester) async {
      await SampleDataSeeder(db).seedDiverseFiveMotorcycles();
      final motors = await db.getAllMotorcycles();
      final active = motors.first;

      await _pumpNarrowScreen(
        tester,
        db: db,
        activeMotor: active,
        child: const HealthScreen(),
        verify: (t) async {
          expect(find.textContaining('${active.manufactureYear}'), findsWidgets);
        },
      );

      await _pumpNarrowScreen(
        tester,
        db: db,
        activeMotor: active,
        child: const PartsCatalogScreen(),
        verify: (t) async {
          expect(find.text('Katalog Sparepart'), findsOneWidget);
        },
      );

      await _pumpNarrowScreen(
        tester,
        db: db,
        activeMotor: active,
        child: RemindersScreen(motorcycleId: active.id),
        verify: (t) async {
          expect(find.text('Cek Notif di HP Saya'), findsOneWidget);
        },
      );

      await _pumpNarrowScreen(
        tester,
        db: db,
        activeMotor: active,
        child: const AiAssistantScreen(),
        verify: (t) async {
          expect(find.text('AI Health Assistant'), findsOneWidget);
        },
      );
    });

    testWidgets('AppShell bottom navbar rapi dan bebas overflow di layar 360x780', (tester) async {
      await db.setSetting('auth_logged_in', 'true');
      await db.setSetting('onboarding_completed', 'true');
      await SampleDataSeeder(db).seedDiverseFiveMotorcycles();

      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      tester.platformDispatcher.textScaleFactorTestValue = 1.15;
      final errors = <FlutterErrorDetails>[];
      final prev = FlutterError.onError;
      FlutterError.onError = errors.add;

      try {
        final router = GoRouter(
          initialLocation: '/home',
          routes: [
            StatefulShellRoute.indexedStack(
              builder: (_, __, shell) => AppShell(navigationShell: shell),
              branches: [
                StatefulShellBranch(routes: [GoRoute(path: '/home', builder: (_, __) => const HomeScreen())]),
                StatefulShellBranch(routes: [GoRoute(path: '/health', builder: (_, __) => const HealthScreen())]),
                StatefulShellBranch(routes: [GoRoute(path: '/parts', builder: (_, __) => const PartsCatalogScreen())]),
                StatefulShellBranch(routes: [GoRoute(path: '/reminders', builder: (_, __) => const RemindersScreen())]),
                StatefulShellBranch(routes: [GoRoute(path: '/account', builder: (_, __) => const AccountScreen())]),
              ],
            ),
          ],
        );
        await tester.pumpWidget(
          ProviderScope(
            overrides: [databaseProvider.overrideWithValue(db)],
            child: MaterialApp.router(
              theme: BuildHausTheme.darkTheme(),
              routerConfig: router,
            ),
          ),
        );
        await _settleBounded(tester);

        expect(find.text('Beranda'), findsOneWidget);
        expect(find.text('Sehat'), findsOneWidget);
        expect(find.text('Sparepart'), findsOneWidget);
        expect(find.text('Riwayat'), findsOneWidget);
        expect(find.text('Akun'), findsOneWidget);
        expect(
          errors.where((e) => e.toString().toLowerCase().contains('overflowed')),
          isEmpty,
        );
      } finally {
        await _drainWidgetTree(tester);
        FlutterError.onError = prev;
        tester.platformDispatcher.clearTextScaleFactorTestValue();
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      }
    });
  });
}
