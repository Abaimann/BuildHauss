import 'package:flutter_test/flutter_test.dart';
import 'package:buildhaus/core/engines/self_inspection_engine.dart';

void main() {
  group('SelfInspectionEngine', () {
    test('17. Pertanyaan dengan jawaban positif yang menunjukkan gejala', () {
      // Answering that brake emits screeching metallic noise
      final answers = {'rem_bunyi': 'gesekan_logam'};
      final eval = SelfInspectionEngine.evaluate(answers);

      expect(eval.totalIssues, equals(1));
      expect(eval.allFindings.single.componentName, equals('Kampas rem'));
      expect(eval.allFindings.single.riskLevel, equals('high'));
      expect(eval.allFindings.single.isSafetyCritical, isTrue);
    });

    test(
      '18. Pertanyaan dengan indikasi masalah berbasis makna (semantic evaluation)',
      () {
        // Normal lights = no issue
        final normalEval = SelfInspectionEngine.evaluate({
          'kelistrikan_lampu': 'menyala_terang',
        });
        expect(normalEval.totalIssues, equals(0));
        expect(normalEval.riskLevel, equals('low'));

        // Dim lights = issue
        final issueEval = SelfInspectionEngine.evaluate({
          'kelistrikan_lampu': 'redup',
        });
        expect(issueEval.totalIssues, equals(1));
        expect(issueEval.allFindings.single.componentName, equals('Aki'));
        expect(issueEval.allFindings.single.riskLevel, equals('medium'));
      },
    );

    test('19. Peringatan rem tidak berfungsi (safety critical trigger)', () {
      final answers = {'rem_respons': 'blong'};
      final eval = SelfInspectionEngine.evaluate(answers);

      expect(eval.hasSafetyAlert, isTrue);
      expect(eval.riskLevel, equals('high'));
      expect(eval.safetyAlerts, isNotEmpty);
      expect(eval.safetyAlerts.first.componentName, equals('Kampas rem'));
      expect(eval.safetyAlerts.first.advice, contains('JANGAN kendarai'));
    });

    test('20. Peringatan kebocoran bahan bakar (fire hazard trigger)', () {
      final answers = {'kebocoran_cairan': 'bocor_bensin'};
      final eval = SelfInspectionEngine.evaluate(answers);

      expect(eval.hasSafetyAlert, isTrue);
      expect(eval.riskLevel, equals('high'));
      expect(
        eval.safetyAlerts.any((a) => a.advice.contains('BAHAYA KEBAKARAN')),
        isTrue,
      );
    });

    test(
      'Identifies affected components correctly for HealthEngine integration',
      () {
        final answers = {
          'rem_respons': 'lemah',
          'ban_kondisi': 'botak_benjol',
          'cvt_transmisi': 'gredek',
        };
        final eval = SelfInspectionEngine.evaluate(answers);

        expect(
          eval.affectedComponentNames,
          containsAll(['Kampas rem', 'Ban', 'CVT']),
        );
        expect(eval.hasSafetyAlert, isTrue);
      },
    );
  });
}
