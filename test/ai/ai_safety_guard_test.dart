import 'package:flutter_test/flutter_test.dart';
import 'package:buildhaus/core/ai/ai_safety_guard.dart';

void main() {
  group('Tahap 04 — Deterministic AI Safety Guard Tests', () {
    test('1. Detects brake failure red flag and enforces critical warning', () {
      final inputs = [
        'Motor saya rem blong di turunan',
        'Tuas rem ambles dan rem tidak pakem sama sekali',
        'Ada minyak rem bocor di kaliper depan',
      ];

      for (final input in inputs) {
        final result = AiSafetyGuard.evaluate(input);
        expect(result.hasRedFlag, isTrue, reason: 'Failed for $input');
        expect(
          result.riskLevel,
          isIn([SafetyRiskLevel.high, SafetyRiskLevel.critical]),
        );
        expect(result.requiresMechanic, isTrue);
        expect(result.doNotRideWarning, isTrue);
        expect(result.warningMessage, contains('PERINGATAN KESELAMATAN'));
      }
    });

    test('2. Detects fuel leak red flag and warns against riding', () {
      final result = AiSafetyGuard.evaluate(
        'Ada bensin bocor dan bau bensin menyengat',
      );

      expect(result.hasRedFlag, isTrue);
      expect(result.riskLevel, equals(SafetyRiskLevel.critical));
      expect(result.requiresMechanic, isTrue);
      expect(result.doNotRideWarning, isTrue);
      expect(result.warningMessage, contains('KEBOCORAN BAHAN BAKAR'));
    });

    test('3. Detects tire blowout / damage red flag', () {
      final result = AiSafetyGuard.evaluate(
        'Ban pecah di jalan dan kawat ban keluar',
      );

      expect(result.hasRedFlag, isTrue);
      expect(result.riskLevel, equals(SafetyRiskLevel.critical));
      expect(result.requiresMechanic, isTrue);
      expect(result.doNotRideWarning, isTrue);
      expect(result.warningMessage, contains('KERUSAKAN BAN'));
    });

    test('4. Detects steering failure red flag', () {
      final result = AiSafetyGuard.evaluate(
        'Stang oleng parah setelah kena lubang',
      );

      expect(result.hasRedFlag, isTrue);
      expect(result.riskLevel, equals(SafetyRiskLevel.critical));
      expect(result.requiresMechanic, isTrue);
      expect(result.doNotRideWarning, isTrue);
      expect(result.warningMessage, contains('GANGGUAN KEMUDI/STANG'));
    });

    test('5. Safe input returns safe evaluation without false alarm', () {
      final result = AiSafetyGuard.evaluate(
        'Berapa interval ganti oli yang bagus untuk harian?',
      );

      expect(result.hasRedFlag, isFalse);
      expect(result.riskLevel, equals(SafetyRiskLevel.low));
      expect(result.requiresMechanic, isFalse);
      expect(result.doNotRideWarning, isFalse);
    });

    test('6. Safety overrides cannot be downgraded by LLM output', () {
      final safety = AiSafetyGuard.evaluate('Rem blong total');

      // Hypothetical buggy LLM that tries to claim the risk is low and no mechanic needed
      final unsafeLlmOutput = <String, dynamic>{
        'risk_level': 'low',
        'requires_mechanic': false,
        'inspection_advice': 'Coba pompa tuas rem sendiri.',
      };

      final enforced = AiSafetyGuard.enforceSafetyOverrides(
        unsafeLlmOutput,
        safety,
      );

      expect(enforced['risk_level'], equals('high'));
      expect(enforced['requires_mechanic'], isTrue);
      expect(enforced['inspection_advice'], contains('JANGAN KENDARAI MOTOR'));
    });
  });
}
