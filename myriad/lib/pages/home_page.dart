import 'package:flutter/material.dart';
import 'package:myriad/components/home_page_notes.dart';
import 'package:myriad/components/my_app_bar.dart';
import 'package:myriad/components/welcome_card.dart';
import 'package:myriad/pages/notify_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
            HomePageNotes(),
            NotifyPage(),
          ],
        ),
      )
      // drawer: MyDrawer(),
    );
  }
}
