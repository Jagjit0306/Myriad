class MedicationResponse {
  final DateTime date;
  final String medicationId;
  final String medicationName;
  final bool took;

  MedicationResponse({
    required this.date,
    required this.medicationId,
    required this.medicationName,
    required this.took,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'medicationId': medicationId,
        'medicationName': medicationName,
        'took': took,
      };

  factory MedicationResponse.fromJson(Map<String, dynamic> json) {
    return MedicationResponse(
      date: DateTime.parse(json['date']),
      medicationId: json['medicationId'],
      medicationName: json['medicationName'],
      took: json['took'],
    );
  }
} 