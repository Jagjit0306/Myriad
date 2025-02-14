import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myriad/auth/auth.dart';
import 'package:myriad/components/extras.dart';
import 'package:myriad/layout/layout_scaffold.dart';
import 'package:myriad/pages/chatbot_home_page.dart';
import 'package:myriad/pages/colorify_page.dart';
import 'package:myriad/pages/community_new_post.dart';
import 'package:myriad/pages/community_page.dart';
import 'package:myriad/pages/google_sign_in.dart';
import 'package:myriad/pages/hearify_page.dart';
import 'package:myriad/pages/home_page.dart';
import 'package:myriad/pages/maps_wheelchair_home_page.dart';
import 'package:myriad/pages/medication_page.dart';
import 'package:myriad/pages/on_boarding.dart';
import 'package:myriad/pages/serenify_page.dart';
import 'package:myriad/pages/sightify_page.dart';
import 'package:myriad/pages/sos_page.dart';
import 'package:myriad/pages/speakify_page.dart';
import 'package:myriad/pages/vibraillify_page.dart';
import 'package:myriad/pages/voicify_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/auth',
  routes: [
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const GoogleSignInScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnBoarding(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => LayoutScaffold(
        navigationShell: navigationShell,
      ),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => HomePage(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/chat_bot',
            builder: (context, state) => const ChatbotHomePage(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
              path: '/extras',
              builder: (context, state) => const Extras(),
              routes: [
                GoRoute(
                  path: 'colorify',
                  builder: (context, state) => const ColorifyPage(),
                ),
                GoRoute(
                  path: 'hearify',
                  builder: (context, state) => const HearifyPage(),
                ),
                GoRoute(
                  path: 'wheelify',
                  builder: (context, state) => const MapsWheelchairHomePage(),
                ),
                GoRoute(
                  path: 'medify',
                  builder: (context, state) => const MedicationPage(),
                ),
                GoRoute(
                  path: 'serenify',
                  builder: (context, state) => const SerenifyPage(),
                ),
                GoRoute(
                  path: 'sightify',
                  builder: (context, state) => const SightifyPage(),
                ),
                GoRoute(
                  path: 'speakify',
                  builder: (context, state) => const SpeakifyPage(),
                ),
                GoRoute(
                  path: 'vibraillify',
                  builder: (context, state) => const VibraillifyPage(),
                ),
                GoRoute(
                  path: 'voicify',
                  builder: (context, state) => const VoicifyPage(),
                ),
              ]),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
              path: '/community',
              builder: (context, state) => const CommunityPage(),
              routes: [
                GoRoute(
                  path: 'new_thread',
                  builder: (context, state) => const CommunityNewPost(),
                ),
              ]),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/sos_page',
            builder: (context, state) => const SosPage(),
          ),
        ]),
      ],
    )
  ],
);
