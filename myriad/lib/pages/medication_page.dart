import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../components/logo_component.dart';

class MedicationSchedule {
  final String medicineName;
  final int timesPerDay;
  final List<String> times;
  final int id;

  MedicationSchedule({
    required this.medicineName,
    required this.timesPerDay,
    required this.times,
    required this.id,
  });

  Map<String, dynamic> toJson() => {
        'medicineName': medicineName,
        'timesPerDay': timesPerDay,
        'times': times,
        'id': id,
      };

  factory MedicationSchedule.fromJson(Map<String, dynamic> json) {
    return MedicationSchedule(
      medicineName: json['medicineName'],
      timesPerDay: json['timesPerDay'],
      times: List<String>.from(json['times']),
      id: json['id'],
    );
  }
}

class MedicationPage extends StatefulWidget {
  const MedicationPage({Key? key}) : super(key: key);

  @override
  _MedicationPageState createState() => _MedicationPageState();
}

class _MedicationPageState extends State<MedicationPage> {
  final TextEditingController _medicineNameController = TextEditingController();
  final TextEditingController _timesPerDayController = TextEditingController();
  final List<TextEditingController> _timeControllers = [];
  List<MedicationSchedule> _medications = [];
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  int _nextId = 0;
  bool _showTimeInputs = false;

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

  void _createTimeInputs() {
    final timesPerDay = int.tryParse(_timesPerDayController.text) ?? 0;
    if (timesPerDay <= 0) {
      _showError('Please enter a valid number of times per day');
      return;
    }

    // Clear existing controllers
    for (var controller in _timeControllers) {
      controller.dispose();
    }
    _timeControllers.clear();

    // Create new controllers
    for (int i = 0; i < timesPerDay; i++) {
      _timeControllers.add(TextEditingController());
    }

    setState(() {
      _showTimeInputs = true;
    });
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
    if (_medicineNameController.text.isEmpty ||
        _timesPerDayController.text.isEmpty) {
      _showError('Please fill in all fields');
      return;
    }

    final timeRegex = RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$');
    final times = <String>[];

    for (var controller in _timeControllers) {
      if (!timeRegex.hasMatch(controller.text)) {
        _showError('Please enter valid times in 24-hour format (HH:mm)');
        return;
      }
      times.add(controller.text);
    }

    final medication = MedicationSchedule(
      medicineName: _medicineNameController.text,
      timesPerDay: times.length,
      times: times,
      id: _nextId,
    );

    _nextId += times.length;

    setState(() {
      _medications.add(medication);
      _showTimeInputs = false;
    });

    await _scheduleNotifications(medication);
    await _saveMedications();

    _medicineNameController.clear();
    _timesPerDayController.clear();
    for (var controller in _timeControllers) {
      controller.clear();
    }
    _timeControllers.clear();

    _showSuccess('Medication added successfully');
  }

  Future<void> _deleteMedication(int index) async {
    final medication = _medications[index];
    // Cancel all notifications for this medication
    for (int i = 0; i < medication.timesPerDay; i++) {
      await flutterLocalNotificationsPlugin.cancel(medication.id + i);
    }

    setState(() {
      _medications.removeAt(index);
    });

    await _saveMedications();
    _showSuccess('Medication deleted successfully');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const LogoComponent(size: 60),
            const SizedBox(width: 8),
            Text(
              'X',
              style: TextStyle(
                fontSize: 36,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.medication,
              size: 60,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(width: 28),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 50),
              // Medicine name input
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                child: TextField(
                  controller: _medicineNameController,
                  decoration: const InputDecoration(
                    labelText: 'Medicine Name',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Times per day row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      child: TextField(
                        controller: _timesPerDayController,
                        decoration: const InputDecoration(
                          labelText: 'Times Per Day',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(8),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _createTimeInputs,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Set Times',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
              if (_showTimeInputs) ...[
                const SizedBox(height: 16),
                ...List.generate(_timeControllers.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      child: TextField(
                        controller: _timeControllers[index],
                        decoration: InputDecoration(
                          labelText: 'Time ${index + 1} (HH:MM)',
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(8),
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _saveMedication,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Save Medication',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Text(
                'Saved Medications:',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _medications.length,
                itemBuilder: (context, index) {
                  final medication = _medications[index];
                  return Card(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    child: ListTile(
                      title: Text(
                        medication.medicineName,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 17,
                        ),
                      ),
                      subtitle: Text(
                        'Times: ${medication.times.join(", ")}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 15,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteMedication(index),
                      ),
                    ),
                  );
                },
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
    _timesPerDayController.dispose();
    for (var controller in _timeControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
