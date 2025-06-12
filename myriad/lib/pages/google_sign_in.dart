import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:myriad/components/logo_component.dart';
import 'package:myriad/database/user.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LogoComponent(size: 150),
            Text(
              l10n.appTitle,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 28,
              ),
            ),
            const SizedBox(height: 25),
            Text(
              l10n.overcomingChallenges,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w600,
              ),
            ),
            Image.asset(
              'assets/login_asset.png',
              height: 320,
            ),
            const SizedBox(height: 48),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 1,
                ),
                onPressed: () async {
                  try {
                    UserCredential? userCredential =
                        await signInWithGoogle(context);

                    if (userCredential == null || userCredential.user == null) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Sign-in failed. Please try again."),
                          ),
                        );
                      }
                      return;
                    }

                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ManageLogin(
                            email: userCredential.user!.email,
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    debugPrint("Error during sign-in: $e");
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("An error occurred. Please try again."),
                        ),
                      );
                    }
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/google_icon.png',
                      height: 24,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Continue with Google',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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

  UserDatabase userDatabase = UserDatabase();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      managePage(context);
    });
  }

  Future<void> managePage(BuildContext context) async {
    if (completed) {
      userDatabase.userCosmeticSync();
      // Navigate to home or onboarding
      if (onboarding) {
        context.go('/onboarding');
      } else {
        context.go('/home_configurator');
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
