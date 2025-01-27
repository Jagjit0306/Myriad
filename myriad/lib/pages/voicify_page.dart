import 'package:flutter/material.dart';

class VoicifyPage extends StatelessWidget {
  const VoicifyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voicify'),
      ),
      body: Center(
        child: const Text('Content for Voicify Page'),
      ),
    );
  }
} 