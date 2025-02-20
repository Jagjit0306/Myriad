import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myriad/auth/google_auth.dart';
import 'package:myriad/helper/configurator.dart';

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

class Extras extends StatefulWidget {
  const Extras({super.key});

  @override
  State<Extras> createState() => _ExtrasState();
}

class _ExtrasState extends State<Extras> with SingleTickerProviderStateMixin {
  List<String> enabledFeatures = [];
  List<bool> visibleItems = [];
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800), // Smooth control
    );

    getConfiguration();
  }

  void getConfiguration() async {
    final List<String> gotConfig = await configurator();
    if (gotConfig.isNotEmpty) {
      setState(() {
        enabledFeatures = gotConfig;
        visibleItems = List.filled(gotConfig.length, false);
      });

      // Staggered reveal for each button
      for (int i = 0; i < gotConfig.length; i++) {
        Future.delayed(Duration(milliseconds: i * 120), () {
          if (mounted) {
            setState(() {
              visibleItems[i] = true;
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          body: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              reverse: true,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 350,
                  ),
                  if (enabledFeatures.isNotEmpty)
                    Column(
                      children: List.generate(enabledFeatures.length, (index) {
                        return SmoothButtonEntry(
                          isVisible: visibleItems[index],
                          delay: index * 100,
                          child: ExtraButton(
                            iconData:
                                iconMap[enabledFeatures[index]] ?? Icons.api,
                            name: enabledFeatures[index].replaceAllMapped(
                                RegExp(r'(^|\s)([a-z])'),
                                (match) =>
                                    '${match.group(1)}${match.group(2)!.toUpperCase()}'),
                            path: "/extras/${enabledFeatures[index]}",
                          ),
                        );
                      }),
                    ),
                  SmoothButtonEntry(
                    isVisible: true,
                    delay: 400,
                    child: ExtraButton(
                      path: "/onboarding",
                      iconData: Icons.star,
                      name: "Onboarding",
                      color: Colors.green,
                    ),
                  ),
                  SmoothButtonEntry(
                    isVisible: true,
                    delay: 500,
                    child: ExtraButton(
                      path: "",
                      customCallback: () {
                        signOutFromGoogle();
                        context.push("/auth");
                      },
                      iconData: Icons.logout,
                      color: Colors.red,
                      name: "Logout",
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          height: 250,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Colors.transparent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
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
              gradient: LinearGradient(colors: [
                color ?? Theme.of(context).colorScheme.onSecondaryContainer,
                (color?.withAlpha(90) ??
                    Theme.of(context)
                        .colorScheme
                        .onSecondaryContainer
                        .withAlpha(90)),
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.onSecondaryContainer,
              ], transform: GradientRotation(3.54)),
              borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(40, 15, 40, 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(iconData, size: 35),
                Text(
                  name,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SmoothEntryTransition extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;

  const SmoothEntryTransition(
      {super.key, required this.child, required this.animation});

  @override
  Widget build(BuildContext context) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutExpo,
    );

    return FadeTransition(
      opacity: curvedAnimation,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.85, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.elasticOut, // Springy effect
          ),
        ),
        child: SlideTransition(
          position:
              Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
                  .animate(CurvedAnimation(
                      parent: animation, curve: Curves.easeOutQuad)),
          child: child,
        ),
      ),
    );
  }
}

class SmoothButtonEntry extends StatefulWidget {
  final Widget child;
  final bool isVisible;
  final int delay;

  const SmoothButtonEntry({
    super.key,
    required this.child,
    required this.isVisible,
    required this.delay,
  });

  @override
  _SmoothButtonEntryState createState() => _SmoothButtonEntryState();
}

class _SmoothButtonEntryState extends State<SmoothButtonEntry>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<double> _scale;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart),
    );

    _scale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _slide =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    // Delayed start to create staggered effect
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.scale(
            scale: _scale.value,
            child: SlideTransition(
              position: _slide,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}
