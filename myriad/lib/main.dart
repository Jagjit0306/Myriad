import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:myriad/auth/auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:myriad/firebase_options.dart';
import 'package:myriad/pages/chatbot_home_page.dart';
import 'package:myriad/pages/community_new_post.dart';
import 'package:myriad/pages/community_page.dart';
import 'package:myriad/pages/vibraillify_page.dart';
import 'package:myriad/pages/home_page.dart';
import 'package:myriad/pages/maps_wheelchair_home_page.dart';
import 'package:myriad/pages/on_boarding.dart';
import 'package:myriad/pages/hearify_page.dart';
import 'package:myriad/pages/serenify_breathe_page.dart';
import 'package:myriad/pages/serenify_meditate_page.dart';
import 'package:myriad/pages/serenify_page.dart';
import 'package:myriad/pages/sightify_page.dart';
import 'package:myriad/pages/speakify_page.dart';
import 'package:myriad/pages/voicify_page.dart';
import 'package:myriad/passwords.dart';
import 'package:myriad/themes/dark_mode.dart';
import 'package:myriad/themes/light_mode.dart';
import 'package:myriad/pages/sos_page.dart';
import 'package:myriad/pages/colorify_page.dart';

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
        '/hearify': (context) => HearifyPage(),
        '/speakify': (context) => SpeakifyPage(),
        '/voicify': (context) => VoicifyPage(),
        '/sightify': (context) => SightifyPage(),
        '/vibraillify': (context) => const VibraillifyPage(),
        '/serenify': (context) => const SerenifyPage(),
        '/serenify_meditate': (context) => const SerenifyMeditatePage(),
        '/serenify_breathe': (context) => const SerenifyBreathePage(),
        '/colorify': (context) => const ColorifyPage(),
      },
    );
  }
}
