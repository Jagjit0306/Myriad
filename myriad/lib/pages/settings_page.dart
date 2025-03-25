import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myriad/auth/google_auth.dart';
import 'package:myriad/components/extras.dart';
import 'package:myriad/components/my_button.dart';
import 'package:myriad/components/my_textfield.dart';
import 'package:myriad/components/vb_chat_bot_monitor.dart';

class SettingsPage extends StatefulWidget {
  final bool vb;
  const SettingsPage({
    super.key,
    this.vb = false,
  });

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
    {'Stress Management': false},
  ];

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  @override
  void dispose() {
    nameController.dispose();
    bioController.dispose();
    super.dispose();
  }

  bool anyPrefSelected() {
    return prefs.any((element) => element.values.first);
  }

  Future<void> loadUserData() async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userData = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.email)
          .get();

      if (userData.exists) {
        final data = userData.data();
        setState(() {
          nameController.text = data?['username'] ?? '';
          bioController.text = data?['bio'] ?? '';

          // Load saved preferences
          final savedPrefs = <String, dynamic>{};
          final List<dynamic>? prefsList = data?['prefs'] as List<dynamic>?;
          if (prefsList != null) {
            for (var pref in prefsList) {
              savedPrefs.addAll(pref as Map<String, dynamic>);
            }
          }
          if (savedPrefs.isNotEmpty) {
            for (int i = 0; i < prefs.length; i++) {
              String key = prefs[i].keys.first;
              prefs[i] = {key: savedPrefs[key] ?? false};
            }
          }
        });
      }
    }
  }

  Future<void> updateUserInfo() async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.email)
          .update({
        "username": nameController.text,
        "bio": bioController.text,
      });
    }
  }

  Future<void> updateAccessibilityPreferences() async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      // Convert prefs list to a map for easier storage
      Map<String, bool> prefsMap = {};
      for (var pref in prefs) {
        prefsMap[pref.keys.first] = pref.values.first;
      }

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.email)
          .update({
        "prefs": prefsMap.entries.map((entry) {
          return {entry.key: entry.value};
        }).toList(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            if (widget.vb) VbChatBotMonitor(),
            // Edit Personal Information Section
            ExpansionTile(
              initiallyExpanded: true,
              title: const Text("Edit Personal Information",
                  style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyTextfield(
                        hintText: 'Update Name',
                        inputType: TextInputType.name,
                        obscureText: false,
                        controller: nameController,
                        onChanged: (value) {},
                      ),
                      const SizedBox(height: 10),
                      MyTextfield(
                        hintText: 'Update Bio',
                        inputType: TextInputType.multiline,
                        obscureText: false,
                        controller: bioController,
                        onChanged: (value) {},
                      ),
                      const SizedBox(height: 10),
                      MyButton(
                        text: 'Update Information',
                        onTap: () async {
                          try {
                            await updateUserInfo();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Information updated successfully'),
                                ),
                              );
                              context.go("/go_to_home");
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('Error updating information: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
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
              initiallyExpanded: true,
              title: const Text("Customize Accessibility Preferences",
                  style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      ...prefs.map((pref) {
                        return CheckboxListTile(
                          title: Text(pref.keys.first),
                          value: pref.values.first,
                          onChanged: (bool? newValue) {
                            setState(() {
                              prefs[prefs.indexOf(pref)] = {
                                pref.keys.first: newValue!
                              };
                            });
                          },
                        );
                      }),
                      const SizedBox(height: 10),
                      MyButton(
                        text: 'Save Preferences',
                        onTap: () async {
                          try {
                            await updateAccessibilityPreferences();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Preferences updated successfully'),
                                ),
                              );
                              context.go('/go_to_home');
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('Error updating preferences: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        enabled: anyPrefSelected(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: ExtraButton(
                path: "",
                customCallback: () {
                  signOutFromGoogle();
                  context.push("/auth");
                },
                iconData: Icons.logout,
                color: Colors.red,
                name: "LOGOUT",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
