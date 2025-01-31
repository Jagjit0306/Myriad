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
        child: Center(
          child: isMeditating
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      "You have been meditating for ${timeSinceInSeconds(secondsSince)}",
                      style: TextStyle(color: Colors.black, fontSize: 15),
                    ),
                    Text(
                      countdown > duration / 2 ? 'Breathe In' : 'Breathe Out',
                      style: TextStyle(fontSize: 24),
                    ),
                    Text(
                      '$countdown',
                      style: TextStyle(fontSize: 48),
                    ),
                    ElevatedButton(
                      onPressed: stopMeditation,
                      child: const Text(
                        'Stop Meditation',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Slider(
                      activeColor: Theme.of(context).colorScheme.secondary,
                      inactiveColor: Theme.of(context).colorScheme.primary,
                      thumbColor: Theme.of(context).colorScheme.inversePrimary,
                      value: duration.toDouble(),
                      min: 5,
                      max: 15,
                      divisions: 10,
                      // label: '$duration seconds',
                      onChanged: (value) {
                        setState(() {
                          duration = value.toInt();
                        });
                      },
                    ),
                    ElevatedButton(
                      onPressed: startMeditation,
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(24),
                      ),
                      child: const Text(
                        'Start Meditation',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
