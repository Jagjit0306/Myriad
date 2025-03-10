import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:myriad/components/medify_tracker.dart';
import 'package:myriad/components/my_button.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:myriad/components/add_medication_form.dart';

class MedicationSchedule {
  final String medicineName;
  final List<String> times;
  final int id;

  MedicationSchedule({
    required this.medicineName,
    required this.times,
    required this.id,
  });

  Map<String, dynamic> toJson() => {
        'medicineName': medicineName,
        'times': times,
        'id': id,
      };

  factory MedicationSchedule.fromJson(Map<String, dynamic> json) {
    return MedicationSchedule(
      medicineName: json['medicineName'],
      times: List<String>.from(json['times']),
      id: json['id'],
    );
  }
}

class MedicationPage extends StatefulWidget {
  const MedicationPage({super.key});

  @override
  _MedicationPageState createState() => _MedicationPageState();
}

class _MedicationPageState extends State<MedicationPage> {
  List<MedicationSchedule> _medications = [];
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  int _nextId = 0;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadMedications();
  }

  Future<void> _initializeNotifications() async {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _loadMedications() async {
    final prefs = await SharedPreferences.getInstance();
    final medicationsJson = prefs.getString('medications');
    final lastId = prefs.getInt('lastId') ?? 0;
    _nextId = lastId;

    if (medicationsJson != null) {
      final List<dynamic> medicationsList = jsonDecode(medicationsJson);
      setState(() {
        _medications = medicationsList
            .map((json) => MedicationSchedule.fromJson(json))
            .toList();
      });
    }
  }

  Future<void> _saveMedications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('medications',
        jsonEncode(_medications.map((m) => m.toJson()).toList()));
    await prefs.setInt('lastId', _nextId);
  }

  Future<void> _scheduleNotifications(MedicationSchedule medication) async {
    for (int i = 0; i < medication.times.length; i++) {
      final timeParts = medication.times[i].split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      final now = DateTime.now();
      var scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      final notificationDetails = NotificationDetails(
        android: const AndroidNotificationDetails(
          'medication_channel',
          'Medication Reminders',
          channelDescription: 'Daily medication reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      await flutterLocalNotificationsPlugin.zonedSchedule(
        medication.id + i,
        'Medication Reminder',
        'Time to take ${medication.medicineName}',
        tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  // void _showError(String message) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //         content: Text(message,
  //             style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
  //         backgroundColor: Theme.of(context).colorScheme.error),
  //   );
  // }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          backgroundColor: Theme.of(context).colorScheme.secondary),
    );
  }

  Future<void> _addNewMedication(String medicineName, List<String> times) async {
    // TODO : refresh the tracker
    final medication = MedicationSchedule(
      medicineName: medicineName,
      times: times,
      id: _nextId,
    );

    _nextId += times.length;

    setState(() {
      _medications.add(medication);
    });

    await _scheduleNotifications(medication);
    await _saveMedications();

    _showSuccess('Medication added successfully');
    if(mounted) {
      Navigator.pop(context); // Close the modal
    }
    setState(() {
      
    });
  }

  Future<void> _deleteMedication(int index) async {
    // TODO : refresh the tracker
    final medication = _medications[index];
    // Cancel all notifications for this medication
    for (int i = 0; i < medication.times.length; i++) {
      await flutterLocalNotificationsPlugin.cancel(medication.id + i);
    }

    setState(() {
      _medications.removeAt(index);
    });

    await _saveMedications();
    _showSuccess('Medication deleted successfully');
  }

  void showAddMedicationModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      builder: (context) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: AddMedicationForm(
            onSave: _addNewMedication,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Medify"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30),
              MedifyTracker(),
              MyButton(
                text: "Add a reminder",
                enabled: true,
                onTap: () => showAddMedicationModal(context),
              ),
              const SizedBox(height: 24),
              Text(
                'Schedule',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _medications.length,
                  itemBuilder: (context, index) {
                    final medication = _medications[index];
                    return Card(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              title: Text(
                                medication.medicineName,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    height: 40, // Fixed height for the scrolling area
                                    child: ListView.separated(
                                      physics: BouncingScrollPhysics(),
                                      scrollDirection: Axis.horizontal,
                                      separatorBuilder: (context, index) => const SizedBox(width: 8),
                                      itemCount: medication.times.length,
                                      itemBuilder: (context, timeIndex) => InkWell(
                                        child: Chip(
                                          label: Text(
                                            medication.times[timeIndex],
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.onSurface,
                                              fontSize: 13,
                                            ),
                                          ),
                                          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  size: 30,
                                  color: Color.fromARGB(255, 255, 130, 121),
                                ),
                                onPressed: () => _deleteMedication(index),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}