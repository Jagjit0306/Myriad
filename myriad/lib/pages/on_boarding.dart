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
    {'Limb Differences': false},
    {'Paralysis': false},
  ];

  Future<void> setPrefs() async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser!.email)
        .update({
      "username": usernameController.text,
      "prefs": prefs,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('On Boarding'),
        // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // decoration: BoxDecoration(
        //     border: Border.all(color: Colors.greenAccent, width: 2)),
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
            ),

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
                  // submit the info and save it
                  // Navigator.pop(context);
                  // Navigator.pushNamed(context, '/home_page');
                  setPrefs();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/home_page', // The name of the route you want to push
                    (route) => false, // This will remove all previous routes
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
