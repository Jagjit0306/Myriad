import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:myriad/pages/community_thread.dart';

class CommunityPost extends StatelessWidget {
  final String postId;
  final dynamic data;
  const CommunityPost({super.key, required this.postId, required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (context) {
          return CommunityThread(title: data['title'], postId: postId);
        },
      )),
      child: Card(
        color: Theme.of(context).colorScheme.secondary,
        margin: EdgeInsets.all(10),
        elevation: 2.0,
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  data['title'],
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(data['content']),
                Text(data['likes'].toString()),
                Text(jsonEncode(data['likers'])),
                Text(data['op']),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
