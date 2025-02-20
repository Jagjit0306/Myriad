import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

Future<List<String>> configurator() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String config = prefs.getString('prefs') ?? "";
  final List<dynamic> savedConfig = jsonDecode(config);
  final Map<String, bool> c =
      savedConfig.fold({}, (acc, map) => {...acc, ...map});

  List<String> result = [];

  List<String> features = [
    "sightify",
    'colorify',
    "hearify",
    "vibraillify",
    "speakify",
    "voicify",
    "wheelify",
    "serenify",
    "medify",
  ];

  if (true) return features;

  // Put the field either in greenCards or ANYgreenCards, depending on requirement

  Map<String, List<String>> greenCards = {
    // all
    "hearify": ["Hearing Support"],
    "vibraillify": ["Hearing Support", "Vision Support"],
    "wheelify": ["Wheelchair Support"],
    "medify": ["Vision Support"],
    "serenify": ["Vision Support"],
    "sightify": ["Vision Support"],
    "speakify": ["Speech Assistance"],
    "voicify": ["Speech Assistance", "Hearing Support"],
  };

  // ignore: non_constant_identifier_names
  Map<String, List<String>> ANYgreenCards = {
    // any 1 will enable the feature
    "colorify": ["Vision Support", "Colorblindness Support"],
  };

  Map<String, List<dynamic>> conflicts = {
    // neither
    "colorify": ["Hearing Support"],
    "hearify": ["Vision Support", "Speech Assistance"],
    "vibraillify": [],
    "wheelify": ["Vision Support"],
    "medify": ["Dexterity Support"],
    "serenify": ["Vision Support"],
    "sightify": ["Hearing Support"],
    "speakify": ["Dexterity Support", "Hearing Support"],
    "voicify": ["Dexterity Support"],
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

    if (!skip) result.add(x);
  }

  print(savedConfig);
  print(jsonEncode(result));
  return result;
}
