import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInScreen extends StatefulWidget {
  const GoogleSignInScreen({super.key});

  @override
  State<GoogleSignInScreen> createState() => _GoogleSignInScreenState();
}

class _GoogleSignInScreenState extends State<GoogleSignInScreen> {
  Future<UserCredential?> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      debugPrint("Google Sign-In error: $e");
      return null; // Return null in case of error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Google Sign-In Screen')),
      body: Center(
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          child: IconButton(
            iconSize: 40,
            icon: const Icon(Icons.fireplace),
            onPressed: () async {
              try {
                UserCredential? userCredential =
                    await signInWithGoogle(context);

                if (userCredential == null || userCredential.user == null) {
                  // Sign-in failed
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Sign-in failed. Please try again.")),
                  );
                  return;
                }

                // Navigate to the next page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManageLogin(
                      email: userCredential.user!.email,
                    ),
                  ),
                );
              } catch (e) {
                debugPrint("Error during sign-in: $e");
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("An error occurred. Please try again.")),
                );
              }
            },
          ),
        ),
      ),
    );
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
      // Navigate to home or onboarding
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
      debugPrint("Error saving user: $e");
      return false; // Indicate failure
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: completed
            ? const Text("Redirecting...")
            : const CircularProgressIndicator(),
      ),
    );
  }
}