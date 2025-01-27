import 'package:flutter/material.dart';

class DeafPage extends StatelessWidget {
  const DeafPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deaf Page'),
      ),
      body: Center(
        child: const Text('Content for Deaf Page'),
      ),
    );
  }
} 