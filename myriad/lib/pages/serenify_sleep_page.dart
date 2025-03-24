import 'package:flutter/material.dart';
import 'package:myriad/pages/serenify_breathe_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

class SerenifySleepPage extends StatefulWidget {
  const SerenifySleepPage({super.key});

  @override
  State<SerenifySleepPage> createState() => _SerenifySleepPageState();
}

class _SerenifySleepPageState extends State<SerenifySleepPage> {
  bool isSleeping = false;
  String elapsedTime = '00:00:00';
  Timer? timer;
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  
  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _checkSleepStatus();

    // Listen for audio completion to loop
    _audioPlayer.onPlayerComplete.listen((event) {
      if (isSleeping) {
        _restartAudio();
      }
    });
  }

  void _checkSleepStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final sleepStartTime = prefs.getString('sleep_start_time');
    
    if (sleepStartTime != null) {
      final startTime = DateTime.parse(sleepStartTime);
      setState(() {
        isSleeping = true;
        _startTimer(startTime);
      });
    }
  }

  void _startTimer(DateTime startTime) {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final difference = DateTime.now().difference(startTime);
      setState(() {
        elapsedTime = _formatDuration(difference);
      });
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  void _restartAudio() async {
    await _audioPlayer.stop();
    await _audioPlayer.setSource(AssetSource('chirping.mp3'));
    await _audioPlayer.setVolume(0.5); // Lower volume for sleep
    await _audioPlayer.resume();
  }

  void _toggleAudio() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      setState(() {
        _isPlaying = false;
      });
    } else {
      _restartAudio();
      setState(() {
        _isPlaying = true;
      });
    }
  }

  void startSleep() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    await prefs.setString('sleep_start_time', now.toIso8601String());
    
    _toggleAudio(); // Start playing audio
    
    setState(() {
      isSleeping = true;
      _startTimer(now);
    });
  }

  void stopSleep() async {
    final prefs = await SharedPreferences.getInstance();
    final sleepStartTime = prefs.getString('sleep_start_time');
    
    if (sleepStartTime != null) {
      final startTime = DateTime.parse(sleepStartTime);
      final duration = DateTime.now().difference(startTime);
      
      await prefs.remove('sleep_start_time');
      _toggleAudio(); // Stop playing audio
      
      setState(() {
        isSleeping = false;
        timer?.cancel();
      });

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Sleep Session Completed'),
            content: Text('You slept for ${_formatDuration(duration)}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    _audioPlayer.dispose(); // Clean up audio player
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.black,
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
                  mainAxisAlignment: isSleeping
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    if (isSleeping)
                      Column(
                        children: [
                          const Text(
                            "Sleep Duration",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            elapsedTime,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 40,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            Center(
              child: SerenifyRoundButton(
                onPressed: () {
                  if (isSleeping) {
                    stopSleep();
                  } else {
                    startSleep();
                  }
                },
                child: isSleeping
                    ? Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Stop Sleep',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "Press to stop",
                            style: TextStyle(color: Colors.grey.shade400),
                          ),
                        ],
                      )
                    : const Text(
                        'Start Sleep',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 