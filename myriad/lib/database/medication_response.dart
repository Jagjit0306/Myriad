import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/medication_response.dart';

class MedicationResponseDatabase {
  final CollectionReference medicationResponses =
      FirebaseFirestore.instance.collection("MedicationResponses");

  Future<void> storeMedicationResponse(MedicationResponse response) async {
    try {
      await medicationResponses.add({
        'date': response.date.toIso8601String(),
        'medicationId': response.medicationId,
        'medicationName': response.medicationName,
        'took': response.took,
      });
      print('Medication response stored successfully.');
    } catch (e) {
      print('Error storing medication response: $e');
    }
  }

  Future<List<MedicationResponse>> getWeeklyResponses() async {
    final List<MedicationResponse> responses = [];
    final userEmail = FirebaseAuth.instance.currentUser?.email;

    try {
      final QuerySnapshot snapshot = await medicationResponses
          .where('userEmail', isEqualTo: userEmail)
          .orderBy('date', descending: true)
          .get();

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        responses.add(MedicationResponse.fromJson(data));
      }
      print('Loaded medication responses: $responses');
    } catch (e) {
      print('Error retrieving medication responses: $e');
    }

    return responses;
  }
} 