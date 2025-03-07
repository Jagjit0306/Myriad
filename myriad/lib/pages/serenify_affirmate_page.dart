import 'dart:async';
import 'package:flutter/material.dart';

class SerenifyAffirmatePage extends StatefulWidget {
  const SerenifyAffirmatePage({super.key});

  @override
  State<SerenifyAffirmatePage> createState() => _SerenifyAffirmatePageState();
}

class _SerenifyAffirmatePageState extends State<SerenifyAffirmatePage> {
  final List<String> affirmations = [
    "I am enough just as I am.",
    "I believe in myself and my abilities.",
    "I choose to focus on the good in every situation.",
    "I am in control of my thoughts and emotions.",
    "I am capable of achieving my dreams.",
    "Every challenge I face helps me grow and improve.",
    "I release all tension and welcome peace into my life.",
    "I breathe in positivity and exhale all worries.",
    "I am grateful for all the good things in my life.",
    "Happiness is a choice, and I choose to be happy today."
  ];

  String currentAffirmation = '';
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _updateAffirmation();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _updateAffirmation();
    });
  }

  void _updateAffirmation() {
    setState(() {
      currentAffirmation = (affirmations..shuffle()).first; // Randomly select an affirmation
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/affirmate.png'), // Background image
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7, // Fixed width
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8), // Semi-transparent box
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(seconds: 1),
                  child: Text(
                    currentAffirmation,
                    key: ValueKey<String>(currentAffirmation),
                    style: const TextStyle(fontSize: 24, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 