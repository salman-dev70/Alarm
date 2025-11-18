import 'dart:developer';
import 'dart:typed_data';
import 'dart:ui';

import 'package:alarm_app/models/alarm_model.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static final FlutterLocalNotificationsPlugin _notification =
      FlutterLocalNotificationsPlugin();

  // Notification channels and action IDs
  static const String alarmChannelId = 'alarm_channel';
  static const String alarmChannelName = 'Alarm Notifications';
  static const String alarmChannelDesc = 'Channel for alarm notifications';

  static const String snoozeActionId = 'snooze_action';
  static const String cancelActionId = 'cancel_action';

  // initialize

  Future<void> initialize() async {
    tz.initializeTimeZones();

    final location = tz.getLocation('Asia/Karachi');
    tz.setLocalLocation(location);
    //android initialization

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );
    await _notification.initialize(
      settings,
      onDidReceiveNotificationResponse: onNotificationResponse,
    );
    await _createNotificationChannel();
  }

  static void onNotificationResponse(NotificationResponse response) {
    log("enter in response function");
    final String? actionId = response.actionId;
    final String? payload = response.payload;
    log("$actionId,==$snoozeActionId");
    if (actionId == snoozeActionId) {
      _handleSnooze(payload!);
      print('OK action tapped. Payload: $payload');
    } else if (actionId == cancelActionId) {
      _handleCancel(payload!);
      print('Cancel action tapped. Payload: $payload');
    } else {
      _handleNotificationTap(payload!);
      print('Notification body tapped. Payload: $payload');
    }
  }

  static void _handleSnooze(String payload) async {
    try {
      print(' Snooze button pressed with payload: $payload');

      final parts = payload.split('|');
      if (parts.length >= 3) {
        final originalAlarmId = parts[0];
        final alarmLabel = parts[1];

        print(' Snoozing alarm: $alarmLabel');

        // Cancel current notification
        await _notification.cancel(int.parse(originalAlarmId));
        final int newSnoozeId =
            DateTime.now().millisecondsSinceEpoch % 1000000000;

        // Schedule snooze for 5 minutes later
        final snoozeTime = DateTime.now().add(const Duration(minutes: 5));

        await NotificationService.scheduleSnoozeNotification(
          alarmId: newSnoozeId.toString(),
          originalAlarmId: originalAlarmId,
          title: 'Snooze: $alarmLabel',
          body: alarmLabel,
          scheduledTime: snoozeTime,
          originalTime: DateTime.now(),
        );

        log(' Snooze scheduled for 5 minutes at $snoozeTime');
      }
    } catch (e) {
      print(' Snooze error: $e');
    }
  }

  static void _handleCancel(String payload) {
    // Payload format: 'alarmId|alarmLabel|originalTime'
    final parts = payload.split('|');
    if (parts.isNotEmpty) {
      final alarmId = parts[0];
      print('Canceling alarm: $alarmId');
      _notification.cancel(int.parse(alarmId));
    }
    log("alarm cancel");
  }

  // static void _handleNotificationTap(String payload) {
  //
  //   print('Notification tapped with payload: $payload');
  //   /
  // }

  Future<void> _createNotificationChannel() async {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      alarmChannelId,
      alarmChannelName,
      description: alarmChannelDesc,
      importance: Importance.max,

      sound: RawResourceAndroidNotificationSound('alarm_sound'),
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
      playSound: true,
    );

    await _notification
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  // Snooze aur Cancel buttons notification details
  static NotificationDetails _getAlarmNotificationDetails(String payload) {
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      alarmChannelId, //
      alarmChannelName, //
      channelDescription: alarmChannelDesc,
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('alarm_sound'),
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
      playSound: true,
      autoCancel: false,
      ongoing: true,
      fullScreenIntent: true,
      actions: [
        AndroidNotificationAction(
          snoozeActionId,
          'snooze',
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          cancelActionId,
          'Cancel',
          showsUserInterface: true,
          cancelNotification: true,
        ),
      ],
    );

    return NotificationDetails(android: androidDetails);
  }

  // Main alarm notification schedule
  Future<void> scheduleAlarmNotification({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required RepeatType repeat,
  }) async {
    final tz.TZDateTime scheduledTZTime = tz.TZDateTime.from(
      scheduledTime,
      tz.local,
    );
    log("seetting id");
    // Payload format: 'alarmId|alarmLabel|originalTime'
    final payload = '$id|$body|${scheduledTime.toIso8601String()}';

    final notificationId = _generateNotificationId(id);
    log('Id set in range');
    switch (repeat) {
      // for repeat once

      case RepeatType.once:
        log('🔄 Scheduling once notification...');
        await _notification.zonedSchedule(
          notificationId,
          title,
          body,
          scheduledTZTime,
          _getAlarmNotificationDetails(payload),
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: payload,
        );
        log('✅ Alarm set successfully!');
        break;

      // for repeating daily

      case RepeatType.daily:
        await _notification.zonedSchedule(
          notificationId,
          title,
          body,
          scheduledTZTime,
          _getAlarmNotificationDetails(payload),
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: payload,
        );
        break;

      // for repeating weeklyy====

      case RepeatType.weekly:
        await _notification.zonedSchedule(
          notificationId,
          title,
          body,
          scheduledTZTime,
          _getAlarmNotificationDetails(payload),
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          payload: payload,
        );
        break;
    }

    print('Alarm scheduled: $id at $scheduledTime');
    final pending = await getPendingNotifications();
    print('📋 Pending notifications: ${pending.length}');
  }

  // Snooze notification

  static Future<void> scheduleSnoozeNotification({
    required String alarmId,
    required String originalAlarmId,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required DateTime originalTime,
  }) async {
    final tz.TZDateTime scheduledTZTime = tz.TZDateTime.from(
      scheduledTime,
      tz.local,
    );

    // Payload format: 'originalAlarmId|alarmLabel|originalTime'
    final payload = '$originalAlarmId|$body|${originalTime.toIso8601String()}';

    await _notification.zonedSchedule(
      int.parse(alarmId),
      title,
      body,
      scheduledTZTime,
      _getAlarmNotificationDetails(payload),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );

    print('Snooze scheduled: $alarmId at $scheduledTime');
  }

  // if user tap on notification
  static void _handleNotificationTap(String payload) {}
  Future<void> cancelNotification(String id) async {
    await _notification.cancel(int.parse(id));
  }

  Future<void> cancelAllNotifications() async {
    await _notification.cancelAll();
  }

  // check pending notification
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notification.pendingNotificationRequests();
  }

  // gneretae notification ID

  int _generateNotificationId(String id) {
    try {
      // Method 1: Try parsing as integer first
      if (int.tryParse(id as String) != null) {
        final parsedId = int.parse(id as String);
        return parsedId.abs() % 2147483647; // Ensure within 32-bit range
      }

      // Method 2: Use hashCode and ensure positive 32-bit range
      final hash = id.hashCode.abs() % 2147483647;
      return hash == 0 ? 1 : hash; // Ensure non-zero
    } catch (e) {
      // Method 3: Fallback - use timestamp
      return DateTime.now().millisecondsSinceEpoch % 1000000;
    }
  }
}
