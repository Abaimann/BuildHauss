# BuildHaus Test Report

## Build Environment

- **OS**: Windows 11
- **Flutter**: 3.38.5
- **Dart**: 3.10.4
- **Android SDK**: 36
- **JDK**: Temurin 17
- **Gradle**: 8.x (bundled with Flutter)

## Verification Pipeline Status

### 1. Flutter Analyze
```powershell
flutter analyze
```
✅ **SUCCESS** - `No issues found!` (0 errors, 0 warnings, 0 infos).

### 2. Dependencies & Code Generation
```powershell
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```
✅ **SUCCESS** - Drift and Riverpod code generators completed with 0 errors.

### 3. Automated Test Suite
```powershell
flutter test
```
✅ **SUCCESS** - **68/68 passed** (100% pass rate, 0 failed, 0 skipped).

#### Breakdown of Test Suites:
- `test/widget_test.dart` (2 tests): Logo branding & tagline smoke tests.
- `test/database/migration_v1_to_v4_test.dart` (3 tests): SQLite schema migrations v1 $\to$ v4, v2 $\to$ v4, v3 $\to$ v4 with real SQLite files.
- `test/database/phase01_database_test.dart` (14 tests): Multi-motor isolation, atomic transactions, catalog lookup, foreign keys.
- `test/engines/budget_engine_test.dart` (8 tests): Budget allocation baseline tests.
- `test/engines/mileage_predictor_test.dart` (19 tests): 3-monthly learning phase, predictions, recalibration, duplicate timestamps, low usage, decreasing odometers.
- `test/engines/health_engine_test.dart` (17 tests): Model-specific rules, component isolation, inspect vs replace actions, safety overrides, ratio thresholds.
- `test/engines/self_inspection_engine_test.dart` (5 tests): Semantic meaning evaluations, safety critical alerts (brakes, fuel leak, tyres, steering), component mapping.
- `test/database/phase02_health_database_test.dart` (5 tests): Self-inspection persistence, dynamic status recalculation, post-service status recalculation, same-timestamp odometers, multi-motor isolation.

### 4. Android Debug APK Build
```powershell
flutter build apk --debug
```
✅ **SUCCESS** - Built `build\app\outputs\flutter-apk\app-debug.apk` via Gradle `assembleDebug` in 30.9s.
