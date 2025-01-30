import 'package:flutter/material.dart';

class FeelifyPage extends StatelessWidget {
  const FeelifyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feelify'),
      ),
      body: const Center(
        child: Text('Feelify Page, recycle code from Hearify(future)'),
      ),
    );
  }
}