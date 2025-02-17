import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/medication_response.dart';
import '../models/medicine_data.dart';


class MedicationResponseHelper {
  static const String _storageKey = 'medication_responses';

  // Store a medication response
static Future<void> storeMedicationResponse(MedicationResponse response) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    List<String> responses = prefs.getStringList(_storageKey) ?? [];
    
    // Add debug logging
    print('Current stored responses before adding: $responses');
    
    String encodedResponse = jsonEncode(response.toJson());
    print('New response to store: $encodedResponse');
    
    responses.add(encodedResponse);
    
    bool success = await prefs.setStringList(_storageKey, responses);
    print('Storage operation success: $success');
    
    // Verify storage
    List<String>? verifiedResponses = prefs.getStringList(_storageKey);
    print('Verified stored responses after adding: $verifiedResponses');
  } catch (e) {
    print('Error storing medication response: $e');
    throw e; // Rethrow to handle in UI if needed
  }
}

  // Get all medication responses
  static Future<List<MedicationResponse>> getAllResponses() async {
    final prefs = await SharedPreferences.getInstance();
    final responses = prefs.getStringList(_storageKey) ?? [];
    
    return responses
        .map((response) => MedicationResponse.fromJson(jsonDecode(response)))
        .toList();
  }

  // Get medication consistency for a specific date
  static Future<double> getMedicationConsistency(DateTime date) async {
    final responses = await getAllResponses();
    
    // Filter responses for the specific date
    final dateResponses = responses.where((response) =>
        response.date.year == date.year &&
        response.date.month == date.month &&
        response.date.day == date.day);
    
    if (dateResponses.isEmpty) return 0.0;
    
    final takenCount = dateResponses.where((response) => response.took).length;
    return (takenCount / dateResponses.length) * 100;
  }

  // Get medication consistency for the last 7 days
  static Future<List<MedicineData>> getWeeklyConsistency() async {
    final List<MedicineData> data = [];
    final now = DateTime.now();
    
    print('Getting weekly consistency...'); // Debug line
    final allResponses = await getAllResponses();
    print('Total responses in storage: ${allResponses.length}'); // Debug line
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final consistency = await getMedicationConsistency(date);
      data.add(MedicineData(date.day, consistency));
      
      print('Date: ${date.toIso8601String()}, Consistency: $consistency');
    }
    
    return data;
  }
} 