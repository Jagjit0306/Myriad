import 'package:flutter/material.dart';
import 'package:myriad/components/my_button.dart';
import 'package:myriad/helper/medify_functions.dart';

class MedifyTracker extends StatefulWidget {
  const MedifyTracker({super.key});

  @override
  State<MedifyTracker> createState() => _MedifyTrackerState();
}

class _MedifyTrackerState extends State<MedifyTracker> {
  final MedifyHistory medifyHistory = MedifyHistory();
  List<dynamic> records = [];

  @override
  void initState() {
    super.initState();
    initMedify();
  }

  void initMedify() async {
    await medifyHistory.init();
    setState(() {
      records = medifyHistory.getRecords();
    });
  }

  // Add this method to toggle the timing status
  void toggleMedicineStatus(int recordIndex, int medicineIndex, int timeIndex) {
    setState(() {
      Map<String, dynamic> record = records[recordIndex];
      Map<String, dynamic> medicine = record["records"][medicineIndex];
      Map<String, bool> timing =
          Map<String, bool>.from(medicine['times'][timeIndex]);

      // Get the key (time) from the timing map
      String timeKey = timing.keys.first;

      // Toggle the boolean value
      timing[timeKey] = !timing.values.first;

      // Update the timing in the records
      medicine['times'][timeIndex] = timing;

      // Save the updated records to persistent storage
      medifyHistory.updateRecords(records);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MyButton(
          text: "Clear",
          enabled: true,
          onTap: medifyHistory.clearData,
        ),
        SizedBox(
          height: 200,
          child: records.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    return _MedifyRecordCard(
                      item: records[index],
                      recordIndex: index,
                      onToggle: toggleMedicineStatus,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _MedifyRecordCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final int recordIndex;
  final Function(int, int, int) onToggle;

  const _MedifyRecordCard({
    required this.item,
    required this.recordIndex,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red,
      margin: const EdgeInsets.all(8.0),
      child: Container(
        width:
            MediaQuery.of(context).size.width * 0.9, // Fixed width for the card
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item["date"],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: item["records"].length,
                itemBuilder: (context, index) {
                  return _MedifyRecordMedicine(
                    med: item["records"][index],
                    recordIndex: recordIndex,
                    medicineIndex: index,
                    onToggle: onToggle,
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _MedifyRecordMedicine extends StatelessWidget {
  final Map<String, dynamic> med;
  final int recordIndex;
  final int medicineIndex;
  final Function(int, int, int) onToggle;

  const _MedifyRecordMedicine({
    required this.med,
    required this.recordIndex,
    required this.medicineIndex,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 85, 85, 85),
      margin: const EdgeInsets.only(bottom: 4),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              med["medicineName"],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 30, // Fixed height for the times list
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: med['times'].length,
                itemBuilder: (context, index) {
                  Map<String, bool> timing =
                      Map<String, bool>.from(med['times'][index]);
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: GestureDetector(
                      onTap: () => onToggle(recordIndex, medicineIndex, index),
                      child: Chip(
                        label: Text(timing.keys.first),
                        backgroundColor:
                            timing.values.first ? Colors.green : Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
