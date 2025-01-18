import 'package:flutter/material.dart';

class CommunityThread extends StatelessWidget {
  final String title;
  final String postId;

  const CommunityThread({super.key, required this.title, required this.postId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Text("show content for postid $postId"),
    );
  }
}
