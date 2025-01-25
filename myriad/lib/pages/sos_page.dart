import 'package:flutter/material.dart';

class SosPage extends StatelessWidget {
  const SosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SOS Page"),
      ),
      body: Center(
        child: Text("This is the SOS Page"),
      ),
    );
  }
} 