import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myriad/components/circular_image.dart';
import 'package:myriad/helper/helper_functions.dart';

class WelcomeCard extends StatelessWidget {
  const WelcomeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          CircularImage(
            imageUrl: FirebaseAuth.instance.currentUser?.photoURL ?? "",
            placeholder: Icon(
              Icons.person,
              size: 100,
            ),
            size: 100,
          ),
          const SizedBox(width: 15), // Added spacing
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