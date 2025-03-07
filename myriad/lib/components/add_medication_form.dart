import 'package:flutter/material.dart';
import 'package:myriad/components/my_button.dart';
import 'package:myriad/components/my_textfield.dart';

class AddMedicationForm extends StatefulWidget {
  final Function(String medicineName, List<String> times) onSave;

  const AddMedicationForm({
    super.key,
    required this.onSave,
  });

  @override
  _AddMedicationFormState createState() => _AddMedicationFormState();
}

class _AddMedicationFormState extends State<AddMedicationForm> {
  final TextEditingController _medicineNameController = TextEditingController();
  final List<TextEditingController> _timeControllers = List.generate(
    6, // Maximum number of time slots
    (index) => TextEditingController(),
  );

  @override
  void initState() {
    super.initState();
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
      setState(() {
        _timeControllers[index].text = formattedTime;
      });
    }
  }

  void _saveMedication() {
    if (_medicineNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a prescription name',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final timeRegex = RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$');
    final times = <String>[];

    // Only collect non-empty time inputs
    for (var controller in _timeControllers) {
      if (controller.text.isNotEmpty) {
        if (!timeRegex.hasMatch(controller.text)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please enter valid times in 24-hour format (HH:mm)',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
          return;
        }
        times.add(controller.text);
      }
    }

    if (times.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter at least one time',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    // Call the parent's onSave method
    widget.onSave(_medicineNameController.text, times);
    
    // Clear form
    _medicineNameController.clear();
    for (var controller in _timeControllers) {
      controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
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