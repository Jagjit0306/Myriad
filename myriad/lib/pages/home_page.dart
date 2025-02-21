import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myriad/components/my_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final User? currentUser = FirebaseAuth.instance.currentUser;

  Future<DocumentSnapshot<Map<String, dynamic>>> getUser() async {
    return await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser!.email)
        .get();
  }

  Future<void> _prefsSaver(List<dynamic> prefs) async {
    SharedPreferences localPrefs = await SharedPreferences.getInstance();
    localPrefs.setString('prefs', jsonEncode(prefs));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: 'Myriad',
        actions: [
          AppbarIcon(
            onTouch: () => context.push('/notify'),
            iconData: Icons.notifications_active_outlined,
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: getUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          } else if (snapshot.hasData) {
            if (snapshot.data!.data() != null) {
              _prefsSaver(snapshot.data!.data()!['prefs']);
              return Column(
                children: [
                  Image.network(
                    currentUser!.photoURL!,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  (loadingProgress.expectedTotalBytes ?? 1)
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (BuildContext context, Object error,
                        StackTrace? stackTrace) {
                      return const Text('Failed to load image');
                    },
                  ),
                  Text(
                    "DATA OBTAINED -> \n\n\n\n${jsonEncode(snapshot.data!.data())}",
                  ),
                ],
              );
            } else {
              return Text("NODATA");
            }
          } else {
            return Text("NODATA");
          }
        },
      ),
      // drawer: MyDrawer(),
    );
  }
}
