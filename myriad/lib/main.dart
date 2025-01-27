import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:myriad/auth/auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:myriad/firebase_options.dart';
import 'package:myriad/pages/chatbot_home_page.dart';
import 'package:myriad/pages/community_new_post.dart';
import 'package:myriad/pages/community_page.dart';
import 'package:myriad/pages/home_page.dart';
import 'package:myriad/pages/maps_wheelchair_home_page.dart';
import 'package:myriad/pages/on_boarding.dart';
import 'package:myriad/pages/deaf_page.dart';
import 'package:myriad/pages/dumb_page.dart';
import 'package:myriad/pages/deaf_dumb_page.dart';
import 'package:myriad/passwords.dart';
import 'package:myriad/themes/dark_mode.dart';
import 'package:myriad/themes/light_mode.dart';
import 'package:myriad/pages/sos_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Gemini.init(
    apiKey: GEMINI_API_KEY,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Myriad',
      theme: lightMode,
      darkTheme: darkMode,
      home: AuthPage(),
      routes: {
        '/home_page': (context) => HomePage(),
        '/on_boarding': (context) => OnBoarding(),
        '/community_page': (context) => CommunityPage(),
        '/new_thread': (context) => CommunityNewPost(),
        '/gemini_chat': (context) => ChatbotHomePage(),
        '/wheelchair_map': (context) => MapsWheelchairHomePage(),
        '/sos_page': (context) => SosPage(),
        '/deaf_page': (context) => DeafPage(),
        '/dumb_page': (context) => DumbPage(),
        '/deaf_dumb_page': (context) => DeafDumbPage(),
      },
    );
  }
}
