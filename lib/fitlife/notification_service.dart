import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final instance = NotificationService._();
  static const _workoutId = 100;
  static const _waterIds = [200, 201, 202, 203];
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;

  Future<void> initialize() async {
    if (_ready || kIsWeb) return;
    if (!Platform.isAndroid && !Platform.isIOS) {
      _ready = true;
      return;
    }
    tz.initializeTimeZones();
    if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));
    }
    await _notifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _ready = true;
  }

  Future<bool> requestPermission() async {
    await initialize();
    if (Platform.isAndroid) {
      return await _notifications
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()
              ?.requestNotificationsPermission() ??
          false;
    }
    if (Platform.isIOS) {
      return await _notifications
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >()
              ?.requestPermissions(alert: true, badge: true, sound: true) ??
          false;
    }
    return false;
  }

  Future<void> scheduleWorkout({
    required bool enabled,
    required int hour,
    required int minute,
  }) async {
    await initialize();
    if (!Platform.isAndroid && !Platform.isIOS) return;
    await _notifications.cancel(id: _workoutId);
    if (!enabled) return;
    await _notifications.zonedSchedule(
      id: _workoutId,
      title: 'Your FitMalaysia session is ready',
      body: 'A short workout today keeps your 28-day plan moving.',
      scheduledDate: _nextTime(hour, minute),
      notificationDetails: _details(
        channelId: 'fitmalaysia_workout',
        channelName: 'Workout reminders',
        description: 'Daily reminders for scheduled FitMalaysia workouts.',
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'workout',
    );
  }

  Future<void> scheduleWater({required bool enabled}) async {
    await initialize();
    if (!Platform.isAndroid && !Platform.isIOS) return;
    for (final id in _waterIds) {
      await _notifications.cancel(id: id);
    }
    if (!enabled) return;
    const hours = [9, 12, 15, 18];
    for (var index = 0; index < hours.length; index++) {
      await _notifications.zonedSchedule(
        id: _waterIds[index],
        title: 'Hydration check',
        body: 'Log a glass of water and keep today\'s goal within reach.',
        scheduledDate: _nextTime(hours[index], 0),
        notificationDetails: _details(
          channelId: 'fitmalaysia_water',
          channelName: 'Water reminders',
          description: 'Gentle hydration reminders during daytime hours.',
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'water',
      );
    }
  }

  tz.TZDateTime _nextTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  NotificationDetails _details({
    required String channelId,
    required String channelName,
    required String description,
  }) => NotificationDetails(
    android: AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: description,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    ),
    iOS: const DarwinNotificationDetails(),
  );
}
