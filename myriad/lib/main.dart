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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top],
  );
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Gemini.init(
    apiKey: GEMINI_API_KEY,
  );
  tz.initializeTimeZones();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Define the notification actions for iOS
  final DarwinInitializationSettings darwinSettings = DarwinInitializationSettings(
  requestAlertPermission: true,
  requestBadgePermission: true,
  requestSoundPermission: true,
  notificationCategories: <DarwinNotificationCategory>[
    DarwinNotificationCategory(
      'medicationReminder',
      actions: <DarwinNotificationAction>[
        DarwinNotificationAction.plain('yes', 'Taken', options: {
          DarwinNotificationActionOption.foreground,
        }),
        DarwinNotificationAction.plain('no', 'Skipped', options: {
          DarwinNotificationActionOption.foreground,
        }),
      ],
      options: <DarwinNotificationCategoryOption>{
        DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
      },
    ),
  ],
);

  await flutterLocalNotificationsPlugin.initialize(
    InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: darwinSettings,
    ),
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      if (response.payload != null) {
        final payloadData = jsonDecode(response.payload!);
        final medicationResponse = MedicationResponse(
          date: DateTime.now(),
          medicationId: payloadData['medicationId'],
          medicationName: payloadData['medicationName'],
          took: response.actionId == 'yes',
        );

        await MedicationResponseHelper.storeMedicationResponse(medicationResponse);
      }
    },
  );

  runApp(const MainApp());
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