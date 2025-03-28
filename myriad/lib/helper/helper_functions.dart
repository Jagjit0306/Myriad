import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

void displayMessageToUser(String message, BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(message),
    ),
  );
}

Future<void> prefsSaver(List<dynamic> prefs) async {
  SharedPreferences localPrefs = await SharedPreferences.getInstance();
  localPrefs.setString('prefs', jsonEncode(prefs));
}

String getSalutation() {
  final hour = DateTime.now().hour;

  if (hour >= 5 && hour < 12) {
    return "Good Morning";
  } else if (hour >= 12 && hour < 17) {
    return "Good Afternoon";
  } else if (hour >= 17 && hour < 21) {
    return "Good Evening";
  } else {
    return "Good Night";
  }
}

String timeSince(Timestamp timestamp) {
  final now = DateTime.now();
  final DateTime dateTime = timestamp.toDate(); // Convert Timestamp to DateTime
  final difference = now.difference(dateTime);

  final years = difference.inDays ~/ 365;
  if (years > 0) {
    return '${years}y';
  }

  final months = difference.inDays ~/ 30;
  if (months > 0) {
    return '${months}mon';
  }

  final days = difference.inDays;
  if (days > 0) {
    return '${days}d';
  }

  final hours = difference.inHours;
  if (hours > 0) {
    return '${hours}h';
  }

  final minutes = difference.inMinutes;
  if (minutes > 0) {
    return '${minutes}m';
  }

  final seconds = difference.inSeconds;
  return '${seconds}s';
}

String timeSinceInSeconds(int seconds) {
  final duration = Duration(seconds: seconds);

  final days = duration.inDays;
  final hours = duration.inHours.remainder(24);
  final minutes = duration.inMinutes.remainder(60);
  final secs = duration.inSeconds.remainder(60);

  final parts = <String>[];
  if (days > 0) parts.add(days.toString().padLeft(2, '0'));
  if (hours > 0 || parts.isNotEmpty) {
    parts.add(hours.toString().padLeft(2, '0'));
  }
  parts.add(minutes.toString().padLeft(2, '0'));
  parts.add(secs.toString().padLeft(2, '0'));

  return parts.join(':');
}

class FallDetectionService {
  static final FallDetectionService _instance =
      FallDetectionService._internal();
  factory FallDetectionService() => _instance;

  late final AudioPlayer _audioPlayer;
  Timer? _timer;

  bool _hasFallen = false;
  bool _isCountDown = true;
  bool _contactAuthorities = false;

  static const countdownDuration = Duration(seconds: 30);
  int _seconds = 30;
  Duration _duration = countdownDuration;

  // Getters
  bool get hasFallen => _hasFallen;
  bool get isCountDown => _isCountDown;
  bool get contactAuthorities => _contactAuthorities;
  int get seconds => _seconds;
  Duration get duration => _duration;

  FallDetectionService._internal() {
    _audioPlayer = AudioPlayer();
    _startListening();
  }

  void _startListening() {
    accelerometerEventStream().listen((AccelerometerEvent event) {
      double acceleration = _calculateAcceleration(event);

      // Threshold can be adjusted based on testing
      if (acceleration > 15.0 && !_hasFallen) {
        fallTrigger();
      }
    });
  }

  double _calculateAcceleration(AccelerometerEvent event) {
    // Calculate the magnitude of acceleration using the 3D vector
    return sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => decrement(),
    );
  }

  void decrement() {
    if (_isCountDown) {
      _seconds = _duration.inSeconds - 1;
      if (_seconds < 0) {
        confirmedFall();
      } else {
        _duration = Duration(seconds: _seconds);
      }
    }
  }

  void resetTimer() {
    _timer?.cancel();
    _duration = countdownDuration;
    _seconds = countdownDuration.inSeconds;
  }

  void resetApp() {
    _hasFallen = false;
    _isCountDown = true;
    _contactAuthorities = false;
    resetTimer();
    _audioPlayer.stop();
  }

  void fallTrigger() {
    _hasFallen = true;
    // makeNoise();
    startTimer();
  }

  void confirmedFall() {
    _contactAuthorities = true;
    _isCountDown = false;
    resetTimer();
  }

  Future<void> makeNoise(context) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setSource(AssetSource('scream.mp3'));
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.resume();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error playing audio: $e')),
        );
      }
    }
  }

  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
  }
}
