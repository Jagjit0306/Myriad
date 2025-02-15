import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:myriad/helper/helper_functions.dart';

class SerenifyBreathePage extends StatefulWidget {
  const SerenifyBreathePage({super.key});

  @override
  State<SerenifyBreathePage> createState() => _SerenifyBreathePageState();
}

class _SerenifyBreathePageState extends State<SerenifyBreathePage> {
  bool isMeditating = false;
  int duration = 10; // Duration of each breathing cycle in seconds
  int countdown = 0;
  int millisecondsSince = 0;
  Timer? timer;
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool isBreathing = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    // Listen for audio completion
    _audioPlayer.onPlayerComplete.listen((event) {
      if (isBreathing) {
        _restartAudio();
      }
    });
  }

  void _restartAudio() async {
    await _audioPlayer.stop(); 
    await _audioPlayer.setSource(AssetSource('chirping.mp3'));
    await _audioPlayer.setVolume(1.0);
    await _audioPlayer.resume();
  }

  void _toggleBreathing() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      setState(() {
        _isPlaying = false;
        isBreathing = false;
      });
    } else {
      _restartAudio();
      setState(() {
        _isPlaying = true;
        isBreathing = true;
      });
    }
  }

  void startMeditation() {
    setState(() {
      isMeditating = true;
      countdown = duration * 1000;
    });
    _toggleBreathing();
    timer = Timer.periodic(Duration(milliseconds: 20), (timer) {
      setState(() {
        millisecondsSince += 20;
        if (countdown > 0) {
          countdown -= 20;
        } else {
          countdown = duration * 1000;
        }
      });
    });
  }

  void stopMeditation() {
    _toggleBreathing();
    timer?.cancel();
    setState(() {
      isMeditating = false;
      countdown = 0;
      millisecondsSince = 0;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  double getOpac(double dur) {
    if (dur > 5000) {
      return ((dur - 5000) / 5000) * 1;
    } else {
      return 1 - (dur / 5000) * 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: const Text(
        //   'Relax - Serenify',
        //   style: TextStyle(color: Colors.black),
        // ),
        backgroundColor:
            Color.fromRGBO(255, 255, 255, getOpac(countdown.toDouble())),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.black,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(255, 255, 255, getOpac(countdown.toDouble())),
              Color.fromRGBO(0, 0, 0, 1)
            ],
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
                            "Meditating since",
                            style: TextStyle(color: Colors.grey.shade900, fontSize: 20),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            timeSinceInSeconds(millisecondsSince ~/ 1000),
                            style: TextStyle(
                              // color: Color.fromRGBO(0, 0, 0, getOpac(countdown.toDouble())),
                              color: Colors.black,
                              fontSize: 40,
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
                          Text(
                            countdown > (duration * 500) ? 'Inhale' : 'Exhale',
                            key: ValueKey<int>(countdown),
                            style: TextStyle(
                              // color: Colors.white,
                              color: Color.fromRGBO(255, 255, 255, getOpac(countdown.toDouble())),
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text("Press to stop",
                              style: TextStyle(color: Colors.grey.shade400)),
                        ],
                      )
                    : const Text(
                        'Start',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.w600),
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
  final Widget child;
  final VoidCallback onPressed;
  const SerenifyRoundButton(
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
        boxShadow: [
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.2),
          spreadRadius: 4,
          blurRadius: 7,
          offset: Offset(0, 3), // changes position of shadow
        ),
        ],
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
