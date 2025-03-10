import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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
      records = medifyHistory.getRecords().reversed.toList();
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
    // return (!(records.length == 1 && records[0]["records"].length == 0))
    return (!(records.every((e) => e["records"].length == 0)))
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Medication History',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                  PopupMenuButton(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    onSelected: (value) {
                      switch (value) {
                        case 'clrmedhist':
                          medifyHistory.clearData();
                          initMedify();
                          break;
                        default:
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'clrmedhist',
                        child: Text("Clear History"),
                      ),
                    ],
                  )
                ],
              ),
              SizedBox(
                height: 310,
                child: records.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : PageView.builder(
                        reverse: true,
                        controller: _pageController,
                        itemCount: records.length,
                        itemBuilder: (context, index) {
                          return AnimatedBuilder(
                            animation: _pageController,
                            builder: (context, child) {
                              double scale = 1.0;
                              if (_pageController.position.haveDimensions) {
                                double pageOffset =
                                    _pageController.page! - index;
                                scale = (1 - (pageOffset.abs() * 0.2))
                                    .clamp(0.8, 1.0);
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
                      ),
              ),
            ],
          )
        : SizedBox.shrink();
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
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 15,
              children: [
                Icon(
                  Icons.date_range_outlined,
                  size: 20,
                ),
                Text(
                  item["date"],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            (item["records"].length != 0)
                ? Expanded(
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
                : Center(
                    child: const Text("No data for this date"),
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
      color: Theme.of(context).colorScheme.secondaryContainer,
      margin: const EdgeInsets.only(bottom: 4),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                spacing: 15,
                children: [
                  Icon(
                    LucideIcons.pill,
                    size: 20,
                  ),
                  Text(
                    med["medicineName"],
                    style: const TextStyle(
                      // color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
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
                          label: Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: Text(
                              timing.keys.first,
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                          backgroundColor: timing.values.first
                              ? Color(0xFF9bbb4f)
                              : Color(0xFFdb4d58),
                          side: BorderSide(
                            color: Colors.transparent,
                            width: 0,
                          ),
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
