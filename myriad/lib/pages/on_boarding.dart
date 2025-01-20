import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myriad/components/my_button.dart';
import 'package:myriad/components/my_textfield.dart';

class OnBoarding extends StatefulWidget {
  const OnBoarding({super.key});

  @override
  State<OnBoarding> createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  final TextEditingController usernameController = TextEditingController();

  List<Map<String, bool>> prefs = [
    {'Visual Impairment': false},
    {'Hearing Impairment': false},
    {'Speech Impairment': false},
    {'Dexterity Impairment': false},
    {'Wheelchair Bound': false},
    {'Limb Differences': false},
    {'Paralysis': false},
  ];

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
      isUsernameUnique = result.docs.isEmpty &&
          usernameController.text.isNotEmpty;
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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('On Boarding'),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Welcome to Myriad"),

            const SizedBox(
              height: 25,
            ),

            // app name
            Text(
              "U S E R N A M E",
              style: TextStyle(fontSize: 20),
            ),

            const SizedBox(
              height: 25,
            ),

            MyTextfield(
              hintText: 'Username',
              obscureText: false,
              controller: usernameController,
              onChanged: (value) {
                checkUsernameUnique(value);
              },
            ),
            if (!isUsernameUnique && usernameController.text.isNotEmpty)
              const Text("THIS USERNAME IS TAKEN/INVALID"),

            const SizedBox(
              height: 25,
            ),

            Expanded(
              child: ListView.builder(
                itemCount: prefs.length,
                itemBuilder: (context, index) {
                  return CheckboxListTile(
                    title: Text(prefs[index].keys.first),
                    value: prefs[index].values.first,
                    onChanged: (bool? newValue) {
                      setState(() {
                        prefs[index] = {prefs[index].keys.first: newValue!};
                      });
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: MyButton(
                text: 'Lets get started',
                onTap: () {
                  setPrefs();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/home_page',
                    (route) => false,
                  );
                },
                enabled: isUsernameUnique && anyPrefSelected(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
