import 'package:flutter/material.dart';

class DeafDumbPage extends StatelessWidget {
  const DeafDumbPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deaf and Dumb Page'),
      ),
      body: Center(
        child: const Text('Content for Deaf and Dumb Page'),
      ),
    );
  }
} 