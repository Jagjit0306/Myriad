import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myriad/helper/helper_functions.dart';

// Crucial file that syncs prefs with local storage

class WelcomeCard extends StatelessWidget {
  WelcomeCard({super.key});

  final User? currentUser = FirebaseAuth.instance.currentUser;

  Future<void> getUser() async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> currUser =
          await FirebaseFirestore.instance
              .collection("Users")
              .doc(currentUser!.email)
              .get();

      if (currUser.exists) {
        List<dynamic>? prefs = currUser.data()?["prefs"] as List<dynamic>?;

        if (prefs != null) {
          // log("Prefs: $prefs");
          prefsSaver(prefs);
        }
        // else {
        //   log("No prefs found");
        // }
      }
    } catch (e) {
      log("Error fetching user: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    getUser();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 40),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Align text to start
              children: [
                Text(
                  "${getSalutation()} ${FirebaseAuth.instance.currentUser?.displayName?.split(" ")[0]}!",
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w600,
                  ),
                  softWrap: true, // Allow word wrapping
                  overflow: TextOverflow.ellipsis, // Prevent overflow
                  maxLines: 2, // Limit to 2 lines if necessary
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
