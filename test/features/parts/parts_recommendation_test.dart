import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:buildhaus/core/database/app_database.dart';
import 'package:buildhaus/core/database/sample_data_seeder.dart';
import 'package:buildhaus/core/providers/app_providers.dart';
import 'package:buildhaus/core/providers/database_provider.dart';
import 'package:buildhaus/features/parts/presentation/providers/parts_providers.dart';

class _TestActiveMotorcycleNotifier extends ActiveMotorcycleNotifier {
  _TestActiveMotorcycleNotifier(super.ref, Motorcycle? motor) {
    state = motor;
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

  group('Sparepart Recommendation Priorities (Budget 1st, Health 2nd)', () {
    test('1. When no motorcycle is active, all spareparts are in generalCatalog tier', () async {
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          activeMotorcycleProvider.overrideWith(
            (ref) => _TestActiveMotorcycleNotifier(ref, null),
          ),
        ],
      );
      addTearDown(container.dispose);

      final parts = await container.read(prioritizedSparepartsProvider.future);
      expect(parts, isNotEmpty);
      expect(
        parts.every((p) => p.tier == RecommendationTier.generalCatalog),
        isTrue,
      );
    });

    test('2. Seeded Vario 160 with budget plan prioritizes budget funded parts (Priority 1)', () async {
      final seeder = SampleDataSeeder(db);
      await seeder.seedRealisticSampleMotorcycles();

      final motors = await db.getAllMotorcycles();
      final vario = motors.firstWhere((m) => m.nickname.contains('Vario'));

      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          activeMotorcycleProvider.overrideWith(
            (ref) => _TestActiveMotorcycleNotifier(ref, vario),
          ),
        ],
      );
      addTearDown(container.dispose);

      final parts = await container.read(prioritizedSparepartsProvider.future);
      expect(parts, isNotEmpty);

      // Verify that budget funded recommendations exist
      final budgetParts = parts.where((p) => p.isBudgetRecommended).toList();
      expect(budgetParts, isNotEmpty);

      // Top parts must be in Priority 1 (budgetFunded or budgetDeferred)
      expect(parts.first.isBudgetRecommended, isTrue);
      expect(parts.first.tier, equals(RecommendationTier.budgetFunded));
    });

    test('3. Seeded Beat Street identifies health attention parts (Priority 2)', () async {
      final seeder = SampleDataSeeder(db);
      await seeder.seedRealisticSampleMotorcycles();

      final motors = await db.getAllMotorcycles();
      final beat = motors.firstWhere((m) => m.nickname.contains('Beat'));

      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          activeMotorcycleProvider.overrideWith(
            (ref) => _TestActiveMotorcycleNotifier(ref, beat),
          ),
        ],
      );
      addTearDown(container.dispose);

      final parts = await container.read(prioritizedSparepartsProvider.future);
      expect(parts, isNotEmpty);

      // Verify health attention parts exist for components needing service
      final healthParts = parts.where((p) => p.isHealthRecommended).toList();
      expect(healthParts, isNotEmpty);

      for (final hp in healthParts) {
        expect(hp.tier, equals(RecommendationTier.healthAttention));
        expect(hp.badgeText, isNotNull);
        expect(hp.componentName, isNotNull);
      }
    });

    test('4. Brand isolation: Honda motorcycle does not get Yamaha parts as budget recommendations', () async {
      final seeder = SampleDataSeeder(db);
      await seeder.seedRealisticSampleMotorcycles();

      final motors = await db.getAllMotorcycles();
      final vario = motors.firstWhere((m) => m.nickname.contains('Vario'));

      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          activeMotorcycleProvider.overrideWith(
            (ref) => _TestActiveMotorcycleNotifier(ref, vario),
          ),
        ],
      );
      addTearDown(container.dispose);

      final parts = await container.read(prioritizedSparepartsProvider.future);
      final recommendedParts = parts.where((p) => p.isBudgetRecommended || p.isHealthRecommended).toList();

      for (final p in recommendedParts) {
        final brand = (p.part.brand ?? '').toLowerCase();
        final name = p.part.name.toLowerCase();
        expect(brand.contains('yamaha'), isFalse, reason: 'Honda should not recommend Yamaha part $name');
        expect(name.contains('yamalube'), isFalse, reason: 'Honda should not recommend Yamalube part $name');
      }
    });

    test('5. Stats provider accurately calculates budget and health count', () async {
      final seeder = SampleDataSeeder(db);
      await seeder.seedRealisticSampleMotorcycles();

      final motors = await db.getAllMotorcycles();
      final vario = motors.firstWhere((m) => m.nickname.contains('Vario'));

      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          activeMotorcycleProvider.overrideWith(
            (ref) => _TestActiveMotorcycleNotifier(ref, vario),
          ),
        ],
      );
      addTearDown(container.dispose);

      final stats = await container.read(sparepartRecommendationStatsProvider.future);
      expect(stats.motorcycleName, equals(vario.nickname));
      expect(stats.budgetAmount, isNotNull);
      expect(stats.totalCount, greaterThan(0));
      expect(stats.budgetCount, greaterThan(0));
    });
  });
}
