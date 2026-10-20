import '../database/app_database.dart';

/// Mileage prediction engine.
/// Estimates future odometer readings based on historical data.
///
/// Algorithm:
/// - Requires at least 2 odometer readings on different dates
/// - Calculates km/day from consecutive readings
/// - Uses weighted average giving more weight to recent data
/// - Predictions become more accurate with more data points
class MileagePredictor {
  final List<OdometerLog> _logs;

  MileagePredictor(this._logs);

  /// Returns km per day estimate, or null if not enough data.
  double? get kmPerDay {
    if (_logs.length < 2) return null;

    final sorted = [..._logs]
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));

    // Simple average of daily rates between consecutive readings
    double totalKm = 0;
    double totalDays = 0;

    for (int i = 1; i < sorted.length; i++) {
      final prev = sorted[i - 1];
      final curr = sorted[i];
      final days = curr.recordedAt.difference(prev.recordedAt).inDays;
      if (days > 0) {
        final kmPerDay = (curr.odometerKm - prev.odometerKm) / days;
        if (kmPerDay >= 0) {
          // Weight by recency (more recent = higher weight)
          final weight = i / sorted.length;
          totalKm += kmPerDay * weight;
          totalDays += weight;
        }
      }
    }

    if (totalDays == 0) return null;
    return totalKm / totalDays;
  }

  /// Estimated km per week
  double get kmPerWeek => (kmPerDay ?? 0) * 7;

  /// Estimated km per month (30 days)
  double get kmPerMonth => (kmPerDay ?? 0) * 30;

  /// Estimated next service odometer based on interval km
  double? predictNextServiceOdometer(double lastOdometer, double intervalKm) {
    if (kmPerDay == null || kmPerDay! <= 0) return null;
    final nextOdo = lastOdometer + intervalKm;
    return nextOdo;
  }

  /// Estimated date when odometer will reach target km
  DateTime? predictDateForOdometer(
    double currentOdometer,
    double targetOdometer,
  ) {
    if (kmPerDay == null || kmPerDay! <= 0) return null;
    final kmRemaining = targetOdometer - currentOdometer;
    if (kmRemaining <= 0) return DateTime.now();
    final daysNeeded = kmRemaining / kmPerDay!;
    return DateTime.now().add(Duration(days: daysNeeded.ceil()));
  }

  /// Confidence level based on data quality
  String get confidence {
    if (_logs.isEmpty) return 'unknown';
    if (_logs.length < 2) return 'low';
    if (_logs.length < 4) return 'medium';
    return 'high';
  }

  /// Data sufficiency for predictions
  bool get hasEnoughData => _logs.length >= 2;
}
