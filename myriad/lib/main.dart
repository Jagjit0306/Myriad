import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:myriad/firebase_options.dart';
import 'package:myriad/passwords.dart';
import 'package:myriad/router.dart';
import 'package:myriad/themes/dark_mode.dart';
import 'package:myriad/themes/light_mode.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top],
  );
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Gemini.init(
    apiKey: GEMINI_API_KEY,
  );
  // FallDetectionService();
  tz.initializeTimeZones();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Myriad',
      routerConfig: router,
      theme: lightMode,
      darkTheme: darkMode,
    );
    // return MaterialApp(
    //   title: 'Myriad',
    //   theme: lightMode,
    //   darkTheme: darkMode,
    //   home: AuthPage(),
    //   routes: {
    //     '/home_page': (context) => HomePage(),
    //     '/on_boarding': (context) => OnBoarding(),
    //     '/community_page': (context) => CommunityPage(),
    //     '/new_thread': (context) => CommunityNewPost(),
    //     '/gemini_chat': (context) => ChatbotHomePage(),
    //     '/wheelchair_map': (context) => MapsWheelchairHomePage(),
    //     '/sos_page': (context) => SosPage(),
    //     '/hearify': (context) => HearifyPage(),
    //     '/speakify': (context) => SpeakifyPage(),
    //     '/voicify': (context) => VoicifyPage(),
    //     '/sightify': (context) => SightifyPage(),
    //     '/vibraillify': (context) => const VibraillifyPage(),
    //     '/serenify': (context) => const SerenifyPage(),
    //     '/serenify_meditate': (context) => const SerenifyMeditatePage(),
    //     '/serenify_breathe': (context) => const SerenifyBreathePage(),
    //     '/colorify': (context) => const ColorifyPage(),
    //     '/medication': (context) => const MedicationPage(),
    //   },
    // );
  }
}
