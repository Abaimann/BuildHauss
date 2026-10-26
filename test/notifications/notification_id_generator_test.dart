import 'package:flutter_test/flutter_test.dart';
import 'package:buildhaus/core/notifications/notification_id_generator.dart';

void main() {
  group('Tahap 06 — NotificationIdGenerator Tests', () {
    test(
      '1. Generated IDs are strictly within 31-bit positive integer range',
      () {
        for (int m = 1; m <= 50; m++) {
          final odoId = NotificationIdGenerator.forOdometer(m);
          expect(odoId, greaterThanOrEqualTo(0));
          expect(odoId, lessThanOrEqualTo(2147483647));

          for (int c = 1; c <= 20; c++) {
            final compId = NotificationIdGenerator.forComponent(m, c);
            expect(compId, greaterThanOrEqualTo(0));
            expect(compId, lessThanOrEqualTo(2147483647));

            final compClaimId = NotificationIdGenerator.forComplaint(m, c);
            expect(compClaimId, greaterThanOrEqualTo(0));
            expect(compClaimId, lessThanOrEqualTo(2147483647));

            final manualId = NotificationIdGenerator.forManual(m, c);
            expect(manualId, greaterThanOrEqualTo(0));
            expect(manualId, lessThanOrEqualTo(2147483647));
          }
        }
      },
    );

    test('2. Zero collision across motorcycles, types, and components', () {
      final seenIds = <int, String>{};

      // Test with 30 motorcycles, 25 components, 20 complaints, 20 manual reminders
      for (int m = 1; m <= 30; m++) {
        // Odometer reminder
        final odoId = NotificationIdGenerator.forOdometer(m);
        final odoKey = 'Motor-$m-Odometer';
        expect(
          seenIds.containsKey(odoId),
          isFalse,
          reason:
              'Collision detected: $odoKey collided with ${seenIds[odoId]} (ID: $odoId)',
        );
        seenIds[odoId] = odoKey;

        // Component reminders
        for (int c = 1; c <= 25; c++) {
          final compId = NotificationIdGenerator.forComponent(m, c);
          final compKey = 'Motor-$m-Comp-$c';
          expect(
            seenIds.containsKey(compId),
            isFalse,
            reason:
                'Collision detected: $compKey collided with ${seenIds[compId]} (ID: $compId)',
          );
          seenIds[compId] = compKey;
        }

        // Complaint reminders
        for (int cmp = 1; cmp <= 20; cmp++) {
          final cmpId = NotificationIdGenerator.forComplaint(m, cmp);
          final cmpKey = 'Motor-$m-Complaint-$cmp';
          expect(
            seenIds.containsKey(cmpId),
            isFalse,
            reason:
                'Collision detected: $cmpKey collided with ${seenIds[cmpId]} (ID: $cmpId)',
          );
          seenIds[cmpId] = cmpKey;
        }

        // Manual reminders
        for (int man = 1; man <= 20; man++) {
          final manId = NotificationIdGenerator.forManual(m, man);
          final manKey = 'Motor-$m-Manual-$man';
          expect(
            seenIds.containsKey(manId),
            isFalse,
            reason:
                'Collision detected: $manKey collided with ${seenIds[manId]} (ID: $manId)',
          );
          seenIds[manId] = manKey;
        }
      }

      // Total generated unique IDs
      expect(seenIds.length, 30 * (1 + 25 + 20 + 20));
    });

    test('3. IDs are deterministic and stable across identical inputs', () {
      for (int m = 1; m <= 10; m++) {
        expect(
          NotificationIdGenerator.forOdometer(m),
          equals(NotificationIdGenerator.forOdometer(m)),
        );
        for (int c = 1; c <= 5; c++) {
          expect(
            NotificationIdGenerator.forComponent(m, c),
            equals(NotificationIdGenerator.forComponent(m, c)),
          );
        }
      }
    });
  });
}
