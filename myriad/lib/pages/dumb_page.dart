import 'package:flutter/material.dart';

class DumbPage extends StatelessWidget {
  const DumbPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dumb Page'),
      ),
      body: Center(
        child: const Text('Content for Dumb Page'),
      ),
    );
  }
} 