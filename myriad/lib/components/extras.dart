import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myriad/auth/google_auth.dart';
import 'package:myriad/helper/configurator.dart';

class Extras extends StatefulWidget {
  const Extras({super.key});

  @override
  State<Extras> createState() => _ExtrasState();
}

class _ExtrasState extends State<Extras> {
  List<String> enabledFeatures = [];

  @override
  void initState() {
    super.initState();
    getConfiguration();
  }

  void getConfiguration() async {
    final List<String> gotConfig = await configurator();
    if (gotConfig.isNotEmpty) {
      setState(() {
        enabledFeatures = gotConfig;
      });
    }
  }

  Map<String, IconData> iconMap = {
    "colorify": Icons.color_lens_outlined,
    "hearify": Icons.hearing_outlined,
    "vibraillify": Icons.drag_indicator_outlined,
    "wheelify": Icons.accessibility_new_outlined,
    "medify": Icons.medical_services_outlined,
    "sightify": Icons.visibility_outlined,
    "serenify": Icons.self_improvement_rounded,
    "speakify": Icons.record_voice_over_outlined,
    "voicify": Icons.loop_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      // Make the entire scaffold transparent
      extendBodyBehindAppBar: true,

      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (enabledFeatures.isNotEmpty)
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ...enabledFeatures.map(
                    (e) => ExtraButton(
                      iconData: iconMap[e] ?? Icons.api,
                      name: e.replaceAllMapped(
                        RegExp(r'(^|\s)([a-z])'),
                        (Match match) =>
                            '${match.group(1)}${match.group(2)!.toUpperCase()}',
                      ),
                      path: "/extras/$e",
                    ),
                  ),
                  ExtraButton(
                    path: "/onboarding",
                    iconData: Icons.star,
                    name: "Onboarding",
                    color: Colors.green,
                  ),
                  ExtraButton(
                    path: "",
                    customCallback: () {
                      signOutFromGoogle();
                      context.push("/auth");
                    },
                    iconData: Icons.logout,
                    color: Colors.red,
                    name: "Logout",
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class ExtraButton extends StatelessWidget {
  String name;
  String path;
  IconData iconData;
  Color? color;
  VoidCallback? customCallback;
  ExtraButton({
    super.key,
    required this.name,
    required this.path,
    required this.iconData,
    this.color,
    this.customCallback,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: customCallback ?? () => context.push(path),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(40, 5, 40, 5),
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
                width: 0.8,
              ),
              gradient: LinearGradient(
                colors: [
                  color ?? Theme.of(context).colorScheme.onSecondaryContainer,
                  (color?.withAlpha(90) ?? Theme.of(context).colorScheme.onSecondaryContainer.withAlpha(90)),
                  Theme.of(context).colorScheme.surface,
                  Theme.of(context).colorScheme.onSecondaryContainer,
                ],
                transform: GradientRotation(3.54)
              ),
              borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(40, 15, 40, 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(iconData, size: 35),
                Text(
                  name,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w400, letterSpacing: 1.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
