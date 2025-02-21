import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myriad/components/home_quick_links.dart';
import 'package:myriad/components/my_app_bar.dart';
import 'package:myriad/components/welcome_card.dart';
import 'package:myriad/pages/notify_page.dart';
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
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            WelcomeCard(),
            HomeQuickLinks(),
            NotifyPage(),
          ],
        ),
      )
      // drawer: MyDrawer(),
    );
  }
}
