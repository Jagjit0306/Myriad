import 'package:flutter/material.dart';

class CommunityNewPost extends StatelessWidget {
  const CommunityNewPost({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Thread'),
      ),
      body: const Text("this is where you author a new post"),
    );
  }
}
