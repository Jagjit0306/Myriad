import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myriad/all_preferences.dart';
import 'package:myriad/components/logo_component.dart';
import 'package:myriad/components/my_button.dart';
import 'package:myriad/components/my_textfield.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OnBoarding extends StatefulWidget {
  const OnBoarding({super.key});

  @override
  State<OnBoarding> createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController guardianPhoneController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  List<Map<String, bool>> prefs = prefsList;
  List<List<String>> prefsExclusive = prefsExclusiveGroupings;

  bool isUsernameUnique = false;

  bool anyPrefSelected() {
    bool valid = false;
    for (var element in prefs) {
      valid = valid || element.values.first;
    }
    return valid;
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
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser!.email)
          .update({
        "username": usernameController.text,
        "prefs": prefs,
        "guardianPhone": guardianPhoneController.text,
        "bio": bioController.text,
        "following": [],
        "followers": [],
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 70,
              ),
              Center(
                child: LogoComponent(
                  size: 120,
                ),
              ),
              Text(
                l10n.welcomeToMyriad,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
              ),
              const SizedBox(
                height: 25,
              ),
              MyTextfield(
                hintText: l10n.username,
                inputType: TextInputType.name,
                obscureText: false,
                controller: usernameController,
                onChanged: (value) {
                  checkUsernameUnique(value);
                },
              ),
              if (!isUsernameUnique && usernameController.text.isNotEmpty)
                Text(l10n.usernameTaken),
              const SizedBox(
                height: 25,
              ),
              MyTextfield(
                hintText: l10n.guardianPhone,
                inputType: TextInputType.phone,
                obscureText: false,
                controller: guardianPhoneController,
                onChanged: (value) {},
              ),
              const SizedBox(
                height: 25,
              ),
              MyTextfield(
                hintText: l10n.bio,
                inputType: TextInputType.multiline,
                obscureText: false,
                controller: bioController,
                onChanged: (value) {},
              ),
              const SizedBox(
                height: 25,
              ),
              Text(
                l10n.selectPreferences,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Card(
                  color: Theme.of(context).colorScheme.secondary,
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: prefs.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          CheckboxListTile(
                            title: Text(prefs[index].keys.first),
                            value: prefs[index].values.first,
                            onChanged: (bool? newValue) {
                              setState(() {
                                prefs[index] = {
                                  prefs[index].keys.first: newValue!
                                };
                              });
                              // TODO: Handle exclusive groupings

                              if(newValue == true) { //Coz we only need 1 from them, or neither
                                for(var group in prefsExclusive) {
                                  if(group.contains(prefs[index].keys.first)) {
                                    for(var pref in group) {
                                      if(pref != prefs[index].keys.first) {
                                        prefs.firstWhere((element) => element.keys.first == pref)[pref] = false;
                                      }
                                    }
                                  }
                                }
                              }
                            },
                          ),
                          if (index < prefs.length - 1)
                            Divider(
                              color: Theme.of(context).colorScheme.onSecondary,
                              thickness: 2,
                              indent: MediaQuery.of(context).size.width * 0.2,
                              endIndent:
                                  MediaQuery.of(context).size.width * 0.2,
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: MyButton(
                  text: 'Lets get started',
                  onTap: () {
                    setPrefs();
                    context.go('/go_to_home');
                  },
                  enabled: isUsernameUnique && anyPrefSelected(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
