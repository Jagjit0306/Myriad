import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myriad/components/my_button.dart';
import 'package:myriad/components/my_textfield.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class OnBoarding extends StatefulWidget {
  const OnBoarding({super.key});

  @override
  State<OnBoarding> createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  final TextEditingController usernameController = TextEditingController();

  // List of all possible disabilities
  final List<String> allDisabilities = [
    'Visual Impairment',
    'Hearing Impairment',
    'Speech Impairment',
    'Dexterity Impairment',
    'Wheelchair Bound',
    'Limb Differences',
    'Paralysis',
  ];

  // List to hold the selected disabilities
  List<String> selectedDisabilities = [];

  bool isUsernameUnique = false;

  // Function to check if any disability is selected
  bool anyPrefSelected() {
    return selectedDisabilities.isNotEmpty;
  }

  Future<void> checkUsernameUnique(String username) async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('Users')
        .where('username', isEqualTo: username)
        .get();
    setState(() {
      isUsernameUnique =
          result.docs.isEmpty && usernameController.text.isNotEmpty;
    });
  }

  Future<void> setPrefs() async {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (isUsernameUnique) {
      // Save the selected disabilities to Firestore
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser!.email)
          .update({
        "username": usernameController.text,
        "prefs": selectedDisabilities, // Save as a list of strings
      });

      // Save the selected disabilities locally using SharedPreferences
      SharedPreferences localPrefs = await SharedPreferences.getInstance();
      await localPrefs.setString(
        'prefs',
        jsonEncode(selectedDisabilities), // Save as JSON string
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('On Boarding'),
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text("Welcome to Myriad"),

            const SizedBox(height: 25),

            // Username section
            const Text(
              "U S E R N A M E",
              style: TextStyle(fontSize: 20),
            ),

            const SizedBox(height: 25),

            MyTextfield(
              hintText: 'Username',
              obscureText: false,
              controller: usernameController,
              onChanged: (value) {
                checkUsernameUnique(value);
              },
            ),
            if (!isUsernameUnique && usernameController.text.isNotEmpty)
              const Text(
                "THIS USERNAME IS TAKEN/INVALID",
                style: TextStyle(color: Colors.red),
              ),

            const SizedBox(height: 25),

            // Dropdown for selecting disabilities
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                value: null,
                hint: const Text("Select Disabilities"),
                onChanged: (String? newValue) {
                  setState(() {
                    if (newValue != null &&
                        !selectedDisabilities.contains(newValue)) {
                      selectedDisabilities.add(newValue);
                    }
                  });
                },
                items: allDisabilities.map((String disability) {
                  return DropdownMenuItem<String>(
                    value: disability,
                    child: Text(disability),
                  );
                }).toList(),
              ),
            ),

            // Display selected disabilities
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
              child: Wrap(
                children: selectedDisabilities.map((disability) {
                  return Chip(
                    label: Text(disability),
                    onDeleted: () {
                      setState(() {
                        selectedDisabilities.remove(disability);
                      });
                    },
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 25),

            Padding(
              padding: const EdgeInsets.all(15.0),
              child: MyButton(
                text: 'Lets get started',
                onTap: () async {
                  await setPrefs();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/home_page',
                    (route) => false,
                  );
                },
                enabled: isUsernameUnique &&
                    anyPrefSelected() &&
                    usernameController.text.isNotEmpty,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
