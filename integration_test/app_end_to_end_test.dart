import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:buildhaus/app/app.dart';
import 'package:buildhaus/core/database/app_database.dart';
import 'package:buildhaus/core/providers/database_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.ensureReferenceData();
  });

  tearDown(() async {
    await db.close();
  });

  group(
    'Tahap 06 — Full App Integration Test (E2E Navigation & Rendering)',
    () {
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

        // Tap on navigation destinations in order
        // 1. Tab Sehat
        final sehatDest = find.text('Sehat');
        if (sehatDest.evaluate().isNotEmpty) {
          await tester.tap(sehatDest, warnIfMissed: false);
          await tester.pump(const Duration(milliseconds: 300));
        }

        // 2. Tab Sparepart
        final sparepartDest = find.text('Sparepart');
        if (sparepartDest.evaluate().isNotEmpty) {
          await tester.tap(sparepartDest, warnIfMissed: false);
          await tester.pump(const Duration(milliseconds: 300));
        }

        // 3. Tab Riwayat
        final riwayatDest = find.text('Riwayat');
        if (riwayatDest.evaluate().isNotEmpty) {
          await tester.tap(riwayatDest, warnIfMissed: false);
          await tester.pump(const Duration(milliseconds: 300));
        }

        // 4. Tab Akun
        final akunDest = find.text('Akun');
        if (akunDest.evaluate().isNotEmpty) {
          await tester.tap(akunDest, warnIfMissed: false);
          await tester.pump(const Duration(milliseconds: 300));
        }

        // 5. Back to Beranda
        final berandaDest = find.text('Beranda');
        if (berandaDest.evaluate().isNotEmpty) {
          await tester.tap(berandaDest, warnIfMissed: false);
          await tester.pump(const Duration(milliseconds: 300));
        }

        // Drain any pending timers
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 200));
      });
    },
  );
}
