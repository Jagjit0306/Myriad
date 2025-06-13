import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myriad/auth/auth.dart';
import 'package:myriad/components/chat_bot_configurator.dart';
import 'package:myriad/components/extras.dart';
import 'package:myriad/components/go_to_home.dart';
import 'package:myriad/components/home_configurator.dart';
import 'package:myriad/layout/layout_scaffold.dart';
import 'package:myriad/layout/layout_scaffold_2.dart';
import 'package:myriad/pages/serenify_sleep_page.dart';
import 'package:myriad/pages/sightify_asl_page.dart';
import 'package:myriad/pages/vb_chat_bot.dart';
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
import 'package:myriad/pages/profile_page.dart';
import 'package:myriad/pages/serenify_breathe_page.dart';
import 'package:myriad/pages/serenify_meditate_page.dart';
import 'package:myriad/pages/serenify_page.dart';
import 'package:myriad/pages/settings_page.dart';
import 'package:myriad/pages/sightify_page.dart';
import 'package:myriad/pages/sos_page.dart';
import 'package:myriad/pages/speakify_page.dart';
import 'package:myriad/pages/vibraillify_page.dart';
import 'package:myriad/pages/vision_support_layout.dart';
import 'package:myriad/pages/voicify_page.dart';
import 'package:myriad/pages/user_profile_page.dart';
import 'package:myriad/pages/serenify_affirmate_page.dart';

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
      path: '/go_to_home',
      builder: (context, state) => const GoToHome(),
    ),
    GoRoute(
      path: '/home_configurator',
      builder: (context, state) => const HomeConfigurator(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnBoarding(),
    ),
    GoRoute(
      path: '/serenify_meditate',
      builder: (context, state) => const SerenifyMeditatePage(),
    ),
    GoRoute(
      path: '/serenify_breathe',
      builder: (context, state) => const SerenifyBreathePage(),
    ),
    GoRoute(
      path: '/serenify_affirmate',
      builder: (context, state) => const SerenifyAffirmatePage(),
    ),
    GoRoute(
      path: '/serenify_sleep',
      builder: (context, state) => const SerenifySleepPage(),
    ),
    GoRoute(
      path: '/sos_page',
      builder: (context, state) => const SosPage(),
    ),
    GoRoute(
      path: '/vision_support_layout',
      builder: (context, state) => VisionSupportLayout(),
    ),
    GoRoute(
      path: '/vision_support_sightify',
      builder: (context, state) => const SightifyPage(),
    ),
    GoRoute(
      path: '/vision_support_serenify',
      builder: (context, state) => const SightifyPage(),
    ),
    GoRoute(
      path: '/vision_support_settings',
      builder: (context, state) => SettingsPage(),
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
              builder: (context, state) => const ChatBotConfigurator(),
              routes: [
                GoRoute(
                  path: '/chat_bot_0',
                  builder: (context, state) => const ChatbotHomePage(),
                ),
                GoRoute(
                  path: '/chat_bot_1',
                  builder: (context, state) => const ChatbotHomePage(
                    voiceInput: true,
                  ),
                ),
                GoRoute(
                  path: '/chat_bot_2',
                  builder: (context, state) => const ChatbotHomePage(
                    voiceOutput: true,
                  ),
                ),
                GoRoute(
                  path: '/chat_bot_3',
                  builder: (context, state) => const ChatbotHomePage(
                    voiceOutput: true,
                    voiceInput: true,
                  ),
                ),
              ]),
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
                  path: 'colorify_talkback',
                  builder: (context, state) => const ColorifyPage(
                    talkback: true,
                  ),
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
                  path: '/sightify_asl',
                  builder: (context, state) => const SightifyASLPage(),
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
                GoRoute(
                  path: 'settings',
                  builder: (context, state) => SettingsPage(),
                )
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
            path: '/profile',
            builder: (context, state) => const ProfilePage(),
          ),
          GoRoute(
            path: '/profile/:email',
            builder: (context, state) => UserProfilePage(
              userEmail: state.pathParameters['email']!,
            ),
          ),
        ]),
      ],
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => LayoutScaffold2(
        navigationShell: navigationShell,
      ),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/vb_chat_bot',
            builder: (context, state) => const VbChatBot(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/vb_vibraillify',
            builder: (context, state) => const VibraillifyPage(),
          ),
        ]),
      ],
    ),
    GoRoute(
      path: '/vb_settings',
      builder: (context, state) => const SettingsPage(vb: true),
    ),
  ],
);
