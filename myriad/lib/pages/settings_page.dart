import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myriad/components/my_button.dart';
import 'package:myriad/components/my_textfield.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  List<Map<String, bool>> prefs = [
    {'Vision Support': false},
    {'Hearing Support': false},
    {'Speech Assistance': false},
    {'Colorblindness Support': false},
    {'Dexterity Support': false},
    {'Wheelchair Support': false},
    {'Limb Diversity Support': false},
    {'Paralysis Support': false},
  ];

  bool anyPrefSelected() {
    return prefs.any((element) => element.values.first);
  }

  Future<void> updateUserInfo() async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await FirebaseFirestore.instance.collection('Users').doc(currentUser.email).update({
        "username": nameController.text,
        "bio": bioController.text,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Edit Personal Information Section
              ExpansionTile(
                title: const Text("Edit Personal Information",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Profile Name:", style: TextStyle(fontSize: 16)),
                        MyTextfield(
                          hintText: 'Enter Name',
                          inputType: TextInputType.name,
                          obscureText: false,
                          controller: nameController,
                          onChanged: (value) {},
                        ),
                        const SizedBox(height: 10),
                        const Text("Profile Bio:", style: TextStyle(fontSize: 16)),
                        MyTextfield(
                          hintText: 'Enter Bio',
                          inputType: TextInputType.multiline,
                          obscureText: false,
                          controller: bioController,
                          onChanged: (value) {},
                        ),
                        const SizedBox(height: 10),
                        MyButton(
                          text: 'Update Information',
                          onTap: () {
                            updateUserInfo();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Information updated successfully'),
                              ),
                            );
                          },
                          enabled: nameController.text.isNotEmpty,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Accessibility Preferences Section
              ExpansionTile(
                title: const Text("Customize Accessibility Preferences",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: prefs.asMap().entries.map((entry) {
                        int index = entry.key;
                        String title = entry.value.keys.first;
                        bool value = entry.value.values.first;
                        return CheckboxListTile(
                          title: Text(title),
                          value: value,
                          onChanged: (bool? newValue) {
                            setState(() {
                              prefs[index] = {title: newValue!};
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}