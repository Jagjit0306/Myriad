import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:myriad/pages/medication_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MedifyHistory {
  static const int _saveDays = 7;
  late SharedPreferences _prefs;
  late List<dynamic> _medSchedule;
  late List<dynamic> _history;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final String medicationsJson = _prefs.getString('medications') ?? "";

    if (medicationsJson.isNotEmpty) {
      final List<dynamic> medicationsList = jsonDecode(medicationsJson);
      _medSchedule = medicationsList
          .map((json) => MedicationSchedule.fromJson(json))
          .toList();
    } else {
      _medSchedule = [];
    }

    // _prefs.setString('medicationsHistory', "");
    final String medicationsHistoryJson =
        _prefs.getString('medicationsHistory') ?? "";

    if (medicationsHistoryJson.isNotEmpty) {
      _history = jsonDecode(medicationsHistoryJson);
      // print("HISTORY RESTORED");
      // print(jsonEncode(_history));

      String currentDate = _currDate();

      // Find the newest date in history
      if (_history.isNotEmpty) {
        String newestDate = _findNewestDate(_history);
        int missingDays = _daysBetween(newestDate, currentDate);

        // Add entries for missing days, but limit to _saveDays if gap is large
        if (missingDays > 0) {
          // Limit days to add based on _saveDays
          int daysToAdd = (missingDays > _saveDays) ? _saveDays : missingDays;

          for (int i = daysToAdd; i > 0; i--) {
            String missingDate = _subtractDaysFromToday(i);

            if (!_history.any((entry) => entry["date"] == missingDate)) {
              _history.add({
                "date": missingDate,
                "records": _medSchedule.map((medicine) {
                  return {
                    "medicineName": medicine.medicineName,
                    "times":
                        medicine.times.map((time) => {time: false}).toList(),
                    "id": medicine.id
                  };
                }).toList()
              });
            }
          }
        }
      }

      // Check if today's entry exists
      if (!_history.any((entry) => entry["date"] == currentDate)) {
        // Add today's entry
        _history.add({
          "date": currentDate,
          "records": _medSchedule.map((medicine) {
            return {
              "medicineName": medicine.medicineName,
              "times": medicine.times.map((time) => {time: false}).toList(),
              "id": medicine.id
            };
          }).toList()
        });
      }

      // Remove entries older than _saveDays
      _history.removeWhere(
          (entry) => _daysBetween(entry["date"], currentDate) > _saveDays);

      //modify today (balance the prescriptions)
      int index =
          _history.indexWhere((element) => element["date"] == _currDate());
      _history[index] = {
        "date": _currDate(),
        "records": _updateMedicineData(_history[index]["records"], _medSchedule)
      };

      // print(jsonEncode(_history));
      _prefs.setString('medicationsHistory', jsonEncode(_history));
    } else {
      // Initialize with today's entry if history is empty
      _history = [];
      _history.add({
        "date": _currDate(),
        "records": _medSchedule.map((medicine) {
          return {
            "medicineName": medicine.medicineName,
            "times": medicine.times.map((time) => {time: false}).toList(),
            "id": medicine.id
          };
        }).toList()
      });
      print(jsonEncode(_history));
      _prefs.setString('medicationsHistory', jsonEncode(_history));
    }
  }

  List<Map<String, dynamic>> _updateMedicineData(
      List<dynamic> A, List<dynamic> B) {
    Map<int, Map<String, dynamic>> aMap = {
      for (var item in A)
        if (item is Map<String, dynamic>) item['id']: item
    };

    List<Map<String, dynamic>> updatedA = [];

    for (var bItem in B) {
      int id;
      String medicineName;
      List<String> bTimes;

      // Handle MedicationSchedule class instance
      if (bItem is MedicationSchedule) {
        id = bItem.id;
        medicineName = bItem.medicineName;
        bTimes = List<String>.from(bItem.times);
      } else if (bItem is Map<String, dynamic>) {
        id = bItem['id'];
        medicineName = bItem['medicineName'];
        bTimes = List<String>.from(bItem['times']);
      } else {
        continue; // Skip invalid entries
      }

      Map<String, bool> timeMap = {};

      if (aMap.containsKey(id)) {
        Map<String, dynamic> existingItem = aMap[id]!;
        Map<String, bool> existingTimes = {
          for (var entry in existingItem['times'])
            entry.keys.first: entry.values.first
        };

        for (var time in bTimes) {
          timeMap[time] =
              existingTimes.containsKey(time) ? existingTimes[time]! : false;
        }
      } else {
        for (var time in bTimes) {
          timeMap[time] = false;
        }
      }

      updatedA.add({
        'medicineName': medicineName,
        'times': timeMap.entries.map((e) => {e.key: e.value}).toList(),
        'id': id,
      });
    }

    return updatedA;
  }

  String _subtractDaysFromToday(int days) {
    DateTime date = DateTime.now().subtract(Duration(days: days));
    return DateFormat('yyyy-MM-dd').format(date);
  }

  void clearData() {
    _prefs.setString('medicationsHistory', "");
  }

  List<dynamic> getRecords() {
    return _history;
  }

  void updateRecords(List<dynamic> records) {
    _prefs.setString('medicationsHistory', jsonEncode(records));
  }

  String _currDate({int offset = 0}) {
    DateTime now = DateTime.now().subtract(Duration(days: offset));
    return DateFormat('yyyy-MM-dd').format(now);
  }

  int _daysBetween(String date1, String date2) {
    DateTime d1 = DateTime.parse(date1);
    DateTime d2 = DateTime.parse(date2);
    return d2.difference(d1).inDays;
  }

  String _findNewestDate(List<dynamic> history) {
    return history
        .map((entry) => entry["date"])
        .reduce((a, b) => DateTime.parse(a).isAfter(DateTime.parse(b)) ? a : b);
  }
}

class DailyConsistency {
  final DateTime date;
  final int day;
  final double percentage;
  
  DailyConsistency({
    required this.date,
    required this.day,
    required this.percentage,
  });
}

class MedifyConsistencyCalculator {
  final MedifyHistory _medifyHistory;
  
  MedifyConsistencyCalculator(this._medifyHistory);
  
  // Calculate daily consistency percentages for the last 7 days
  Future<List<DailyConsistency>> getConsistencyForLastWeek() async {
    await _medifyHistory.init(); // Make sure history is initialized
    final records = _medifyHistory.getRecords();
    
    // List to store the consistency data for each day
    final List<DailyConsistency> consistencyData = [];
    
    // Calculate last 7 days (including today)
    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dateString = DateFormat('yyyy-MM-dd').format(date);
      
      // Find the record for this date
      final recordForDay = records.firstWhere(
        (record) => record["date"] == dateString,
        orElse: () => {"date": dateString, "records": []}
      );
      
      // Calculate the adherence percentage for this day
      double percentage = 0.0;
      int totalMedicationTimes = 0;
      int takenMedicationTimes = 0;
      
      for (var medicine in recordForDay["records"]) {
        for (var timeSlot in medicine["times"]) {
          totalMedicationTimes++;
          // Each timeSlot is a map like {"08:00": true} or {"08:00": false}
          if (timeSlot.values.first == true) {
            takenMedicationTimes++;
          }
        }
      }
      
      // Calculate percentage if there were any medications scheduled
      if (totalMedicationTimes > 0) {
        percentage = (takenMedicationTimes / totalMedicationTimes) * 100;
      }
      
      // Add to consistency data
      consistencyData.add(DailyConsistency(
        date: date,
        day: date.day,
        percentage: percentage,
      ));
    }
    
    return consistencyData;
  }
  
  // Calculate the current streak (consecutive days where medication consistency >= 80%)
  Future<int> calculateConsistencyStreak() async {
    final consistencyData = await getConsistencyForLastWeek();
    int streak = 0;
    
    // Start from the most recent day and go backwards
    for (int i = consistencyData.length - 1; i >= 0; i--) {
      if (consistencyData[i].percentage >= 80) {
        streak++;
      } else {
        break; // Break the streak
      }
    }
    
    return streak;
  }
}