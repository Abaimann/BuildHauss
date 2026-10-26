import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_10y.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Local notification service for Android and offline platforms.
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin;
  bool _isInitialized = false;

  NotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  bool get isInitialized => _isInitialized;

  /// Initializes the notification plugin and local timezone database.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      tz_data.initializeTimeZones();
      // Set default local timezone to Asia/Jakarta if not set
      try {
        final location = tz.getLocation('Asia/Jakarta');
        tz.setLocalLocation(location);
      } catch (_) {
        // Fallback to UTC if timezone name not found
        tz.setLocalLocation(tz.getLocation('UTC'));
      }
    } catch (e) {
      debugPrint('Timezone initialization warning: $e');
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);

    try {
      await _plugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('Notification clicked: ${response.payload}');
        },
      );
      _isInitialized = true;
    } catch (e) {
      debugPrint(
        'NotificationService initialization failed (non-Android or headless): $e',
      );
    }
  }

  /// Requests notification permission on Android 13+ (API 33+).
  Future<bool> requestPermission() async {
    if (kIsWeb || !Platform.isAndroid) return true;

    try {
      final androidImplementation = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidImplementation != null) {
        final granted = await androidImplementation
            .requestNotificationsPermission();
        return granted ?? false;
      }
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
    }
    return true;
  }

  /// Checks whether notifications are enabled on the device.
  Future<bool> areNotificationsEnabled() async {
    if (kIsWeb || !Platform.isAndroid) return true;

    try {
      final androidImplementation = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidImplementation != null) {
        final enabled = await androidImplementation.areNotificationsEnabled();
        return enabled ?? true;
      }
    } catch (e) {
      debugPrint('Error checking notifications enabled: $e');
    }
    return true;
  }

  /// Displays an immediate notification.
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String channelId = 'buildhaus_reminders',
    String channelName = 'Pengingat Perawatan BuildHaus',
    String channelDescription =
        'Notifikasi jadwal servis, ganti oli, odometer, dan keluhan motor',
  }) async {
    if (!_isInitialized) await initialize();

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    final details = NotificationDetails(android: androidDetails);

    try {
      await _plugin.show(id, title, body, details, payload: payload);
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }

  /// Schedules a notification for a future date and time using inexact scheduling.
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    String channelId = 'buildhaus_reminders',
    String channelName = 'Pengingat Perawatan BuildHaus',
  }) async {
    if (!_isInitialized) await initialize();

    // If date is in the past, do not schedule
    if (scheduledDate.isBefore(DateTime.now())) {
      debugPrint(
        'Scheduled date is in the past, skipping schedule: $scheduledDate',
      );
      return;
    }

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    final details = NotificationDetails(android: androidDetails);

    final tzDateTime = tz.TZDateTime.from(scheduledDate, tz.local);

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tzDateTime,
        details,
        androidScheduleMode: AndroidScheduleMode.inexact,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  /// Cancels a specific scheduled notification by ID.
  Future<void> cancelNotification(int id) async {
    try {
      await _plugin.cancel(id);
    } catch (e) {
      debugPrint('Error canceling notification $id: $e');
    }
  }

  /// Cancels all scheduled and displayed notifications.
  Future<void> cancelAll() async {
    try {
      await _plugin.cancelAll();
    } catch (e) {
      debugPrint('Error canceling all notifications: $e');
    }
  }
}
