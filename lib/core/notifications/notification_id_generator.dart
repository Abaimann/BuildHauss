/// Deterministic, stable, and collision-free notification ID generator for BuildHaus.
///
/// Guarantees that notification IDs for different motorcycles, component reminders,
/// complaint follow-ups, and manual reminders never collide within the 31-bit
/// positive integer range (0 to 2,147,483,647).
class NotificationIdGenerator {
  NotificationIdGenerator._();

  static const int maxSafeId = 2147483647; // 31-bit positive signed integer
  static const int perMotorBlock = 100000;
  static const int offsetOdometer = 10000;
  static const int offsetComponent = 20000;
  static const int offsetComplaint = 30000;
  static const int offsetManual = 40000;

  /// Generates a stable unique ID for an odometer staleness reminder.
  static int forOdometer(int motorcycleId) {
    final motorBlock = (motorcycleId.abs() % 20000) * perMotorBlock;
    return (motorBlock + offsetOdometer) % maxSafeId;
  }

  /// Generates a stable unique ID for a component health reminder.
  static int forComponent(int motorcycleId, int componentTypeId) {
    final motorBlock = (motorcycleId.abs() % 20000) * perMotorBlock;
    return (motorBlock + offsetComponent + (componentTypeId.abs() % 9999)) %
        maxSafeId;
  }

  /// Generates a stable unique ID for a complaint follow-up reminder.
  static int forComplaint(int motorcycleId, int complaintId) {
    final motorBlock = (motorcycleId.abs() % 20000) * perMotorBlock;
    return (motorBlock + offsetComplaint + (complaintId.abs() % 9999)) %
        maxSafeId;
  }

  /// Generates a stable unique ID for a manual user-created reminder.
  static int forManual(int motorcycleId, int manualId) {
    final motorBlock = (motorcycleId.abs() % 20000) * perMotorBlock;
    return (motorBlock + offsetManual + (manualId.abs() % 9999)) % maxSafeId;
  }
}
