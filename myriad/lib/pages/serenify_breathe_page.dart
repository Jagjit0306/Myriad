import 'package:flutter/material.dart';
import 'dart:async';

import 'package:myriad/helper/helper_functions.dart';

class SerenifyBreathePage extends StatefulWidget {
  const SerenifyBreathePage({super.key});

  @override
  _SerenifyBreathePageState createState() => _SerenifyBreathePageState();
}

class _SerenifyBreathePageState extends State<SerenifyBreathePage> {
  bool isMeditating = false;
  int duration = 10; // Duration of each breathing cycle in seconds
  int countdown = 0;
  int secondsSince = 0;
  Timer? timer;

  void startMeditation() {
    setState(() {
      isMeditating = true;
      countdown = duration;
    });
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        secondsSince++;
        if (countdown > 0) {
          countdown--;
        } else {
          countdown = duration;
        }
      });
    });
  }

  void stopMeditation() {
    timer?.cancel();
    setState(() {
      isMeditating = false;
      countdown = 0;
      secondsSince = 0;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Relax - Serenify',
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
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 60, 0, 60),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: isMeditating
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    if (isMeditating)
                      Column(
                        children: [
                          Text(
                            "You have been meditating for",
                            style: TextStyle(color: Colors.black, fontSize: 15),
                          ),
                          Text(
                            timeSinceInSeconds(secondsSince),
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 25,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    if (!isMeditating)
                      Theme(
                        data: ThemeData.light(),
                        child: Slider(
                          activeColor: Colors.grey.shade500,
                          inactiveColor: Colors.grey.shade800,
                          thumbColor: Colors.white,
                          value: duration.toDouble(),
                          min: 5,
                          max: 15,
                          divisions: 10,
                          onChanged: (value) {
                            setState(() {
                              duration = value.toInt();
                            });
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Center(
              child: SerenifyRoundButton(
                onPressed: () {
                  if (isMeditating) {
                    stopMeditation();
                  } else {
                    startMeditation();
                  }
                },
                child: isMeditating
                    ? Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedSwitcher(
                            duration: Duration(seconds: 1),
                            child: Text(
                              countdown > duration / 2 ? 'Inhale' : 'Exhale',
                              key: ValueKey<int>(countdown),
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text("Press to stop",
                              style: TextStyle(color: Colors.grey.shade400)),
                        ],
                      )
                    : const Text(
                        'Start Meditation',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w400),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SerenifyRoundButton extends StatelessWidget {
  Widget child;
  VoidCallback onPressed;
  SerenifyRoundButton(
      {super.key, required this.child, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Feedback.forTap(context);
        onPressed();
      },
      child: Container(
        width: 250.0,
        height: 250.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: AssetImage('assets/Serenify_Round_Button.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: child,
        ),
      ),
    );
  }
}
