import 'package:alarm_app/models/alarm_model.dart';
import 'package:alarm_app/services/notification_service.dart';
import 'package:alarm_app/view/homescreen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hive_flutter/hive_flutter.dart';

void notificationTapBackground(NotificationResponse notificationResponse) {
  NotificationService.onNotificationResponse(notificationResponse);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('bird');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    // This handles taps when the app is in the FOREGROUND/OPEN
    onDidReceiveNotificationResponse:
        NotificationService.onNotificationResponse,
    // This handles taps when the app is in the BACKGROUND/TERMINATED
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );

  // Hive Flutter Initialization
  await Hive.initFlutter();

  // Register Hive Adapters
  Hive.registerAdapter(RepeatTypeAdapter());
  Hive.registerAdapter(AlarmAdapter());

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: HomeScreen(),
    );
  }
}
