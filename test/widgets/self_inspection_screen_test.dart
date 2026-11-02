import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide Column, isNotNull;
import 'package:drift/native.dart';
import 'package:buildhaus/core/theme/app_theme.dart';
import 'package:buildhaus/core/database/app_database.dart';
import 'package:buildhaus/core/providers/database_provider.dart';
import 'package:buildhaus/core/engines/self_inspection_engine.dart';
import 'package:buildhaus/features/self_inspection/presentation/screens/self_inspection_screen.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.ensureReferenceData();
  });

  tearDown(() async {
    await db.close();
  });

  testWidgets('SelfInspectionScreen can select answer and auto-advances or advances via button', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
        child: MaterialApp(
          theme: BuildHausTheme.darkTheme(),
          home: const SelfInspectionScreen(motorcycleId: 1),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Pertanyaan 1 dari'), findsOneWidget);

    // Tap first option - it auto advances after short delay
    final firstOption = find.text('Pakem dan merespons normal');
    expect(firstOption, findsOneWidget);
    await tester.tap(firstOption);
    await tester.pumpAndSettle();

    // Successfully auto-advanced to question 2!
    expect(find.textContaining('Pertanyaan 2 dari'), findsOneWidget);

    // Tap 'Kembali' button to verify going back to question 1
    final backBtn = find.text('Kembali');
    expect(backBtn, findsWidgets);
    await tester.tap(backBtn.first);
    await tester.pumpAndSettle();

    expect(find.textContaining('Pertanyaan 1 dari'), findsOneWidget);

    // Now on question 1 (where answer was already selected), 'Lanjut' button is visible!
    final nextBtn = find.text('Lanjut');
    expect(nextBtn, findsOneWidget);
    await tester.tap(nextBtn);
    await tester.pumpAndSettle();

    expect(find.textContaining('Pertanyaan 2 dari'), findsOneWidget);
  });

  testWidgets('SelfInspectionScreen full flow to results and saving', (tester) async {
    // Insert a sample motorcycle to db with valid modelId
    final models = await db.getAllMotorcycleModels();
    final model = models.first;
    final motorId = await db.createMotorcycle(
      motorcycle: MotorcyclesCompanion(
        nickname: const Value('Beat FI Test'),
        modelId: Value(model.id),
        manufactureYear: Value(model.yearStart),
      ),
      initialOdometerKm: 12000,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
        child: MaterialApp(
          theme: BuildHausTheme.darkTheme(),
          home: SelfInspectionScreen(motorcycleId: motorId),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Answer all 8 questions
    final questions = SelfInspectionEngine.questions;
    for (int i = 0; i < questions.length; i++) {
      expect(find.textContaining('Pertanyaan ${i + 1} dari ${questions.length}'), findsOneWidget);
      final opt = questions[i].options.first;
      final optFinder = find.text(opt.label);
      expect(optFinder, findsOneWidget);
      await tester.tap(optFinder);
      await tester.pumpAndSettle();
    }

    // On the 8th question, tap 'Selesai'
    final finishBtn = find.text('Selesai');
    if (finishBtn.evaluate().isNotEmpty) {
      await tester.tap(finishBtn);
      await tester.pumpAndSettle();
    }

    // Now on Result screen
    expect(find.text('Hasil Pemeriksaan Mandiri'), findsOneWidget);
    final saveBtn = find.text('Simpan Hasil Pemeriksaan');
    expect(saveBtn, findsOneWidget);
    await tester.scrollUntilVisible(saveBtn, 200);
    await tester.tap(saveBtn);
    await tester.pumpAndSettle();

    // Verify inspection saved to db
    final inspection = await db.getLatestSelfInspection(motorId);
    expect(inspection, isNotNull);
  });
}
