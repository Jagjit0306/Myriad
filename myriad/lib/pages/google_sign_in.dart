import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myriad/auth/google_auth.dart';

class GoogleSignInScreen extends StatefulWidget {
  const GoogleSignInScreen({Key? key}) : super(key: key);

  @override
  State<GoogleSignInScreen> createState() => _GoogleSignInScreenState();
}

class _GoogleSignInScreenState extends State<GoogleSignInScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Google SignIn Screen')),
        body: Center(
          child: Card(
            elevation: 5,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: IconButton(
              iconSize: 40,
              icon: Icon(Icons.fireplace),
              onPressed: () async {
                UserCredential userCredential = await signInWithGoogle(context);

                Navigator.push(
                    // ignore: use_build_context_synchronously
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ManageLogin(email: userCredential.user!.email),
                    ));
              },
            ),
          ),
        ));
  }
}

class ManageLogin extends StatefulWidget {
  final String? email;

  const ManageLogin({super.key, required this.email});

  @override
  State<ManageLogin> createState() => _ManageLoginState();
}

class _ManageLoginState extends State<ManageLogin> {
  bool completed = false;
  bool onboarding = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      managePage(context);
    });
  }

  Future<void> managePage(BuildContext context) async {
    if (completed) {
      // go to home or onboarding whatever
      if (onboarding) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/on_boarding',
          (router) => false,
        );
      } else {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home_page',
          (router) => false,
        );
      }
    } else {
      bool accountState = await saveUser(widget.email);
      if (context.mounted) {
        if (accountState) {
          setState(() {
            completed = true;
          });
        } else {
          setState(() {
            completed = true;
            onboarding = true;
          });
        }
        managePage(context);
      }
    }
  }

  Future<bool> saveUser(String? userEmail) async {
    if (userEmail == null) {
      return false;
    }

    try {
      // Check if a user with the given email already exists
      final querySnapshot = await FirebaseFirestore.instance
          .collection("Users")
          .where('email', isEqualTo: userEmail)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return true; // User already exists
      } else {
        // Create a new user account
        await FirebaseFirestore.instance
            .collection("Users")
            .doc(userEmail) // Use email as the document ID
            .set({'email': userEmail});
        return false; // New user created
      }
    } catch (e) {
      return false; // Indicate failure
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
      ],
    );
  }
}
