import '../database/app_database.dart';

/// Mileage prediction engine for BuildHaus.
///
/// Features:
/// - Learning phase: Tracks 3 monthly periods of odometer updates.
/// - Prioritizes actual readings over estimates.
/// - Weighted average giving more weight to recent data intervals.
/// - Handles duplicate timestamps, out-of-order logs, odometer resets/decreases,
///   low usage, and long idle periods without crashing or producing negative rates.
class MileagePredictor {
  final List<OdometerLog> _logs;

  MileagePredictor(List<OdometerLog> logs) : _logs = List.unmodifiable(logs);

  /// Returns sorted, clean odometer logs in chronological order.
  List<OdometerLog> get sortedLogs {
    final list = [..._logs];
    list.sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
    return list;
  }

  /// Latest actual odometer reading recorded by the user.
  OdometerLog? get latestActualReading {
    if (_logs.isEmpty) return null;
    final sorted = sortedLogs;
    return sorted.last;
  }

  /// Latest actual kilometer value, or null if no logs exist.
  double? get latestActualOdometer => latestActualReading?.odometerKm;

  /// Earliest actual odometer reading.
  OdometerLog? get baselineReading {
    if (_logs.isEmpty) return null;
    return sortedLogs.first;
  }

  /// Number of distinct, valid monthly periods (~25-30 days per period)
  /// covered by user readings.
  ///
  /// A valid period requires readings separated across distinct monthly checkpoints,
  /// preventing 3 entries on the same day or week from falsely completing the learning phase.
  int get validMonthlyPeriodsCount {
    final sorted = sortedLogs;
    if (sorted.length < 2) return 0;

    int periods = 0;
    DateTime lastCheckpoint = sorted.first.recordedAt;

    for (int i = 1; i < sorted.length; i++) {
      final current = sorted[i];
      final daysDiff = current.recordedAt.difference(lastCheckpoint).inDays;
      // At least 25 days gap to count as a distinct monthly period interval
      if (daysDiff >= 25) {
        periods++;
        lastCheckpoint = current.recordedAt;
        if (periods >= 3) break;
      }
    }

    return periods;
  }

  /// Whether the user has completed the mandatory 3 monthly monitoring periods.
  bool get hasCompletedThreeMonthlyPeriods => validMonthlyPeriodsCount >= 3;

  /// True during the initial 3 monthly periods learning phase.
  bool get isLearningPhase => !hasCompletedThreeMonthlyPeriods;

  /// Human-readable learning phase status for UI and transparent communication.
  String get learningStatusMessage {
    if (_logs.isEmpty) {
      return 'Belum ada data odometer.';
    }
    if (_logs.length == 1) {
      return 'Data baseline tercatat. Lakukan pembaruan rutin selama 3 periode bulanan.';
    }
    if (isLearningPhase) {
      return 'Data penggunaan belum cukup ($validMonthlyPeriodsCount/3 periode bulanan).';
    }
    return 'Pembelajaran selesai (3 periode bulanan terpenuhi).';
  }

  /// Minimal data sufficiency for preliminary daily calculation (at least 2 readings on distinct dates).
  bool get hasEnoughData {
    if (_logs.length < 2) return false;
    final sorted = sortedLogs;
    return sorted.last.recordedAt.difference(sorted.first.recordedAt).inDays >
        0;
  }

  /// Estimated km per day based on historical data.
  ///
  /// Uses a recency-weighted average of valid positive daily intervals.
  /// Ignores duplicate dates and negative deltas (odometer rollbacks/typos).
  double? get kmPerDay {
    final sorted = sortedLogs;
    if (sorted.length < 2) return null;

    double totalWeightedKmPerDay = 0;
    double totalWeights = 0;

    for (int i = 1; i < sorted.length; i++) {
      final prev = sorted[i - 1];
      final curr = sorted[i];
      final days = curr.recordedAt.difference(prev.recordedAt).inDays;

      // Handle duplicate timestamp or same-day multiple entries
      if (days <= 0) continue;

      final kmDiff = curr.odometerKm - prev.odometerKm;

      // Gracefully handle odometer rollback/reset: ignore negative intervals
      if (kmDiff < 0) continue;

      final dailyRate = kmDiff / days;

      // Recency weight: more recent intervals receive proportionally higher weight
      final weight = i / sorted.length;
      totalWeightedKmPerDay += dailyRate * weight;
      totalWeights += weight;
    }

    if (totalWeights == 0) return null;
    return totalWeightedKmPerDay / totalWeights;
  }

  /// Estimated km per week (7 days).
  double get kmPerWeek => (kmPerDay ?? 0.0) * 7.0;

  /// Estimated km per month (30 days).
  double get kmPerMonth => (kmPerDay ?? 0.0) * 30.0;

  /// Confidence level based on data quality
  String get confidence {
    if (_logs.isEmpty) return 'unknown';
    if (_logs.length < 2) return 'low';
    if (_logs.length < 4) return 'medium';
    return 'high';
  }

  /// Estimates future odometer value on a given target date based on current rate.
  /// Returns actual odometer if target date is in the past or equal to latest reading.
  double? estimateOdometerAt(DateTime targetDate) {
    final latest = latestActualReading;
    if (latest == null) return null;

    final rate = kmPerDay;
    if (rate == null) return latest.odometerKm;

    final days = targetDate.difference(latest.recordedAt).inDays;
    if (days <= 0) return latest.odometerKm;

    return latest.odometerKm + (days * rate);
  }

  /// Estimated target odometer for next scheduled service based on interval.
  double? predictNextServiceOdometer(double lastOdometer, double intervalKm) {
    if (intervalKm <= 0) return null;
    return lastOdometer + intervalKm;
  }

  /// Estimated date when odometer will reach target km.
  /// If target already passed or reached, returns now.
  DateTime? predictDateForOdometer(
    double currentOdometer,
    double targetOdometer,
  ) {
    final rate = kmPerDay;
    if (rate == null || rate <= 0) return null;

    final kmRemaining = targetOdometer - currentOdometer;
    if (kmRemaining <= 0) return DateTime.now();

    final daysNeeded = kmRemaining / rate;
    return DateTime.now().add(Duration(days: daysNeeded.ceil()));
  }

  /// Estimated date of next service based on service interval km.
  DateTime? predictNextServiceDate(double lastServiceOdo, double intervalKm) {
    final target = predictNextServiceOdometer(lastServiceOdo, intervalKm);
    final current = latestActualOdometer ?? lastServiceOdo;
    if (target == null) return null;
    return predictDateForOdometer(current, target);
  }
}
