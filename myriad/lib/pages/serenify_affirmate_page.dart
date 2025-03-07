import 'package:flutter/material.dart';

class SerenifyAffirmatePage extends StatelessWidget {
  const SerenifyAffirmatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Affirmations'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Daily Affirmations',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text(
                'I am capable of achieving my goals.',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'I believe in myself and my abilities.',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'I am worthy of love and respect.',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              // Add more affirmations as needed
            ],
          ),
        ),
      ),
    );
  }
} 