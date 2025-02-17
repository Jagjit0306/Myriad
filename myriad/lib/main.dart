import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:myriad/firebase_options.dart';
import 'package:myriad/passwords.dart';
import 'package:myriad/router.dart';
import 'package:myriad/themes/dark_mode.dart';
import 'package:myriad/themes/light_mode.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'package:myriad/helper/medication_response_helper.dart';
import 'package:myriad/models/medication_response.dart';

Future<FlutterLocalNotificationsPlugin> initNotifications() async {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = 
      FlutterLocalNotificationsPlugin();

  // Define notification actions for Android
  // const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
  //   'medication_channel',
  //   'Medication Reminders',
  //   channelDescription: 'Daily medication reminders',
  //   importance: Importance.max,
  //   priority: Priority.high,
  //   actions: <AndroidNotificationAction>[
  //     AndroidNotificationAction('yes', 'Taken'),
  //     AndroidNotificationAction('no', 'Skipped'),
  //   ],
  // );

  // Define notification actions for iOS
  final DarwinInitializationSettings darwinSettings = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
    notificationCategories: <DarwinNotificationCategory>[
      DarwinNotificationCategory(
        'medicationReminder', // This category ID must match what you use when scheduling
        actions: <DarwinNotificationAction>[
          DarwinNotificationAction.plain(
            'yes',
            'Taken',
            options: {
              DarwinNotificationActionOption.foreground,
            },
          ),
          DarwinNotificationAction.plain(
            'no',
            'Skipped',
            options: {
              DarwinNotificationActionOption.foreground,
            },
          ),
        ],
      ),
    ],
  );

  // Initialize plugin
  await flutterLocalNotificationsPlugin.initialize(
    InitializationSettings(
      android: const AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: darwinSettings,
    ),
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      print('Notification response received with action: ${response.actionId}');
      await handleNotificationResponse(response);
    },
    onDidReceiveBackgroundNotificationResponse: handleNotificationResponse,
  );

  return flutterLocalNotificationsPlugin;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top],
  );
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Gemini.init(apiKey: GEMINI_API_KEY);
  tz.initializeTimeZones();

  // final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  //     FlutterLocalNotificationsPlugin();

  // // Define iOS notification categories
  // final DarwinInitializationSettings darwinSettings = DarwinInitializationSettings(
  //   requestAlertPermission: true,
  //   requestBadgePermission: true,
  //   requestSoundPermission: true,
  //   notificationCategories: <DarwinNotificationCategory>[
  //     DarwinNotificationCategory(
  //       'medicationReminder',
  //       actions: <DarwinNotificationAction>[
  //         DarwinNotificationAction.plain('yes', 'Taken', options: {
  //           DarwinNotificationActionOption.foreground,
  //         }),
  //         DarwinNotificationAction.plain('no', 'Skipped', options: {
  //           DarwinNotificationActionOption.foreground,
  //         }),
  //       ],
  //     ),
  //   ],
  // );

  // await flutterLocalNotificationsPlugin.initialize(
  //   InitializationSettings(
  //     android: AndroidInitializationSettings('@mipmap/ic_launcher'),
  //     iOS: darwinSettings,
  //   ),
  //   onDidReceiveNotificationResponse: (NotificationResponse response) async {
  //     print('Foreground notification action received');
  //     await handleNotificationResponse(response);
  //   },
  //   onDidReceiveBackgroundNotificationResponse: handleNotificationResponse,
  // );

  // final iosPlugin = flutterLocalNotificationsPlugin
  //     .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

  // iosPlugin?.requestPermissions(
  //   alert: true,
  //   badge: true,
  //   sound: true,
  // );

  await initNotifications();
  runApp(const MainApp());
}

@pragma('vm:entry-point')
Future<void> handleNotificationResponse(NotificationResponse response) async {
  print('📢 Background notification action received: ${response.actionId}');
  print('📢 Payload: ${response.payload}');

  if (response.payload != null) {
    final payloadData = jsonDecode(response.payload!);
    final medicationResponse = MedicationResponse(
      date: DateTime.now(),
      medicationId: payloadData['medicationId'],
      medicationName: payloadData['medicationName'],
      took: response.actionId == 'yes',
    );

    await MedicationResponseHelper.storeMedicationResponse(medicationResponse);
    print('✅ Medication response stored successfully');

    // Force UI Update (Workaround for iOS background)
    final navigatorKey = GlobalKey<NavigatorState>();
    navigatorKey.currentState?.pushNamed('/home');
  }
}


class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Myriad',
      routerConfig: router,
      theme: lightMode,
      darkTheme: darkMode,
    );
  }
}
