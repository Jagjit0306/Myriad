import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myriad/all_preferences.dart';
import 'package:myriad/auth/google_auth.dart';
import 'package:myriad/components/extras.dart';
import 'package:myriad/components/my_button.dart';
import 'package:myriad/components/my_textfield.dart';
import 'package:myriad/components/vb_chat_bot_monitor.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myriad/main.dart';

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

  String _currentLanguage = 'en';
  bool _isChangingLanguage = false;
  List<Map<String, bool>> prefs = prefsList;
  List<List<String>> prefsExclusive = prefsExclusiveGroupings;

  @override
  void initState() {
    super.initState();
    loadUserData();
    _loadLanguage();
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

  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _currentLanguage = prefs.getString('language') ?? 'en';
        });
      }
    } catch (e) {
      debugPrint('Error loading language: $e');
    }
  }

  Future<void> _changeLanguage(String languageCode) async {
    if (_isChangingLanguage || languageCode == _currentLanguage) return;

    setState(() {
      _isChangingLanguage = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', languageCode);

      if (mounted) {
        // Show snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                languageCode == 'hi' ? 'भाषा बदली गई' : 'Language changed'),
            duration: const Duration(seconds: 1),
          ),
        );

        // Update the app's locale
        if (context.mounted) {
          final mainApp = context.findAncestorStateOfType<MainAppState>();
          if (mainApp != null) {
            mainApp.changeLocale(Locale(languageCode));
            // Update the current language state
            setState(() {
              _currentLanguage = languageCode;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error changing language: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error changing language: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isChangingLanguage = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Convert the prefs list to use localized strings
    final localizedPrefs = prefs.map((pref) {
      final key = pref.keys.first;
      String localizedKey;
      switch (key) {
        case 'visionSupport':
          localizedKey = l10n.visionSupport;
          break;
        case 'visionSupportSimplified':
          localizedKey = l10n.visionSupportSimplified;
          break;
        case 'hearingSupport':
          localizedKey = l10n.hearingSupport;
          break;
        case 'speechAssistance':
          localizedKey = l10n.speechAssistance;
          break;
        case 'colorblindnessSupport':
          localizedKey = l10n.colorblindnessSupport;
          break;
        case 'dexteritySupport':
          localizedKey = l10n.dexteritySupport;
          break;
        case 'wheelchairSupport':
          localizedKey = l10n.wheelchairSupport;
          break;
        case 'limbDiversitySupport':
          localizedKey = l10n.limbDiversitySupport;
          break;
        case 'paralysisSupport':
          localizedKey = l10n.paralysisSupport;
          break;
        case 'stressManagement':
          localizedKey = l10n.stressManagement;
          break;
        default:
          localizedKey = key;
      }
      return {localizedKey: pref.values.first};
    }).toList();

    return WillPopScope(
      onWillPop: () async {
        if (_isChangingLanguage) return false;
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.settings),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              if (widget.vb) VbChatBotMonitor(),
              // Language Selection Section
              ExpansionTile(
                initiallyExpanded: true,
                title: Text(l10n.language,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w500)),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        RadioListTile<String>(
                          title: Text(l10n.english),
                          value: 'en',
                          groupValue: _currentLanguage,
                          onChanged: _isChangingLanguage
                              ? null
                              : (value) {
                                  if (value != null) {
                                    _changeLanguage(value);
                                  }
                                },
                        ),
                        RadioListTile<String>(
                          title: Text(l10n.hindi),
                          value: 'hi',
                          groupValue: _currentLanguage,
                          onChanged: _isChangingLanguage
                              ? null
                              : (value) {
                                  if (value != null) {
                                    _changeLanguage(value);
                                  }
                                },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Edit Personal Information Section
              ExpansionTile(
                initiallyExpanded: true,
                title: Text(l10n.editPersonalInfo,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w500)),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyTextfield(
                          hintText: l10n.updateName,
                          inputType: TextInputType.name,
                          obscureText: false,
                          controller: nameController,
                          onChanged: (value) {},
                        ),
                        const SizedBox(height: 10),
                        MyTextfield(
                          hintText: l10n.updateBio,
                          inputType: TextInputType.multiline,
                          obscureText: false,
                          controller: bioController,
                          onChanged: (value) {},
                        ),
                        const SizedBox(height: 10),
                        MyButton(
                          text: l10n.updateInformation,
                          onTap: () async {
                            try {
                              await updateUserInfo();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.updateInformation),
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
                        ...localizedPrefs.map((pref) {
                          return CheckboxListTile(
                            title: Text(pref.keys.first),
                            value: pref.values.first,
                            onChanged: (bool? newValue) {
                              setState(() {
                                final originalKey =
                                    prefs[localizedPrefs.indexOf(pref)]
                                        .keys
                                        .first;
                                prefs[localizedPrefs.indexOf(pref)] = {
                                  originalKey: newValue!
                                };
                              });

                                if (newValue == true) {
                                // Get the original key for the current preference
                                final originalKey = prefs[localizedPrefs.indexOf(pref)].keys.first;
                                
                                // Check exclusive groups using original keys
                                for (var group in prefsExclusive) {
                                  if (group.contains(originalKey)) {
                                  for (var groupPref in group) {
                                    if (groupPref != originalKey) {
                                    // Find and update the original preference
                                    final prefIndex = prefs.indexWhere(
                                      (element) => element.keys.first == groupPref);
                                    if (prefIndex != -1) {
                                      prefs[prefIndex] = {groupPref: false};
                                    }
                                    }
                                  }
                                  }
                                }
                                }
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
      ),
    );
  }
}
