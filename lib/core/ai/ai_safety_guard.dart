import 'package:equatable/equatable.dart';

/// Severity of safety alerts detected by the deterministic safety guard.
enum SafetyRiskLevel { low, medium, high, critical }

/// Result produced by [AiSafetyGuard] evaluation.
class SafetyEvaluationResult extends Equatable {
  final bool hasRedFlag;
  final SafetyRiskLevel riskLevel;
  final String? warningTitle;
  final String? warningMessage;
  final List<String> detectedKeywords;
  final bool requiresMechanic;
  final bool doNotRideWarning;

  const SafetyEvaluationResult({
    required this.hasRedFlag,
    required this.riskLevel,
    this.warningTitle,
    this.warningMessage,
    this.detectedKeywords = const [],
    required this.requiresMechanic,
    required this.doNotRideWarning,
  });

  /// Safe default result when no red flags are found.
  static const SafetyEvaluationResult safe = SafetyEvaluationResult(
    hasRedFlag: false,
    riskLevel: SafetyRiskLevel.low,
    requiresMechanic: false,
    doNotRideWarning: false,
  );

  @override
  List<Object?> get props => [
    hasRedFlag,
    riskLevel,
    warningTitle,
    warningMessage,
    detectedKeywords,
    requiresMechanic,
    doNotRideWarning,
  ];
}

/// Deterministic safety guard that inspects user complaints and motorcycle context.
///
/// Ensures critical red-flag safety issues (brakes, fuel leaks, tire damage, steering failure)
/// ALWAYS produce prominent safety warnings and mechanic referrals, regardless of LLM generation.
class AiSafetyGuard {
  static const List<String> _brakeKeywords = [
    'rem blong',
    'rem tidak pakem',
    'rem tidak berfungsi',
    'rem los',
    'rem ambles',
    'rem keras',
    'rem bunyi',
    'minyak rem bocor',
    'kampas rem habis',
    'pengereman blong',
    'rem bermasalah',
  ];

  static const List<String> _fuelKeywords = [
    'bensin bocor',
    'bahan bakar bocor',
    'bau bensin',
    'tangki bocor',
    'selang bensin bocor',
    'karburator banjir',
    'bocor bensin',
  ];

  static const List<String> _tireKeywords = [
    'ban pecah',
    'ban robek',
    'ban benjol',
    'kawat ban keluar',
    'ban meledak',
    'ban retak parah',
    'ban gembos terus',
  ];

  static const List<String> _steeringKeywords = [
    'stang oleng',
    'stang goyang',
    'segitiga bengkok',
    'kemudi macet',
    'koma stang',
    'stang berat',
    'bearing stang oblak',
    'setir goyang',
  ];

  /// Evaluates an input complaint string deterministically.
  static SafetyEvaluationResult evaluate(String input) {
    final lower = input.toLowerCase();
    final matchedBrake = _brakeKeywords
        .where((k) => lower.contains(k))
        .toList();
    final matchedFuel = _fuelKeywords.where((k) => lower.contains(k)).toList();
    final matchedTire = _tireKeywords.where((k) => lower.contains(k)).toList();
    final matchedSteering = _steeringKeywords
        .where((k) => lower.contains(k))
        .toList();

    final allMatches = [
      ...matchedBrake,
      ...matchedFuel,
      ...matchedTire,
      ...matchedSteering,
    ];

    if (allMatches.isEmpty) {
      // Check for generic high-risk keywords
      if (lower.contains('rem') || lower.contains('pengereman')) {
        return const SafetyEvaluationResult(
          hasRedFlag: true,
          riskLevel: SafetyRiskLevel.medium,
          warningTitle: 'Peringatan Sistem Pengereman',
          warningMessage:
              'Keluhan Anda melibatkan sistem rem. Rem adalah fitur keselamatan vital. '
              'Pastikan ketebalan kampas, level minyak rem, dan jarak main tuas rem diperiksa dengan teliti.',
          detectedKeywords: ['rem'],
          requiresMechanic: true,
          doNotRideWarning: false,
        );
      }
      return SafetyEvaluationResult.safe;
    }

    // Critical red flag detected!
    final warnings = <String>[];
    if (matchedBrake.isNotEmpty) {
      warnings.add(
        '• SISTEM REM: Risiko kegagalan pengereman yang sangat tinggi.',
      );
    }
    if (matchedFuel.isNotEmpty) {
      warnings.add(
        '• KEBOCORAN BAHAN BAKAR: Risiko kebakaran mesin atau percikan api.',
      );
    }
    if (matchedTire.isNotEmpty) {
      warnings.add('• KERUSAKAN BAN: Risiko hilang kendali saat berkendara.');
    }
    if (matchedSteering.isNotEmpty) {
      warnings.add('• GANGGUAN KEMUDI/STANG: Bahaya kehilangan arah kemudi.');
    }

    final message =
        '⚠️ PERINGATAN KESELAMATAN KRITIS\n\n'
        'Keluhan yang Anda laporkan mengindikasikan bahaya langsung bagi keselamatan berkendara:\n'
        '${warnings.join('\n')}\n\n'
        '🚨 ANJURAN KESELAMATAN:\n'
        '1. JANGAN mengendarai sepeda motor ini di jalan raya.\n'
        '2. Segera bawa ke bengkel resmi atau mekanik profesional terdekat.\n'
        '3. Masalah ini TIDAK BISA ditunda demi keselamatan jiwa Anda.';

    return SafetyEvaluationResult(
      hasRedFlag: true,
      riskLevel: SafetyRiskLevel.critical,
      warningTitle: 'Bahaya Keselamatan Berkendara',
      warningMessage: message,
      detectedKeywords: allMatches,
      requiresMechanic: true,
      doNotRideWarning: true,
    );
  }

  /// Deterministically merges AI inference results with safety guard requirements.
  /// Enforces that if a safety red flag exists, the output ALWAYS has risk_level = 'high'
  /// and requires_mechanic = true, preventing the LLM from downplaying safety risks.
  static Map<String, dynamic> enforceSafetyOverrides(
    Map<String, dynamic> aiOutput,
    SafetyEvaluationResult safety,
  ) {
    if (!safety.hasRedFlag) return aiOutput;

    final updated = Map<String, dynamic>.from(aiOutput);

    // Enforce high or critical risk level
    if (safety.riskLevel == SafetyRiskLevel.critical ||
        safety.riskLevel == SafetyRiskLevel.high) {
      updated['risk_level'] = 'high';
      updated['requires_mechanic'] = true;
    }

    if (safety.doNotRideWarning) {
      final existingAdvice = updated['inspection_advice'] as String? ?? '';
      updated['inspection_advice'] =
          '🚨 PERINGATAN: JANGAN KENDARAI MOTOR. '
          '${safety.warningTitle}: ${safety.warningMessage}\n\n$existingAdvice';
    }

    return updated;
  }
}
