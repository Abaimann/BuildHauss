import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buildhaus/app/app.dart';
import 'package:buildhaus/core/database/app_database.dart';
import 'package:buildhaus/core/providers/database_provider.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.ensureReferenceData();
  });

  tearDown(() async {
    await db.close();
  });

  group('Tahap 06 — App Navigation & UI Flow Widget Tests', () {
    testWidgets(
      '1. Fresh launch -> Dashboard loads without unhandled exceptions',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [databaseProvider.overrideWithValue(db)],
            child: const BuildHausApp(),
          ),
        );

        await tester.pumpAndSettle();

        // App should be rendered without crashing
        expect(find.byType(MaterialApp), findsOneWidget);

        // Drain any pending Drift query stream timers
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 200));
      },
    );

    testWidgets('2. Multi-Motor & Dashboard tab navigation flow', (
      tester,
    ) async {
      // Pre-populate with a motor
      await db.insertMotorcycle(
        MotorcyclesCompanion.insert(
          nickname: 'Vario E2E',
          manufactureYear: 2023,
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(db)],
          child: const BuildHausApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify bottom navigation bar exists
      expect(find.byType(NavigationBar), findsOneWidget);

      // Verify destinations exist
      expect(find.text('Beranda'), findsOneWidget);
      expect(find.text('Sehat'), findsOneWidget);
      expect(find.text('Sparepart'), findsOneWidget);
      expect(find.text('Riwayat'), findsOneWidget);
      expect(find.text('Akun'), findsOneWidget);

      // Tap on navigation destinations in order
      await tester.tap(find.text('Sehat'), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('Sparepart'), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('Riwayat'), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('Akun'), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('Beranda'), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      // Drain any pending Drift query stream timers
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 200));
    });

    testWidgets('3. Empty state "Muat 3 Data Motor Contoh" button seeds 3 motorcycles', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(db)],
          child: const BuildHausApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Empty state buttons should be visible
      final loadSampleBtn = find.text('Muat 3 Data Motor Contoh');
      expect(loadSampleBtn, findsOneWidget);

      // Tap load sample data button
      await tester.tap(loadSampleBtn);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Verify 3 motorcycles are populated in the database
      final motors = await db.getAllMotorcycles();
      expect(motors.length, 3);
      expect(motors.any((m) => m.nickname == 'Vario 160 Hitam'), isTrue);
      expect(motors.any((m) => m.nickname == 'Aerox Biru Doff'), isTrue);
      expect(motors.any((m) => m.nickname == 'Beat Street Putih'), isTrue);

      // Drain any pending Drift query stream timers
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 200));
    });

    testWidgets(
      '4. Account screen: Tapping motorcycle tile navigates to Edit Motorcycle screen without 404',
      (tester) async {
        await db.insertMotorcycle(
          MotorcyclesCompanion.insert(
            nickname: 'Vario Nav Test',
            manufactureYear: 2023,
          ),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [databaseProvider.overrideWithValue(db)],
            child: const BuildHausApp(),
          ),
        );

        await tester.pumpAndSettle();

        // Navigate to Akun tab
        await tester.tap(find.text('Akun'), warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pumpAndSettle();

        // Scroll until motorcycle tile is visible
        final tile = find.text('Vario Nav Test');
        await tester.scrollUntilVisible(tile, 300);
        await tester.pumpAndSettle();

        expect(tile, findsOneWidget);

        // Tap on the motorcycle tile
        await tester.tap(tile);
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();

        // Verify Edit Motorcycle screen is displayed without 404 Page Not Found
        expect(find.text('Edit Motor'), findsOneWidget);
        expect(find.text('Page not found'), findsNothing);

        // Drain pending timers
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 200));
      },
    );
  });
}
