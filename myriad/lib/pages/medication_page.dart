import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:myriad/components/medify_tracker.dart';
import 'package:myriad/components/my_button.dart';
import 'package:myriad/components/my_textfield.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
// import 'package:intl/intl.dart';
// import 'package:myriad/helper/medify_functions.dart';

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
  // final MedifyHistory medifyHistory = MedifyHistory();
  final TextEditingController _medicineNameController = TextEditingController();
  final List<TextEditingController> _timeControllers = List.generate(
    6, // Maximum number of time slots
    (index) => TextEditingController(),
  );
  List<MedicationSchedule> _medications = [];
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  int _nextId = 0;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadMedications();
    // medifyHistory.init();

    // Add listeners to all time controllers to trigger UI updates
    for (var controller in _timeControllers) {
      controller.addListener(() {
        setState(() {}); // Rebuild UI when any time input changes
      });
    }
  }

  bool _shouldShowTimeField(int index) {
    if (index == 0) return true; // Always show first time field

    // Show this field only if the previous field is filled
    return _timeControllers[index - 1].text.isNotEmpty;
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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          backgroundColor: Theme.of(context).colorScheme.error),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          backgroundColor: Theme.of(context).colorScheme.secondary),
    );
  }

  Future<void> _saveMedication() async {
    if (_medicineNameController.text.isEmpty) {
      _showError('Please enter a prescription name');
      return;
    }

    final timeRegex = RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$');
    final times = <String>[];

    // Only collect non-empty time inputs
    for (var controller in _timeControllers) {
      if (controller.text.isNotEmpty) {
        if (!timeRegex.hasMatch(controller.text)) {
          _showError('Please enter valid times in 24-hour format (HH:mm)');
          return;
        }
        times.add(controller.text);
      }
    }

    if (times.isEmpty) {
      _showError('Please enter at least one time');
      return;
    }

    final medication = MedicationSchedule(
      medicineName: _medicineNameController.text,
      times: times,
      id: _nextId,
    );

    _nextId += times.length;

    setState(() {
      _medications.add(medication);
    });

    await _scheduleNotifications(medication);
    await _saveMedications();

    _medicineNameController.clear();
    for (var controller in _timeControllers) {
      controller.clear();
    }

    _showSuccess('Medication added successfully');
  }

  Future<void> _deleteMedication(int index) async {
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

  Future<void> _selectTime(BuildContext context, int index) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (picked != null) {
      String formattedTime =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      _timeControllers[index].text = formattedTime;
    }
  }

  void showAddMedicationModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.secondary,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  'Add Reminder',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              MyTextfield(
                hintText: "Prescription Name",
                controller: _medicineNameController,
                onChanged: (v) {},
              ),
              const SizedBox(height: 16),
              ...List.generate(_timeControllers.length, (index) {
                // Only show this time field if all previous ones are filled
                if (!_shouldShowTimeField(index)) {
                  return const SizedBox.shrink(); // Hidden field
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      _selectTime(context, index);
                    },
                    child: MyTextfield(
                      hintText:
                          "Dosage ${index + 1}${index == 0 ? '' : ' (optional)'}",
                      controller: _timeControllers[index],
                      onChanged: (v) {},
                      readOnly: true,
                      enabled: false,
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
              MyButton(
                text: "Add to Schedule",
                enabled: true,
                onTap: _saveMedication,
                fontSize: 18,
              ),
            ],
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

  @override
  void dispose() {
    _medicineNameController.dispose();
    for (var controller in _timeControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
