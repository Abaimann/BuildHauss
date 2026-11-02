import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:go_router/go_router.dart';
import 'package:buildhaus/core/theme/app_theme.dart';
import 'package:buildhaus/core/database/app_database.dart';
import 'package:buildhaus/core/providers/database_provider.dart';
import 'package:buildhaus/features/motorcycles/presentation/screens/add_motorcycle_screen.dart';
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

  testWidgets('AddMotorcycleScreen redirects to SelfInspectionScreen upon adding motor', (tester) async {
    final router = GoRouter(
      initialLocation: '/motorcycles/add',
      routes: [
        GoRoute(
          path: '/motorcycles/add',
          builder: (context, state) => const AddMotorcycleScreen(),
        ),
        GoRoute(
          path: '/motor/:id/inspection',
          builder: (context, state) => SelfInspectionScreen(
            motorcycleId: int.parse(state.pathParameters['id']!),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
        child: MaterialApp.router(
          theme: BuildHausTheme.darkTheme(),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tambah Motor'), findsOneWidget);

    // Fill in nickname
    final nicknameFinder = find.widgetWithText(TextFormField, 'Contoh: Honda Beat B 1234 XYZ');
    if (nicknameFinder.evaluate().isNotEmpty) {
      await tester.enterText(nicknameFinder, 'Honda Vario Baru');
    } else {
      await tester.enterText(find.byType(TextFormField).first, 'Honda Vario Baru');
    }

    // Scroll to Simpan Motor button
    final saveBtn = find.widgetWithText(ElevatedButton, 'Simpan Motor');
    expect(saveBtn, findsOneWidget);
    await tester.scrollUntilVisible(saveBtn, 200, scrollable: find.byType(Scrollable).first);
    await tester.tap(saveBtn);
    await tester.pumpAndSettle();

    // Verify redirected immediately to Pemeriksaan Mandiri!
    expect(find.text('Pemeriksaan Mandiri'), findsOneWidget);
    expect(find.textContaining('Pertanyaan 1 dari'), findsOneWidget);
  });
}
