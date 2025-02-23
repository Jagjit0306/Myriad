import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myriad/components/my_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatBotConfigurator extends StatefulWidget {
  const ChatBotConfigurator({super.key});

  @override
  State<ChatBotConfigurator> createState() => _ChatBotConfiguratorState();
}

class _ChatBotConfiguratorState extends State<ChatBotConfigurator> {
  final dev = false;

  @override
  void initState() {
    super.initState();
    if (!dev) {
      handleInit();
    }
  }

  void handleInit() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String config = prefs.getString('prefs') ?? "";
    final List<dynamic> savedConfig = jsonDecode(config);
    final Map<String, bool> c =
        savedConfig.fold({}, (acc, map) => {...acc, ...map});

    List<String> result = [];

    // still not sure if to use braille input or voice input for visually impaired
    // TODO: review these later

    // This also acts as a priority order
    List<String> features = [
      "chat_bot_0",
      "chat_bot_1",
      "chat_bot_3",
      "chat_bot_2",
    ];

    Map<String, List<String>> greenCards = {
      // all
      "chat_bot_0": [],
      "chat_bot_2": [],
      "chat_bot_3": ["Vision Support"],
    };

    // ignore: non_constant_identifier_names
    Map<String, List<String>> ANYgreenCards = {
      // any 1 will enable the feature
      "chat_bot_1": ["Dexterity Support", "Hearing Support"],
    };

    Map<String, List<dynamic>> conflicts = {
      // neither
      "chat_bot_0": ["Vision Support", "Dexterity Support"],
      "chat_bot_1": ["Vision Support", "Speech Assistance"],
      "chat_bot_2": ["Hearing Support", "Dexterity Support"],
      "chat_bot_3": ["Hearing Support", "Speech Assistance"],
    };

    for (String x in features) {
      bool skip = true;

      if (greenCards.containsKey(x)) {
        skip = false;
        for (String y in greenCards[x] ?? []) {
          if (!(c[y] ?? false)) {
            skip = true;
            break;
          }
        }
      } else if (ANYgreenCards.containsKey(x)) {
        // Clause where any 1 requirement is enough to activate
        for (String y in ANYgreenCards[x] ?? []) {
          if (c[y] ?? false) {
            skip = false;
            break;
          }
        }
      }

      // Skip if any conflict is present
      for (String y in conflicts[x] ?? []) {
        if (c[y] ?? false) {
          skip = true;
          break;
        }
      }

      // if (!skip) result.add(x);
      if (!skip) {
        result = [...result, x];
      }
    }
    print("RESULT FOR VOICE MODE IS $result");
    context.go('/chat_bot/${result[0]}');
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: dev
          ? Column(
              children: [
                MyButton(
                  text: "0",
                  enabled: true,
                  onTap: () => context.go('/chat_bot/chat_bot_0'),
                ),
                MyButton(
                  text: "1",
                  enabled: true,
                  onTap: () => context.go('/chat_bot/chat_bot_1'),
                ),
                MyButton(
                  text: "2",
                  enabled: true,
                  onTap: () => context.go('/chat_bot/chat_bot_2'),
                ),
                MyButton(
                  text: "3",
                  enabled: true,
                  onTap: () => context.go('/chat_bot/chat_bot_3'),
                ),
              ],
            )
          : CircularProgressIndicator.adaptive(),
    );
  }
}
