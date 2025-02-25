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
  final PageController _pageController = PageController(viewportFraction: 0.9);
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyButton(
          text: "Clear History",
          enabled: true,
          onTap: medifyHistory.clearData,
        ),
        Text(
          'Medication History',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        SizedBox(
            height: 310,
            child: records.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : PageView.builder(
                    controller: _pageController,
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      return AnimatedBuilder(
                        animation: _pageController,
                        builder: (context, child) {
                          double scale = 1.0;
                          if (_pageController.position.haveDimensions) {
                            double pageOffset = _pageController.page! - index;
                            scale =
                                (1 - (pageOffset.abs() * 0.2)).clamp(0.8, 1.0);
                          }
                          return Transform.scale(
                            scale: scale,
                            child: _MedifyRecordCard(
                              item: records[index],
                              recordIndex: index,
                              onToggle: toggleMedicineStatus,
                            ),
                          );
                        },
                      );
                    },
                  )),
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
      color: Theme.of(context).colorScheme.onSecondaryContainer,
      margin: const EdgeInsets.all(8.0),
      child: Container(
        width: MediaQuery.of(context).size.width, // Fixed width for the card
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              item["date"],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
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
      color: Theme.of(context).colorScheme.onSecondary.withAlpha(130),
      margin: const EdgeInsets.only(bottom: 4),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              med["medicineName"],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
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
                        onTap: () =>
                            onToggle(recordIndex, medicineIndex, index),
                        child: Chip(
                          label: Row(
                            spacing: 5,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(timing.keys.first, style: TextStyle(fontWeight: FontWeight.w500),),
                              Icon(
                                timing.values.first
                                    ? Icons.check
                                    : Icons.question_mark,
                                size: 15,
                              )
                            ],
                          ),
                          backgroundColor:
                              timing.values.first ? Colors.green : Color.fromARGB(255, 182, 39, 54),
                        ),
                      ),
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
