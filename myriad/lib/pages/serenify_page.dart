import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SerenifyPage extends StatefulWidget {
  const SerenifyPage({super.key});

  @override
  State<SerenifyPage> createState() => _SerenifyPageState();
}

class _SerenifyPageState extends State<SerenifyPage> {
  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  // }

  @override
  Widget build(BuildContext context) {
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (Platform.isAndroid) {
    //     SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    //       systemNavigationBarColor: Colors.black,
    //     ));
    //   }
    // });
    return Theme(
      data: ThemeData.dark(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Serenify',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Colors.black],
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(25, 40, 25, 40),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Morning, ${(FirebaseAuth.instance.currentUser!.displayName as String).split(" ")[0]}!\n"
                        "Start your mindfulness journey",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 30,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  children: [
                    SerenifySubWidget(
                      imgPath: 'assets/Frame_Meditate.png',
                      link: '/serenify_meditate',
                    ),
                    SerenifySubWidget(
                      imgPath: 'assets/Frame_Sleep.png',
                      link: '/serenify_meditate',
                    ),
                    SerenifySubWidget(
                      imgPath: 'assets/Frame_Breathe.png',
                      link: '/serenify_breathe',
                    ),
                    SerenifySubWidget(
                      imgPath: 'assets/Frame_Affirmate.png',
                      link: '/serenify_meditate',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SerenifySubWidget extends StatelessWidget {
  String imgPath;
  String link;
  SerenifySubWidget({super.key, required this.imgPath, required this.link});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, link),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(imgPath),
              fit: BoxFit.cover,
            ),
            border: Border.all(color: Colors.black, width: 1),
            borderRadius: BorderRadius.circular(20),
          ),
          // child: const Text('heyy'),
        ),
      ),
    );
  }
}
